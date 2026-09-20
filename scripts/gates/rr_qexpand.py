"""Gate: Rogers–Ramanujan HJO q-expansion (arXiv:2608.05480 / 2608.15219).

Type D — finite coefficient check of Z_{a,b}(q) = P_{a,b}(q) for (a,b) in
{(2,3), (3,4), (3,5), (3,7), (3,8)}, plus 15219 Lemma 12 (b=4 sum-to-sum)
for several fixed r_1. Exact integer series arithmetic (no floats).

Type E — OreReduce identity (34) from 2608.15219 requires RISC
HolonomicFunctions (Mathematica). Marked capability-limited; not faked.

PASS  = all executable series / sum-to-sum checks match (escalate).
BREAK = first coefficient or Lemma-12 mismatch.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from math import comb, isqrt
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# Campaign degrees: keep CI under ~15s on a laptop.
CHECKS: list[tuple[int, int, int]] = [
    (2, 3, 40),  # classical RR harness
    (3, 4, 30),
    (3, 5, 24),
    (3, 7, 15),
    (3, 8, 12),
]
LEMMA12_RS = (0, 1, 2, 3, 4)
LEMMA12_DEG = 50


def gaps(a: int, b: int) -> tuple[list[int], set[int]]:
    """Gap set G = N \\ <a,b> and a finite chunk of the semigroup Gamma."""
    Gamma: set[int] = {0}
    changed = True
    limit = a * b + a + b + 5
    while changed:
        changed = False
        for x in list(Gamma):
            for s in (a, b):
                y = x + s
                if y <= limit and y not in Gamma:
                    Gamma.add(y)
                    changed = True
    frobenius = a * b - a - b
    G = [i for i in range(1, frobenius + 1) if i not in Gamma]
    return G, Gamma


def charge(a: int, b: int, i: int) -> int:
    """r_{a,b}(i) as in 2608.05480 (7) / 2608.15219."""
    L = a + b
    d = min(abs(a * i - L * t) for t in range(-(abs(a * i) // L) - 3, abs(a * i) // L + 4))
    return min(a, b, d) - 1 + (1 if i % L == 0 else 0)


def U(a: int, b: int, x: int) -> int:
    return (
        (1 if x >= 0 else 0)
        - (1 if x >= a else 0)
        - (1 if x >= b else 0)
        + (1 if x >= a + b else 0)
    )


def series_mul(A: list[int], B: list[int], N: int) -> list[int]:
    C = [0] * (N + 1)
    for i, ai in enumerate(A):
        if not ai:
            continue
        for j in range(0, N - i + 1):
            bj = B[j]
            if bj:
                C[i + j] += ai * bj
    return C


def series_pow_inv(e: int, r: int, N: int) -> list[int]:
    """Coefficients of 1/(1-q^e)^r up to degree N."""
    out = [0] * (N + 1)
    if r == 0:
        out[0] = 1
        return out
    for k in range(0, N // e + 1):
        out[k * e] = comb(k + r - 1, k)
    return out


def q_poch_series(m: int, N: int) -> list[int]:
    """(q)_m = prod_{j=1}^m (1-q^j), truncated."""
    out = [0] * (N + 1)
    out[0] = 1
    for j in range(1, m + 1):
        fac = [0] * (N + 1)
        fac[0] = 1
        if j <= N:
            fac[j] = -1
        out = series_mul(out, fac, N)
    return out


def inv_q_poch_series(m: int, N: int) -> list[int]:
    """1/(q)_m = prod_{j=1}^m 1/(1-q^j), truncated."""
    out = [0] * (N + 1)
    out[0] = 1
    for j in range(1, m + 1):
        out = series_mul(out, series_pow_inv(j, 1, N), N)
    return out


def q_binomial_series(n: int, k: int, N: int) -> list[int]:
    """Gaussian binomial [n choose k]_q as a truncated series."""
    if k < 0 or k > n:
        return [0] * (N + 1)
    return series_mul(
        series_mul(q_poch_series(n, N), inv_q_poch_series(k, N), N),
        inv_q_poch_series(n - k, N),
        N,
    )


def P_series(a: int, b: int, N: int) -> list[int]:
    """Charge product P_{a,b}(q) = prod_i (1-q^i)^{-r_{a,b}(i)}."""
    out = [0] * (N + 1)
    out[0] = 1
    for i in range(1, N + 1):
        r = charge(a, b, i)
        if r:
            out = series_mul(out, series_pow_inv(i, r, N), N)
    return out


def Z_series(a: int, b: int, N: int) -> list[int]:
    """Eulerian sum Z_{a,b}(q) truncated to degree N.

    Enumerates n in Z^G ∩ C with ||n||_∞ bounded by Huang's positivity
    Q ≥ ||n||_∞² / |G| (so ||n||_∞ ≤ sqrt(N |G|) + O(1)).
    """
    G, Gamma = gaps(a, b)
    nmax = int(isqrt(N * max(len(G), 1))) + 2
    out = [0] * (N + 1)
    # Cache Pochhammer series by index length.
    cache_qp: dict[int, list[int]] = {}
    cache_iqp: dict[int, list[int]] = {}

    def qp(m: int) -> list[int]:
        if m not in cache_qp:
            cache_qp[m] = q_poch_series(m, N)
        return cache_qp[m]

    def iqp(m: int) -> list[int]:
        if m not in cache_iqp:
            cache_iqp[m] = inv_q_poch_series(m, N)
        return cache_iqp[m]

    def rec(idx: int, n_map: dict[int, int]) -> None:
        if idx == len(G):
            Q = 0
            for i in G:
                ni = n_map[i]
                for j in G:
                    Q += U(a, b, j - i) * ni * n_map[j]
            if Q > N:
                return

            def n_at(t: int) -> int:
                return n_map[t] if t in n_map else 0

            term = [0] * (N + 1)
            term[0] = 1
            for i in G:
                A = n_at(i) - n_at(i - a - b)
                B = n_at(i) - n_at(i - a)
                C = n_at(i) - n_at(i - b)
                if A < 0 or B < 0 or C < 0:
                    return
                term = series_mul(term, qp(A), N)
                term = series_mul(term, iqp(B), N)
                term = series_mul(term, iqp(C), N)
            for d, c in enumerate(term):
                if c and d + Q <= N:
                    out[d + Q] += c
            return

        gi = G[idx]
        for v in range(0, nmax + 1):
            ok = True
            for gj in G[:idx]:
                if (gi - gj) in Gamma and v < n_map[gj]:
                    ok = False
                    break
                if (gj - gi) in Gamma and n_map[gj] < v:
                    ok = False
                    break
            if not ok:
                continue
            n_map[gi] = v
            rec(idx + 1, n_map)
            del n_map[gi]

    rec(0, {})
    return out


def lemma12_sides(r1: int, deg: int) -> tuple[list[int], list[int]]:
    """15219 Lemma 12 (b=4 sum-to-sum) LHS/RHS as truncated series."""
    lhs = [0] * (deg + 1)
    for n1 in range(0, r1 + 1):
        for n2 in range(0, r1 + 1):
            Q = n1 * n1 + n2 * n2 + r1 * r1 + n1 * n2 - n1 * r1
            if Q > deg:
                continue
            term = series_mul(q_binomial_series(r1, n1, deg), q_binomial_series(r1, n2, deg), deg)
            for d, c in enumerate(term):
                if c and d + Q <= deg:
                    lhs[d + Q] += c
    rhs = [0] * (deg + 1)
    for m in range(0, 2 * r1 + 1):
        Q = r1 * r1 - r1 * m + m * m
        if Q > deg:
            continue
        term = q_binomial_series(2 * r1, m, deg)
        for d, c in enumerate(term):
            if c and d + Q <= deg:
                rhs[d + Q] += c
    return lhs, rhs


def first_diff(A: list[int], B: list[int]) -> int | None:
    for i, (a, b) in enumerate(zip(A, B)):
        if a != b:
            return i
    if len(A) != len(B):
        return min(len(A), len(B))
    return None


def run_zp_checks() -> dict:
    results = []
    all_ok = True
    for a, b, N in CHECKS:
        P = P_series(a, b, N)
        Z = Z_series(a, b, N)
        d = first_diff(Z, P)
        ok = d is None
        all_ok = all_ok and ok
        results.append(
            {
                "a": a,
                "b": b,
                "N": N,
                "ok": ok,
                "first_diff_degree": d,
                "P_head": P[:8],
                "Z_head": Z[:8],
                "gap_count": len(gaps(a, b)[0]),
            }
        )
        if not ok:
            break
    return {"checks": results, "all_ok": all_ok}


def run_lemma12() -> dict:
    rows = []
    all_ok = True
    for r1 in LEMMA12_RS:
        lhs, rhs = lemma12_sides(r1, LEMMA12_DEG)
        d = first_diff(lhs, rhs)
        ok = d is None
        all_ok = all_ok and ok
        rows.append({"r1": r1, "ok": ok, "first_diff_degree": d})
        if not ok:
            break
    return {
        "source": "2608.15219 Lemma 12 (b=4)",
        "degree": LEMMA12_DEG,
        "rows": rows,
        "all_ok": all_ok,
    }


def ore_reduce_status() -> dict:
    return {
        "source": "2608.15219 identity (34) / OreReduce cofactors",
        "status": "capability-limited",
        "reason": (
            "Verification needs RISC HolonomicFunctions OreReduce over a "
            "q-shift operator algebra (Mathematica). Campaign stack is "
            "Python mpmath/Fraction/SymPy only — no Sage/Magma/RISC. "
            "Authors state (34) is independently checkable from printed "
            "cofactors; we do not invent those operators here."
        ),
        "note": "Blocked replay is not a BREAK of Z=P.",
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    zp = run_zp_checks()
    lem = run_lemma12()
    ore = ore_reduce_status()

    if not zp["all_ok"] or not lem["all_ok"]:
        verdict = "BREAK"
    else:
        verdict = "PASS"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "2f",
        "sources": ["arXiv:2608.05480", "arXiv:2608.15219"],
        "pdfs": [
            "incoming/rr-2608.05480.pdf",
            "incoming/rr-2608.15219.pdf",
        ],
        "zp_expand": zp,
        "lemma12": lem,
        "ore_reduce_34": ore,
        "verdict": verdict,
        "note": (
            "PASS escalates the Type-D q-expand route; does not certify the "
            "geometric point-count identification or the b=8 Ore proof. "
            "BREAK is a coefficient mismatch, not a claim that HJO is false."
        ),
        "harvest_correction": (
            "2608.05480 eq. (5) is the published HJO geometric identity "
            "S_q = Z(q^{-1}) prod (1-q^{-n})^{-1}, not an unpublished q-series."
        ),
    }
    out = RESULTS / "rr_qexpand_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print("[PASS] rr_qexpand" if verdict == "PASS" else "[BREAK] rr_qexpand")
    for c in zp["checks"]:
        status = "ok" if c["ok"] else f"DIFF@{c['first_diff_degree']}"
        print(f"  Z=P ({c['a']},{c['b']}) N={c['N']}: {status} head={c['P_head']}")
    print(
        f"  lemma12 r in {list(LEMMA12_RS)}: "
        f"{'ok' if lem['all_ok'] else 'FAIL'}"
    )
    print(f"  OreReduce (34): {ore['status']}")
    print(f"  verdict: {verdict}")
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
