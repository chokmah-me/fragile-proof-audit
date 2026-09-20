"""Instrument: replay Grinsztajn 2026 Borsuk-63 author verifier (Track C).

Runs the pinned clone's verify_borsuk63.py. Issues no campaign verdict and is
deliberately not registered in scripts/gates/check.py.

PASS  = author script exits 0 and prints the success line.
UNKNOWN = clone missing or script not found (operator must re-clone).
BREAK is not a legal output of this wrapper: a failing author script is a
broken pin, not a Borsuk disproof.
"""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
CLONE = ROOT / "incoming" / "borsuk-63"
SCRIPT = CLONE / "verify_borsuk63.py"
PIN_COMMIT = "cdcdbeac2e692b8641218c70ce9f414522e125e5"
PIN_SCRIPT_SHA256 = "c3144ffeb009c634eeaf2f0eb45c70ef4eeeb779f55e2d8ffd4446b0ba4d9673"
SUCCESS_LINE = "all exact verification checks passed"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def git_head(repo: Path) -> str | None:
    try:
        out = subprocess.check_output(
            ["git", "-C", str(repo), "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        return out.strip()
    except (OSError, subprocess.CalledProcessError):
        return None


def main() -> int:
    ts = datetime.now(timezone.utc).isoformat()
    meta: dict = {
        "timestamp": ts,
        "phase": "track-c",
        "gate": "borsuk63",
        "instrument": True,
        "registered_in_check_py": False,
        "source": "https://github.com/maaxgrin/borsuk-63-counterexample",
        "pin_commit": PIN_COMMIT,
        "pin_script_sha256": PIN_SCRIPT_SHA256,
        "command": [sys.executable, str(SCRIPT)],
    }
    if not SCRIPT.is_file():
        meta["verdict"] = "UNKNOWN"
        meta["note"] = "clone missing; git clone maaxgrin/borsuk-63-counterexample into incoming/borsuk-63/"
        RESULTS.mkdir(parents=True, exist_ok=True)
        (RESULTS / "borsuk63_gate_meta.json").write_text(
            json.dumps(meta, indent=2), encoding="utf-8"
        )
        print("UNKNOWN: Borsuk-63 clone not present")
        return 0

    observed = sha256_file(SCRIPT)
    head = git_head(CLONE)
    meta["observed_script_sha256"] = observed
    meta["observed_commit"] = head
    if observed.lower() != PIN_SCRIPT_SHA256:
        meta["verdict"] = "UNKNOWN"
        meta["note"] = "script sha256 drifted from pin"
        (RESULTS / "borsuk63_gate_meta.json").write_text(
            json.dumps(meta, indent=2), encoding="utf-8"
        )
        print("UNKNOWN: verify_borsuk63.py sha256 drift")
        return 0

    t0 = time.perf_counter()
    proc = subprocess.run(
        [sys.executable, str(SCRIPT)],
        cwd=str(CLONE),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    elapsed = time.perf_counter() - t0
    stdout = proc.stdout or ""
    meta["returncode"] = proc.returncode
    meta["elapsed_s"] = round(elapsed, 3)
    meta["stdout_tail"] = stdout.strip().splitlines()[-12:]
    if proc.returncode == 0 and SUCCESS_LINE in stdout.lower():
        meta["verdict"] = "PASS"
    else:
        meta["verdict"] = "UNKNOWN"
        meta["stderr_tail"] = (proc.stderr or "").strip().splitlines()[-20:]
        meta["note"] = "author script failed or success line missing; pin is broken, not a Borsuk result"

    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "borsuk63_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"{meta['verdict']}  borsuk63  {elapsed:.2f}s  wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
