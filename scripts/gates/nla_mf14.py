"""Numeric gate (Type E): Webb's exact degree-47 seven-product certificate.

Source claim (pinned PDF incoming/nla-mf14-webb.pdf, Marcus Webb,
"The exact seven-product closure degree is forty-seven", 17 Sep 2026):
Theorem 1: d7 = 47. The load-bearing computational claim is Lemma 3
(certified contact): the 49-parameter seven-product family Phi has a
point z* with F(z*) = 0 and det J(z*) != 0, where

    F(z) = ([x^0]Phi(iota(z)), ..., [x^47]Phi(iota(z)))^T - (0,...,0,1)^T,

certified by exact Gaussian-rational inequalities at the seed center zc:

    eps   = ||B F(zc)||       < 1e-69
    delta = ||I - B J(zc)||   < 1e-57
    ||B|| < 4000,  H < 2e12
    q = delta + ||B|| H r < 1e-29,  eps + q r < r    (r = 1e-45)
    |Re(bc) - 2| > r                                    (b != 2)

which feed Banach's fixed-point theorem (paper Sec. 3).

The gate replays the author's
source/experiments/lower_full49_certify.py in re-derived form: the
circuit is rebuilt from the paper's equations (2)-(5) (never imported),
evaluated with exact forward-mode automatic differentiation over the 48
active parameters in C[x]/(x^48), and the (v, d, h) Hessian majorant of
Sec. 3 (eq. 13) is propagated independently. All arithmetic is exact
(Fraction-based Gaussian rationals); |w|_1 = |Re w| + |Im w|, vector
norm = max entry norm, matrix norm = max row sum.

Scope: the gate covers Lemma 3's certificate. Proposition 4 (inverse
function + scaling to full V47 coverage) and Lemma 5 (dim X7 <= 49, hence
d7 = 47 together with x^128 in P7) are analytic and not gated.
Gates refute routes, not theorems: PASS says the exact contact
certificate is as claimed.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
SEED_PATH = ROOT / "incoming" / "nla-mf14-seed.json"

NCOEF = 48          # equations: coefficients of x^0 .. x^47
NPAR = 48           # active parameters
R = Fraction(1, 10**45)
THETA_DEN = 10**70
INV_DEN = 10**60

# Appendix A active-coordinate order (every index except 48 = e8, fixed).
ACTIVE_APPENDIX_A = [
    4, 3, 14, 18, 19, 5, 34, 36, 35, 10, 25, 0,
    15, 20, 23, 22, 28, 29, 8, 45, 37, 40, 41, 43,
    42, 44, 7, 46, 30, 11, 1, 24, 21, 2, 31, 16,
    9, 47, 6, 27, 12, 38, 39, 26, 17, 33, 13, 32,
]

# Parameter block layout, Table 1 (zero-based).
I_ALPHA, I_B, I_C, I_ETA = 0, 1, 2, 3
I_U4 = (4, 5, 6)
I_V4 = (7, 8, 9)
I_U5 = (10, 11, 12, 13)
I_V5 = (14, 15, 16, 17)
I_U6 = (18, 19, 20, 21, 22)
I_V6 = (23, 24, 25, 26, 27)
I_U7 = (28, 29, 30, 31, 32, 33)
I_V7 = (34, 35, 36, 37, 38, 39)
I_E = tuple(range(40, 49))  # e0..e8


# ---------------------------------------------------------------------------
# Exact Gaussian rationals: (re, im) of Fractions.
# ---------------------------------------------------------------------------

ZERO = (Fraction(0), Fraction(0))
ONE = (Fraction(1), Fraction(0))


def gadd(a, b):
    return (a[0] + b[0], a[1] + b[1])


def gsub(a, b):
    return (a[0] - b[0], a[1] - b[1])


def gmul(a, b):
    return (a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0])


def gnorm1(a):
    return abs(a[0]) + abs(a[1])


def is_zero(a):
    return a[0] == 0 and a[1] == 0


# ---------------------------------------------------------------------------
# Polynomials mod x^NCOEF with forward-mode AD over the active parameters.
# A node is (val, der): val = list of NCOEF Gaussian rationals,
# der[p] = list of NCOEF Gaussian rationals, p = 0..NPAR-1.
# ---------------------------------------------------------------------------


def _conv_trunc(a, b):
    n = NCOEF
    c = [ZERO] * n
    for i, ai in enumerate(a):
        if is_zero(ai):
            continue
        # j ranges so i + j < n
        for j in range(n - i):
            bj = b[j]
            if is_zero(bj):
                continue
            c[i + j] = gadd(c[i + j], gmul(ai, bj))
    return c


def padd(A, B):
    v = [gadd(a, b) for a, b in zip(A[0], B[0])]
    d = [[gadd(x, y) for x, y in zip(da, db)] for da, db in zip(A[1], B[1])]
    return (v, d)


def pmul(A, B):
    av, ad = A
    bv, bd = B
    v = _conv_trunc(av, bv)
    d = []
    for p in range(NPAR):
        t1 = _conv_trunc(av, bd[p])
        t2 = _conv_trunc(bv, ad[p])
        d.append([gadd(x, y) for x, y in zip(t1, t2)])
    return (v, d)


def pscale(c, A):
    v = [gmul(c, a) for a in A[0]]
    d = [[gmul(c, x) for x in da] for da in A[1]]
    return (v, d)


def monomial(k):
    v = [ZERO] * NCOEF
    v[k] = ONE
    return (v, [[ZERO] * NCOEF for _ in range(NPAR)])


def param_node(theta, j, active_pos):
    """Constant-polynomial node for theta_j; derivative only if active."""
    v = [ZERO] * NCOEF
    v[0] = theta[j]
    d = [[ZERO] * NCOEF for _ in range(NPAR)]
    if j in active_pos:
        d[active_pos[j]][0] = ONE
    return (v, d)


def lincomb(base, coeff_idx, rlist, theta, active_pos):
    """base + sum_j theta[coeff_idx[j]] * rlist[j]."""
    acc = base
    for cj, r in zip(coeff_idx, rlist):
        acc = padd(acc, pmul(param_node(theta, cj, active_pos), r))
    return acc


# ---------------------------------------------------------------------------
# Seed loading.
# ---------------------------------------------------------------------------


def load_seed():
    raw = SEED_PATH.read_bytes()
    sha = hashlib.sha256(raw).hexdigest()
    s = json.loads(raw)
    assert s["degree"] == 47, "seed degree field"
    assert len(s["active_parameters"]) == NPAR
    assert s["active_parameters"] == ACTIVE_APPENDIX_A, "active order vs App. A"
    assert int(s["theta_denominator"]) == THETA_DEN
    assert int(s["inverse_denominator"]) == INV_DEN
    assert len(s["theta_numerators"]) == 49
    assert len(s["inverse_numerators"]) == NPAR
    assert all(len(row) == NPAR for row in s["inverse_numerators"])
    theta = [
        (Fraction(int(re), THETA_DEN), Fraction(int(im), THETA_DEN))
        for re, im in s["theta_numerators"]
    ]
    B = [
        [
            (Fraction(int(re), INV_DEN), Fraction(int(im), INV_DEN))
            for re, im in row
        ]
        for row in s["inverse_numerators"]
    ]
    return theta, B, sha


# ---------------------------------------------------------------------------
# Circuit (paper eqs. 2-5), values + Jacobian.
# ---------------------------------------------------------------------------


def build_circuit(theta, active_pos):
    x = monomial(1)
    x2 = monomial(2)
    x3 = monomial(3)
    x4 = monomial(4)
    q1 = pmul(x, x)                                        # x^2
    alpha = param_node(theta, I_ALPHA, active_pos)
    b = param_node(theta, I_B, active_pos)
    c = param_node(theta, I_C, active_pos)
    eta = param_node(theta, I_ETA, active_pos)
    Q = padd(x4, pmul(alpha, x3))                          # x^4 + a x^3
    Q2 = pmul(Q, Q)
    R = padd(
        padd(Q2, pmul(b, pmul(x2, Q))),
        padd(pmul(c, pmul(x, Q)), pmul(eta, x3)),
    )
    q4 = pmul(
        lincomb(R, I_U4, [x, q1, Q], theta, active_pos),
        lincomb(R, I_V4, [x, q1, Q], theta, active_pos),
    )
    q5 = pmul(
        lincomb(q4, I_U5, [x, q1, Q, R], theta, active_pos),
        lincomb(q4, I_V5, [x, q1, Q, R], theta, active_pos),
    )
    q6 = pmul(
        lincomb(q5, I_U6, [x, q1, Q, R, q4], theta, active_pos),
        lincomb(q5, I_V6, [x, q1, Q, R, q4], theta, active_pos),
    )
    q7 = pmul(
        lincomb(q6, I_U7, [x, q1, Q, R, q4, q5], theta, active_pos),
        lincomb(q6, I_V7, [x, q1, Q, R, q4, q5], theta, active_pos),
    )
    Phi = param_node(theta, I_E[0], active_pos)
    Phi = padd(Phi, pmul(param_node(theta, I_E[1], active_pos), x))
    for ek, qk in zip(I_E[2:], [q1, Q, R, q4, q5, q6, q7]):
        Phi = padd(Phi, pmul(param_node(theta, ek, active_pos), qk))
    return Phi


# ---------------------------------------------------------------------------
# Hessian majorant: scalar (v, d, h) triples, paper eq. 13.
# v bounds the coefficient norm, d the summed first-derivative norms,
# h the summed ordered second-derivative norms, uniformly on the r-ball.
# ---------------------------------------------------------------------------


def build_majorant(theta):
    # leaf triples: (v, d, h)
    def tparam(j):
        n1 = gnorm1(theta[j])
        if j == 48 or j not in ACTIVE_APPENDIX_A:
            return (n1, Fraction(0), Fraction(0))
        return (n1 + R, Fraction(1), Fraction(0))

    def tadd(A, B):
        return (A[0] + B[0], A[1] + B[1], A[2] + B[2])

    def tmul(A, B):
        v = A[0] * B[0]
        d = A[1] * B[0] + A[0] * B[1]
        h = A[2] * B[0] + 2 * A[1] * B[1] + A[0] * B[2]
        return (v, d, h)

    MON = (Fraction(1), Fraction(0), Fraction(0))  # fixed monomial
    p = {j: tparam(j) for j in range(49)}

    def lin(tbase, cidx, rlist):
        acc = tbase
        for cj, r in zip(cidx, rlist):
            acc = tadd(acc, tmul(p[cj], r))
        return acc

    q1 = tmul(MON, MON)
    Q = tadd(MON, tmul(p[I_ALPHA], MON))
    Q2 = tmul(Q, Q)
    RR = tadd(tadd(Q2, tmul(p[I_B], tmul(MON, Q))),
               tadd(tmul(p[I_C], tmul(MON, Q)), tmul(p[I_ETA], MON)))
    q4 = tmul(lin(RR, I_U4, [MON, q1, Q]), lin(RR, I_V4, [MON, q1, Q]))
    q5 = tmul(lin(q4, I_U5, [MON, q1, Q, RR]), lin(q4, I_V5, [MON, q1, Q, RR]))
    q6 = tmul(lin(q5, I_U6, [MON, q1, Q, RR, q4]),
              lin(q5, I_V6, [MON, q1, Q, RR, q4]))
    q7 = tmul(lin(q6, I_U7, [MON, q1, Q, RR, q4, q5]),
              lin(q6, I_V7, [MON, q1, Q, RR, q4, q5]))
    Phi = p[I_E[0]]
    Phi = tadd(Phi, tmul(p[I_E[1]], MON))
    for ek, qk in zip(I_E[2:], [q1, Q, RR, q4, q5, q6, q7]):
        Phi = tadd(Phi, tmul(p[ek], qk))
    return Phi[2]  # H


# ---------------------------------------------------------------------------
# Norms and the certificate inequalities.
# ---------------------------------------------------------------------------


def mat_vec_mul(M, v):
    out = []
    for i in range(NPAR):
        acc = ZERO
        Mi = M[i]
        for j in range(NPAR):
            acc = gadd(acc, gmul(Mi[j], v[j]))
        out.append(acc)
    return out


def mat_mat_mul(A, Bm):
    n = NPAR
    C = [[ZERO] * n for _ in range(n)]
    for i in range(n):
        Ai = A[i]
        Ci = C[i]
        for k in range(n):
            aik = Ai[k]
            if is_zero(aik):
                continue
            Bk = Bm[k]
            for j in range(n):
                bkj = Bk[j]
                if not is_zero(bkj):
                    Ci[j] = gadd(Ci[j], gmul(aik, bkj))
    return C


def vec_norm1(v):
    return max(gnorm1(x) for x in v)


def mat_norm1(M):
    return max(sum(gnorm1(x) for x in row) for row in M)


def check_certificate():
    checks = {}
    theta, B, seed_sha = load_seed()
    checks["seed_sha256"] = seed_sha
    checks["seed_degree_field_47"] = True
    checks["seed_active_order_matches_appendix_a"] = True
    checks["seed_denominators_1e70_1e60"] = True

    active_pos = {j: p for p, j in enumerate(ACTIVE_APPENDIX_A)}
    Phi = build_circuit(theta, active_pos)
    val, der = Phi

    # F(zc): coefficients 0..46 target 0, coefficient 47 targets 1.
    F = [gsub(val[j], ONE if j == 47 else ZERO) for j in range(NCOEF)]
    # J: rows = equations (degree), cols = active params in I order.
    J = [[der[p][j] for p in range(NPAR)] for j in range(NCOEF)]

    BF = mat_vec_mul(B, F)
    eps = vec_norm1(BF)
    checks["eps_lt_1e_69"] = eps < Fraction(1, 10**69)

    BJ = mat_mat_mul(B, J)
    ImBJ = [
        [gsub(ONE if i == j else ZERO, BJ[i][j]) for j in range(NPAR)]
        for i in range(NPAR)
    ]
    delta = mat_norm1(ImBJ)
    checks["delta_lt_1e_57"] = delta < Fraction(1, 10**57)

    Bnorm = mat_norm1(B)
    checks["Bnorm_lt_4000"] = Bnorm < 4000

    H = build_majorant(theta)
    checks["H_lt_2e12"] = H < 2 * 10**12

    q = delta + Bnorm * H * R
    checks["q_lt_1e_29"] = q < Fraction(1, 10**29)
    checks["eps_plus_qr_lt_r"] = eps + q * R < R

    b = theta[I_B]
    # exact form of paper eq. 12: |Re(bc) - 2| > r
    checks["b_away_from_2"] = abs(b[0] - 2) > R

    checks["eps_value"] = str(eps)
    checks["delta_value"] = str(delta)
    checks["Bnorm_value"] = str(Bnorm)
    checks["H_value"] = str(H)
    checks["q_value"] = str(q)
    return checks


def main() -> int:
    checks = check_certificate()
    scalar = {k: v for k, v in checks.items() if isinstance(v, bool)}
    ok = all(scalar.values())
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "nla_mf14",
        "source_claim": (
            "Webb (2026): exact seven-product closure degree d7 = 47; "
            "Lemma 3 certified contact via exact Gaussian-rational "
            "contraction certificate"
        ),
        "local_pdf": "incoming/nla-mf14-webb.pdf",
        "local_pdf_sha256": "80712867ccf9cf5490ab8e672245d9c55773222f1578ae91d952c1da4e13f4b0",
        "seed_file": "incoming/nla-mf14-seed.json",
        "seed_sha256": checks["seed_sha256"],
        "paper_thresholds": {
            "eps": "1e-69", "delta": "1e-57", "Bnorm": "4000",
            "H": "2e12", "q": "1e-29", "r": "1e-45",
        },
        "checks": checks,
        "verdict": "PASS" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "Lemma 3 hypotheses hold exactly: eps<1e-69, delta<1e-57, "
            "||B||<4000, H<2e12, q<1e-29, eps+q r<r, |Re(b)-2|>r; "
            "Banach gives z* with F(z*)=0 and det J(z*)!=0"
        ),
        "false_instance": None if ok else "certificate inequality failed",
        "ok": ok,
    }
    out = RESULTS / "nla_mf14_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")
    status = "PASS" if ok else "FAIL"
    print(f"[{status}] nla_mf14")
    for k in ("eps_lt_1e_69", "delta_lt_1e_57", "Bnorm_lt_4000",
              "H_lt_2e12", "q_lt_1e_29", "eps_plus_qr_lt_r",
              "b_away_from_2"):
        print(f"  {k}: {scalar[k]}")
    print(f"  eps   = {checks['eps_value']}")
    print(f"  delta = {checks['delta_value']}")
    print(f"  ||B|| = {checks['Bnorm_value']}")
    print(f"  H     = {checks['H_value']}")
    print(f"  q     = {checks['q_value']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
