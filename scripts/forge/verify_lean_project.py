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

DEFAULT_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}

# Directories that contain build artifacts or vendored dependencies, not our sources.
# Campaign-local: also skip third-party mirrors and non-Lean trees so forge
# audits the FragileProofAudit library, not incoming/*/comparator sorry holes.
SKIP_DIRS = {
    ".lake", "lake-packages", "build", ".git", ".github", "_target", "results",
    "incoming", "corpus", "docs", "scripts",
}

FORBIDDEN_TOKENS = {
    "sorry": r"\bsorry\b",
    "sorryAx": r"\bsorryAx\b",
    "admit": r"\badmit\b",
    "native_decide": r"\bnative_decide\b",
}

# `axiom Foo : ...` / `noncomputable axiom` etc. at declaration position.
AXIOM_DECL_RE = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)*(?:private\s+|protected\s+|noncomputable\s+)*axiom\s+([A-Za-z_][^\s:]*)")

# Top-level theorem-like declarations we want to audit for axioms.
DECL_RE = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|partial\s+|unsafe\s+)*"
    r"(theorem|lemma)\s+"
    r"([A-Za-z_\u03b1-\u03c9][^\s:({\[⦃]*)"
)

NAMESPACE_RE = re.compile(r"^\s*namespace\s+([A-Za-z_][\w.']*)")
SECTION_RE = re.compile(r"^\s*(?:noncomputable\s+)?section(?:\s+([A-Za-z_][\w.']*))?\s*$")
END_RE = re.compile(r"^\s*end\s*([A-Za-z_][\w.']*)?\s*$")

AXIOM_OUT_RE = re.compile(r"'(?P<name>[^']+)' (?:does not depend on any axioms|depends on axioms: \[(?P<axioms>[^\]]*)\])")


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


def qualified_declarations(clean_text: str) -> list[tuple[str, int]]:
    """
    Return (fully_qualified_name, line_number) for theorem/lemma declarations,
    tracking `namespace` / `end` so names resolve when printed.

    Sections and anonymous `end`s are handled by only popping the stack when the
    `end` matches the innermost namespace name, which is what Lean requires.
    """
    results: list[tuple[str, int]] = []
    # stack entries are (kind, name) where kind is "namespace" or "section";
    # only namespace entries contribute to the qualified name, but sections must
    # be tracked so that an anonymous `end` closes the section rather than
    # silently popping the enclosing namespace.
    stack: list[tuple[str, str | None]] = []

    def qualify(base: str) -> str:
        parts = [n for k, n in stack if k == "namespace" and n]
        return ".".join(parts + [base]) if parts else base

    for lineno, line in enumerate(clean_text.splitlines(), start=1):
        m = NAMESPACE_RE.match(line)
        if m:
            stack.append(("namespace", m.group(1)))
            continue
        m = SECTION_RE.match(line)
        if m:
            stack.append(("section", m.group(1)))
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
            continue
        m = DECL_RE.match(line)
        if m:
            base = m.group(2).strip()
            if not base or base.startswith("_"):
                continue
            results.append((qualify(base), lineno))
    return results


def module_name_for(path: Path, root: Path) -> str:
    rel = path.relative_to(root).with_suffix("")
    return ".".join(rel.parts)


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
                 timeout: int) -> tuple[Finding, int]:
    """
    Generate a scratch Lean file that imports every module and prints the axiom
    dependencies of each discovered theorem, then run it via `lake env lean`.
    """
    decls: list[str] = []
    modules: list[str] = []
    for f in files:
        try:
            clean = strip_lean_comments(f.read_text(encoding="utf-8", errors="replace"))
        except OSError:
            continue
        found = qualified_declarations(clean)
        if found:
            modules.append(module_name_for(f, root))
            decls.extend(name for name, _ in found)

    decls = sorted(set(decls))
    if not decls:
        return Finding("axiom_audit", "UNKNOWN",
                       "no theorem/lemma declarations discovered to audit"), 0

    if shutil.which("lake") is None:
        return Finding(
            "axiom_audit", "UNKNOWN",
            f"{len(decls)} declaration(s) found but lake is unavailable — axioms "
            "NOT checked. Status is capability-limited, not verified.",
        ), len(decls)

    lines = [f"import {m}" for m in sorted(set(modules))]
    lines += [f"#print axioms {d}" for d in decls]
    scratch = root / "_lpf_axiom_audit.lean"
    try:
        scratch.write_text("\n".join(lines) + "\n", encoding="utf-8")
        code, output = run(["lake", "env", "lean", scratch.name], root, timeout)
    finally:
        scratch.unlink(missing_ok=True)

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

    hits = {
        "violations": violations,
        "unresolved": unresolved[:100],
        "audited": len(used),
        "expected": len(decls),
    }

    if violations:
        return Finding(
            "axiom_audit", "FAIL",
            f"{len(violations)} declaration(s) depend on axioms outside the allowlist",
            [hits],
        ), len(decls)
    if unresolved:
        return Finding(
            "axiom_audit", "UNKNOWN",
            f"audited {len(used)}/{len(decls)}; {len(unresolved)} name(s) did not "
            "resolve (namespace/section parsing or elaboration failure) — treat "
            "those as unchecked, not as clean",
            [hits],
        ), len(decls)
    return Finding(
        "axiom_audit", "PASS",
        f"all {len(used)} declaration(s) within allowlist",
        [hits],
    ), len(decls)


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
                    help="permit native_decide (records the weakened policy in the report)")
    ap.add_argument("--skip-build", action="store_true",
                    help="source scans only — produces a SCAN, never a proof")
    ap.add_argument("--skip-axioms", action="store_true", help="skip the axiom audit")
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
        axf, ndecls = check_axioms(root, files, allowlist, args.timeout)
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
