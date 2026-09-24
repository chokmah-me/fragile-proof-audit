"""Numeric gate (Type A): Holden's nine-point GMRES subset-bound counterexample.

Source claim (pinned PDF incoming/nla-ie16-holden.pdf, Sidney Holden,
"IE-16: A counterexample and the failure of every universal subset
constant", September 2026):

    R_4(L_{1/1000}) > 13/10 > 4/pi,

where L_eps = {w^a + eps*w^b : a,b in {0,1,2}}, w = e^{2 pi i/3},
eps = 1/1000, M_4(E) = min{||p||_E : deg p <= 4, p(0) = 1},
B_4(E) = max_{|S|=5} M_4(S), R_4(E) = M_4(E)/B_4(E).

The gate replays the paper's exact-arithmetic certificate (Section 6,
code/verify.py) in re-derived form. All arithmetic is exact: points live in
Q(w) represented in the basis {1, w} (Fractions; w^2 = -1-w), and every
modulus uses |x + y w|^2 = x^2 - x y + y^2.

Load-bearing checks:

1. Full-set value M_4(L) = m exactly, where m = 3 eps (1+eps+eps^2)/D,
   D = 1+eps+3 eps^2+eps^3+eps^4:
   (a) m equals the paper's exact fraction 3003003000/1001003001001;
   (b) the polynomial p*(z) = 1 - ((1+eps)/D) z^3 attains |p*| = m at all
       nine points (nine exact residual-modulus identities);
   (c) positive weights nu certify optimality: with mu_0 = H/(3D),
       mu_1 = mu_2 = Q/(3D), nu_{a,b} = mu_{(b-a) mod 3}/3,
       sum nu_{a,b} conj(p*(z_{a,b})) z_{a,b}^l = 0 for l = 1..4.
       NOTE: the paper's displayed identity (13) omits the conjugation on
       p*; as printed it is false at l = 3 (off by ~9e-6). The conjugated
       identity is what the paper's own l = 3 computation verifies
       (mu_0 U (1+c*U) + (1-mu_0)(V + c*(V^2+W^2)) = 0, checked exactly
       here) and what the optimality identity (14) actually needs.
       Harmless expositional slip; the computation underneath is correct.
   (a)-(c) give M_4(L) = m exactly (m > 299/100000, exact).

2. Subset bound B_4(L) < 23/10000: for each of the 126 five-point subsets,
   Lemma 2.1 gives M_4(S) = (sum_j prod_{h != j} |z_h|/|z_j - z_h|)^{-1}.
   The gate lower-bounds each Lagrange sum rigorously: each term is
   sqrt(A_j/B_j) for positive integers A_j, B_j (exact), bounded below by
   isqrt(A_j*B_j)/B_j. All 126 sums exceed 10000/23, so every
   M_4(S) < 23/10000. Corroboration: the cluster-occupancy profile counts
   are 81/27/18, matching the paper.

3. Ratio: R_4 > (299/100000)/(23/10000) = 299/230 = 13/10.
   13/10 > 4/pi via a certified pi > 3.1415 (Machin identity with
   alternating-series remainder bounds, exact rational arithmetic).

Gates refute routes, not theorems: a PASS here says the finite nine-point
witness is exactly as claimed. Theorem 1.2 (no universal finite constant,
via the amplification lemma) is analytic and informal-only; it is not
gated here.
"""

from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from fractions import Fraction
from itertools import combinations
from math import isqrt
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

EPS = Fraction(1, 1000)

# ---------------------------------------------------------------------------
# Exact arithmetic in Q(w), basis {1, w}, w^2 = -1 - w.
# ---------------------------------------------------------------------------

Pt = tuple  # (x, y) meaning x + y*w, x,y Fractions


def _add(p, q):
    return (p[0] + q[0], p[1] + q[1])


def _mul(p, q):
    x1, y1 = p
    x2, y2 = q
    return (x1 * x2 - y1 * y2, x1 * y2 + x2 * y1 - y1 * y2)


def _conj(p):
    # conj(x + y w) = x + y w^2 = x + y(-1-w) = (x-y) - y w
    x, y = p
    return (x - y, -y)


def _pwr(p, n: int):
    r = (Fraction(1), Fraction(0))
    for _ in range(n):
        r = _mul(r, p)
    return r


def _norm2(p) -> Fraction:
    # |x + y w|^2 = x^2 - x y + y^2
    x, y = p
    return x * x - x * y + y * y


def _is_zero(p) -> bool:
    return p[0] == 0 and p[1] == 0


# ---------------------------------------------------------------------------
# Paper quantities (all exact Fractions).
# ---------------------------------------------------------------------------

D = 1 + EPS + 3 * EPS**2 + EPS**3 + EPS**4
H = 1 - 3 * EPS + EPS**2 - 3 * EPS**3 + EPS**4
Q_ = (1 + EPS) ** 2 * (1 + EPS + EPS**2)
CSTAR = -(1 + EPS) / D
M = 3 * EPS * (1 + EPS + EPS**2) / D

MU = [H / (3 * D), Q_ / (3 * D), Q_ / (3 * D)]

_ONE = (Fraction(1), Fraction(0))
_W = (Fraction(0), Fraction(1))
_W2 = (-Fraction(1), -Fraction(1))
_WPOWS = [_ONE, _W, _W2]

POINTS: dict[tuple[int, int], tuple] = {
    (a, b): _add(_WPOWS[a], (EPS * _WPOWS[b][0], EPS * _WPOWS[b][1]))
    for a in range(3)
    for b in range(3)
}
PT_LIST = [POINTS[(a, b)] for a in range(3) for b in range(3)]

NU: dict[tuple[int, int], Fraction] = {
    (a, b): MU[(b - a) % 3] / 3 for a in range(3) for b in range(3)
}

M_PAPER = Fraction(3003003000, 1001003001001)


def _pstar(z):
    z3 = _pwr(z, 3)
    return _add(_ONE, (CSTAR * z3[0], CSTAR * z3[1]))


# ---------------------------------------------------------------------------
# Check 1: full-set value M_4(L) = m exactly.
# ---------------------------------------------------------------------------


def check_full_set() -> dict:
    checks: dict[str, object] = {}

    checks["m_equals_paper_fraction"] = M == M_PAPER
    checks["m_gt_299_100000"] = M > Fraction(299, 100000)
    checks["H_plus_2Q_eq_3D"] = H + 2 * Q_ == 3 * D

    # Nine points distinct and nonzero.
    seen = set()
    distinct_nonzero = True
    for z in PT_LIST:
        if _norm2(z) == 0:
            distinct_nonzero = False
        key = (z[0], z[1])
        if key in seen:
            distinct_nonzero = False
        seen.add(key)
    checks["nine_points_distinct_nonzero"] = distinct_nonzero and len(seen) == 9

    # p* attains modulus m at all nine points (exact).
    m2 = M * M
    bad_mod = [
        key for key, z in POINTS.items() if _norm2(_pstar(z)) != m2
    ]
    checks["nine_moduli_eq_m2"] = not bad_mod
    checks["nine_moduli_bad_points"] = bad_mod

    # Weights positive, sum to one.
    checks["mu_positive_sum_one"] = all(x > 0 for x in MU) and sum(MU) == 1
    checks["nu_positive_sum_one"] = all(x > 0 for x in NU.values()) and sum(
        NU.values()
    ) == 1

    # Optimality certificate: sum nu conj(p*(z)) z^l = 0 for l = 1..4.
    # (Paper's (13) as printed omits the conjugation; the conjugated form is
    # what its own l=3 computation verifies and what (14) needs.)
    ortho_bad = []
    for ell in range(1, 5):
        s = (Fraction(0), Fraction(0))
        for key, z in POINTS.items():
            t = _mul(_conj(_pstar(z)), _pwr(z, ell))
            n = NU[key]
            s = _add(s, (n * t[0], n * t[1]))
        if not _is_zero(s):
            ortho_bad.append(ell)
    checks["orthogonality_conj_l1_l4"] = not ortho_bad
    checks["orthogonality_bad_l"] = ortho_bad

    # The paper's own l=3 reduction, verified exactly (uses W^2 rational).
    U = (1 + EPS) ** 3
    V = 1 - Fraction(3, 2) * EPS - Fraction(3, 2) * EPS**2 + EPS**3
    W2_ = Fraction(27, 4) * (EPS - EPS**2) ** 2  # W^2, exact
    mu0, mu1 = MU[0], MU[1]
    checks["paper_l3_cancellation_exact"] = (
        mu0 * U * (1 + CSTAR * U) + (1 - mu0) * (V + CSTAR * (V**2 + W2_))
        == 0
    )
    checks["one_plus_cstarU_eq_neg_m"] = 1 + CSTAR * U == -M

    return checks


# ---------------------------------------------------------------------------
# Check 2: subset bound B_4(L) < 23/10000 via rigorous Lagrange sums.
# ---------------------------------------------------------------------------


def _lagrange_sum_lower(S: tuple[int, ...]) -> Fraction:
    """Rigorous lower bound on sum_j prod_{h != j} |z_h|/|z_j - z_h|.

    Each term is sqrt(A/B) for positive integers A, B (exact); bounded below
    by isqrt(A*B)/B. Hence the returned Fraction is <= the true Lagrange
    sum, i.e. 1/returned >= M_4(S).
    """
    total = Fraction(0)
    for j in S:
        zj = PT_LIST[j]
        num = Fraction(1)
        den = Fraction(1)
        for h in S:
            if h == j:
                continue
            zh = PT_LIST[h]
            num *= _norm2(zh)
            dz = (zj[0] - zh[0], zj[1] - zh[1])
            den *= _norm2(dz)
        r = num / den
        A, B = r.numerator, r.denominator
        total += Fraction(isqrt(A * B), B)
    return total


def check_subsets() -> dict:
    checks: dict[str, object] = {}
    # Need lagrange sum > 10000/23 for M_4(S) < 23/10000.
    thresh = Fraction(10000, 23)
    n_checked = 0
    bad: list[tuple] = []
    min_sum: Fraction | None = None
    # Corroboration: cluster-occupancy profiles (paper: 81/27/18).
    prof_counts: dict[tuple, int] = {}
    for S in combinations(range(9), 5):
        n_checked += 1
        s = _lagrange_sum_lower(S)
        if min_sum is None or s < min_sum:
            min_sum = s
        if not s > thresh:
            bad.append(S)
        prof = tuple(
            sorted(
                sum(1 for j in S if (j // 3) == ca) for ca in range(3)
            )
        )
        prof_counts[prof] = prof_counts.get(prof, 0) + 1
    checks["subsets_checked_126"] = n_checked == 126
    checks["all_lagrange_sums_above_threshold"] = not bad
    checks["subsets_failing"] = [list(s) for s in bad[:5]]
    checks["min_lagrange_sum_num_den"] = (
        (min_sum.numerator, min_sum.denominator) if min_sum is not None else None
    )
    # Implied rigorous upper bound on B_4.
    checks["implied_B4_upper_lt_23_10000"] = (
        min_sum is not None and Fraction(1, 1) / min_sum < Fraction(23, 10000)
    )
    checks["profile_counts"] = {str(k): v for k, v in prof_counts.items()}
    checks["profile_counts_match_paper_81_27_18"] = prof_counts == {
        (1, 2, 2): 81,
        (1, 1, 3): 27,
        (0, 2, 3): 18,
    }
    return checks


# ---------------------------------------------------------------------------
# Check 3: ratio chain R_4 > 13/10 > 4/pi.
# ---------------------------------------------------------------------------


def _atan_bounds(x_num: int, x_den: int, nterms: int):
    """Lower/upper bounds on arctan(x_num/x_den) from the alternating series.

    Terms decrease, so odd partial sums bound below, even above.
    """
    x = Fraction(x_num, x_den)
    s = Fraction(0)
    lo = hi = None
    for k in range(nterms + 1):
        s += Fraction((-1) ** k) * x ** (2 * k + 1) / (2 * k + 1)
        if k % 2 == 0:
            hi = s
        else:
            lo = s
    return lo, hi


def check_ratio() -> dict:
    checks: dict[str, object] = {}
    # R_4 = M_4/B_4 > (299/100000)/(23/10000) = 299/230 = 13/10.
    checks["ratio_gt_13_10"] = Fraction(299, 100000) / Fraction(
        23, 10000
    ) == Fraction(13, 10)
    # 13/10 > 4/pi  <=>  pi > 40/13; certify pi > 3.1415 via Machin.
    lo5, hi5 = _atan_bounds(1, 5, 12)
    lo239, hi239 = _atan_bounds(1, 239, 4)
    pi_lo = 4 * (4 * lo5 - hi239)
    pi_hi = 4 * (4 * hi5 - lo239)
    checks["pi_lower_bound_gt_3_1415"] = pi_lo > Fraction(31415, 10000)
    checks["thirteen_tenths_gt_4_over_pi"] = Fraction(13, 10) > Fraction(
        4, 1
    ) / pi_lo
    checks["pi_enclosure"] = (float(pi_lo), float(pi_hi))
    return checks


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    full = check_full_set()
    subs = check_subsets()
    ratio = check_ratio()

    scalar_checks = {
        k: v
        for d in (full, subs, ratio)
        for k, v in d.items()
        if k
        not in (
            "nine_moduli_bad_points",
            "orthogonality_bad_l",
            "subsets_failing",
            "min_lagrange_sum_num_den",
            "profile_counts",
            "pi_enclosure",
        )
    }
    ok = all(v is True for v in scalar_checks.values())

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "nla_ie16",
        "source_claim": (
            "Holden (2026): nine-point set L_{1/1000} at degree 4 gives "
            "R_4 = M_4/B_4 > 13/10 > 4/pi, refuting the IE-16 subset bound"
        ),
        "local_pdf": "incoming/nla-ie16-holden.pdf",
        "local_pdf_sha256": "a28b181ac1eab457bbae3d609eff91d7800a33c8a69dec669ba9e08679964ff4",
        "paper_exact_M4": "3003003000/1001003001001",
        "paper_subset_bound": "B_4 < 23/10000",
        "paper_ratio_approx": "1.33299891979475829424",
        "checks": {**full, **subs, **ratio},
        "verdict": "PASS" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "M_4(L_{1/1000}) = 3003003000/1001003001001 > 299/100000 and "
            "B_4(L_{1/1000}) < 23/10000, hence R_4 > 13/10 > 4/pi"
        ),
        "false_instance": None if ok else "witness failed exact check",
        "ok": ok,
    }
    out = RESULTS / "nla_ie16_gate_meta.json"
    import json

    out.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] nla_ie16")
    print(f"  M4 == paper fraction: {full['m_equals_paper_fraction']}")
    print(f"  nine moduli / orthogonality: "
          f"{full['nine_moduli_eq_m2']} / {full['orthogonality_conj_l1_l4']}")
    print(f"  subsets: {subs['subsets_checked_126']} checked, "
          f"all above threshold: {subs['all_lagrange_sums_above_threshold']}, "
          f"profiles 81/27/18: {subs['profile_counts_match_paper_81_27_18']}")
    print(f"  ratio chain 13/10 > 4/pi: {ratio['thirteen_tenths_gt_4_over_pi']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
