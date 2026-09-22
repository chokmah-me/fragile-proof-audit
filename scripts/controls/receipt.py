"""Uniform receipt writer for discrimination controls.

Controls are instruments, not gates: they issue no campaign verdict and are
never registered in `scripts/gates/check.py` (docs/GATE-BEFORE-PROVE.md,
"Controls are instruments, not gates"). But until 2026-09-21 eight of the ten
controls left no machine-readable trace at all -- their "NO FALSE POSITIVE"
findings existed only in stdout and in prose in the docs, which is precisely
the unauditable shape the campaign refuses to accept from the papers it
audits. This module gives every control the same receipt so the claim can be
re-read later without re-running it.

A receipt is NOT a verdict lock. Nothing fails CI when one changes; it records
what the instrument found and when.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"


def write_receipt(
    control: str,
    gate: str,
    verdict: str,
    checks: dict,
    ok: bool,
    extra: dict | None = None,
) -> Path:
    """Write `results/<control>_meta.json` and return its path.

    `control` is the receipt's stem, e.g. "cohen_break_control".
    `verdict` is the control's own finding, e.g. "NO FALSE POSITIVE".
    `checks` maps each named check to its result payload.
    """
    RESULTS.mkdir(parents=True, exist_ok=True)
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": control,
        "gate": gate,
        "instrument": True,
        "registered_in_check_py": False,
        "checks": checks,
        "verdict": verdict,
        "ok": ok,
    }
    if extra:
        meta.update(extra)
    out = RESULTS / f"{control}_meta.json"
    out.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")
    print(f"Wrote {out}")
    return out
