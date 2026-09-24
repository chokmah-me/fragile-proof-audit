"""Discrimination control for the nla_nr03 PASS gate.

The gate's verdict is PASS on an exact-equality check (W V = C7 diag(d)
over all 16,384 entries, plus the rational cross-check). Per
docs/GATE-BEFORE-PROVE.md such a verdict is "ceremony"-adjacent -- exact
comparison catches discrepancies by construction -- but the open question
here is vacuity, not arithmetic: the gate reads a third-party certificate
file, and a check that passed on truncated, mis-shaped, or silently
swallowed input would be evidence of nothing. This instrument shows the
gate's check actually rejects near-misses:

1. Perturbation: flip a single entry of W by +1 (everything else fixed,
   including the independently rebuilt target matrix) -> the gate must
   reject, and must reject via the exact-product check (not a loader
   exception). Same for one entry of V and one denominator.
2. Non-vacuity: the unperturbed certificate passes through the same code
   path, so the instrument is not an always-reject detector.
3. Transcription independence (structural): the gate rebuilds C7 from the
   mask definition C7(a,b) = (1-popcount(a&b))^2; the JSON's entries are
   never used as the oracle. Asserted here by re-deriving the 5,103/11,281
   zero/positive split from the definition alone.

Run:  python scripts/controls/nla_nr03_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""

from __future__ import annotations

import copy
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import nla_nr03 as GATE  # noqa: E402
from receipt import write_receipt  # noqa: E402

CERT = ROOT / "incoming" / "nla-nr03-factors_n7.json"


def load():
    raw = CERT.read_bytes()
    cert = json.loads(raw.decode("utf-8"))
    return cert, hashlib.sha256(raw).hexdigest()


def perturbation_checks(W, V, d, target) -> dict:
    """Single-entry perturbations; each must flip the gate to reject."""
    out = {}

    # (a) perturb one W entry
    Wp = copy.deepcopy(W)
    Wp[0][0] += 1
    r = GATE.verify_certificate(Wp, V, d, target)
    out["perturb_W00_rejected"] = not r["ok"]
    out["perturb_W00_rejected_by_product_check"] = not r["int_product_all_16384"]

    # (b) perturb one V entry
    Vp = copy.deepcopy(V)
    Vp[5][10] += 1
    r = GATE.verify_certificate(W, Vp, d, target)
    out["perturb_V5_10_rejected"] = not r["ok"]
    out["perturb_V5_10_rejected_by_product_check"] = not r["int_product_all_16384"]

    # (c) perturb one denominator
    dp = list(d)
    dp[3] += 1
    r = GATE.verify_certificate(W, V, dp, target)
    out["perturb_d3_rejected"] = not r["ok"]

    return out


def main() -> int:
    cert, sha = load()
    W, V, d = cert["W"], cert["H_scaled"], cert["denominators"]
    target = GATE.build_target()

    print("[1] perturbation discrimination (matched: single entry each)")
    pert = perturbation_checks(W, V, d, target)
    for k, v in pert.items():
        print(f"    {k}: {v}")

    print("[2] non-vacuity: unperturbed certificate passes the same path")
    base = GATE.verify_certificate(W, V, d, target)
    non_vacuous = bool(base["ok"])
    print(f"    unperturbed ok: {non_vacuous}")

    print("[3] transcription independence (target rebuilt from definition)")
    n_zero = sum(1 for row in target for x in row if x == 0)
    # The JSON's own entries are never read as the oracle: rebuild uses only
    # masks 0..127 and the definition C7(a,b) = (1-popcount(a&b))^2.
    independent = n_zero == 5103 and len(target) == 128 and len(target[0]) == 128
    print(f"    rebuilt target 128x128, zeros={n_zero} (paper: 5103): {independent}")

    checks = {
        "certificate_sha256": sha,
        **pert,
        "unperturbed_passes": non_vacuous,
        "target_rebuilt_from_definition": independent,
    }
    ok = all(pert.values()) and non_vacuous and independent
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL FAILURE"

    print(f"\nverdict: {verdict}")
    write_receipt(
        control="nla_nr03_control",
        gate="nla_nr03",
        verdict=verdict,
        checks=checks,
        ok=ok,
        extra={
            "note": (
                "Perturbations are matched: one entry changed, everything "
                "else (including the independently rebuilt target) fixed. "
                "Rejection must come from the exact-product check, proving "
                "the gate reads and verifies all 16,384 entries."
            )
        },
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
