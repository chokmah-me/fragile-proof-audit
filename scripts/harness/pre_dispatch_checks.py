#!/usr/bin/env python3
"""Pre-dispatch checks for the five failure modes banked 2026-10-09.

Spec: docs/PRE-DISPATCH-CHECKS.md. Read-only: this script never dispatches,
commits, or pushes. Exit 0 = all applicable checks pass; exit 1 = REFUSED.
Checks whose inputs were not supplied print SKIP, never a silent pass.
"""
import argparse
import json
import os
import re
import sys

FAILURES = []


def refuse(mode, msg):
    FAILURES.append(f"{mode} REFUSED: {msg}")


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


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--workflow")
    ap.add_argument("--lakefile")
    ap.add_argument("--project")
    ap.add_argument("--vendor")
    ap.add_argument("--root-module")
    ap.add_argument("--expected-count", type=int)
    a = ap.parse_args()

    ran = []
    if a.workflow:
        check_workflow_inputs(a.workflow)
        ran.append("FM3(workflow inputs)")
    else:
        print("SKIP FM3: no --workflow given")
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

    if FAILURES:
        print("\n*** PRE-DISPATCH REFUSED ***", file=sys.stderr)
        for f in FAILURES:
            print(f, file=sys.stderr)
        return 1
    print(f"PRE-DISPATCH OK: {'; '.join(ran) if ran else 'nothing to check'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
