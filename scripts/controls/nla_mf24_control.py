"""Discrimination control for the nla_mf24 PASS gate.

The gate's verdict is PASS on exact-equality checks (the eta-charpoly
identity (8) between X and Y, the exact t^2 row entries / m t^4 row norm
of p_m(X), the per-block Frobenius bounds for p_m(Y), and the exact
ratio arithmetic). Per docs/GATE-BEFORE-PROVE.md the open question for
a PASS is vacuity ("could it miss a real defect?"). This instrument
shows the gate's checks reject near-misses:

1. Perturbed word (one bridge weight 1 -> 2, everything else fixed)
   -> the S1 sip charpoly identity must reject (mismatch at some rho).
2. Perturbed heights (one motif-edge increment 1 -> 0, everything else
   fixed) -> the S2 numerator exactness must reject (row norm^2 != m t^4).
3. Non-vacuity: the unperturbed (m, t) pair passes the same code path,
   so the instrument is not an always-reject detector.

Run:  python scripts/controls/nla_mf24_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import nla_mf24 as GATE  # noqa: E402
from receipt import write_receipt  # noqa: E402

M_CTL, T_CTL = 3, Fraction(3)


def main() -> int:
    checks: dict[str, object] = {}
    wx, wy, ix, iy = GATE.build_words(M_CTL, T_CTL)

    print("[1] perturbed word: X's '1' bridge weight 1 -> 2 (all else fixed)")
    # The '1' bridge of X is at 0-based index m (after the first motif U).
    wxp = list(wx)
    assert wxp[M_CTL] == 1, "bridge position"
    wxp[M_CTL] = Fraction(2)
    mismatches = []
    for rho in GATE.RHOS:
        if GATE.transfer_charpoly(wxp, rho) != GATE.transfer_charpoly(wy, rho):
            mismatches.append(str(rho))
    checks["bridge_perturbation_sip_rejected"] = bool(mismatches)
    checks["sip_mismatch_rhos"] = mismatches
    print(f"    rejected: {bool(mismatches)} (mismatch at rho={mismatches})")

    print("[2] perturbed heights: first motif-edge increment 1 -> 0")
    ixp = list(ix)
    ixp[0] = 0
    hxp = GATE.heights_from_increments(ixp)
    total_p, _ = GATE.row0_supernorm2(M_CTL, T_CTL, hxp)
    checks["increment_perturbation_numerator_rejected"] = bool(
        total_p != M_CTL * T_CTL**4
    )
    checks["perturbed_row0_norm2"] = str(total_p)
    checks["expected_row0_norm2"] = str(M_CTL * T_CTL**4)
    print(f"    rejected: {checks['increment_perturbation_numerator_rejected']} "
          f"(got {total_p}, want {M_CTL * T_CTL**4})")

    print("[3] non-vacuity: unperturbed pair passes the same path")
    sip_ok = all(GATE.check_sip(M_CTL, T_CTL).values())
    num = GATE.check_numerator(M_CTL, T_CTL)
    num_ok = all(v for v in num.values() if isinstance(v, bool))
    den = GATE.check_denominator(M_CTL, T_CTL)
    den_ok = all(v for v in den.values() if isinstance(v, bool))
    checks["unperturbed_sip_passes"] = bool(sip_ok)
    checks["unperturbed_numerator_passes"] = bool(num_ok)
    checks["unperturbed_denominator_passes"] = bool(den_ok)
    print(f"    sip={sip_ok} numerator={num_ok} denominator={den_ok}")

    ok = all(
        [
            checks["bridge_perturbation_sip_rejected"],
            checks["increment_perturbation_numerator_rejected"],
            checks["unperturbed_sip_passes"],
            checks["unperturbed_numerator_passes"],
            checks["unperturbed_denominator_passes"],
        ]
    )
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL FAILURE"
    print(f"\nverdict: {verdict}")
    write_receipt(
        control="nla_mf24_control",
        gate="nla_mf24",
        verdict=verdict,
        checks=checks,
        ok=ok,
        extra={
            "note": (
                "Perturbations are matched: one bridge weight (1->2) or one "
                "height increment (1->0) changed, everything else fixed. "
                "Rejection comes from the gate's own exact checks (charpoly "
                "mismatch; row norm^2 != m t^4), proving they read the "
                "witness rather than rubber-stamping."
            )
        },
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
