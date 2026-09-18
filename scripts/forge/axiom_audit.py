"""AxiomAudit: catalog sorry/admit/axiom/native_decide/opaque in a Lean tree.

Reusable Phase 1(a) deliverable. Does not claim a proof is wrong — it reports
what the sources contain so a human can judge statement fidelity.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path

PATTERNS = {
    "sorry": re.compile(r"\bsorry\b"),
    "admit": re.compile(r"\badmit\b"),
    "sorryAx": re.compile(r"\bsorryAx\b"),
    "axiom": re.compile(r"(?m)^\s*axiom\b"),
    "native_decide": re.compile(r"\bnative_decide\b"),
    "opaque": re.compile(r"(?m)^\s*opaque\b"),
    "constant": re.compile(r"(?m)^\s*constant\b"),
}

# Heuristic: top-level theorem/def/structure names for the catalog.
DECL = re.compile(
    r"(?m)^(theorem|lemma|def|structure|inductive|class|instance|axiom|opaque|constant)\s+([^\s:(]+)"
)


@dataclass
class Hit:
    kind: str
    path: str
    line: int
    text: str


@dataclass
class Decl:
    kind: str
    name: str
    path: str
    line: int


def scan_file(path: Path, root: Path) -> tuple[list[Hit], list[Decl]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    rel = str(path.relative_to(root)).replace("\\", "/")
    hits: list[Hit] = []
    decls: list[Decl] = []
    for i, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if stripped.startswith("--"):
            continue
        for kind, pat in PATTERNS.items():
            if pat.search(line):
                hits.append(Hit(kind=kind, path=rel, line=i, text=stripped[:200]))
        m = DECL.match(line)
        if m:
            decls.append(Decl(kind=m.group(1), name=m.group(2), path=rel, line=i))
    return hits, decls


def scan_tree(root: Path) -> dict:
    root = root.resolve()
    hits: list[Hit] = []
    decls: list[Decl] = []
    lean_files = sorted(root.rglob("*.lean"))
    # Skip lake packages if present under .lake
    lean_files = [p for p in lean_files if ".lake" not in p.parts]
    for path in lean_files:
        h, d = scan_file(path, root)
        hits.extend(h)
        decls.extend(d)
    by_kind: dict[str, int] = {}
    for h in hits:
        by_kind[h.kind] = by_kind.get(h.kind, 0) + 1
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "root": str(root),
        "lean_file_count": len(lean_files),
        "hit_counts": by_kind,
        "hits": [asdict(h) for h in hits],
        "declarations": [asdict(d) for d in decls],
        "statement_heuristics": {
            "mentions_eulMascheroniConst": any(
                "eulMascheroniConst" in (root / h["path"]).read_text(encoding="utf-8", errors="replace")
                if False
                else False
                for h in []
            ),
        },
    }


def enrich_statement_heuristics(root: Path, report: dict) -> None:
    blob = ""
    for path in root.rglob("*.lean"):
        if ".lake" in path.parts:
            continue
        blob += path.read_text(encoding="utf-8", errors="replace")
    report["statement_heuristics"] = {
        "mentions_eulMascheroniConst": "eulMascheroniConst" in blob,
        "mentions_Irrational": bool(re.search(r"\bIrrational\b", blob)),
        "mentions_Real_gamma": bool(re.search(r"Real\.(eulerMascheroni|eulMascheroni|gamma)", blob, re.I)),
        "has_mathlib_import": bool(re.search(r"(?m)^import Mathlib", blob)),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("root", type=Path, help="Lean project or directory to scan")
    ap.add_argument("--json-out", type=Path, default=None)
    args = ap.parse_args()
    report = scan_tree(args.root)
    enrich_statement_heuristics(args.root.resolve(), report)

    print(f"root: {report['root']}")
    print(f"lean files: {report['lean_file_count']}")
    print("hit counts:", report["hit_counts"] or "(none)")
    print("statement heuristics:", report["statement_heuristics"])
    if report["hits"]:
        print("\nhits:")
        for h in report["hits"]:
            print(f"  {h['kind']:14} {h['path']}:{h['line']}  {h['text']}")
    print("\ndeclarations:")
    for d in report["declarations"]:
        print(f"  {d['kind']:10} {d['name']:40} {d['path']}:{d['line']}")

    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(f"\nwrote {args.json_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
