"""Discrimination control for krr_cl.

The gate says the Q^{[1]} congruence on page 27 is not an identity, at one
normalized path. The same Lagrange factor, on a single node of Z_4, is the
Kronecker delta. The same substitution, on the P_g formula printed above the
congruence, matches ±C on Phi(g) and 0 off it. The telescoping step that
feeds the binomial expansion is an identity on this same f.

A checker that doubled every Lagrange factor would still see 64 != 128, and
would fail the single-node delta. A checker that only reconfirmed
score(f) = 4 would not be evidence about the congruence.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import krr_cl as G  # noqa: E402
from receipt import write_receipt  # noqa: E402


def kronecker_lagrange() -> dict:
    """L(x; 3) on Z_4 is 1 at 3 and 0 at 0, 1, 2."""
    values = [G.lagrange_at(i, 3, 4) for i in range(4)]
    return {
        "values": [str(v) for v in values],
        "is_delta": values == [Fraction(0), Fraction(0), Fraction(0), Fraction(1)],
    }


def main() -> int:
    left, right = G.congruence_sides(G.F, G.SIGMA)
    delta = kronecker_lagrange()
    formula = G.evaluation_formula_holds(G.F)
    telescope = G.telescoping_holds(G.F)
    shifted = G.telescoping_difference(G.F, len(G.F) - 2)
    scores = {"f": G.score(G.F), "g": G.score(G.partial_iterate(G.F))}
    checks = {
        "congruence_is_64_against_128": {
            "left": str(left),
            "right": str(right),
            "unequal": left == 64 and right == 128 and left != right,
        },
        "same_page_evaluation_formula_holds": formula,
        "lagrange_factor_is_kronecker": delta,
        "telescoping_identity": telescope,
        "shifted_anchor_is_not_identity": shifted != {},
        "scores_equal_n": scores["f"] == 4 and scores["g"] == 4,
        "normalized_diameter_at_least_3": (
            G.normalized_path(G.F) and G.diameter(G.F) >= 3
        ),
    }
    ok = (
        checks["congruence_is_64_against_128"]["unequal"]
        and formula
        and delta["is_delta"]
        and telescope
        and shifted != {}
        and checks["scores_equal_n"]
        and checks["normalized_diameter_at_least_3"]
    )
    write_receipt(
        control="krr_cl_break_control",
        gate="krr_cl",
        verdict="NO FALSE POSITIVE" if ok else "CONTROL FAILED",
        checks=checks,
        ok=ok,
        extra={
            "why": (
                "The Q^{[1]} sum double-counts a repeated coordinate pair. "
                "The Lagrange factor itself, the P_g formula above the "
                "congruence, and the telescoping step all match."
            )
        },
    )
    print(f"[{'PASS' if ok else 'FAIL'}] krr_cl_break_control")
    print(f"  congruence {left} vs {right}; P_g formula {formula}; delta {delta['is_delta']}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
