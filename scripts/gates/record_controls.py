"""Embed control outcomes into each locked gate's own meta JSON.

For every gate registered in EXPECTED_VERDICT (scripts/gates/check.py),
finds control receipts under results/ whose "gate" field names it, and
writes into the gate's meta JSON:

    "controls": [
        {"control": <receipt's control name>,
         "verdict": <receipt's verdict string>,
         "ok": <bool>,
         "receipt": <relative path>,
         "receipt_sha256": <hex>,
         "receipt_timestamp": <iso>,
         "recorded_at": <iso>}
    ]

Gates with no control receipt get "controls": [] -- an honest empty
record, not an omitted field. Four locked gates are exempt from
discrimination controls (exact-equality class, §5.2 of the paper); two
more carry their control inline instead of as a receipt (gb_sce's
matched control, documented in its audit note; mah_3's wrong-θ control,
inside the gate). The paper documents both classes.

Idempotent and quiet: a gate meta is rewritten only when its embedded
controls actually change (compared ignoring "recorded_at"), so repeat
runs produce no diff churn. Control receipts are produced by
scripts/controls/ (which run outside check.py); this step embeds
whatever the current receipts say, so a re-run of the controls followed
by the aggregate refreshes the record. A receipt whose "ok" is false is
embedded as-is and reported loudly -- the verdict lock itself still
judges only verdicts (see check.py).

Unreadable receipts, receipts with no "gate" field, and receipts naming
a gate outside EXPECTED_VERDICT are never silently dropped: each
produces a warning in the returned report.

Usage:
    python scripts/gates/record_controls.py          # standalone
    # or via check.py, which calls record_controls() after the gate run
"""

from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

sys.path.insert(0, str(ROOT / "scripts" / "gates"))


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _control_receipts(known_gates: set[str]) -> tuple[dict[str, list[Path]], list[str]]:
    """Map gate name -> control receipt paths, via each receipt's gate field.

    Returns (by_gate, warnings). Nothing is silently dropped: unreadable
    receipts, receipts with no gate field, and receipts naming an unknown
    gate each produce a warning.
    """
    by_gate: dict[str, list[Path]] = {}
    warnings: list[str] = []
    for path in sorted(RESULTS.glob("*control*meta.json")):
        try:
            meta = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as exc:
            warnings.append(f"control receipt unreadable, skipped: {path.name} ({exc})")
            continue
        gate = meta.get("gate")
        if not gate:
            warnings.append(f"control receipt has no 'gate' field, skipped: {path.name}")
            continue
        if gate not in known_gates:
            warnings.append(
                f"control receipt names unknown gate {gate!r}, skipped: {path.name}"
            )
            continue
        by_gate.setdefault(gate, []).append(path)
    return by_gate, warnings


def _controls_equal(old: object, new: list[dict]) -> bool:
    """True if the embedded controls match, ignoring recorded_at timestamps."""
    if not isinstance(old, list) or len(old) != len(new):
        return False
    def strip(entries):
        return [
            {k: v for k, v in e.items() if k != "recorded_at"}
            for e in entries
            if isinstance(e, dict)
        ]
    return strip(old) == strip(new)


def record_controls() -> dict:
    """Embed control outcomes into locked-gate metas. Returns a report dict."""
    from check import EXPECTED_VERDICT

    known = set(EXPECTED_VERDICT)
    receipts, receipt_warnings = _control_receipts(known)
    now = datetime.now(timezone.utc).isoformat()
    report = {"recorded_at": now, "gates": [], "warnings": list(receipt_warnings)}

    for gate_name, (meta_name, _expected) in EXPECTED_VERDICT.items():
        meta_path = RESULTS / meta_name
        entry: dict = {"gate": gate_name, "meta": meta_name, "controls": []}
        if not meta_path.exists():
            entry["note"] = "gate meta missing; nothing embedded"
            report["warnings"].append(f"{gate_name}: gate meta missing")
            report["gates"].append(entry)
            continue
        try:
            gate_meta = json.loads(meta_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as exc:
            entry["note"] = f"gate meta unreadable: {exc}"
            report["warnings"].append(f"{gate_name}: gate meta unreadable")
            report["gates"].append(entry)
            continue

        controls = []
        for receipt_path in receipts.get(gate_name, []):
            try:
                rmeta = json.loads(receipt_path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError) as exc:
                report["warnings"].append(
                    f"{gate_name}: control receipt unreadable: {receipt_path.name} ({exc})"
                )
                continue
            ok = bool(rmeta.get("ok"))
            controls.append(
                {
                    "control": rmeta.get("control", receipt_path.stem),
                    "verdict": rmeta.get("verdict"),
                    "ok": ok,
                    "receipt": str(receipt_path.relative_to(ROOT)),
                    "receipt_sha256": _sha256(receipt_path),
                    "receipt_timestamp": rmeta.get("timestamp"),
                    "recorded_at": now,
                }
            )
            entry["controls"].append(
                {"control": rmeta.get("control", receipt_path.stem), "ok": ok}
            )
            if not ok:
                report["warnings"].append(
                    f"{gate_name}: CONTROL REPORTS FAILURE "
                    f"({receipt_path.name}, verdict={rmeta.get('verdict')!r})"
                )

        if not _controls_equal(gate_meta.get("controls"), controls):
            gate_meta["controls"] = controls
            meta_path.write_text(json.dumps(gate_meta, indent=2) + "\n", encoding="utf-8")
            entry["note"] = "controls embedded/updated"
        else:
            entry["note"] = "controls unchanged; meta not rewritten"
        if not controls:
            entry["note"] += "; no control receipt (honest empty list)"
        report["gates"].append(entry)

    return report


def main() -> int:
    report = record_controls()
    n_with = sum(1 for g in report["gates"] if g["controls"])
    n_without = sum(1 for g in report["gates"] if not g["controls"])
    print(f"controls embedded: {n_with} gates with, {n_without} gates without")
    for w in report["warnings"]:
        print(f"  WARNING: {w}")
    out = RESULTS / "record_controls_report.json"
    out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"report: {out.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
