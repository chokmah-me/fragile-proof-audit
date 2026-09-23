#!/usr/bin/env python3
"""Second independent implementation of the Liouville summatory function.

Computes L(n) = sum_{k=1}^{n} lambda(k) with lambda(k) = (-1)^Omega(k),
for the Polya counterexample canonization (harvest rank 9).

STRATEGY (independent of polya/src/liouville_sieve.c):
  Uses the identity  Omega(n) = #{ (p,k) : k >= 1, p^k divides n }.
  Every prime power dividing n contributes exactly one to the total prime
  factor count with multiplicity.  (Check: n = 12 = 2^2*3 has prime-power
  divisors 2, 4, 3 -> 3 = Omega(12).)

  Hence lambda(n) = (-1)^Omega(n) is obtained by starting from parity 0
  and flipping one bit for every multiple of every prime power q = p^k <= N.
  There are no cofactors, no division of n, no per-number factor stripping:
  the sieve is driven by prime powers (prime-driven), whereas the C
  implementation is number-driven (per-n cofactor divided down by small
  primes).  A defect in cofactor/parity bookkeeping -- e.g. the p=2
  2-adic-inverse bug caught during v1 -- cannot occur here, because there
  is no division anywhere in this program.

  Derived from the recon brief's mathematics section (~/workspace/recon-polya.md);
  the C source was deliberately not consulted.

CONVENTION: L(1) = +1 (lambda(1) = +1 since Omega(1) = 0).  The sieve covers
n >= 2; every statement of the result is scoped to n >= 2, matching the
chunk certificates in polya/certs/.

Environment: Python 3.12, numpy 1.26.4, numba 0.67.0.
Usage:
  python3 liouville_sieve2.py --selftest        # small-N validation vs brute force
  python3 liouville_sieve2.py --N 1000000000   # full run: anchors + chunk stats
"""

import argparse
import json
import sys
import time
from pathlib import Path

import numpy as np

try:
    import numba
except ImportError:
    sys.exit("numba is required (pip install numba)")

NEG = -(1 << 60)
CHUNK = 10_000_000
N_CERT = 906_150_257  # Tanaka's smallest counterexample; certs cover [2, N_CERT]


@numba.njit
def sieve_odds(is_comp, N):
    """Mark composites among odd numbers; is_comp[i] <-> n = 2*i+1."""
    sq = int(N ** 0.5)
    # (p*p)//2 is the index of p*p for odd p
    for i in range(1, sq // 2 + 1):
        if is_comp[i] == 0:
            p = 2 * i + 1
            start = (p * p) // 2
            for j in range(start, len(is_comp), p):
                is_comp[j] = 1


@numba.njit
def collect_primes(is_comp, out):
    out[0] = 2
    c = 1
    for i in range(1, len(is_comp)):
        if is_comp[i] == 0:
            out[c] = 2 * i + 1
            c += 1
    return c


@numba.njit
def flip_multiples(par, drivers, N):
    """For each prime power q in drivers: par[m] ^= 1 for all multiples m of q."""
    for qi in range(len(drivers)):
        q = drivers[qi]
        m = q
        while m <= N:
            par[m] ^= np.uint8(1)
            m += q


@numba.njit
def analyze(par, N, n_chunks, csum, cmax, carg, res):
    """Single left-to-right pass: L values, chunk stats, anchors.

    res = [L(N), first n>=2 with L(n)>0, max L over [2,N], argmax]
    Chunks: chunk k covers [2+k*CHUNK, 2+(k+1)*CHUNK-1], last ends at N_CERT.
    """
    L = 1  # L(1) = +1
    first_cross = 0
    maxL = NEG
    argmaxL = 0
    ck = 0
    next_boundary = 2 + CHUNK
    cur = 0
    curmax = NEG
    curarg = 0
    for n in range(2, N + 1):
        lam = -1 if par[n] else 1
        L += lam
        if L > maxL:
            maxL = L
            argmaxL = n
        if first_cross == 0 and L > 0:
            first_cross = n
        if n <= N_CERT:
            if n == next_boundary:
                csum[ck] = cur
                cmax[ck] = curmax
                carg[ck] = curarg
                ck += 1
                next_boundary += CHUNK
                cur = 0
                curmax = NEG
                curarg = 0
            cur += lam
            if cur > curmax:
                curmax = cur
                curarg = n
    csum[ck] = cur
    cmax[ck] = curmax
    carg[ck] = curarg
    res[0] = L
    res[1] = first_cross
    res[2] = maxL
    res[3] = argmaxL


@numba.njit
def prefix_before(par, lo, hi):
    """Max relative prefix sum of lambda over n in [lo, hi]; returns (best, arg)."""
    cur = 0
    best = NEG
    arg = lo
    for n in range(lo, hi + 1):
        lam = -1 if par[n] else 1
        cur += lam
        if cur > best:
            best = cur
            arg = n
    return best, arg


def primes_upto(N):
    """All primes <= N as int64 array (odd-only bitset sieve, numba)."""
    t0 = time.time()
    is_comp = np.zeros(N // 2 + 1, dtype=np.uint8)
    is_comp[0] = 1  # n = 1 is not prime
    sieve_odds(is_comp, N)
    # pi(1e9) = 50847534; over-allocate slightly
    out = np.empty(51_000_000, dtype=np.int64)
    c = collect_primes(is_comp, out)
    del is_comp
    print(f"  primes: {c} primes <= {N} ({time.time()-t0:.1f}s)")
    return out[:c]


def prime_powers_ge2(primes_small, N):
    """All prime powers p^k <= N with k >= 2 (only ~3.6k of them)."""
    out = []
    for p in primes_small:
        if p * p > N:
            break
        q = p * p
        while q <= N:
            out.append(q)
            if q > N // p:
                break
            q *= p
    return np.array(out, dtype=np.int64)


def run(N):
    """Full pipeline at bound N. Returns dict of results."""
    t0 = time.time()
    primes = primes_upto(N)
    small = primes[primes <= int(N ** 0.5) + 1]
    pp2 = prime_powers_ge2(small, N)
    print(f"  prime powers p^k (k>=2): {len(pp2)}")
    drivers = np.concatenate([primes, pp2])
    del primes, small

    print(f"  flipping multiples of {len(drivers)} prime powers ...")
    par = np.zeros(N + 1, dtype=np.uint8)
    t1 = time.time()
    flip_multiples(par, drivers, N)
    del drivers
    print(f"  flips done ({time.time()-t1:.1f}s)")

    n_chunks = (N_CERT - 1 + CHUNK - 1) // CHUNK
    csum = np.zeros(n_chunks, dtype=np.int64)
    cmax = np.zeros(n_chunks, dtype=np.int64)
    carg = np.zeros(n_chunks, dtype=np.int64)
    res = np.zeros(4, dtype=np.int64)
    t1 = time.time()
    analyze(par, N, n_chunks, csum, cmax, carg, res)
    print(f"  analysis pass done ({time.time()-t1:.1f}s)")
    out = {
        "N": N,
        "L_N": int(res[0]),
        "first_cross": int(res[1]),
        "maxL": int(res[2]),
        "argmaxL": int(res[3]),
        "csum": csum,
        "cmax": cmax,
        "carg": carg,
        "elapsed": time.time() - t0,
    }
    # max relative prefix before the first crossing inside the last chunk
    lo_last = 2 + (n_chunks - 1) * CHUNK
    best, arg = prefix_before(par, lo_last, N_CERT - 1)
    out["last_chunk_lo"] = lo_last
    out["max_prefix_before_first"] = int(best)
    out["argmax_prefix_before_first"] = int(arg)
    print(f"  total {out['elapsed']:.1f}s")
    return out


def selftest():
    """Validate against brute-force trial division at small N."""
    N = 100_000
    print(f"selftest at N={N}")
    par = np.zeros(N + 1, dtype=np.uint8)
    primes = primes_upto(N)
    small = primes[primes <= int(N ** 0.5) + 1]
    drivers = np.concatenate([primes, prime_powers_ge2(small, N)])
    del primes, small
    flip_multiples(par, drivers, N)
    del drivers
    lam = np.where(par[2:] == 0, 1, -1)
    L = 1 + np.cumsum(lam)  # L(1) = +1 convention
    # published spot values (OEIS A002819 partial sums)
    for n, want in [(100, -2), (1000, -14), (10000, -94), (100000, -288)]:
        got = int(L[n - 2])
        assert got == want, f"L({n})={got}, want {want}"
        print(f"  L({n}) = {got} OK")
    # brute force cross-check for n <= 2000
    for n in range(2, 2001):
        m, omega = n, 0
        d = 2
        while d * d <= m:
            while m % d == 0:
                m //= d
                omega += 1
            d += 1 if d == 2 else 2
        if m > 1:
            omega += 1
        want = 1 if omega % 2 == 0 else -1
        got = int(lam[n - 2])
        assert got == want, f"lambda({n}): sieve={got}, brute={want}"
    print("  brute-force agreement for 2..2000 OK")
    print("SELFTEST PASS")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--N", type=int, default=1_000_000_000)
    args = ap.parse_args()
    if args.selftest:
        selftest()
        return
    out = run(args.N)
    print(f"L({args.N}) = {out['L_N']}")
    print(f"first n>=2 with L(n)>0: {out['first_cross']}")
    print(f"max L over [2,{args.N}]: {out['maxL']} at n={out['argmaxL']}")
    # persist chunk stats for the cert-agreement check
    certdir = Path(__file__).resolve().parent.parent / "certs"
    with open("/tmp/sieve2_chunks.json", "w") as f:
        json.dump({
            "L_N": out["L_N"],
            "first_cross": out["first_cross"],
            "maxL": out["maxL"],
            "argmaxL": out["argmaxL"],
            "csum": out["csum"].tolist(),
            "cmax": out["cmax"].tolist(),
            "carg": out["carg"].tolist(),
            "max_prefix_before_first": out["max_prefix_before_first"],
        }, f)
    print("chunk stats -> /tmp/sieve2_chunks.json")


if __name__ == "__main__":
    main()