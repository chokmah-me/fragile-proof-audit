"""Regression entrypoint for all numeric gates.

Phase 0: harness self-test only (empty target suite).
Phase 1+: each target gate registers here and must stay green in CI.
"""

from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
HARNESS_SELFTEST = ROOT / "scripts" / "harness" / "selftest.py"
SUMAN_EQ48 = ROOT / "scripts" / "gates" / "suman_eq48.py"
ODD_ZETA_1609 = ROOT / "scripts" / "gates" / "odd_zeta_1609.py"
ES_COVER = ROOT / "scripts" / "gates" / "es_cover.py"
RR_QEXPAND = ROOT / "scripts" / "gates" / "rr_qexpand.py"


def run_script(name: str, path: Path) -> dict:
    proc = subprocess.run(
        [sys.executable, str(path)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    return {
        "name": name,
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


def run_harness() -> dict:
    return run_script("harness_selftest", HARNESS_SELFTEST)


def run_suman_eq48() -> dict:
    return run_script("suman_eq48", SUMAN_EQ48)


def run_odd_zeta_1609() -> dict:
    return run_script("odd_zeta_1609", ODD_ZETA_1609)


def run_es_cover() -> dict:
    return run_script("es_cover", ES_COVER)


def run_rr_qexpand() -> dict:
    return run_script("rr_qexpand", RR_QEXPAND)


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    # Phase 1(b)+2(d)+2(e)+2(f): harness + Suman + odd-zeta + ESC + RR q-expand.
    results = [
        run_harness(),
        run_suman_eq48(),
        run_odd_zeta_1609(),
        run_es_cover(),
        run_rr_qexpand(),
    ]
    failed = [r for r in results if not r["ok"]]
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "2f",
        "gates": [
            {
                "name": r["name"],
                "ok": r["ok"],
                "exit_code": r["exit_code"],
            }
            for r in results
        ],
        "all_ok": not failed,
    }
    out = RESULTS / "gates_check_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    for r in results:
        status = "PASS" if r["ok"] else "FAIL"
        print(f"[{status}] {r['name']}")
        if r["stdout"]:
            print(r["stdout"].rstrip())
        if r["stderr"]:
            print(r["stderr"].rstrip(), file=sys.stderr)
    print(f"\nWrote {out}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
