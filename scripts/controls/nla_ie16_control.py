"""Discrimination control for the nla_ie16 PASS gate.

The gate's verdict is PASS on exact-equality / exact-inequality checks (the
nine-point witness reproduces the paper's exact rational M4, the conjugated
orthogonality identities hold exactly, and all 126 Lagrange sums clear a
rational threshold). Per docs/GATE-BEFORE-PROVE.md the open question for a
PASS is vacuity ("could it miss a real defect?"). This instrument shows the
gate's checks reject near-misses:

1. Wrong claimed value: shift the claimed m by 1e-9 (same points, same p*,
   only the claimed value changes) -> the nine-moduli check must reject.
2. Too-tight subset bound: claim B_4 < 0.0022, below the true ~0.0022506
   (same geometry, tighter threshold) -> the Lagrange-sum threshold check
   must reject, while the paper's 23/10000 claim passes on the same sums.
3. Perturbed witness: move a single point by 1/100 (everything else fixed)
   -> the nine-moduli check must reject.
4. Non-vacuity: the unperturbed witness passes the same code path, so the
   instrument is not an always-reject detector.

Run:  python scripts/controls/nla_ie16_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import nla_ie16 as GATE  # noqa: E402
from receipt import write_receipt  # noqa: E402


def main() -> int:
    checks: dict[str, object] = {}

    print("[1] wrong claimed m (shifted by 1e-9, points and p* fixed)")
    m_wrong = GATE.M + Fraction(1, 10**9)
    m2_wrong = m_wrong * m_wrong
    rejected = any(
        GATE._norm2(GATE._pstar(z)) != m2_wrong for z in GATE.PT_LIST
    )
    checks["wrong_m_1e9_rejected"] = bool(rejected)
    print(f"    rejected: {rejected}")

    print("[2] too-tight subset bound (same sums, threshold 0.0022 vs 0.0023)")
    min_sum: Fraction | None = None
    for S in combinations(range(9), 5):
        s = GATE._lagrange_sum_lower(S)
        if min_sum is None or s < min_sum:
            min_sum = s
    assert min_sum is not None
    # Paper's claim passes on these sums; the tighter claim must fail.
    paper_claim_ok = min_sum > Fraction(10000, 23)
    tight_claim_rejected = not (min_sum > Fraction(10000, 22))
    checks["paper_bound_23_10000_passes"] = bool(paper_claim_ok)
    checks["tight_bound_22_10000_rejected"] = bool(tight_claim_rejected)
    print(f"    paper bound passes: {paper_claim_ok}, "
          f"tight bound rejected: {tight_claim_rejected}")

    print("[3] perturbed witness (one point moved by 1/100)")
    moved = list(GATE.PT_LIST)
    z0 = moved[0]
    moved[0] = (z0[0] + Fraction(1, 100), z0[1])
    m2 = GATE.M * GATE.M
    perturbed_rejected = any(
        GATE._norm2(GATE._pstar(z)) != m2 for z in moved
    )
    checks["perturbed_point_rejected"] = bool(perturbed_rejected)
    print(f"    rejected: {perturbed_rejected}")

    print("[4] non-vacuity: unperturbed witness passes the same path")
    full = GATE.check_full_set()
    non_vacuous = bool(
        full["m_equals_paper_fraction"]
        and full["nine_moduli_eq_m2"]
        and full["orthogonality_conj_l1_l4"]
    )
    checks["unperturbed_passes"] = non_vacuous
    print(f"    unperturbed ok: {non_vacuous}")

    ok = all(
        [
            checks["wrong_m_1e9_rejected"],
            checks["paper_bound_23_10000_passes"],
            checks["tight_bound_22_10000_rejected"],
            checks["perturbed_point_rejected"],
            checks["unperturbed_passes"],
        ]
    )
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL FAILURE"
    print(f"\nverdict: {verdict}")
    write_receipt(
        control="nla_ie16_control",
        gate="nla_ie16",
        verdict=verdict,
        checks=checks,
        ok=ok,
        extra={
            "note": (
                "Perturbations are matched: one value changed at a time "
                "(claimed m, claimed bound, one point), everything else "
                "fixed. Rejection comes from the gate's own exact checks, "
                "proving they read the witness rather than rubber-stamping."
            )
        },
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
