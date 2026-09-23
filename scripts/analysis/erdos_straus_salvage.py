#!/usr/bin/env python3
"""
Follow-up analysis for the Thm-10 interval gap (arXiv:2404.01508v3).

The gate (scripts/gates/erdos_straus_checker.py) implements the paper's
parameters LITERALLY and finds k=718 failing at n=6. This script asks the
deeper question: is the gap repairable?

For each even n and each k in [n! - n/2, n! - 1], search for ANY
(d, u, v) with:
    u, v | k+d,   4d-1 | u+v,   y,z positive integers,
where y = (k+d)(u+v)/((4d-1)u), z = (k+d)(u+v)/((4d-1)v),
such that the paper's chain yields 4/(4k+1) = 1/x + 1/(ny) + 1/(nz)
with x = k+d — verified with exact Fraction arithmetic.

Odd k are already covered by the paper's "automatic" case (d=u=1, v=2),
verified separately in the gate; they are re-confirmed here for completeness.

Search bounds: d in [1, n!/2] is the paper's range; u,v range over divisors
of k+d. For n=8, k+d <= 40320 — cheap. n=10 would need k+d ~ 3.6M divisor
enumerations x5 k-values; skipped (n=4,6,8 already decide the question:
the paper's *method* either repairs everywhere or it doesn't).

This is ANALYSIS, not a gate: it does not modify the gate's verdict.
Exit 0 always; prints the salvage table.
"""

import math
import sys
from fractions import Fraction


def divisors(m):
    ds = set()
    i = 1
    while i * i <= m:
        if m % i == 0:
            ds.add(i)
            ds.add(m // i)
        i += 1
    return sorted(ds)


def build_identity(k, d, u, v):
    """Paper's chain, exact. Returns (ok, detail)."""
    a = 4 * d - 1
    b = k + d
    if b % u != 0 or b % v != 0:
        return False, "u,v not both | k+d"
    if (u + v) % a != 0:
        return False, "4d-1 not | u+v"
    if (b * (u + v)) % (a * u) != 0 or (b * (u + v)) % (a * v) != 0:
        return False, "y,z not integral"
    y = b * (u + v) // (a * u)
    z = b * (u + v) // (a * v)
    if y <= 0 or z <= 0:
        return False, "y,z not positive"
    if Fraction(a, b) != Fraction(1, y) + Fraction(1, z):
        return False, "a/b != 1/y + 1/z"
    x = k + d
    n = 4 * k + 1
    if Fraction(4, n) != Fraction(1, x) + Fraction(1, n * y) + Fraction(1, n * z):
        return False, "final ES identity fails"
    return True, "d=%d u=%d v=%d y=%d z=%d" % (d, u, v, y, z)


def salvage_search(k, dmax):
    """Find any (d,u,v) completing the construction. Returns witness or None."""
    # odd k: the paper's automatic case always works (gate-verified); use it.
    if k % 2 == 1:
        ok, detail = build_identity(k, 1, 1, 2)
        return (1, 1, 2, detail) if ok else None
    for d in range(1, dmax + 1):
        b = k + d
        a = 4 * d - 1
        divs = divisors(b)
        # need u,v | b with a | u+v; try small u first
        for u in divs:
            # v must satisfy v | b and v = m*a - u for some m >= 1
            # => iterate m, check v = m*a - u divides b
            m = 1
            while True:
                v = m * a - u
                if v < 1:
                    m += 1
                    continue
                if v > b:
                    break
                if b % v == 0:
                    ok, detail = build_identity(k, d, u, v)
                    if ok:
                        return (d, u, v, detail)
                m += 1
    return None


def main():
    all_salvageable = True
    for n in (4, 6, 8):
        fn = math.factorial(n)
        lo = fn - n // 2
        fails_paper_params = []  # with the paper's literal (d,u,v)
        unsalvageable = []
        salvage_examples = {}
        for k in range(lo, fn):
            # paper's literal parameters
            if k % 2 == 1:
                ok, _ = build_identity(k, 1, 1, 2)
            else:
                d = fn - k
                ok, _ = build_identity(k, d, n, n - 1)
            if not ok:
                fails_paper_params.append(k)
            # salvage search over the paper's d-range
            w = salvage_search(k, fn // 2)
            if w is None:
                unsalvageable.append(k)
                all_salvageable = False
            elif k in fails_paper_params:
                salvage_examples[k] = w
        print("n=%d interval [%d, %d]:" % (n, lo, fn - 1))
        print("  fail with paper's literal parameters: %s"
              % (fails_paper_params if fails_paper_params else "none"))
        print("  unsalvageable by ANY (d,u,v) in range: %s"
              % (unsalvageable if unsalvageable else "none"))
        for k, w in sorted(salvage_examples.items()):
            print("  k=%d salvaged via %s" % (k, w[3]))
    print("CONCLUSION: interval conclusions %s by alternate parameters."
          % ("ALL SALVAGEABLE" if all_salvageable else "NOT all salvageable"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
