#!/usr/bin/env python3
"""Pre-dispatch checks for the failure modes banked 2026-10-09 through
2026-10-14.

Spec: docs/PRE-DISPATCH-CHECKS.md. Read-only: this script never dispatches,
commits, or pushes. Exit 0 = all applicable checks pass; exit 1 = REFUSED.
Checks whose inputs were not supplied print SKIP, never a silent pass.
A finding can be waived per dispatch with --waive MODE=REASON: the finding
prints as WAIVED with its reason and does not count toward refusal. A
waiver is one dispatch only and is never silent; see the spec's waiver
section.
Waivers can also be recorded ahead of a dispatch in a waivers file
(--waivers-file PATH): JSON lines, one record per line, of the form
{"fm": MODE, "reason": "...", "date": "YYYY-MM-DD", "workflow": NAME}.
The checker reads the file at startup; a record waives its mode for this
dispatch only when it names one of the workflows being checked (by the
path as given, by basename, or "*" for any), so a waiver recorded for
one workflow can never silently waive a finding in another. When --waive
is used together with --waivers-file, each CLI waiver is appended to the
file as a record (fm, reason, today's date, the first workflow being
checked), so waiver use stays countable at the monthly hygiene review.
A waivers file that cannot be parsed, or a CLI waiver that cannot be
recorded, is a usage error (exit 2): a waiver that leaves no record must
not waive. With no --waivers-file, behavior is exactly the per-dispatch
--waive above and nothing is persisted.
"""
import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

FAILURES = []
WAIVERS = {}
WAIVER_SOURCES = {}
WAIVED = []


def refuse(mode, msg):
    if mode in WAIVERS:
        note = f"waiver: {WAIVERS[mode]}"
        if mode in WAIVER_SOURCES:
            note += f"; {WAIVER_SOURCES[mode]}"
        WAIVED.append(f"{mode} WAIVED: {msg} ({note})")
        return
    FAILURES.append(f"{mode} REFUSED: {msg}")


# --- Waivers file: recorded, workflow-scoped waivers --------------------
def checked_workflow_names(a):
    names = []
    if a.workflow:
        names.append(a.workflow)
    names += list(a.workflows or [])
    return names


def waiver_record_applies(record, names):
    wf = (record.get("workflow") or "").strip()
    if wf == "*":
        return True
    if not names:
        return False
    return any(wf == n or os.path.basename(wf) == os.path.basename(n)
               for n in names)


def load_waivers_file(path):
    """Read a waivers file. Returns (records, error): one JSON object
    per non-blank line, each with fm and a non-empty reason."""
    records = []
    if not os.path.exists(path):
        return records, None
    for i, line in enumerate(open(path, encoding="utf-8"), 1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except ValueError:
            return None, f"{path}:{i} is not valid JSON"
        if not isinstance(record, dict) or not record.get("fm") \
                or not (record.get("reason") or "").strip():
            return None, (f"{path}:{i} needs an fm and a non-empty "
                          f"reason")
        records.append(record)
    return records, None


def record_cli_waivers(path, records, cli_waivers, names):
    """Append one record per CLI waiver not already in the file.
    Returns an error string, or None."""
    workflow = names[0] if names else ""
    existing = {(r.get("fm"), r.get("reason"), r.get("workflow"))
                for r in records}
    new = []
    for mode, reason in cli_waivers.items():
        key = (mode, reason, workflow)
        if key in existing:
            continue
        existing.add(key)
        new.append({"fm": mode, "reason": reason,
                    "date": datetime.date.today().isoformat(),
                    "workflow": workflow})
    if not new:
        return None
    try:
        with open(path, "a", encoding="utf-8") as f:
            for record in new:
                f.write(json.dumps(record) + "\n")
    except OSError as e:
        return f"could not record waiver(s) in {path}: {e}"
    return None


# --- FM3: workflow inputs must never reach a run: block unquoted ----------
def check_workflow_inputs(path):
    lines = open(path, encoding="utf-8").read().splitlines()
    env_indent = None
    for i, line in enumerate(lines, 1):
        stripped = line.lstrip()
        indent = len(line) - len(stripped)
        if re.match(r"env:\s*$", stripped):
            env_indent = indent
            continue
        if env_indent is not None and stripped and indent <= env_indent:
            env_indent = None
        for m in re.finditer(r"\$\{\{\s*inputs\.([A-Za-z0-9_-]+)", line):
            if env_indent is not None and indent > env_indent:
                continue  # env: value -- never re-parsed by the shell
            if re.match(r'\s*[A-Za-z_][A-Za-z0-9_]*="\$\{\{\s*inputs\.', line):
                continue  # quoted-var-first: NAME="${{ inputs.x }}"
            refuse("FM3", f"{path}:{i} inputs.{m.group(1)} reaches a run "
                         "block unquoted (pass it via env: or quote it "
                         "var-first)")


# --- FM2 + FM5: lakefile checks --------------------------------------------
REQUIRE_RE = re.compile(r"^\s*require\s+(\S+?)(?:\s|$)")
REV_RE = re.compile(r'(?:@|rev\s+|")\s*"?([0-9a-f]{7,40})"?')
LEAN_LIB_RE = re.compile(r"lean_lib\s+(\S+)\s+where(.*?)(?=\n\S|\Z)", re.S)


def check_lakefile(path, manifest_path=None):
    text = open(path, encoding="utf-8").read()
    requires = [m.group(1) for ln in text.splitlines()
                if (m := REQUIRE_RE.match(ln))]
    if "mathlib" in requires and requires[-1] != "mathlib":
        refuse("FM2", f"{path}: require mathlib is not last "
                      f"(order: {', '.join(requires)})")
    pins = {}
    for src, body in [(path, text)] + (
            [(manifest_path, open(manifest_path, encoding="utf-8").read())]
            if manifest_path and os.path.exists(manifest_path) else []):
        for pkg, rev in re.findall(
                r'"name":\s*"([^"]+)".*?"rev":\s*"([0-9a-f]{7,40})"',
                body, re.S):
            pins.setdefault(pkg, set()).add(rev)
        for ln in body.splitlines():
            m = REQUIRE_RE.match(ln)
            r = REV_RE.search(ln)
            if m and r:
                pins.setdefault(m.group(1), set()).add(r.group(1))
    for pkg, revs in sorted(pins.items()):
        if len(revs) > 1:
            refuse("FM2", f"package {pkg} pins different versions: "
                          f"{' vs '.join(sorted(revs))}")
    for m in LEAN_LIB_RE.finditer(text):
        block = m.group(2)
        if re.search(r"^\s*roots", block, re.M) and \
                not re.search(r"^\s*globs", block, re.M):
            refuse("FM5", f"{path}: lean_lib {m.group(1)} restricts roots "
                          "without globs (non-root modules silently "
                          "excluded from the build plan)")


# --- FM4: import closure ----------------------------------------------------
IMPORT_RE = re.compile(r"^\s*import\s+([A-Z][A-Za-z0-9_.]*)", re.M)


def check_import_closure(project):
    lean_files = []
    for root, dirs, files in os.walk(project):
        if ".lake" in root.split(os.sep):
            continue
        lean_files += [os.path.join(root, f) for f in files
                       if f.endswith(".lean")]
    libs = {d for d in os.listdir(project)
            if os.path.isdir(os.path.join(project, d)) and d != ".lake"
            and any(f.endswith(".lean")
                    for _, _, fs in os.walk(os.path.join(project, d))
                    for f in fs)}
    for f in lean_files:
        for mod in IMPORT_RE.findall(open(f, encoding="utf-8").read()):
            top = mod.split(".")[0]
            if top not in libs:
                continue
            rel = os.path.join(project, *mod.split(".")) + ".lean"
            if not os.path.exists(rel):
                refuse("FM4", f"unresolved import {mod} in "
                              f"{os.path.relpath(f, project)}")


# --- FM1: vendor integrity ---------------------------------------------------
def check_vendor(vendor, root_module, expected_count):
    if not os.path.exists(os.path.join(vendor, root_module)):
        refuse("FM1", f"root module {root_module} missing from vendor "
                      f"tree {vendor}")
    count = sum(1 for _, _, fs in os.walk(vendor)
                for f in fs if f.endswith(".lean"))
    if expected_count is not None and count != expected_count:
        refuse("FM1", f"vendor tree {vendor} holds {count} .lean files, "
                      f"expected {expected_count}")


# --- K13/K14: workflow lint (D1 family) ---------------------------------
# Historical failures: a dropped closing quote killed a run in 7s; ".." in
# an action `path:` was rejected by upload-artifact; `cmd; code=$?` under
# `set -euo pipefail` silently exited and lost the verdict.

RUN_KEY_RE = re.compile(r"^(\s*)run:\s*(.*)$")
RUN_BLOCK_IND_RE = re.compile(r"^\s*run:\s*(?:[|>]|[-+][|>])\s*$")
PATH_KEY_RE = re.compile(r"^\s*(?:path|working-directory):\s*(.*)$")
EXIT_CAPTURE_RE = re.compile(r";\s*[A-Za-z_][A-Za-z0-9_]*=\$\?")


def extract_run_blocks(lines):
    """Yield (lineno, script) for each run: block, stdlib line scan.

    Handles block scalars (`run: |`) via indentation, plus plain one-line
    scalars (`run: echo hi`).
    """
    i = 0
    n = len(lines)
    while i < n:
        m = RUN_KEY_RE.match(lines[i])
        if not m:
            i += 1
            continue
        indent = len(m.group(1))
        rest = m.group(2).strip()
        lineno = i + 1
        if RUN_BLOCK_IND_RE.match(lines[i]):
            # block scalar: consume lines strictly deeper than `run:`
            body = []
            i += 1
            while i < n and (not lines[i].strip()
                            or len(lines[i]) - len(lines[i].lstrip()) > indent):
                body.append(lines[i])
                i += 1
            indents = [len(b) - len(b.lstrip()) for b in body
                       if b.strip()]
            cut = min(indents) if indents else 0
            yield lineno, "\n".join(b[cut:] for b in body)
        elif rest:
            # single-line scalar
            yield lineno, rest
            i += 1
        else:
            i += 1


def check_workflow_lint(path):
    lines = open(path, encoding="utf-8").read().splitlines()
    ran_blocks = list(extract_run_blocks(lines))
    if not ran_blocks:
        print(f"NOTE: {path}: no run: blocks found")
    for lineno, script in ran_blocks:
        if not script.strip():
            continue
        with tempfile.NamedTemporaryFile("w", suffix=".sh",
                                         delete=False) as tf:
            tf.write(script)
            tf.flush()
            name = tf.name
        try:
            r = subprocess.run(["bash", "-n", name],
                               capture_output=True, text=True, timeout=30)
        except FileNotFoundError:
            print(f"SKIP {path}:{lineno}: bash not available for -n check")
            os.unlink(name)
            continue
        os.unlink(name)
        if r.returncode != 0:
            refuse("K13", f"{path}:{lineno} run: block fails `bash -n`: "
                          f"{r.stderr.strip().splitlines()[0] if r.stderr.strip() else 'syntax error'}")
        # The heuristic runs on full-line-comment-stripped text: a `;` in a
        # full-line comment can never be shell code (the failure it documents
        # names the forbidden pattern in prose).
        stripped = "\n".join(l for l in script.splitlines()
                             if not re.match(r"^\s*#", l))
        if EXIT_CAPTURE_RE.search(stripped):
            refuse("K14", f"{path}:{lineno} run: block captures an exit "
                          "code with `; <var>=$?` under set -e; use the "
                          "exempt form `cmd || code=$?` instead")
    for i, line in enumerate(lines, 1):
        pm = PATH_KEY_RE.match(line)
        if pm and ".." in pm.group(1):
            refuse("K13", f"{path}:{i} `..` in a path:/working-directory: "
                          "value is rejected by action path validation")
    check_fm7(path, lines)


# --- FM7: probe gating + df use-before-create (eth-forge run #1, 2026-10-27) --
# Run #1 died in 4s: the Runner probe ran `df -h "$ETH_TARGET"` before the
# step that creates $ETH_TARGET (the clone step, later). df exited 1 on the
# missing directory; the probe block ends with that pipeline, so under
# `pipefail` its exit code became the step's, despite `set +e`. Two checks:
# (a) a $VAR passed to `df` must be created by an earlier `mkdir -p "$VAR"`
#     (in file order) or the df pipeline must be guarded with `|| true/echo`;
# (b) a step named *probe* is informational by definition: it must be
#     structurally non-gating (continue-on-error: true, or its run block
#     ends with `exit 0`).

STEP_NAME_RE = re.compile(r"^(\s*)-\s*name:\s*(.+?)\s*$")
CONTINUE_ON_ERROR_RE = re.compile(r"^\s*continue-on-error:\s*true\s*$", re.I)
MKDIR_VAR_RE = re.compile(
    r'\bmkdir\b[^;|&]*?"?\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?')
DF_VAR_RE = re.compile(
    r'\bdf\b[^;|&]*?"?\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?')


def check_fm7(path, lines):
    blocks = list(extract_run_blocks(lines))
    created = set()
    for lineno, script in blocks:
        for raw in script.splitlines():
            if re.match(r"^\s*#", raw):
                continue
            events = [(m.start(), "mkdir", m.group(1))
                      for m in MKDIR_VAR_RE.finditer(raw)]
            events += [(m.start(), "df", m.group(1))
                       for m in DF_VAR_RE.finditer(raw)]
            for pos, kind, var in sorted(events):
                if kind == "mkdir":
                    created.add(var)
                elif var not in created and not re.search(
                        r"\|\|\s*(true|echo)\b", raw[pos:]):
                    refuse("FM7", f"{path}:{lineno} df on ${var} before "
                                  f"any mkdir -p creates it and unguarded: "
                                  f"on a fresh runner the path does not "
                                  f"exist, df exits 1, and a trailing probe "
                                  f"pipeline leaks that as the step verdict")
    for idx, line in enumerate(lines):
        m = STEP_NAME_RE.match(line)
        if not m or "probe" not in m.group(2).lower():
            continue
        dash_indent = len(m.group(1))
        end = len(lines)
        for j in range(idx + 1, len(lines)):
            stripped = lines[j].strip()
            if not stripped:
                continue
            indent = len(lines[j]) - len(lines[j].lstrip())
            if indent < dash_indent or (
                    indent == dash_indent and stripped.startswith("- ")):
                end = j
                break
        step_lines = lines[idx:end]
        if any(CONTINUE_ON_ERROR_RE.match(l) for l in step_lines):
            continue
        step_blocks = list(extract_run_blocks(step_lines))
        if not step_blocks:
            continue
        meaningful = [l.strip() for l in step_blocks[0][1].splitlines()
                      if l.strip() and not l.strip().startswith("#")]
        if not meaningful or meaningful[-1] != "exit 0":
            refuse("FM7", f"{path}:{idx + 1} step '{m.group(2)}' is a "
                          f"probe (informational) but can gate the job: "
                          f"no continue-on-error: true and its run block "
                          f"does not end with `exit 0`")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--workflow")
    ap.add_argument("--workflows", nargs="+")
    ap.add_argument("--lakefile")
    ap.add_argument("--project")
    ap.add_argument("--vendor")
    ap.add_argument("--root-module")
    ap.add_argument("--expected-count", type=int)
    ap.add_argument("--waive", action="append", default=[],
                    metavar="MODE=REASON",
                    help="waive one failure mode for this dispatch only, "
                         "with a recorded one-line reason, e.g. "
                         "--waive FM7=\"first run on a pre-provisioned "
                         "runner\". Repeatable. Waived findings print as "
                         "WAIVED and never count toward refusal.")
    ap.add_argument("--waivers-file", metavar="PATH",
                    help="JSON-lines waivers file (records of fm, "
                         "reason, date, workflow). Records naming one "
                         "of the workflows being checked waive their "
                         "mode for this dispatch and print as WAIVED "
                         "with their recorded date; --waive waivers "
                         "are appended to the file as new records.")
    a = ap.parse_args()

    cli_waivers = {}
    for w in a.waive:
        mode, sep, reason = w.partition("=")
        mode, reason = mode.strip(), reason.strip()
        if not sep or not mode or not reason:
            print(f"error: --waive needs MODE=REASON with a non-empty "
                  f"reason, got {w!r}", file=sys.stderr)
            return 2
        cli_waivers[mode] = reason
        WAIVERS[mode] = reason

    if a.waivers_file:
        names = checked_workflow_names(a)
        records, err = load_waivers_file(a.waivers_file)
        if err:
            print(f"error: --waivers-file {err}", file=sys.stderr)
            return 2
        for record in records:
            if not waiver_record_applies(record, names):
                continue
            mode = record["fm"]
            if mode in cli_waivers:
                continue  # the CLI waiver for this dispatch wins
            WAIVERS[mode] = record["reason"].strip()
            WAIVER_SOURCES[mode] = (
                f"recorded {record.get('date', '?')} for workflow "
                f"{record.get('workflow', '')} in {a.waivers_file}")
        err = record_cli_waivers(a.waivers_file, records, cli_waivers,
                                 names)
        if err:
            print(f"error: {err}", file=sys.stderr)
            return 2

    ran = []
    if a.workflow:
        check_workflow_inputs(a.workflow)
        ran.append("FM3(workflow inputs)")
    else:
        print("SKIP FM3: no --workflow given")
    if a.workflows:
        for wf in a.workflows:
            check_workflow_lint(wf)
        ran.append(f"K13/K14(workflow lint of {len(a.workflows)} file(s))")
    else:
        print("SKIP K13/K14: no --workflows given")
    if a.lakefile:
        man = os.path.join(os.path.dirname(a.lakefile), "lake-manifest.json")
        check_lakefile(a.lakefile, man)
        ran.append("FM2(require order/pins), FM5(lean_lib roots/globs)")
    else:
        print("SKIP FM2/FM5: no --lakefile given")
    if a.project:
        check_import_closure(a.project)
        ran.append("FM4(import closure)")
    else:
        print("SKIP FM4: no --project given")
    if a.vendor and a.root_module:
        check_vendor(a.vendor, a.root_module, a.expected_count)
        ran.append("FM1(vendor integrity)")
    else:
        print("SKIP FM1: no --vendor/--root-module given")

    for wline in WAIVED:
        print(wline)
    used = {wline.split(" ", 1)[0] for wline in WAIVED}
    for mode in WAIVERS:
        if mode not in used:
            print(f"NOTE: waiver for {mode} matched no finding")
    if FAILURES:
        print("\n*** PRE-DISPATCH REFUSED ***", file=sys.stderr)
        for f in FAILURES:
            print(f, file=sys.stderr)
        return 1
    ok = f"PRE-DISPATCH OK: {'; '.join(ran) if ran else 'nothing to check'}"
    if WAIVED:
        ok += f" ({len(WAIVED)} waived: {', '.join(sorted(used))})"
    print(ok)
    return 0


if __name__ == "__main__":
    sys.exit(main())
