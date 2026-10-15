#!/usr/bin/env python3
"""
verify_lean_project.py — deterministic verification gate for Lean 4 lake projects.

`lake build` only tells you the elaborator did not reject the file. This script
answers the question that actually matters: is the thing proved?

Checks performed
----------------
  1. Project shape       lakefile.{toml,lean} + lean-toolchain present
  2. Source scan         sorry / admit / sorryAx / native_decide / local `axiom`
                         declarations, with Lean comments and string literals
                         stripped so comments do not produce false positives
  3. Build               `lake build [target]`, exit code + stderr captured
  4. Build-output scan   "declaration uses 'sorry'" warnings (authoritative —
                         catches sorries the source scan cannot see, e.g. ones
                         produced by macros or tactics)
  5. Axiom audit         generates a temporary Lean file that `#print axioms`
                         every discovered top-level theorem, runs it under
                         `lake env lean`, and compares against the allowlist

Exit codes
----------
  0  green under the agreed policy
  1  policy violation (sorry, axiom, build failure, ...)
  2  could not run the check at all (bad project, missing lake)

Anything the script could not check is reported as UNKNOWN, never as PASS.
Silent degradation is the failure mode this file exists to prevent.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

DEFAULT_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}

# Directories that contain build artifacts or vendored dependencies, not our sources.
# Campaign-local: also skip third-party mirrors and non-Lean trees so forge
# audits the FragileProofAudit library, not incoming/*/comparator sorry holes.
SKIP_DIRS = {
    ".lake", "lake-packages", "build", ".git", ".github", "_target", "results",
    "incoming", "corpus", "docs", "scripts",
    # Scratch trees other workflows create at the root of the shared
    # self-hosted workspace (oai-family-forge / oai-headline-forge): they
    # hold vendored foreign Lean projects, not this project's sources.
    # family-forge/ in particular is DELIBERATELY left behind after a
    # family-forge run (its .lake feeds the actions cache) and is cleared
    # only at the start of the next family-forge run; headline-forge's
    # end-of-run step heals git state but never removes its scratch dirs.
    # Walking into them maps their files to hyphenated module names
    # (family-forge.OAI.…), which trips the axiom audit's
    # illegal-identifier guard and turns verify red on unrelated commits
    # (verify run 38744148349, main@af56586 — AGENTS.md lesson (20)).
    # Registration rule: any new workflow scratch dir that can persist
    # in the shared workspace is added here in the same commit that
    # introduces it.
    "family-forge", "oai-math", "forge-stage",
    "headline-forge", "headline-stage",
    # Agent worktrees under .claude/worktrees/ are full copies of the Lean
    # sources. Walking into one yields module names like
    # ".claude.worktrees.<id>.FragileProofAudit", whose `import` line is a
    # syntax error -- which aborts the whole generated axiom-audit file and
    # reports every declaration as unresolved. Found 2026-09-21: a stale
    # worktree had been silently turning the local axiom audit into
    # CAPABILITY_LIMITED, while CI stayed green because a fresh checkout has
    # no .claude/ at all.
    ".claude", ".vscode", ".idea", "node_modules", ".venv", "venv",
}

FORBIDDEN_TOKENS = {
    "sorry": r"\bsorry\b",
    "sorryAx": r"\bsorryAx\b",
    "admit": r"\badmit\b",
    "native_decide": r"\bnative_decide\b",
}

# `axiom Foo : ...` / `noncomputable axiom` etc. at declaration position.
AXIOM_DECL_RE = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)*(?:private\s+|protected\s+|noncomputable\s+)*axiom\s+([A-Za-z_][^\s:]*)")

# Top-level theorem-like declarations we want to audit for axioms. The
# modifier chain is captured: a `private` declaration's environment name is
# mangled by Lean (it is NOT stored under its source-level qualified name),
# so it can never be resolved by a #print from another file — the audit
# must know which declarations are private and leave them out of the print
# list (see check_axioms).
DECL_RE = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)*"
    r"((?:private\s+|protected\s+|noncomputable\s+|partial\s+|unsafe\s+)*)"
    r"(theorem|lemma)\s+"
    r"([A-Za-z_\u03b1-\u03c9][^\s:({\[⦃]*)"
)

NAMESPACE_RE = re.compile(r"^\s*namespace\s+([A-Za-z_][\w.']*)")
SECTION_RE = re.compile(r"^\s*(?:noncomputable\s+)?section(?:\s+([A-Za-z_][\w.']*))?\s*$")
END_RE = re.compile(r"^\s*end\s*([A-Za-z_][\w.']*)?\s*$")

# A declaration modifier on its own line, e.g. `private` alone on the line
# before the theorem it modifies (euler-blowup TimeRates.lean:76043). The
# parser carries such dangling modifiers forward to the next declaration.
_MOD_WORDS = r"(?:private|protected|noncomputable|partial|unsafe)"
MODS_ONLY_RE = re.compile(rf"^\s*({_MOD_WORDS}(?:\s+{_MOD_WORDS})*)\s*$")
ATTR_ONLY_RE = re.compile(r"^\s*@\[[^\]]*\]\s*$")

# Lean quotes declaration names with single quotes, and Lean names may
# themselves contain quotes (the fluid_lean `foo'` convention for variant
# lemmas prints as `'Mod.foo'' depends on axioms: [...]`). The name group
# must be greedy: `[^']+` stops at the first inner quote and then can never
# match the rest of the line, so every quoted name silently became
# "unresolved" (euler run #15: 88 `...'` names printed fine but were never
# parsed — audited 28033/28106 with zero violations).
AXIOM_OUT_RE = re.compile(r"'(?P<name>.+)' (?:does not depend on any axioms|depends on axioms: \[(?P<axioms>[^\]]*)\])")

# Auxiliary axioms generated by `native_decide` (Lean 4.32 names them
# `<decl>._native.native_decide.ax_<i>_<j>`). Exempted as a group when the
# --allow-native-decide policy is active, so the flag coherently covers both
# the source scan and the axiom audit.
NATIVE_DECIDE_AX_RE = re.compile(r"\._native\.native_decide\.")


# --------------------------------------------------------------------------- #
# Lean source lexing
# --------------------------------------------------------------------------- #

def strip_lean_comments(text: str) -> str:
    """
    Replace Lean comments and string literals with spaces, preserving newlines
    and total length so line numbers stay meaningful.

    Lean block comments /- -/ nest, and doc comments /-- -/ are block comments.
    A naive regex gets this wrong, which is how `-- we removed the sorry here`
    ends up failing a build gate.
    """
    out = list(text)
    i, n = 0, len(text)
    depth = 0          # block-comment nesting depth
    in_line = False
    in_str = False
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""

        if in_line:
            if c == "\n":
                in_line = False
            else:
                out[i] = " "
            i += 1
            continue

        if depth > 0:
            if c == "/" and nxt == "-":
                depth += 1
                out[i] = out[i + 1] = " "
                i += 2
                continue
            if c == "-" and nxt == "/":
                depth -= 1
                out[i] = out[i + 1] = " "
                i += 2
                continue
            if c != "\n":
                out[i] = " "
            i += 1
            continue

        if in_str:
            if c == "\\":
                if i + 1 < n and text[i + 1] != "\n":
                    out[i] = out[i + 1] = " "
                    i += 2
                    continue
            if c == '"':
                in_str = False
                out[i] = " "
                i += 1
                continue
            if c != "\n":
                out[i] = " "
            i += 1
            continue

        # not in any special state
        if c == "-" and nxt == "-":
            in_line = True
            out[i] = out[i + 1] = " "
            i += 2
            continue
        if c == "/" and nxt == "-":
            depth = 1
            out[i] = out[i + 1] = " "
            i += 2
            continue
        if c == '"':
            in_str = True
            out[i] = " "
            i += 1
            continue
        i += 1

    return "".join(out)


def qualified_declarations(clean_text: str) -> list[tuple[str, int, bool]]:
    """
    Return (fully_qualified_name, line_number, is_private) for theorem/lemma
    declarations, tracking `namespace` / `end` so names resolve when printed.

    Sections and anonymous `end`s are handled by only popping the stack when the
    `end` matches the innermost namespace name, which is what Lean requires.
    """
    results: list[tuple[str, int, bool]] = []
    # stack entries are (kind, name) where kind is "namespace" or "section";
    # only namespace entries contribute to the qualified name, but sections must
    # be tracked so that an anonymous `end` closes the section rather than
    # silently popping the enclosing namespace.
    stack: list[tuple[str, str | None]] = []
    # Modifiers dangling on their own line(s) (e.g. `private` alone on the
    # line before the theorem it modifies), carried forward to the next
    # declaration found. Any other real line — a `def`, a `variable`, a
    # command, a namespace/section/end — ends the dangle: in Lean a modifier
    # can only modify the declaration immediately following it, so letting
    # it leak would mis-attribute privateness to an unrelated later theorem.
    # Blank lines and attribute-only lines do not end the dangle.
    pending_mods: list[str] = []

    def qualify(base: str) -> str:
        parts = [n for k, n in stack if k == "namespace" and n]
        return ".".join(parts + [base]) if parts else base

    def clear_pending() -> None:
        del pending_mods[:]

    for lineno, line in enumerate(clean_text.splitlines(), start=1):
        m = MODS_ONLY_RE.match(line)
        if m:
            pending_mods.extend(m.group(1).split())
            continue
        m = NAMESPACE_RE.match(line)
        if m:
            stack.append(("namespace", m.group(1)))
            clear_pending()
            continue
        m = SECTION_RE.match(line)
        if m:
            stack.append(("section", m.group(1)))
            clear_pending()
            continue
        m = END_RE.match(line)
        if m:
            name = m.group(1)
            if not stack:
                continue
            if name is None:
                if stack[-1][0] == "section":
                    stack.pop()
            else:
                for i in range(len(stack) - 1, -1, -1):
                    sname = stack[i][1]
                    if sname and (sname == name or sname.endswith("." + name)):
                        del stack[i:]
                        break
            clear_pending()
            continue
        m = DECL_RE.match(line)
        if m:
            base = m.group(3).strip()
            if not base or base.startswith("_"):
                clear_pending()
                continue
            is_private = "private" in m.group(1).split() or "private" in pending_mods
            clear_pending()
            results.append((qualify(base), lineno, is_private))
            continue
        if line.strip() and not ATTR_ONLY_RE.match(line):
            clear_pending()
    return results


def load_lib_src_dirs(root: Path) -> list[Path]:
    """
    Source directories of the project's `lean_lib`s, longest path first.

    Lake maps a file's module name relative to its library's `srcDir`
    (default: the project root), NOT relative to the project root. A
    vendored library declared as

        [[lean_lib]]
        name = "Cm24"
        srcDir = "vendor/cm24-r2"

    therefore builds `vendor/cm24-r2/Cm24/Basic.lean` as module
    `Cm24.Basic` — the hyphenated directory never becomes an identifier.
    Deriving module names from the project root instead produces
    `vendor.cm24-r2.Cm24.Basic`, trips the illegal-identifier guard in
    check_axioms, and aborts the whole axiom audit (fluid_lean
    euler-blowup, forge run 2026-10-13: 32 such paths, audit UNKNOWN).

    Only `lakefile.toml` is parsed; `lakefile.lean` projects keep the
    historical root-relative mapping. A malformed manifest, a non-string
    srcDir, or a srcDir that is absolute or escapes the project root is
    ignored — the fallback is the root mapping, and the illegal-name
    guard in check_axioms stays fail-closed on anything that still does
    not resolve to a legal identifier.
    """
    dirs: set[Path] = {Path(".")}
    toml_path = root / "lakefile.toml"
    if toml_path.is_file():
        try:
            import tomllib

            data = tomllib.loads(toml_path.read_text(encoding="utf-8"))
            libs = data.get("lean_lib", [])
            if isinstance(libs, dict):  # a single table, not an array
                libs = [libs]
            for lib in libs:
                if not isinstance(lib, dict):
                    continue
                sd = lib.get("srcDir")
                if isinstance(sd, str) and sd.strip():
                    p = Path(sd.strip())
                    if not p.is_absolute() and ".." not in p.parts:
                        dirs.add(p)
        except Exception:
            pass  # fall back to the root-only mapping; never crash the audit
    # Longest (most specific) srcDir wins when directories nest.
    return sorted(dirs, key=lambda p: len(p.parts), reverse=True)


def module_name_for(path: Path, root: Path,
                    src_dirs: list[Path] | None = None) -> str:
    rel = path.relative_to(root)
    for sd in src_dirs or ():
        if sd == Path("."):
            continue
        try:
            inner = rel.relative_to(sd)
        except ValueError:
            continue
        return ".".join(inner.with_suffix("").parts)
    return ".".join(rel.with_suffix("").parts)


# --------------------------------------------------------------------------- #
# Result model
# --------------------------------------------------------------------------- #

@dataclass
class Finding:
    check: str
    status: str            # PASS | FAIL | UNKNOWN | SKIPPED
    detail: str = ""
    hits: list = field(default_factory=list)


@dataclass
class Report:
    project: str
    target: str | None
    timestamp: str
    verdict: str = "UNKNOWN"
    findings: list = field(default_factory=list)
    files_scanned: int = 0
    declarations_found: int = 0
    allowlist: list = field(default_factory=list)
    toolchain: str | None = None
    build_exit_code: int | None = None


# --------------------------------------------------------------------------- #
# Checks
# --------------------------------------------------------------------------- #

def find_sources(root: Path) -> list[Path]:
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if fn.endswith(".lean"):
                files.append(Path(dirpath) / fn)
    return sorted(files)


def check_project_shape(root: Path) -> tuple[Finding, str | None]:
    lakefiles = [p for p in ("lakefile.toml", "lakefile.lean") if (root / p).exists()]
    toolchain_file = root / "lean-toolchain"
    toolchain = toolchain_file.read_text().strip() if toolchain_file.exists() else None

    missing = []
    if not lakefiles:
        missing.append("lakefile.toml or lakefile.lean")
    if toolchain is None:
        missing.append("lean-toolchain")

    if missing:
        return Finding(
            "project_shape", "FAIL",
            f"Not a lake project root — missing: {', '.join(missing)}",
        ), toolchain
    return Finding(
        "project_shape", "PASS",
        f"{lakefiles[0]}, toolchain {toolchain}",
    ), toolchain


def check_source_tokens(root: Path, files: list[Path], allow_native_decide: bool) -> list[Finding]:
    token_hits: dict[str, list] = {k: [] for k in FORBIDDEN_TOKENS}
    axiom_hits: list = []

    for f in files:
        try:
            raw = f.read_text(encoding="utf-8", errors="replace")
        except OSError as e:
            token_hits.setdefault("_unreadable", []).append({"file": str(f), "error": str(e)})
            continue
        clean = strip_lean_comments(raw)
        lines = clean.splitlines()
        raw_lines = raw.splitlines()

        for name, pattern in FORBIDDEN_TOKENS.items():
            rx = re.compile(pattern)
            for i, line in enumerate(lines):
                if rx.search(line):
                    token_hits[name].append({
                        "file": str(f.relative_to(root)),
                        "line": i + 1,
                        "text": raw_lines[i].strip()[:200] if i < len(raw_lines) else "",
                    })

        for i, line in enumerate(lines):
            m = AXIOM_DECL_RE.match(line)
            if m:
                axiom_hits.append({
                    "file": str(f.relative_to(root)),
                    "line": i + 1,
                    "name": m.group(1),
                    "text": raw_lines[i].strip()[:200] if i < len(raw_lines) else "",
                })

    findings = []

    holes = token_hits["sorry"] + token_hits["sorryAx"] + token_hits["admit"]
    findings.append(Finding(
        "no_sorry_admit",
        "FAIL" if holes else "PASS",
        f"{len(holes)} proof hole(s) in sources" if holes else "no sorry/admit/sorryAx in sources",
        holes,
    ))

    nd = token_hits["native_decide"]
    if allow_native_decide:
        findings.append(Finding(
            "native_decide", "SKIPPED",
            f"{len(nd)} use(s) present; check disabled by --allow-native-decide", nd,
        ))
    else:
        findings.append(Finding(
            "native_decide",
            "FAIL" if nd else "PASS",
            f"{len(nd)} native_decide use(s) — these trust the compiler, not the kernel"
            if nd else "no native_decide",
            nd,
        ))

    findings.append(Finding(
        "local_axiom_declarations",
        "FAIL" if axiom_hits else "PASS",
        f"{len(axiom_hits)} locally declared axiom(s)" if axiom_hits
        else "no locally declared axioms",
        axiom_hits,
    ))

    if "_unreadable" in token_hits:
        findings.append(Finding(
            "source_readability", "UNKNOWN",
            "some files could not be read", token_hits["_unreadable"],
        ))

    return findings


def run(cmd: list[str], cwd: Path, timeout: int) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            cmd, cwd=str(cwd), capture_output=True, text=True,
            timeout=timeout, errors="replace",
        )
        return proc.returncode, (proc.stdout or "") + (proc.stderr or "")
    except FileNotFoundError:
        return 127, f"command not found: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return 124, f"timed out after {timeout}s: {' '.join(cmd)}"


def check_build(root: Path, target: str | None, timeout: int) -> tuple[list[Finding], str, int | None]:
    if shutil.which("lake") is None:
        return [Finding(
            "lake_build", "UNKNOWN",
            "lake not on PATH — cannot build. Install elan. Status is "
            "capability-limited, NOT verified.",
        )], "", None

    cmd = ["lake", "build"] + ([target] if target else [])
    code, output = run(cmd, root, timeout)

    findings = [Finding(
        "lake_build",
        "PASS" if code == 0 else "FAIL",
        f"`{' '.join(cmd)}` exited {code}",
    )]

    # The build log is authoritative about sorries: it sees through macros and
    # tactic-generated terms that a source grep cannot.
    warn_lines = [
        ln.strip() for ln in output.splitlines()
        if "declaration uses 'sorry'" in ln or "uses sorry" in ln
    ]
    findings.append(Finding(
        "build_sorry_warnings",
        "FAIL" if warn_lines else "PASS",
        f"{len(warn_lines)} sorry warning(s) in build output" if warn_lines
        else "no sorry warnings in build output",
        warn_lines[:200],
    ))
    return findings, output, code


def check_axioms(root: Path, files: list[Path], allowlist: set[str],
                 timeout: int, allow_native_decide: bool = False,
                 exclude_modules: tuple[str, ...] = ()) -> tuple[Finding, int]:
    """
    Generate a scratch Lean file that imports every module and prints the axiom
    dependencies of each discovered theorem, then run it via `lake env lean`.

    Modules named in exclude_modules are left out of the generated file's
    imports AND their declarations are left out of the #print list, and the
    exclusion is recorded in the report. They remain covered by the source
    scans. This is for trusted statement modules that cannot share an
    elaboration environment with the library (e.g. fluid_lean's Challenge,
    which re-declares EulerBlowup-namespace structures also declared by the
    EulerBlowup library — importing both aborts the whole file with
    "environment already contains ...", zeroing the audit).

    `private` declarations are left out of the #print list and recorded
    separately. Lean stores a private constant under a mangled internal
    name, so its source-level qualified name is an unknown constant from
    any other file — printing it can only error. This loses no coverage
    of the project's public claims: #print axioms reports the TRANSITIVE
    axiom set, so a private lemma's axioms surface through every public
    declaration that depends on it (verified synthetically: a public
    theorem proved via a sorry-backed private lemma reports sorryAx).
    A private declaration nothing public depends on cannot contaminate
    any audited result. (euler-blowup run #14, 2026-10-13: 1,135 private
    Cm24 declarations each errored "Unknown constant"; at error #100 lean
    aborted the audit file, leaving 28,256 of 29,241 declarations —
    nearly all public — never attempted.)
    """
    decls: list[str] = []
    private_decls: list[str] = []
    modules: list[str] = []
    src_dirs = load_lib_src_dirs(root)
    excluded: set[str] = set(exclude_modules)
    matched_exclusions: set[str] = set()
    excluded_decls = 0
    for f in files:
        try:
            clean = strip_lean_comments(f.read_text(encoding="utf-8", errors="replace"))
        except OSError:
            continue
        found = qualified_declarations(clean)
        if found:
            mod = module_name_for(f, root, src_dirs)
            if mod in excluded:
                matched_exclusions.add(mod)
                excluded_decls += len(found)
                continue
            modules.append(mod)
            for name, _, is_private in found:
                (private_decls if is_private else decls).append(name)

    decls = sorted(set(decls))
    private_decls = sorted(set(private_decls) - set(decls))
    total_decls = len(decls) + len(private_decls)
    private_note = (
        f"; {len(private_decls)} private declaration(s) not printed "
        f"(Lean-mangled names; covered transitively via dependents)"
        if private_decls else ""
    )
    exclusion_note = ""
    if excluded:
        exclusion_note = (
            f"; excluded {len(matched_exclusions)} module(s) "
            f"({excluded_decls} declarations) via --exclude-module"
        )
        unmatched = sorted(excluded - matched_exclusions)
        if unmatched:
            exclusion_note += f"; unmatched exclusions (no such module): {unmatched}"
    if not decls:
        return Finding("axiom_audit", "UNKNOWN",
                       "no non-private theorem/lemma declarations discovered "
                       "to audit" + exclusion_note + private_note), total_decls

    if shutil.which("lake") is None:
        return Finding(
            "axiom_audit", "UNKNOWN",
            f"{len(decls)} declaration(s) found but lake is unavailable — axioms "
            "NOT checked. Status is capability-limited, not verified.",
        ), total_decls

    # A module name that is not a legal Lean identifier path produces a
    # syntax error on line 1 and silently zeroes the entire audit. Name the
    # cause instead of reporting 150 mysteriously "unresolved" declarations.
    bad_modules = sorted(
        m for m in set(modules)
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_']*(\.[A-Za-z_][A-Za-z0-9_']*)*", m)
    )
    if bad_modules:
        return Finding(
            "axiom_audit", "UNKNOWN",
            f"{len(bad_modules)} module path(s) are not legal Lean identifiers, "
            f"so the generated audit file would not parse and NOTHING would be "
            f"checked: {bad_modules[:3]}. This usually means find_sources walked "
            f"into a directory that should be in SKIP_DIRS (a worktree, a stray "
            f"copy), or a library whose srcDir the module mapping does not "
            f"cover. Axioms NOT checked.",
        ), total_decls

    lines = [f"import {m}" for m in sorted(set(modules))]
    lines += [f"#print axioms {d}" for d in decls]
    scratch = root / "_lpf_axiom_audit.lean"
    try:
        scratch.write_text("\n".join(lines) + "\n", encoding="utf-8")
        # The frontend's error cap must never abort the audit early: one
        # unresolvable name has to degrade to "that name unresolved", not
        # zero out every later declaration. The cap is read from the
        # STARTUP options — an in-file `set_option maxErrors` does NOT
        # lift it (verified on lean v4.32.2: in-file values 0 and 1000000
        # both still aborted at 100) — so it is passed via -D.
        code, output = run(
            ["lake", "env", "lean", "-D", "maxErrors=1000000", scratch.name],
            root, timeout)
    finally:
        scratch.unlink(missing_ok=True)

    # The lean run's raw output is the only evidence when the audit cannot
    # complete. Keep a truncated head/tail with the finding so a future
    # UNKNOWN is diagnosable from the report alone — an audit that reports
    # "0/N resolved" without saying what lean did is a dead end
    # (euler-blowup run #12, 2026-10-13: 0/29241 resolved, no output kept).
    out_lines = output.splitlines()
    lean_evidence = {
        "lean_exit_code": code,
        "lean_output_lines": len(out_lines),
        "lean_output_head": out_lines[:20],
        "lean_output_tail": out_lines[-20:] if len(out_lines) > 20 else [],
    }

    used: dict[str, list[str]] = {}
    for m in AXIOM_OUT_RE.finditer(output):
        name = m.group("name")
        ax = m.group("axioms")
        used[name] = [a.strip() for a in ax.split(",")] if ax else []

    unresolved = [d for d in decls if d not in used]
    violations = {
        name: sorted(set(axs) - allowlist)
        for name, axs in used.items()
        if set(axs) - allowlist
    }

    nd_exempted = 0
    if allow_native_decide:
        # The permit-native_decide policy covers the compiled-evaluation
        # axioms as well; any other axiom outside the allowlist still fails.
        kept: dict[str, list[str]] = {}
        for name, axs in violations.items():
            rest = [a for a in axs if not NATIVE_DECIDE_AX_RE.search(a)]
            nd_exempted += len(axs) - len(rest)
            if rest:
                kept[name] = rest
        violations = kept

    hits = {
        "violations": violations,
        "unresolved": unresolved[:100],
        "audited": len(used),
        "expected": len(decls),
        "native_decide_exempted": nd_exempted,
        "excluded_modules": sorted(matched_exclusions),
        "excluded_declarations": excluded_decls,
        "private_declarations": len(private_decls),
    }
    # On any non-PASS outcome the lean run's own output is load-bearing
    # evidence; attach it so the report stands alone.
    if not violations and unresolved:
        hits["lean"] = lean_evidence

    if violations:
        return Finding(
            "axiom_audit", "FAIL",
            f"{len(violations)} declaration(s) depend on axioms outside the allowlist",
            [hits],
        ), total_decls
    if unresolved:
        return Finding(
            "axiom_audit", "UNKNOWN",
            f"audited {len(used)}/{len(decls)}; {len(unresolved)} name(s) did not "
            "resolve (namespace/section parsing or elaboration failure) — treat "
            "those as unchecked, not as clean",
            [hits],
        ), total_decls
    detail = f"all {len(used)} declaration(s) within allowlist"
    if allow_native_decide and nd_exempted:
        detail += f" ({nd_exempted} native_decide axiom(s) exempted by --allow-native-decide)"
    detail += exclusion_note
    detail += private_note
    return Finding(
        "axiom_audit", "PASS",
        detail,
        [hits],
    ), total_decls


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #

def verdict_from(findings: list[Finding]) -> str:
    statuses = {f.status for f in findings}
    if "FAIL" in statuses:
        return "FAILED"
    if "UNKNOWN" in statuses:
        return "CAPABILITY_LIMITED"
    return "VERIFIED"


def render_text(report: Report) -> str:
    width = 74
    out = [
        "=" * width,
        "  lean-proof-forge :: verification report",
        "=" * width,
        f"  project     : {report.project}",
        f"  target      : {report.target or '(all)'}",
        f"  toolchain   : {report.toolchain or '(unknown)'}",
        f"  timestamp   : {report.timestamp}",
        f"  files       : {report.files_scanned}",
        f"  declarations: {report.declarations_found}",
        f"  allowlist   : {', '.join(report.allowlist)}",
        "-" * width,
    ]
    mark = {"PASS": "[ PASS ]", "FAIL": "[ FAIL ]",
            "UNKNOWN": "[  ??  ]", "SKIPPED": "[ skip ]"}
    for f in report.findings:
        out.append(f"  {mark.get(f.status, '[  ??  ]')} {f.check}: {f.detail}")
        for h in f.hits[:12]:
            if isinstance(h, dict) and "file" in h:
                out.append(f"           {h['file']}:{h.get('line','?')}  {h.get('text','')}")
            elif isinstance(h, dict) and "violations" in h:
                for name, axs in list(h["violations"].items())[:12]:
                    out.append(f"           {name} -> {', '.join(axs)}")
                for name in h.get("unresolved", [])[:12]:
                    out.append(f"           unresolved: {name}")
            else:
                out.append(f"           {str(h)[:150]}")
        if len(f.hits) > 12:
            out.append(f"           ... and {len(f.hits) - 12} more (see JSON)")
    out += [
        "-" * width,
        f"  VERDICT: {report.verdict}",
        "=" * width,
    ]
    if report.verdict == "CAPABILITY_LIMITED":
        out.append("  Some checks could not run. This is NOT a proof of anything.")
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Deterministic verification gate for Lean 4 lake projects.")
    ap.add_argument("--project", required=True, help="path to the lake project root")
    ap.add_argument("--target", default=None, help="optional lake build target")
    ap.add_argument("--results-dir", default=None,
                    help="where to write reports (default: <project>/results)")
    ap.add_argument("--extra-axiom", action="append", default=[],
                    help="additional permitted axiom (repeatable)")
    ap.add_argument("--allow-native-decide", action="store_true",
                    help="permit native_decide (records the weakened policy in the report; "
                         "covers the source scan and the axiom audit)")
    ap.add_argument("--skip-build", action="store_true",
                    help="source scans only — produces a SCAN, never a proof")
    ap.add_argument("--skip-axioms", action="store_true", help="skip the axiom audit")
    ap.add_argument("--exclude-module", action="append", default=[],
                    help="module to leave out of the axiom audit's imports and "
                         "#print list (repeatable). The module stays covered by "
                         "the source scans; the exclusion is recorded in the "
                         "report. For trusted statement modules that cannot "
                         "share an elaboration environment with the library.")
    ap.add_argument("--timeout", type=int, default=3600, help="per-command timeout, seconds")
    ap.add_argument("--json", action="store_true", help="print the JSON report to stdout")
    args = ap.parse_args()

    root = Path(args.project).expanduser().resolve()
    if not root.is_dir():
        print(f"error: not a directory: {root}", file=sys.stderr)
        return 2

    allowlist = DEFAULT_AXIOMS | set(args.extra_axiom)
    report = Report(
        project=str(root),
        target=args.target,
        timestamp=datetime.now(timezone.utc).isoformat(timespec="seconds"),
        allowlist=sorted(allowlist),
    )

    shape, toolchain = check_project_shape(root)
    report.toolchain = toolchain
    report.findings.append(shape)
    if shape.status == "FAIL":
        report.verdict = "FAILED"
        emit(report, args, root)
        return 2

    files = find_sources(root)
    report.files_scanned = len(files)
    report.findings.extend(check_source_tokens(root, files, args.allow_native_decide))

    if args.skip_build:
        report.findings.append(Finding(
            "lake_build", "UNKNOWN",
            "--skip-build requested: nothing was compiled. Source scan only."))
        build_out = ""
    else:
        build_findings, build_out, code = check_build(root, args.target, args.timeout)
        report.findings.extend(build_findings)
        report.build_exit_code = code

    if args.skip_axioms:
        report.findings.append(Finding("axiom_audit", "SKIPPED", "--skip-axioms requested"))
    elif args.skip_build:
        report.findings.append(Finding(
            "axiom_audit", "UNKNOWN",
            "axiom audit needs a built project; skipped because --skip-build"))
    else:
        axf, ndecls = check_axioms(root, files, allowlist, args.timeout,
                                   args.allow_native_decide,
                                   tuple(args.exclude_module))
        report.declarations_found = ndecls
        report.findings.append(axf)

    report.verdict = verdict_from(report.findings)
    emit(report, args, root, build_out)
    return 0 if report.verdict == "VERIFIED" else 1


def emit(report: Report, args, root: Path, build_out: str = "") -> None:
    results_dir = Path(args.results_dir).expanduser().resolve() if args.results_dir \
        else root / "results"
    text = render_text(report)
    try:
        results_dir.mkdir(parents=True, exist_ok=True)
        payload = asdict(report)
        (results_dir / "lean_verify_meta.json").write_text(
            json.dumps(payload, indent=2), encoding="utf-8")
        (results_dir / "lean_verify_out.txt").write_text(
            text + ("\n\n--- build output ---\n" + build_out if build_out else ""),
            encoding="utf-8")
        text += f"\n  evidence: {results_dir}/lean_verify_meta.json"
    except OSError as e:
        text += f"\n  WARNING: could not write results to {results_dir}: {e}"

    if args.json:
        print(json.dumps(asdict(report), indent=2))
    else:
        print(text)


if __name__ == "__main__":
    sys.exit(main())
