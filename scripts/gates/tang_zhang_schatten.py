"""Numeric gate: the Tang-Zhang Schatten-norm conjecture is FALSE at p=3/2,
m=2.

Source claim (corpus/live-fragile-proofs-2024-2026.md, Target Identifier
"Tang-Zhang Matrix Bounds, 2026 Refutation"; refutation Zeng, Z., Liu, H.,
Ratnavelu, K. (2026), "A counterexample to the Tang-Zhang Schatten norm
conjecture and sharp positive results," arXiv:2608.15558 [math.CO], PDF
pinned at incoming/tang-zhang-2608.15558.pdf).

NOTE ON PROVENANCE: the corpus doc's own narrative for this target is
corrupted -- several of its bullet points reference numbered inline images
(placeholders like "[63]") whose numeric content was never transcribed, so
the corpus doc alone cannot support a gate. This gate is built directly from
the pinned PDF's Theorem 1.1 and its equations (7)-(10), read via this
campaign's own PDF tool, not from the corpus doc's degraded paraphrase.

Setup (|A| = (A^T A)^{1/2}, ||A||_p = (Tr |A|^p)^{1/p}):

    c_p(m) = dimension-free best constant in  ||sum A_k||_p <= c(m) |||sum
    |A_k|||_p.  Tang and Zhang conjectured, for finite p>1, letting x_{p,m}
    > 1 solve  x^p - 2x - (m-1) = 0:

        C^TZ_{p,m} = sqrt(x_{p,m}(x_{p,m}+m-1)) / (x_{p,m}^p + m-1)^(1/p)

    as the dimension-free best constant for all p. Zeng-Liu-Ratnavelu
    disprove this for m=2, p=3/2 with two explicit real rank-one 2x2
    matrices:

        e = (1,0),  u = (39/40, sqrt(79)/40),  v = (5/8, sqrt(39)/8)
        A1 = e e^T,  A2 = u v^T

    and prove  ||A1+A2||_{3/2} / |||A1|+|A2|||_{3/2}  >  207/200  >
    C^TZ_{3/2,2}.

This gate reproduces the counterexample by two independent paths and cross-
checks them, then independently solves for x_{3/2,2} and re-evaluates
C^TZ_{3/2,2} from the conjectured formula (not copied from the paper's
Remark 2.1 numeric value).

Gates refute routes, not theorems: this does not claim anything about the
Tang-Zhang conjecture beyond the single (p, m) = (3/2, 2) instance computed
below (the paper itself proves the conjecture holds for 2<=p<infinity in
the rank-one case -- see Theorem 1.2, not gated here).
"""

from __future__ import annotations

import json
import math
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

import mpmath as mp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

mp.mp.dps = 60

BOUND = Fraction(207, 200)

# --- rational data defining the counterexample (Theorem 1.1, eq. 7) -------
# e = (1,0), u = (39/40, sqrt(79)/40), v = (5/8, sqrt(39)/8).
# Only the rational parts (first coordinates, and the squares of the second
# coordinates) are needed for the exact-Fraction path below.
U1, U2_SQ = Fraction(39, 40), Fraction(79, 1600)
V1, V2_SQ = Fraction(5, 8), Fraction(39, 64)


def sqrt_fraction(fr: Fraction) -> Fraction | None:
    """Exact rational square root if `fr` is a perfect square of rationals."""
    n, d = fr.numerator, fr.denominator
    sn, sd = math.isqrt(n), math.isqrt(d)
    if sn * sn == n and sd * sd == d:
        return Fraction(sn, sd)
    return None


def matmul2(a, b):
    return [
        [a[0][0] * b[0][0] + a[0][1] * b[1][0], a[0][0] * b[0][1] + a[0][1] * b[1][1]],
        [a[1][0] * b[0][0] + a[1][1] * b[1][0], a[1][0] * b[0][1] + a[1][1] * b[1][1]],
    ]


def exact_rational_path() -> dict:
    """Path A: reproduce eqs. (7)-(9) with fractions.Fraction only -- no
    square root of an irrational number ever touched.

    Unit-vector facts used (verified below, not assumed): e.e=1, u.u=1,
    v.v=1 (from the given rational squared second coordinates), so the
    Gram matrices L = U^T U, G = V^T V (U=(e,u), V=(e,v)) have entries
    L = [[1, e.u], [e.u, 1]], G = [[1, e.v], [e.v, 1]] with e.u = U1,
    e.v = V1 -- both rational, no sqrt needed for these particular dot
    products since e = (1,0).

    The squared singular values of A1+A2 = U V^T are the eigenvalues of
    L @ G (a rational 2x2 matrix); the eigenvalues of |A1|+|A2| = V V^T
    are 1 +/- V1 directly (trace 2, det 1-V1^2 factors as (1-V1)(1+V1)).
    """
    u_unit = (U1 * U1 + U2_SQ) == 1
    v_unit = (V1 * V1 + V2_SQ) == 1

    L = [[Fraction(1), U1], [U1, Fraction(1)]]
    G = [[Fraction(1), V1], [V1, Fraction(1)]]
    LG = matmul2(L, G)
    tr = LG[0][0] + LG[1][1]
    det = LG[0][0] * LG[1][1] - LG[0][1] * LG[1][0]
    disc = tr * tr - 4 * det
    root = sqrt_fraction(disc)
    disc_is_perfect_square = root is not None
    sigma1_sq = (tr + root) / 2
    sigma2_sq = (tr - root) / 2

    lam1 = 1 + V1
    lam2 = 1 - V1

    return {
        "u_unit": u_unit,
        "v_unit": v_unit,
        "LG": [[str(x) for x in row] for row in LG],
        "disc_is_perfect_square": disc_is_perfect_square,
        "sigma1_sq": sigma1_sq,
        "sigma2_sq": sigma2_sq,
        "lam1": lam1,
        "lam2": lam2,
        # cross-check against the paper's own eq. (8)-(9) values, not used
        # to derive our own -- ours are computed above from scratch.
        "matches_paper_eq_8_9": (
            sigma1_sq == Fraction(1027, 320)
            and sigma2_sq == Fraction(3, 320)
            and lam1 == Fraction(13, 8)
            and lam2 == Fraction(3, 8)
        ),
    }


def mpmath_direct_path() -> dict:
    """Path B: build the actual real matrices with sqrt(79), sqrt(39) at
    60 decimal digits and compute singular values via the symmetric 2x2
    eigenvalue formula applied to A^T A / |A1|+|A2| directly, entirely
    independently of path A's Gram-matrix algebra.
    """

    def outer(a, b):
        return [[a[0] * b[0], a[0] * b[1]], [a[1] * b[0], a[1] * b[1]]]

    def add(a, b):
        return [[a[0][0] + b[0][0], a[0][1] + b[0][1]], [a[1][0] + b[1][0], a[1][1] + b[1][1]]]

    def ata(m):
        a, b, c, d = m[0][0], m[0][1], m[1][0], m[1][1]
        return [[a * a + c * c, a * b + c * d], [a * b + c * d, b * b + d * d]]

    def sym_eig2(a):
        tr = a[0][0] + a[1][1]
        det = a[0][0] * a[1][1] - a[0][1] * a[1][0]
        disc = mp.sqrt(tr * tr - 4 * det)
        return (tr + disc) / 2, (tr - disc) / 2

    e = [mp.mpf(1), mp.mpf(0)]
    u = [mp.mpf(39) / 40, mp.sqrt(79) / 40]
    v = [mp.mpf(5) / 8, mp.sqrt(39) / 8]
    u_unit_err = abs(u[0] ** 2 + u[1] ** 2 - 1)
    v_unit_err = abs(v[0] ** 2 + v[1] ** 2 - 1)

    a1 = outer(e, e)
    a2 = outer(u, v)
    m_sum = add(a1, a2)
    n_sum = add(a1, outer(v, v))  # |A1|+|A2| = ee^T + vv^T

    sigma1_sq, sigma2_sq = sym_eig2(ata(m_sum))
    lam1, lam2 = sym_eig2(n_sum)

    r_32 = (sigma1_sq ** mp.mpf("0.75") + sigma2_sq ** mp.mpf("0.75")) / (
        lam1 ** mp.mpf("1.5") + lam2 ** mp.mpf("1.5")
    )
    r = r_32 ** (mp.mpf(2) / 3)

    return {
        "u_unit_err": mp.nstr(u_unit_err, 5),
        "v_unit_err": mp.nstr(v_unit_err, 5),
        "sigma1_sq": sigma1_sq,
        "sigma2_sq": sigma2_sq,
        "lam1": lam1,
        "lam2": lam2,
        "R": r,
    }


def conjectured_constant(p: mp.mpf, m: int) -> tuple[mp.mpf, mp.mpf]:
    """Independently solve x^p - 2x - (m-1) = 0 for x>1, then evaluate the
    Tang-Zhang formula (4). Returns (x_{p,m}, C^TZ_{p,m}).
    """

    def h(x):
        return x**p - 2 * x - (m - 1)

    x0 = mp.findroot(h, mp.mpf(m) + 1)
    c = mp.sqrt(x0 * (x0 + m - 1)) / (x0**p + m - 1) ** (1 / p)
    return x0, c


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    path_a = exact_rational_path()
    path_b = mpmath_direct_path()

    # Combine path A's exact rational squared-singular-values/eigenvalues
    # with high-precision fractional powers (the only step that is
    # genuinely irrational) to get a second, algebra-then-numerics R.
    s1 = mp.mpf(path_a["sigma1_sq"].numerator) / mp.mpf(path_a["sigma1_sq"].denominator)
    s2 = mp.mpf(path_a["sigma2_sq"].numerator) / mp.mpf(path_a["sigma2_sq"].denominator)
    l1 = mp.mpf(path_a["lam1"].numerator) / mp.mpf(path_a["lam1"].denominator)
    l2 = mp.mpf(path_a["lam2"].numerator) / mp.mpf(path_a["lam2"].denominator)
    r_32_from_a = (s1 ** mp.mpf("0.75") + s2 ** mp.mpf("0.75")) / (
        l1 ** mp.mpf("1.5") + l2 ** mp.mpf("1.5")
    )
    r_from_a = r_32_from_a ** (mp.mpf(2) / 3)

    r_from_b = path_b["R"]
    paths_agree = abs(r_from_a - r_from_b) < mp.mpf(10) ** -40

    bound = mp.mpf(BOUND.numerator) / mp.mpf(BOUND.denominator)
    r_exceeds_bound = r_from_a > bound
    margin_r = r_from_a - bound

    x_32, c_32 = conjectured_constant(mp.mpf(3) / 2, 2)
    c_below_bound = c_32 < bound
    margin_c = bound - c_32

    # Sanity floor well under the actual ~1e-4 / ~1e-3 margins reported by
    # the paper's Remark 2.1 -- not a tight threshold, just "not noise".
    safety_floor = mp.mpf(10) ** -20
    margins_safe = margin_r > safety_floor and margin_c > safety_floor

    ok = (
        path_a["u_unit"]
        and path_a["v_unit"]
        and path_a["disc_is_perfect_square"]
        and path_a["matches_paper_eq_8_9"]
        and paths_agree
        and r_exceeds_bound
        and c_below_bound
        and margins_safe
    )

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "tang_zhang_schatten",
        "source_claim": (
            "Tang-Zhang conjecture: C^TZ_{p,m} = sqrt(x(x+m-1))/(x^p+m-1)^(1/p), "
            "x>1 solving x^p-2x-(m-1)=0, is the dimension-free best constant "
            "in ||sum A_k||_p <= c(m) |||sum |A_k|||_p for all finite p>1"
        ),
        "source_refutation": "Zeng, Liu, Ratnavelu (2026), arXiv:2608.15558, Theorem 1.1",
        "corpus_pointer": "corpus/live-fragile-proofs-2024-2026.md",
        "local_pdf": "incoming/tang-zhang-2608.15558.pdf",
        "instance": "p=3/2, m=2",
        "path_a_exact_rational": {
            "u_unit": path_a["u_unit"],
            "v_unit": path_a["v_unit"],
            "disc_is_perfect_square": path_a["disc_is_perfect_square"],
            "sigma1_sq": str(path_a["sigma1_sq"]),
            "sigma2_sq": str(path_a["sigma2_sq"]),
            "lam1": str(path_a["lam1"]),
            "lam2": str(path_a["lam2"]),
            "matches_paper_eq_8_9": path_a["matches_paper_eq_8_9"],
        },
        "path_b_mpmath_direct": {
            "u_unit_err": path_b["u_unit_err"],
            "v_unit_err": path_b["v_unit_err"],
            "sigma1_sq": mp.nstr(path_b["sigma1_sq"], 30),
            "sigma2_sq": mp.nstr(path_b["sigma2_sq"], 30),
            "lam1": mp.nstr(path_b["lam1"], 30),
            "lam2": mp.nstr(path_b["lam2"], 30),
        },
        "R_from_path_a": mp.nstr(r_from_a, 30),
        "R_from_path_b": mp.nstr(r_from_b, 30),
        "paths_agree_to_1e-40": paths_agree,
        "bound_207_200": str(BOUND),
        "R_exceeds_bound": r_exceeds_bound,
        "margin_R_minus_bound": mp.nstr(margin_r, 10),
        "x_3_2_2": mp.nstr(x_32, 30),
        "C_TZ_3_2_2": mp.nstr(c_32, 30),
        "C_below_bound": c_below_bound,
        "margin_bound_minus_C": mp.nstr(margin_c, 10),
        "margins_safe": margins_safe,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": "R_{3/2,2} <= C^TZ_{3/2,2} (Tang-Zhang conjectured formula holds)",
        "false_instance": (
            f"R={mp.nstr(r_from_a, 15)} > 207/200 > "
            f"C^TZ_3/2,2={mp.nstr(c_32, 15)}"
        ),
        "ok": ok,
    }
    out = RESULTS / "tang_zhang_schatten_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] tang_zhang_schatten")
    print(f"  path A (exact Fraction): sigma^2={path_a['sigma1_sq']},{path_a['sigma2_sq']} "
          f"lam={path_a['lam1']},{path_a['lam2']} matches_paper={path_a['matches_paper_eq_8_9']}")
    print(f"  path B (mpmath, 60dps):  R={mp.nstr(r_from_b, 20)}")
    print(f"  R (from path A rationals, mpmath power step) = {mp.nstr(r_from_a, 20)}")
    print(f"  paths agree to 1e-40: {paths_agree}")
    print(f"  R > 207/200: {r_exceeds_bound}  (margin {mp.nstr(margin_r, 6)})")
    print(f"  x_3/2,2 = {mp.nstr(x_32, 20)}")
    print(f"  C^TZ_3/2,2 = {mp.nstr(c_32, 20)}")
    print(f"  C < 207/200: {c_below_bound}  (margin {mp.nstr(margin_c, 6)})")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
