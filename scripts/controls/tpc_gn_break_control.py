"""Discrimination control for tpc_gn.

The gate says the Proposition 3.4 display is not one polynomial up to sign.
On the same two complete labelings, three neighboring claims stay put:

- both labelings are orientations of looped K_3, so they are in Phi(g);
- the absolute Vandermonde factor equals prod_k (k!)^n, the factor the
  display gets right;
- the product of differences over every pair of edges in looped K_3 is the
  same for both labelings, because that product does not see which tree
  owns which edge.

A checker that only asked whether P_g(sigma, y) is the zero polynomial
would accept both labelings and would not see the break. A checker that
only compared absolute Vandermonde factors would also accept them.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import tpc_gn as G  # noqa: E402
from receipt import write_receipt  # noqa: E402


def main() -> int:
    poly_a = G.packing_polynomial(G.G, G.SIGMA_A)
    poly_b = G.packing_polynomial(G.G, G.SIGMA_B)
    edges_a = G.edge_polynomials(G.G, G.SIGMA_A)
    edges_b = G.edge_polynomials(G.G, G.SIGMA_B)
    all_pairs_a = G.all_pairs_difference(edges_a)
    all_pairs_b = G.all_pairs_difference(edges_b)
    checks = {
        "both_labelings_are_in_phi": {
            "sigma_a": G.in_phi(G.G, G.SIGMA_A),
            "sigma_b": G.in_phi(G.G, G.SIGMA_B),
        },
        "factorial_factor_matches_vandermonde": {
            "printed": G.factorial_product(G.N),
            "abs_v_a": abs(G.vandermonde(G.SIGMA_A)),
            "abs_v_b": abs(G.vandermonde(G.SIGMA_B)),
        },
        "cross_tree_polynomials_differ_by_more_than_sign": (
            poly_a != poly_b and poly_a != G.scale(poly_b, -1)
        ),
        "both_polynomials_nonzero": any(poly_a) and any(poly_b),
        "all_pairs_product_ignores_the_partition": all_pairs_a == all_pairs_b,
        "y3_coefficients": {
            "sigma_a": G.coeff(poly_a, 3),
            "sigma_b": G.coeff(poly_b, 3),
        },
    }
    membership = checks["both_labelings_are_in_phi"]
    factorial = checks["factorial_factor_matches_vandermonde"]
    coeffs = checks["y3_coefficients"]
    ok = (
        membership["sigma_a"]
        and membership["sigma_b"]
        and factorial["printed"] == 8
        and factorial["abs_v_a"] == 8
        and factorial["abs_v_b"] == 8
        and checks["cross_tree_polynomials_differ_by_more_than_sign"]
        and checks["both_polynomials_nonzero"]
        and checks["all_pairs_product_ignores_the_partition"]
        and coeffs["sigma_a"] == -3072
        and coeffs["sigma_b"] == 6144
    )
    write_receipt(
        control="tpc_gn_break_control",
        gate="tpc_gn",
        verdict="NO FALSE POSITIVE" if ok else "CONTROL FAILED",
        checks=checks,
        ok=ok,
        extra={
            "note": (
                "The display's factorial factor and the full edge-set product "
                "agree on these two labelings. The cross-tree factor does not. "
                "A nonzero test would accept both."
            )
        },
    )
    print(f"[{'PASS' if ok else 'FAIL'}] tpc_gn_break_control")
    print(f"  y^3: {coeffs['sigma_a']} vs {coeffs['sigma_b']}")
    print(f"  all-pairs product agrees: {checks['all_pairs_product_ignores_the_partition']}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
