"""Numeric gate: Yucai Su's claimed proof of the 2-dimensional Jacobian
conjecture, arXiv:1603.01867v43 (43 versions, 2016-2024, marked "FINAL" by
the author) -- CAS replay of the route's earliest checkable skeleton.

Source (corpus/Fragile-Route_Harvest_Dossier_II.md, Hit "JAC-2D"): claims the
route's "earliest pin" is Remark 2.7 together with the coefficient-comparison
chain culminating in Lemma 2.8's formula (2.41), and describes Remark 2.7 as
"deferring a key identity to 'a symbolic computation.'" Local PDF, live-checked
before download: incoming/jac2d-su-1603.01867v43.pdf (sha256
65634fc3a56a8d380b9ecf020e23667f5cb8d798b11ab2c7bfe1df2b83ec4224, 55 pages).

NOTE ON PROVENANCE: reading the real paper (not the dossier's paraphrase)
shows the dossier's framing is imprecise. Remark 2.7 is NOT an unproven
black-box outsourced to a CAS: the paper gives an inline hand proof (a
weight-counting argument on the u_i as formal variables of weight i,
immediately following the phrase "This follows from a symbolic computation").
The dossier's characterization conflates the author's one-sentence gesture at
*why* a CAS would confirm it with an actual deferral -- there is no deferral;
the proof is on the page. This gate therefore does not test "does the author's
CAS shortcut exist" (it doesn't, there's a real proof) but the honest version
of the dossier's Attack Type E/D idea: replay the coefficient identities
Remark 2.7 and Lemma 2.8 (eq. 2.41) actually assert, from scratch, and see if
they hold.

What is replayed.

(1) Remark 2.7 (general lemma, abstract from F,G): if U = 1 + sum u_i(x) t^i
    with deg_x u_i <= i, and beta is any rational, then U^beta = 1 + sum v_i
    t^i has deg_x v_i <= i; if additionally every deg_x u_i < i then every
    deg_x v_i < i. Tested with GENERIC (tight-degree) symbolic-coefficient
    u_i so the bound is actually exercised, not vacuously satisfied by
    low-degree inputs.

(2) Lemma 2.8 / eq. (2.41), tied to an actual Keller pair (F, G) -- a
    genuinely invertible polynomial map (so the constant-Jacobian hypothesis
    holds unconditionally, no conjecture needed) put in the paper's
    normalized form F = y^m(1 + sum f_i(x) y^-i), G = y^n(1 + sum g_i(x)
    y^-i), n | m. Writing G = sum_{a in A} c_a F^a (eq. 2.40, A = (n -
    Z_>=0)/m) and solving the resulting triangular system for the c_a order
    by order (exactly as the paper describes, "by comparing the coefficients
    of y^{n-i}"), the paper claims:
      (i)   c_a is a genuine constant (deg_x = 0) whenever a > (-m+1)/m
      (ii)  c_{-1} = 0
      (iii) deg_x c_{(-m+1-j)/m} <= j+1 for j >= 0
      (iv)  c_{(-m+1)/m} = -J_0/m * (x + a_1) for some constant a_1, where
            J_0 is the (here literally constant) Jacobian of F,G.
    Tested on two independent Keller pairs of different (m,n).

Discrimination control (scripts/controls/jac_2d_break_control.py): perturbs F
by a single monomial that breaks the constant-Jacobian hypothesis and shows
(i) and (iv) then fail on the SAME machinery -- the check is not a tautology.

Gates refute (or here, fail to refute) routes, not theorems: a PASS here
means this specific checkable skeleton survives replay, not that the paper's
55-page argument is correct end to end (per Governing discipline #3, a pass
escalates, it does not clear the paper). The dossier's own Fr=8 score (43
versions, no acceptance) stands as the fragility signal regardless of this
gate's outcome.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import sympy as sp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

X, T, Y = sp.symbols("x t y")


def series_pow(fhat: sp.Expr, alpha: sp.Rational, order: int) -> list[sp.Expr]:
    """fhat = 1 + O(t). Return the t^0..t^order coefficients of fhat**alpha."""
    expr = sp.series(fhat**alpha, T, 0, order + 1).removeO()
    poly = sp.Poly(sp.expand(expr), T)
    coeffs = [sp.Integer(0)] * (order + 1)
    for monom, c in poly.terms():
        d = monom[0]
        if d <= order:
            coeffs[d] = sp.expand(c)
    return coeffs


def solve_c(fhat: sp.Expr, ghat: sp.Expr, m: int, n: int, order: int) -> dict[int, sp.Expr]:
    """Solve  sum_i c_{(n-i)/m} t^i fhat^{(n-i)/m} = ghat  (mod t^{order+1})
    for c_i := c_{(n-i)/m}, i = 0..order, by the paper's own triangular
    coefficient-comparison (eq. 2.40's derivation)."""
    ghat_c = series_pow(ghat, sp.Integer(1), order)
    pow_cache = {i: series_pow(fhat, sp.Rational(n - i, m), order) for i in range(order + 1)}
    c: dict[int, sp.Expr] = {}
    for i in range(order + 1):
        rhs = ghat_c[i]
        for j in range(i):
            rhs -= c[j] * pow_cache[j][i - j]
        c[i] = sp.expand(rhs)
    return c


def jacobian(f: sp.Expr, g: sp.Expr) -> sp.Expr:
    return sp.expand(sp.diff(f, X) * sp.diff(g, Y) - sp.diff(f, Y) * sp.diff(g, X))


def to_normalized(expr_y: sp.Expr, deg: int) -> sp.Expr:
    """expr_y(x,y), a polynomial with leading y-term y^deg -> fhat(x,t) with
    t = 1/y, i.e. expr_y / y^deg with y -> 1/t."""
    return sp.expand((expr_y / Y**deg).subs(Y, 1 / T))


def check_instance(f_expr: sp.Expr, g_expr: sp.Expr, m: int, n: int, order: int) -> dict:
    """Build a Keller pair (F,G) in the paper's normalized form and check
    Lemma 2.8 / eq. (2.41) (i),(ii),(iii),(iv) against it."""
    j0 = jacobian(f_expr, g_expr)
    j0_is_constant = j0.free_symbols == set()

    fhat = to_normalized(f_expr, m)
    ghat = to_normalized(g_expr, n)
    c = solve_c(fhat, ghat, m, n, order)

    # index i <-> alpha = (n-i)/m ; alpha = -1 at i = n+m ; alpha=(-m+1)/m at i = n+m-1
    i_minus1 = n + m
    i_boundary = n + m - 1
    checks = {}

    c_minus1 = c.get(i_minus1)
    checks["c_minus1_is_zero"] = (c_minus1 is not None) and sp.simplify(c_minus1) == 0

    c_boundary = c.get(i_boundary)
    j_at_boundary = 0  # j=0 term of (2.41)(iii)/(iv)
    expected_boundary = sp.expand(-j0 / m * X) if j0_is_constant else None
    boundary_is_affine_in_x = False
    boundary_linear_coeff_matches = False
    if c_boundary is not None:
        cb_poly = sp.Poly(c_boundary, X) if c_boundary.free_symbols else None
        deg = cb_poly.degree() if cb_poly is not None else 0
        boundary_is_affine_in_x = deg <= 1
        if j0_is_constant and deg >= 0:
            coeff_x1 = sp.expand(c_boundary).coeff(X, 1)
            boundary_linear_coeff_matches = sp.simplify(coeff_x1 - (-j0 / m)) == 0
    checks["c_boundary_affine_in_x"] = boundary_is_affine_in_x
    checks["c_boundary_linear_coeff_matches_negJ0overM"] = boundary_linear_coeff_matches

    # (2.41)(i): constant for i < i_boundary (alpha > (-m+1)/m)
    all_constant_above_boundary = True
    for i in range(i_boundary):
        ci = c.get(i)
        if ci is not None and ci.free_symbols:
            all_constant_above_boundary = False
    checks["constants_above_boundary_i"] = all_constant_above_boundary

    # (2.41)(iii): deg_x c_{(-m+1-j)/m} <= j+1, i.e. at index i = i_boundary + j
    deg_bound_ok = True
    deg_bound_detail = []
    for j in range(0, order - i_boundary):
        i = i_boundary + j
        ci = c.get(i)
        if ci is None:
            continue
        deg = sp.Poly(ci, X).degree() if ci.free_symbols else 0
        deg_bound_detail.append({"j": j, "i": i, "deg_x": int(deg), "bound": j + 1})
        if deg > j + 1:
            deg_bound_ok = False
    checks["degree_bound_2_41_iii"] = deg_bound_ok

    return {
        "F": str(f_expr),
        "G": str(g_expr),
        "m": m,
        "n": n,
        "J0": str(j0),
        "J0_is_constant": j0_is_constant,
        "c_minus1": str(c_minus1),
        "c_boundary": str(c_boundary),
        "degree_bound_detail": deg_bound_detail,
        "checks": checks,
        "all_pass": all(checks.values()),
    }


def check_remark_2_7(order: int, beta: sp.Rational, strict: bool, seed: int) -> dict:
    """Remark 2.7 in the abstract, decoupled from any F,G: generic
    max-degree u_i (or one degree lower, for the strict (ii) variant),
    check deg_x v_i in U(t)^beta stays within the claimed bound."""
    import random

    rnd = random.Random(seed)
    u_expr = sp.Integer(1)
    for i in range(1, order + 1):
        top = i if not strict else i - 1
        coeffs = [rnd.randint(1, 5) for _ in range(top + 1)]
        u_expr += sum(cf * X**k for k, cf in enumerate(coeffs)) * T**i

    v = series_pow(u_expr, beta, order)
    detail = []
    ok = True
    for i in range(1, order + 1):
        vi = v[i]
        deg = sp.Poly(vi, X).degree() if vi.free_symbols else (0 if vi != 0 else -1)
        bound = (i - 1) if strict else i
        detail.append({"i": i, "deg_x": int(deg), "bound": int(bound)})
        if deg > bound:
            ok = False
    return {"beta": str(beta), "strict": strict, "detail": detail, "ok": ok}


def check_discrimination_note() -> None:
    """The full discrimination control lives in
    scripts/controls/jac_2d_break_control.py (instrument, not a gate, per
    docs/GATE-BEFORE-PROVE.md)."""


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    order = 10

    # Instance 1: F = (y^2+x)^2 + y = y^4 + 2xy^2 + x^2 + y, G = y^2 + x.
    # Genuinely invertible: y = F - G^2, x = G - y^2 -- a real Keller pair,
    # constant Jacobian holds unconditionally (no conjecture invoked).
    g1 = Y**2 + X
    f1 = sp.expand(g1**2 + Y)
    inst1 = check_instance(f1, g1, m=4, n=2, order=order)

    # Instance 2: same construction one level up, F = (y^3+x)^2+y, G=y^3+x.
    g2 = Y**3 + X
    f2 = sp.expand(g2**2 + Y)
    inst2 = check_instance(f2, g2, m=6, n=3, order=order)

    rem_i = check_remark_2_7(order=8, beta=sp.Rational(1, 3), strict=False, seed=0)
    rem_ii = check_remark_2_7(order=8, beta=sp.Rational(2, 5), strict=True, seed=1)

    ok = inst1["all_pass"] and inst2["all_pass"] and rem_i["ok"] and rem_ii["ok"]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "jac_2d",
        "source_claim": (
            "Yucai Su, 'Generalizations of local bijectivity of Keller maps "
            "and a proof of 2-dimensional Jacobian conjecture', arXiv:1603.01867v43 "
            "(43 versions, 2016-2024, FINAL)"
        ),
        "corpus_pointer": "corpus/Fragile-Route_Harvest_Dossier_II.md, Hit JAC-2D",
        "local_pdf": "incoming/jac2d-su-1603.01867v43.pdf",
        "local_pdf_sha256": "65634fc3a56a8d380b9ecf020e23667f5cb8d798b11ab2c7bfe1df2b83ec4224",
        "provenance_note": (
            "Dossier describes Remark 2.7 as deferring a key identity to 'a symbolic "
            "computation'. The pinned PDF shows Remark 2.7 has an inline hand proof "
            "(weight-counting argument) immediately after that phrase -- not a deferral. "
            "This gate replays the identities themselves (Remark 2.7 and Lemma 2.8 / "
            "eq. 2.41), not a claimed-but-absent CAS shortcut."
        ),
        "instance_1": inst1,
        "instance_2": inst2,
        "remark_2_7_part_i": rem_i,
        "remark_2_7_part_ii": rem_ii,
        "lemma": "Remark 2.7 and Lemma 2.8 (eq. 2.41), the route's earliest checkable skeleton",
        "verdict": "PASS" if ok else "BREAK",
        "ok": ok,
    }
    out = RESULTS / "jac_2d_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] jac_2d")
    print(f"  instance 1 (m=4,n=2): all_pass={inst1['all_pass']}  checks={inst1['checks']}")
    print(f"  instance 2 (m=6,n=3): all_pass={inst2['all_pass']}  checks={inst2['checks']}")
    print(f"  Remark 2.7(i) beta=1/3: ok={rem_i['ok']}")
    print(f"  Remark 2.7(ii) beta=2/5 strict: ok={rem_ii['ok']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
