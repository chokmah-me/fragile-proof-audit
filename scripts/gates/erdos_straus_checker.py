#!/usr/bin/env python3
"""
Gate for arXiv:2404.01508v3 — Lopez, "A Complete Congruence System
for the Erdos-Straus Conjecture".

Transcribes the paper's claims EXACTLY as stated. No charitable fixes.
Ambiguities are flagged in comments / the audit doc, not resolved silently.

Claim under test (Conjecture 1, paper L379-382):
    Every prime p admits d,n in N with
        p = -4d (mod 4dn-1)   [Type A]  or  p = -n (mod 4dn-1) [Type B].
Decided through the paper's own iff-criteria, valid for p = 4k+1:
    Type A <=> exists t>=0, w | (k+1+t) with w = -1 (mod 3+4t)   [Thm 1]
    Type B <=> exists t>=0, a,b | (k+1+t) with a+b = 3+4t         [Thm 6]
with the paper's own bound 0 <= t <= (k-1)//3                    [Prop 2, 4].

NOTE (Thm 6 proof gap, documented not fixed): the theorem *states* the
condition with a,b each dividing k+1+t, but the converse direction of the
proof only assumes ab | k+1+t. Since ab|m implies a|m and b|m, the proved
converse is for a STRONGER hypothesis than... actually ab|m => a|m, so the
converse proves (ab|m => Type B) while the statement claims (a|m,b|m <=> Type B).
We check the condition AS STATED (a|m and b|m).

Also checked:
  * Type C (Thm 9(iv), informational): exists t, a*b = k+1+t, (3+4t)|(a+b).
  * Thm 10 "automatic" step (L874-876): for odd k, d=u=1, v=2 gives
    u,v | k+d and 4d-1 | u+v; the ES identity 4/n=1/x+1/(ny)+1/(nz) is
    built from the paper's formulas and verified with exact arithmetic.
  * Thm 10 interval parameters (L878-887) for small even n, implemented
    literally: d=f(n)=n/2, u=n, v=n-1 on k in [n!-n/2, n!-1].
"""

import math
import sys
from fractions import Fraction

LIMIT = 100_000
MOD = 840
# Mordell-resistant residue classes (paper L41-42)
HARD_CLASSES = (1, 121, 169, 289, 361, 529)


def sieve_primes(n):
    bs = bytearray(b"\x01") * (n + 1)
    bs[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if bs[i]:
            bs[i * i:n + 1:i] = b"\x00" * ((n - i * i) // i + 1)
    return [i for i, b in enumerate(bs) if b]


def divisor_sieve(n):
    """divs[m] = sorted list of all positive divisors of m."""
    divs = [[] for _ in range(n + 1)]
    for d in range(1, n + 1):
        for m in range(d, n + 1, d):
            divs[m].append(d)
    return divs


def has_type_a(p, divs):
    """Thm 1 as stated. Returns (bool, witness)."""
    k = (p - 1) // 4
    assert 4 * k + 1 == p, "criterion only for p = 4k+1"
    tmax = (k - 1) // 3  # Prop 2
    for t in range(tmax + 1):
        m = k + 1 + t
        s = 3 + 4 * t
        if s > m + 1:  # w+1 is a positive multiple of s, w <= m
            continue
        for w in divs[m]:
            if (w + 1) % s == 0:  # w = -1 (mod 3+4t)
                return True, (t, w)
    return False, None


def has_type_b(p, divs):
    """Thm 6 AS STATED (a,b each divide k+1+t). Returns (bool, witness)."""
    k = (p - 1) // 4
    assert 4 * k + 1 == p
    tmax = (k - 1) // 3  # Prop 4
    for t in range(tmax + 1):
        m = k + 1 + t
        s = 3 + 4 * t
        if s - 1 > m:  # min possible a*b with a+b=s is s-1 > m: impossible
            continue
        for a in divs[m]:
            if a >= s:
                break
            b = s - a
            if b >= 1 and m % b == 0:
                return True, (t, a, b)
    return False, None


def has_type_c(p, divs):
    """Thm 9(iv), informational: ab = k+1+t, (3+4t) | (a+b)."""
    k = (p - 1) // 4
    assert 4 * k + 1 == p
    tmax = (k - 1) // 3  # no bound given in paper; reuse Prop 4 bound
    for t in range(tmax + 1):
        m = k + 1 + t
        s = 3 + 4 * t
        for a in divs[m]:
            if a * a > m:
                break
            b = m // a
            if (a + b) % s == 0:
                return True, (t, a, b)
    return False, None


def check_automatic_case(k):
    """Paper L874-876, implemented literally.

    'Note that if k is odd it is automatically fulfilled by taking
    d=u=1, v=2.'  i.e. with a=4d-1, b=k+d: u,v | b and a | u+v.
    Then rebuilds the paper's chain:
        a/b = 1/y + 1/z  =>  4d/(k+d) = 1/(k+d) + 1/y + 1/z
        =>  4/n = 1/x + 1/(n*y) + 1/(n*z),  x = k+d, n = 4k+1.
    Every divisibility and every identity is checked; nothing is assumed.
    """
    assert k % 2 == 1, "automatic case is stated for odd k"
    d, u, v = 1, 1, 2
    a = 4 * d - 1
    b = k + d
    if b % u != 0 or b % v != 0:
        return False, "u,v do not both divide k+d=%d" % b
    if (u + v) % a != 0:
        return False, "4d-1=%d does not divide u+v=%d" % (a, u + v)
    # y = b(u+v)/(a*u), z = b(u+v)/(a*v)  [standard order-2 construction]
    if (b * (u + v)) % (a * u) != 0 or (b * (u + v)) % (a * v) != 0:
        return False, "y,z not integral"
    y = b * (u + v) // (a * u)
    z = b * (u + v) // (a * v)
    if y <= 0 or z <= 0:
        return False, "y,z not positive"
    if Fraction(a, b) != Fraction(1, y) + Fraction(1, z):
        return False, "(4d-1)/(k+d) != 1/y + 1/z"
    x = k + d
    n = 4 * k + 1
    if Fraction(4, n) != Fraction(1, x) + Fraction(1, n * y) + Fraction(1, n * z):
        return False, "final ES identity fails for n=%d" % n
    # x, n*y, n*z must be positive integers (they are by construction)
    return True, "y=%d z=%d x=%d" % (y, z, x)


def check_thm10_interval(n):
    """Paper L878-887, implemented literally.

    'We consider k of the form n!-f(n), and take d=f(n)' with the
    'Equaling' 4f(n)-1 = 2n-1 giving f(n) = n/2 (n even), u=n, v=n-1.
    The paper concludes the whole interval [n!-n/2, n!-1] works.
    Here: for each k in that interval, use the paper's explicit parameters
    (odd k -> automatic case d=1,u=1,v=2; even k -> d=n!-k, u=n, v=n-1)
    and check the claimed divisibilities + resulting ES identity.
    Returns list of (k, ok, detail).
    """
    assert n % 2 == 0
    fn = n // 2
    results = []
    for k in range(math.factorial(n) - fn, math.factorial(n)):
        if k % 2 == 1:
            ok, detail = check_automatic_case(k)
            results.append((k, ok, "automatic: " + detail))
            continue
        # even k: paper's f(n)-construction parameters
        f = math.factorial(n) - k
        d = f
        u, v = n, n - 1
        b = k + d  # = n! by construction
        a = 4 * d - 1
        if b != math.factorial(n):
            results.append((k, False, "k+d != n!"))
            continue
        if b % u != 0 or b % v != 0:
            results.append((k, False, "u,v do not divide n!"))
            continue
        if (u + v) % a != 0:
            results.append(
                (k, False,
                 "PARAMETER VIOLATION: 4d-1=%d does not divide u+v=%d "
                 "(d=f=%d, u=%d, v=%d)" % (a, u + v, d, u, v)))
            continue
        # build identity as in check_automatic_case
        if (b * (u + v)) % (a * u) != 0 or (b * (u + v)) % (a * v) != 0:
            results.append((k, False, "y,z not integral"))
            continue
        y = b * (u + v) // (a * u)
        z = b * (u + v) // (a * v)
        x = k + d
        nn = 4 * k + 1
        if Fraction(a, b) != Fraction(1, y) + Fraction(1, z):
            results.append((k, False, "a/b != 1/y+1/z"))
            continue
        if Fraction(4, nn) != Fraction(1, x) + Fraction(1, nn * y) + Fraction(1, nn * z):
            results.append((k, False, "final ES identity fails"))
            continue
        results.append((k, True, "f-construction ok: d=%d" % d))
    return results


def main():
    divs = divisor_sieve(100_000)
    primes = sieve_primes(LIMIT - 1)
    gate = [p for p in primes if p % MOD in HARD_CLASSES]
    # sanity: all are 1 mod 4 (needed for Thm 1/6 criteria)
    assert all(p % 4 == 1 for p in gate), "non-4k+1 prime in gate set!"

    print("primes < %d in hard classes %s (mod %d): %d"
          % (LIMIT, HARD_CLASSES, MOD, len(gate)))

    # ---- Part A: Conjecture 1 gate ----
    uncovered = []
    counts = {"A": 0, "B": 0, "AorB": 0, "C": 0}
    first_witness = {}
    for p in gate:
        oka, wa = has_type_a(p, divs)
        okb, wb = has_type_b(p, divs)
        okc, wc = has_type_c(p, divs)
        if oka:
            counts["A"] += 1
        if okb:
            counts["B"] += 1
        if oka or okb:
            counts["AorB"] += 1
        else:
            uncovered.append(p)
        if okc:
            counts["C"] += 1
        if oka and "A" not in first_witness:
            first_witness["A"] = (p, wa)
        if okb and "B" not in first_witness:
            first_witness["B"] = (p, wb)
    print("Type A: %d/%d   Type B: %d/%d   A-or-B: %d/%d   Type C (info): %d/%d"
          % (counts["A"], len(gate), counts["B"], len(gate),
             counts["AorB"], len(gate), counts["C"], len(gate)))
    if uncovered:
        print("UNCOVERED PRIMES (no Type A or B): %s" % uncovered)
    else:
        print("No uncovered prime: Conjecture 1 holds on the gate set.")
    for key in ("A", "B"):
        if key in first_witness:
            p, w = first_witness[key]
            print("first Type %s witness: p=%d %s" % (key, p, w))

    # ---- validation against the paper's named examples ----
    print("--- paper's named examples (validation of transcription) ---")
    for p, exp_a, exp_b, note in [
            (193, False, True, "paper: no Type A, has Type B"),
            (2521, False, True, "paper: no Type A, has Type B"),
            (23929, True, False, "paper: no Type B, has Type A"),
            (66529, False, True, "paper: 'another case' lacking Type A")]:
        oka, wa = has_type_a(p, divs)
        okb, wb = has_type_b(p, divs)
        mark = "OK " if (oka == exp_a and okb == exp_b) else "MISMATCH"
        print("%s p=%d: A=%s (exp %s) B=%s (exp %s) [%s]"
              % (mark, p, oka, exp_a, okb, exp_b, note))

    # ---- Part B: Thm 10 automatic case ----
    print("--- Thm 10 'automatic' odd-k case (d=u=1, v=2), exact check ---")
    bad = []
    n_odd = 0
    for k in range(1, 25000, 2):
        n_odd += 1
        ok, detail = check_automatic_case(k)
        if not ok:
            bad.append((k, detail))
            break
    if bad:
        print("PARAMETER VIOLATION at k=%d: %s" % bad[0])
    else:
        print("all %d odd k in [1, 25000) pass: divisibilities hold and "
              "4/(4k+1) = 1/x + 1/(ny) + 1/(nz) exactly." % n_odd)

    # ---- Part C: Thm 10 interval parameters, literally ----
    print("--- Thm 10 interval claim, paper's explicit parameters ---")
    for n in (4, 6):
        res = check_thm10_interval(n)
        fails = [(k, d) for (k, ok, d) in res if not ok]
        print("n=%d interval [%d, %d]: %d/%d k-values pass"
              % (n, math.factorial(n) - n // 2, math.factorial(n) - 1,
                 len(res) - len(fails), len(res)))
        for k, d in fails:
            print("  k=%d FAIL: %s" % (k, d))

    return 0 if not uncovered else 1


if __name__ == "__main__":
    sys.exit(main())
