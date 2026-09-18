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


def run_harness() -> dict:
    proc = subprocess.run(
        [sys.executable, str(HARNESS_SELFTEST)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    return {
        "name": "harness_selftest",
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    # Phase 0: only the harness. Later phases append gate callables here.
    results = [run_harness()]
    failed = [r for r in results if not r["ok"]]
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": 0,
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
