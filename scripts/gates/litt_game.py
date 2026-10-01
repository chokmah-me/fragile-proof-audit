#!/usr/bin/env python3
"""Numeric gate: arXiv:2503.19035v1 (Janson-Nica-Segert, generalized Litt game).

SCOPE (honest): a NUMERICAL verify/audit replay of Theorem 1.1, formulas
(1.5)-(1.8) [=(tab1)-(tab4)], via an independent exact finite-state DP for
the de Bruijn score process. It does NOT re-derive the Edgeworth expansion
(Theorems 3.1/3.2) -- that proof was scrutinized by hand (see the audit
note docs/audits/litt-generalized-hh-ht.md). What it does:

 1. Asymptotic replay of (tab1)-(tab4) across a sweep of (q, A, B):
    P(Bob)-P(Alice), the individual win probabilities (with the -1
    tie-split terms), and the tie probability, against the (theta, sigma^2)
    formulas. Ratios must converge to 1 with decaying error.
 2. Exact-fairness identity (Remark 1.2): theta_AA == theta_BB implies
    P(Alice) == P(Bob) exactly at finite n (float DP + exact enumeration).
 3. Excluded pathological cases (Examples Egss2, EH-T): confirm the paper's
    claimed failure modes numerically.
 4. Matrix identities behind the proof: Prop P4 (group inverse = theta,
    (cp1)) and Lemma LW ((ql2)) checked numerically to machine precision.
 5. Teeth control: the asymptotic check is re-run with a deliberately wrong
    constant (x1.1) and must FAIL, so a PASS is not vacuous.

A PASS means the numerics confirm the paper's formulas; the 25-gate verdict
lock is untouched (standalone audit).

Source pin: arXiv:2503.19035v1 e-print (single-version paper, v1 == current
arXiv tarball), SHA-256
  de954eead3b07c017c4e7ef206f9ba7812449973ea3816349df828fef0ef909f
fetched 2026-10-01 from https://arxiv.org/e-print/2503.19035v1.

Gates refute routes, not theorems.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from fractions import Fraction
from itertools import product
from math import comb, pi, sqrt
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

SOURCE_SHA256 = "de954eead3b07c017c4e7ef206f9ba7812449973ea3816349df828fef0ef909f"
ARXIV_ID = "2503.19035v1"

H, T = 0, 1


# --------------------------------------------------------------------------
# Paper definitions (tau), (gss9)
# --------------------------------------------------------------------------
def theta(U, V, q):
    """Overlap index (tau): sum of q^{k-ell} over proper prefix/suffix overlaps."""
    U, V = tuple(U), tuple(V)
    ell = len(U)
    s = 0.0
    for k in range(1, ell):
        if U[ell - k:] == V[:k]:
            s += q ** (k - ell)
    return s


def theta_frac(U, V, q):
    U, V = tuple(U), tuple(V)
    ell = len(U)
    s = Fraction(0)
    for k in range(1, ell):
        if U[ell - k:] == V[:k]:
            s += Fraction(1, q ** (ell - k))
    return s


def sigma2(A, B, q):
    """Asymptotic variance (gss9): 2 q^{-ell} (1 + thAA - thAB - thBA + thBB)."""
    A, B = tuple(A), tuple(B)
    ell = len(A)
    return 2 * q ** -ell * (
        1 + theta(A, A, q) - theta(A, B, q) - theta(B, A, q) + theta(B, B, q)
    )


# --------------------------------------------------------------------------
# Exact DP for the game: S_hat = (#A windows) - (#B windows); Alice wins iff > 0
# --------------------------------------------------------------------------
def game_series(q, A, B, n_max, snaps):
    """Return {n: (P(Alice), P(Bob), P(tie))} via exact de Bruijn DP."""
    A, B = tuple(A), tuple(B)
    ell = len(A)
    snaps = sorted(snaps)
    out = {}
    if ell == 1:
        off = n_max
        dp = np.zeros(2 * n_max + 1)
        dp[off] = 1.0
        si = 0
        for m in range(1, n_max + 1):
            ndp = np.zeros(2 * n_max + 1)
            for c in range(q):
                k = (1 if c == A[0] else 0) - (1 if c == B[0] else 0)
                if k == 0:
                    ndp += dp
                elif k == 1:
                    ndp[1:] += dp[:-1]
                else:
                    ndp[:-1] += dp[1:]
            dp = ndp / q
            if si < len(snaps) and m == snaps[si]:
                out[m] = (dp[off + 1:].sum(), dp[:off].sum(), dp[off])
                si += 1
        return out
    nstates = q ** (ell - 1)
    trans = np.zeros((nstates, q), dtype=int)
    inc = np.zeros((nstates, q), dtype=int)
    for s in range(nstates):
        t, dig = s, []
        for _ in range(ell - 1):
            dig.append(t % q)
            t //= q
        dig = dig[::-1]
        for c in range(q):
            block = tuple(dig + [c])
            ns = 0
            for d in dig[1:] + [c]:
                ns = ns * q + d
            trans[s, c] = ns
            inc[s, c] = (1 if block == A else 0) - (1 if block == B else 0)
    off = n_max
    dp = np.zeros((nstates, 2 * n_max + 1))
    dp[:, off] = q ** -(ell - 1)
    si = 0
    while si < len(snaps) and snaps[si] < ell:
        out[snaps[si]] = (0.0, 0.0, 1.0)
        si += 1
    for m in range(ell, n_max + 1):
        ndp = np.zeros((nstates, 2 * n_max + 1))
        for s in range(nstates):
            row = dp[s] / q
            for c in range(q):
                ns, k = trans[s, c], inc[s, c]
                if k == 0:
                    ndp[ns] += row
                elif k == 1:
                    ndp[ns, 1:] += row[:-1]
                else:
                    ndp[ns, :-1] += row[1:]
        dp = ndp
        if si < len(snaps) and m == snaps[si]:
            tot = dp.sum(axis=0)
            assert abs(tot.sum() - 1.0) < 1e-9, "probability leak in DP"
            out[m] = (tot[off + 1:].sum(), tot[:off].sum(), tot[off])
            si += 1
    return out


def exact_counts(q, A, B, n):
    """Brute-force integer enumeration (for small n)."""
    A, B = tuple(A), tuple(B)
    ell = len(A)
    ca = cb = ct = 0
    for outc in product(range(q), repeat=n):
        sa = sum(1 for k in range(n - ell + 1) if tuple(outc[k:k + ell]) == A)
        sb = sum(1 for k in range(n - ell + 1) if tuple(outc[k:k + ell]) == B)
        if sa > sb:
            ca += 1
        elif sb > sa:
            cb += 1
        else:
            ct += 1
    return ca, cb, ct


# --------------------------------------------------------------------------
# Self-test of the harness itself
# --------------------------------------------------------------------------
def selftest():
    # hand theta values
    assert theta((H, H), (H, H), 2) == 0.5
    assert theta((H, T), (H, T), 2) == 0.0
    assert theta((H, H), (H, T), 2) == 0.5
    assert theta((H, T), (H, H), 2) == 0.0
    assert abs(sigma2((H, H), (H, T), 2) - 0.5) < 1e-15
    # n=2 hand enumeration: HH->Alice, HT->Bob, TH/TT->tie
    ca, cb, ct = exact_counts(2, (H, H), (H, T), 2)
    assert (ca, cb, ct) == (1, 1, 2), (ca, cb, ct)
    pa, pb, pt = game_series(2, (H, H), (H, T), 2, [2])[2]
    assert abs(pa - 0.25) < 1e-15 and abs(pb - 0.25) < 1e-15 and abs(pt - 0.5) < 1e-15
    # DP agrees with brute force at n=8
    ca, cb, ct = exact_counts(2, (H, H), (H, T), 8)
    pa, pb, pt = game_series(2, (H, H), (H, T), 8, [8])[8]
    assert abs(pa - ca / 256) < 1e-12 and abs(pb - cb / 256) < 1e-12
    print("selftest: OK (theta hand values, n=2 enumeration, DP vs brute force)")


# --------------------------------------------------------------------------
# Lane 1: asymptotic replay of (tab1)-(tab4)
# --------------------------------------------------------------------------
SWEEP = [
    ("litt-original", 2, (H, H), (H, T)),
    ("hhh-vs-hth", 2, (H, H, H), (H, T, H)),
    ("q3-aaa-vs-abc", 3, (0, 0, 0), (0, 1, 2)),
    ("hhhh-vs-htht", 2, (H, H, H, H), (H, T, H, T)),
    ("q3-ab-vs-ba", 3, (0, 1), (1, 0)),
]

SNAPS = [500, 1000, 2000, 3000]
TOL_RATIO = 0.01      # |ratio - 1| at n=3000 must be below this
TOL_FAIR = 2e-3       # |P(B)-P(A)| bound factor: |diff| <= TOL_FAIR / n when c=0


def lane_asymptotics(cmult=1.0):
    """Check (tab1)-(tab4). Returns (ok, detail). cmult perturbs the constant (teeth)."""
    detail = {}
    ok = True
    for name, q, A, B in SWEEP:
        tAA, tBB = theta(A, A, q), theta(B, B, q)
        s2 = sigma2(A, B, q)
        assert s2 > 0, f"{name}: sigma^2 not positive"
        c_diff = (tAA - tBB) / sqrt(2 * pi * s2) * cmult          # P(B)-P(A) coeff
        c_winA = (tBB - tAA - 1) / (2 * sqrt(2 * pi * s2)) * cmult  # P(A)-1/2 coeff
        res = game_series(q, A, B, SNAPS[-1], SNAPS)
        rows = {}
        for n in SNAPS:
            pa, pb, pt = res[n]
            diff = pb - pa
            if abs(c_diff) > 1e-12:
                r_diff = diff / (c_diff / sqrt(n))
            else:
                r_diff = None
            r_winA = (pa - 0.5) / (c_winA / sqrt(n))
            r_tie = pt * sqrt(2 * pi * s2 * n)
            rows[n] = {"r_diff": r_diff, "r_winA": r_winA, "r_tie": r_tie,
                       "pa": pa, "pb": pb, "pt": pt}
        nL = SNAPS[-1]
        rL = rows[nL]
        checks = []
        if rL["r_diff"] is not None:
            checks.append(("r_diff->1", abs(rL["r_diff"] - 1) < TOL_RATIO))
            # error decay: |r(3000)-1| < |r(1000)-1|
            checks.append(("err-decay", abs(rL["r_diff"] - 1) < abs(rows[1000]["r_diff"] - 1)))
        else:
            diffL = rows[nL]["pb"] - rows[nL]["pa"]
            checks.append(("fair-decay", abs(diffL) < TOL_FAIR / nL))
        checks.append(("r_winA->1", abs(rL["r_winA"] - 1) < TOL_RATIO))
        checks.append(("r_tie->1", abs(rL["r_tie"] - 1) < TOL_RATIO))
        case_ok = all(c[1] for c in checks)
        ok = ok and case_ok
        detail[name] = {"theta_AA": tAA, "theta_BB": tBB, "sigma2": s2,
                        "rows": {n: {k: (round(v, 6) if isinstance(v, float) else v)
                                     for k, v in r.items()} for n, r in rows.items()},
                        "checks": checks, "ok": case_ok}
    return ok, detail


# --------------------------------------------------------------------------
# Lane 2: exact fairness (Remark 1.2) -- theta_AA == theta_BB => exactly fair
# --------------------------------------------------------------------------
FAIR_CASES = [
    (2, (H, H, T), (H, T, T)),
    (2, (H, T, H), (T, H, T)),
    (2, (H, H, H), (T, T, T)),
    (3, (0, 0, 1), (0, 1, 1)),
]


def lane_exact_fairness():
    detail, ok = {}, True
    for q, A, B in FAIR_CASES:
        assert abs(theta(A, A, q) - theta(B, B, q)) < 1e-15
        ca, cb, ct = exact_counts(q, A, B, 10)
        exact_ok = (ca == cb)
        pa, pb, pt = game_series(q, A, B, 3000, [3000])[3000]
        float_ok = abs(pa - pb) < 1e-12
        case_ok = exact_ok and float_ok
        ok = ok and case_ok
        detail[f"q{q}-{A}-{B}"] = {"theta": theta(A, A, q),
                                   "exact_n10": [ca, cb, ct], "exact_ok": exact_ok,
                                   "float_diff_n3000": pb - pa, "float_ok": float_ok,
                                   "ok": case_ok}
    return ok, detail


# --------------------------------------------------------------------------
# Lane 3: excluded pathological cases (Examples Egss2, EH-T)
# --------------------------------------------------------------------------
def lane_pathological():
    detail, ok = {}, True
    # Egss2: A=HTT, B=TTH (ell=3): sigma^2 = 0. Symmetry => P(A)=P(B) exactly,
    # but P(tie) is stuck at a constant: (tab1)-(tab3) fail as claimed.
    A, B = (H, T, T), (T, T, H)
    assert abs(sigma2(A, B, 2)) < 1e-15, "Egss2 must have sigma^2 = 0"
    res = game_series(2, A, B, 2000, [500, 1000, 2000])
    diffs = [abs(res[n][1] - res[n][0]) for n in (500, 1000, 2000)]
    ties = [res[n][2] for n in (500, 1000, 2000)]
    sym_ok = all(d < 1e-12 for d in diffs)
    # (tab3) would predict tie -> 0 like n^-1/2; here it is constant
    stuck_ok = abs(ties[2] - ties[0]) < 1e-12 and ties[2] > 0.5
    case_ok = sym_ok and stuck_ok
    ok = ok and case_ok
    detail["Egss2_HTT_vs_TTH"] = {"sigma2": 0.0, "sym_diff_max": max(diffs),
                                  "tie_probs": ties, "sym_ok": sym_ok,
                                  "tie_stuck_ok": stuck_ok, "ok": case_ok}
    # EH-T: A=H, B=T (ell=1). P(tie) = 0 for odd n -- (tab3) fails.
    # For even n, P(tie) = C(n,n/2)/2^n ~ sqrt(2/(pi n)), 2x the (tab3) value.
    res = game_series(2, (H,), (T,), 2000, [999, 1000, 2000])
    odd_ok = res[999][2] == 0.0
    even_ok = abs(res[1000][2] - comb(1000, 500) / 2 ** 1000) < 1e-12
    ratio_2x = res[2000][2] / (1 / sqrt(2 * pi * 2000))
    factor_ok = abs(ratio_2x - 2.0) < 0.02
    sym2_ok = all(abs(res[n][1] - res[n][0]) < 1e-12 for n in (999, 1000, 2000))
    case_ok = odd_ok and even_ok and factor_ok and sym2_ok
    ok = ok and case_ok
    detail["EH-T_H_vs_T"] = {"tie_odd_n999": res[999][2], "odd_ok": odd_ok,
                             "tie_n1000": res[1000][2], "even_ok": even_ok,
                             "tie_over_tab3_n2000": ratio_2x, "factor2_ok": factor_ok,
                             "sym_ok": sym2_ok, "ok": case_ok}
    return ok, detail


# --------------------------------------------------------------------------
# Lane 4: matrix identities behind the proof -- Prop P4 (cp1), Lemma LW (ql2)
# --------------------------------------------------------------------------
def _digits(u, q, ell):
    d = []
    for _ in range(ell):
        d.append(u % q)
        u //= q
    return tuple(d[::-1])


def lane_matrix_identities():
    detail, ok = {}, True
    for q, ell in [(2, 2), (2, 3), (3, 2)]:
        m = q ** ell
        P = np.zeros((m, m))
        for u in range(m):
            tail = u % q ** (ell - 1)
            for c in range(q):
                P[u, tail * q + c] = 1.0 / q
        one = np.ones(m)
        pi = one / m
        # group inverse of I - P via (I - P + 1 pi^T)^{-1} - 1 pi^T
        Q = np.linalg.inv(np.eye(m) - P + np.outer(one, pi)) - np.outer(one, pi)
        worst = 0.0
        for u in range(m):
            for v in range(m):
                exp = (1.0 if u == v else 0.0) \
                    + float(theta_frac(_digits(u, q, ell), _digits(v, q, ell), q)) \
                    - ell / q ** ell
                worst = max(worst, abs(Q[u, v] - exp))
        case_ok = worst < 1e-9
        ok = ok and case_ok
        detail[f"P4_q{q}_ell{ell}"] = {"max_abs_err": worst, "ok": case_ok}
    for q, A, B in [(2, (H, H), (H, T)), (2, (H, H, H), (H, T, H)),
                    (3, (0, 0, 0), (0, 1, 2))]:
        A, B = tuple(A), tuple(B)
        ell, m = len(A), q ** len(A)

        def idx(w):
            s = 0
            for d in w:
                s = s * q + d
            return s

        P = np.zeros((m, m))
        for u in range(m):
            tail = u % q ** (ell - 1)
            for c in range(q):
                P[u, tail * q + c] = 1.0 / q
        PnB = P.copy()
        PnB[:, idx(B)] = 0.0
        got = np.linalg.inv(np.eye(m) - PnB)[idx(A), idx(A)]
        exp = float(2 + theta_frac(A, A, q) + theta_frac(B, B, q)
                    - theta_frac(A, B, q) - theta_frac(B, A, q))
        err = abs(got - exp)
        case_ok = err < 1e-9
        ok = ok and case_ok
        detail[f"ql2_q{q}_{A}_{B}"] = {"got": got, "expected": exp,
                                      "abs_err": err, "ok": case_ok}
    return ok, detail


# --------------------------------------------------------------------------
# Lane 5: cross-checks against prior independent analyses ([5],[26],[8])
# --------------------------------------------------------------------------
def lane_crosschecks():
    # (1.1): P(B)-P(A) ~ 1/(2 sqrt(pi n)); (1.2): 1/2-P(A) ~ 3/(4 sqrt(pi n)),
    # 1/2-P(B) ~ 1/(4 sqrt(pi n)) -- Litt's original game, three independent
    # derivations (Ekhad-Zeilberger, Segert, Grimmett).
    res = game_series(2, (H, H), (H, T), 3000, [3000])[3000]
    pa, pb, pt = res
    n = 3000
    r11 = (pb - pa) / (1 / (2 * sqrt(pi * n)))
    r12a = (0.5 - pa) / (3 / (4 * sqrt(pi * n)))
    r12b = (0.5 - pb) / (1 / (4 * sqrt(pi * n)))
    ok = all(abs(r - 1) < 0.01 for r in (r11, r12a, r12b))
    return ok, {"eq1.1_ratio": r11, "eq1.2a_ratio": r12a, "eq1.2b_ratio": r12b,
                "ok": ok}


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
def main():
    selftest()
    lanes = {}
    ok_all = True

    ok, det = lane_asymptotics()
    lanes["asymptotics_tab1_tab4"] = {"ok": ok, "detail": det}
    ok_all &= ok

    ok, det = lane_exact_fairness()
    lanes["exact_fairness"] = {"ok": ok, "detail": det}
    ok_all &= ok

    ok, det = lane_pathological()
    lanes["pathological_cases"] = {"ok": ok, "detail": det}
    ok_all &= ok

    ok, det = lane_matrix_identities()
    lanes["matrix_identities"] = {"ok": ok, "detail": det}
    ok_all &= ok

    ok, det = lane_crosschecks()
    lanes["crosschecks_1.1_1.2"] = {"ok": ok, "detail": det}
    ok_all &= ok

    # Teeth control: the asymptotic lane must FAIL on a wrong constant.
    ok_wrong, _ = lane_asymptotics(cmult=1.1)
    teeth_ok = not ok_wrong
    ok_all &= teeth_ok

    meta = {
        "audit_date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "gate": "litt_hh_ht",
        "arxiv_id": ARXIV_ID,
        "paper_title": "The generalized Alice HH vs Bob HT problem",
        "authors": ["Svante Janson", "Mihai Nica", "Simon Segert"],
        "source_sha256": SOURCE_SHA256,
        "source_note": "arXiv e-print tarball (single-version paper; v1 == current tarball)",
        "claim": "Theorem 1.1: for distinct equal-length words A,B over a q-letter "
                 "alphabet, P(Alice)-P(Bob) = (theta_BB-theta_AA)/sqrt(2 pi sigma^2) "
                 "n^-1/2 + O(n^-1), with the -1 tie-split terms in (1.5)/(1.6) and "
                 "P(tie) = 1/sqrt(2 pi sigma^2) n^-1/2 + O(n^-1); sigma^2 from "
                 "(4.19); exact fairness iff theta_AA == theta_BB",
        "lanes": lanes,
        "teeth_control": {
            "description": "asymptotic lane re-run with all predicted constants x1.1",
            "must_fail": True,
            "failed_as_required": teeth_ok,
        },
        "status": "PASS" if ok_all else "FAIL",
        "verdict_lock_untouched": True,
        "notes": [
            "DP engine self-tested: hand theta values, n=2 hand enumeration, "
            "DP vs brute-force enumeration at n=8.",
            "Doc nits (not findings): (i) Sec 2.1 calls rho(A)=max|lambda| the "
            "'spectral norm' -- it is the spectral radius; (ii) (jw5) second "
            "indicator should read Theta(V,T), not Theta(U,V) (result unaffected); "
            "(iii) Tgss0 proof writes sum to n-ell-1, should be n-ell+1.",
        ],
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    with open(RESULTS / "litt_hh_ht_gate_meta.json", "w") as f:
        json.dump(meta, f, indent=2, default=str)

    print("\n==== lane summary ====")
    for name, lane in lanes.items():
        print(f"  {name:28s} {'PASS' if lane['ok'] else 'FAIL'}")
    print(f"  {'teeth_control (must fail)':28s} {'PASS' if teeth_ok else 'FAIL'}")
    print(f"OVERALL: {'PASS' if ok_all else 'FAIL'}")
    return 0 if ok_all else 1


if __name__ == "__main__":
    sys.exit(main())
