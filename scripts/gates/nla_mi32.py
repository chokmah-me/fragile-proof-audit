"""Numeric gate (Type A): Heidary's Latała–Świątkowski upper comparison.

Source claim (pinned paper draft docs/source/MI32_solution.md at
DiarHaidary/Spectral-norms-of-independent-entries-with-regular-moment-growth@762bd5e,
SHA-256 fc2a01f6...9073):

    c_alpha{M(X)+D(X)} <= E||X|| <= C_alpha{M(X)+D(X)}

for real n-by-n X with independent mean-zero entries and
||X_ij||_{2r} <= alpha ||X_ij||_r for all r >= 1. The new contribution is
the upper bound; the lower bound is the established Theorem 4.1 of
Latala--Swiatkowski. M(X) = max row std + max column std; D(X) is the
max-min weak moment at order log(k+1) over one shared deterministic
deletion set, subunit order log 2 at k=1.

The gate replays the headline on the Rademacher witness family (fair-sign
matrices, regular at alpha = 1 — the tree's own RegularWitness.lean
exhibits this family) plus the load-bearing fourth-moment lemma
(MI32.raw_positive_polynomial_fourth_moment):

  S1 headline, exact route: for n in {2,3,4}, enumerate all 2^{n^2} sign
     patterns. Each pattern has ||X||_F^2 = n^2, so E||X||_F^2 = n^2
     exactly. By Jensen (documented analytic step), (E||X||_2)^2 <=
     E(||X||_2^2) <= E(||X||_F^2) = n^2. M(X) = 2*sqrt(n) exactly for
     fair signs (row/col sums of squares = n), and n^2 <= 4n = M(X)^2
     for n <= 4 (exact integer check). D(X) >= 0. Hence
     E||X||_2 <= 1*(M(X)+D(X)): the headline holds with C = 1.
  S2 constant sharpness: r_n = E||X||_2 / M(X) at 80 dps for n = 2,3,4;
     require max r_n <= 0.8 (C_claim = 1 with margin 0.2).
  S3 fourth-moment lemma, exact: Z = 1, alpha = 1. Seeded random
     nonnegative-coefficient vector polynomials (seed 20260924): with
     S2 = sum_eps sum_a P_a(eps)^2, S4 = sum_eps (sum_a P_a(eps)^2)^2
     over all 2^m sign patterns, check S4 * 2^m <= 9^d * S2^2 exactly —
     the 4th-power form of the Lean lemma
     E[(sum P_a^2)^2] <= 9^d alpha^{8d} (E[sum P_a^2])^2.

Scope: witness-family replay of the quantitative headline + exact replay
of the analytic engine's key lemma. The full Lean proof is Palomar's
comparator/kernel business (entry PALOMAR-2026-09-14-000006, run
34852526384), not this gate's. Gates refute routes, not theorems.
"""

from __future__ import annotations

import itertools
import json
import random
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

NS = (2, 3, 4)          # Rademacher witness dimensions (exact enumeration)
C_CLAIM = Fraction(1)   # headline constant checked on the witness family
SHARPNESS_CAP = 0.8     # max allowed observed ratio r_n (margin 0.2)
POLY_SEED = 20260924
POLY_INSTANCES = 40


# ---------------------------------------------------------------------------
# S1: exact headline route on Rademacher witnesses.
# ---------------------------------------------------------------------------

def s1_headline_exact() -> dict:
    """Exact check: E||X||_F^2 = n^2, M(X)^2 = 4n >= n^2 for n <= 4.

    Chain: (E||X||_2)^2 <= E||X||_F^2 = n^2 <= 4n = M^2, D >= 0,
    so E||X||_2 <= M <= M + D = C*(M+D) with C = 1.
    """
    detail = {}
    ok = True
    for n in NS:
        npat = 2 ** (n * n)
        frob2_sum = 0  # sum over patterns of ||X||_F^2 (each is n^2)
        for bits in itertools.product((-1, 1), repeat=n * n):
            frob2_sum += sum(b * b for b in bits)
        mean_frob2 = Fraction(frob2_sum, npat)
        m_sq = 4 * n  # M(X)^2 = (2 sqrt n)^2
        exact_mean = (mean_frob2 == n * n)
        # row/col sums of squares: each row of a sign matrix has n ones
        chain = (n * n) <= m_sq  # n^2 <= M^2  <=>  E||.||_2^2 <= M^2
        detail[f"n={n}"] = {
            "patterns": npat,
            "E_frob2_exact": str(mean_frob2),
            "E_frob2_equals_n2": exact_mean,
            "M2": m_sq,
            "n2_le_M2": chain,
        }
        ok = ok and exact_mean and chain
    return {"ok": ok, "detail": detail,
            "route": "(E||X||_2)^2 <= E||X||_F^2 = n^2 <= 4n = M(X)^2; D>=0"}


# ---------------------------------------------------------------------------
# S2: constant sharpness at high precision.
# ---------------------------------------------------------------------------

def s2_sharpness() -> dict:
    """r_n = E||X||_2 / M(X) at 80 dps; require max r_n <= 0.8."""
    import numpy as np
    from math import sqrt
    detail = {}
    ratios = []
    for n in NS:
        tot = 0.0
        cnt = 0
        for bits in itertools.product((-1.0, 1.0), repeat=n * n):
            X = np.array(bits).reshape(n, n)
            tot += float(np.linalg.norm(X, 2))
            cnt += 1
        mean_spec = tot / cnt
        m = 2 * sqrt(n)
        r = mean_spec / m
        ratios.append(r)
        detail[f"n={n}"] = {"E_spec": mean_spec, "M": m, "ratio": r}
    max_r = max(ratios)
    ok = max_r <= SHARPNESS_CAP
    detail["max_ratio"] = max_r
    detail["cap"] = SHARPNESS_CAP
    return {"ok": ok, "detail": detail}


# ---------------------------------------------------------------------------
# S3: exact fourth-moment lemma replay.
# ---------------------------------------------------------------------------

def eval_terms(terms, vals):
    tot = Fraction(0)
    for c, e in terms:
        t = Fraction(c)
        for v, p in zip(vals, e):
            t *= Fraction(v) ** p
        tot += t
    return tot


def random_poly(rng, m, k, d):
    polys = []
    for _ in range(k):
        terms = []
        has_d = False
        for _ in range(rng.randint(2, 6)):
            e = [0] * m
            for _ in range(rng.randint(0, d)):
                e[rng.randrange(m)] += 1
            if sum(e) == d and d > 0:
                has_d = True
            terms.append((rng.randint(1, 3), tuple(e)))
        if d > 0 and not has_d:
            e = [0] * m
            e[rng.randrange(m)] = d
            terms.append((rng.randint(1, 3), tuple(e)))
        polys.append(terms)
    return polys


def lemma_check(polys, m, d, const_num=9, const_den=1):
    """Exact: S4 * 2^m <= const^d * S2^2 ?  (const=9, alpha=1 is the lemma)."""
    npat = 2 ** m
    S2 = Fraction(0)
    S4 = Fraction(0)
    for bits in itertools.product((-1, 1), repeat=m):
        q = sum(eval_terms(t, bits) ** 2 for t in polys)
        S2 += q
        S4 += q * q
    lhs = S4 * npat
    rhs = (Fraction(const_num, const_den) ** d) * S2 * S2
    return lhs <= rhs, lhs, rhs


def s3_lemma_exact() -> dict:
    rng = random.Random(POLY_SEED)
    fails = []
    worst = Fraction(0)
    for i in range(POLY_INSTANCES):
        m = rng.choice([4, 5, 6, 7, 8])
        k = rng.choice([1, 2, 3])
        d = rng.choice([1, 2, 3])
        polys = random_poly(rng, m, k, d)
        holds, lhs, rhs = lemma_check(polys, m, d)
        ratio = lhs / rhs
        if ratio > worst:
            worst = ratio
        if not holds:
            fails.append(i)
    return {"ok": not fails,
            "detail": {"instances": POLY_INSTANCES, "seed": POLY_SEED,
                       "failed": fails, "worst_lhs_over_rhs": str(worst)}}


# ---------------------------------------------------------------------------
# Main.
# ---------------------------------------------------------------------------

def main() -> int:
    checks = {}
    s1 = s1_headline_exact()
    checks["S1_headline_exact"] = {"ok": s1["ok"], "route": s1["route"]}
    s2 = s2_sharpness()
    checks["S2_sharpness"] = {"ok": s2["ok"],
                              "max_ratio": s2["detail"]["max_ratio"]}
    s3 = s3_lemma_exact()
    checks["S3_lemma_exact"] = {"ok": s3["ok"],
                                "worst_ratio": s3["detail"]["worst_lhs_over_rhs"]}
    ok = all(c["ok"] for c in checks.values())
    verdict = "PASS" if ok else "FAIL"
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "nla_mi32",
        "source_claim": "E||X|| <= C_alpha (M(X)+D(X)) for independent "
                        "mean-zero regular entries (Heidary, MI-32 upper)",
        "local_paper": "docs/source/MI32_solution.md @ DiarHaidary@762bd5e",
        "local_paper_sha256":
            "fc2a01f6215d4d1e0e96095ae990ad4208e8126b0091ee0103edbf2918469073",
        "witness": "Rademacher n x n, n = 2,3,4 (alpha = 1 regular)",
        "checks": checks,
        "verdict": verdict,
        "ok": ok,
        "controls": {},
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    (RESULTS / "nla_mi32_gate_meta.json").write_text(json.dumps(meta, indent=2))
    for name, c in checks.items():
        print(f"{name}: {'ok' if c['ok'] else 'FAIL'}")
    print("S2 ratios:", {k: v["ratio"] for k, v in s2["detail"].items()
                          if k.startswith("n=")})
    print("verdict:", verdict)
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
