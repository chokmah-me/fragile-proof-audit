#!/usr/bin/env python3
"""Control probe (NOT a gate): is Theorem 5 of arXiv:2405.03731v1
  "Let D = A - F, j minimal on D, |D| > 1 ==> 2|D_j| <= |D| + 1"
true on small n? Exhaustive for n<=4, sampled closures for n=5.
A = nonzero bitmasks; F union-closed <=> forall X,Y in F: X|Y in F.
"""
import itertools, random, sys

def all_union_closed(n):
    A = list(range(1, 1 << n))
    Aset = set(A)
    bad = 0
    for r in range(len(A) + 1):
        for combo in itertools.combinations(A, r):
            F = set(combo)
            ok = True
            for x in combo:
                for y in combo:
                    if (x | y) not in F:
                        ok = False
                        break
                if not ok:
                    break
            if ok:
                yield F

def check_thm5(n, F):
    A = set(range(1, 1 << n))
    D = A - F
    if len(D) <= 1:
        return True
    cnt = [0] * n
    for X in D:
        for i in range(n):
            if X >> i & 1:
                cnt[i] += 1
    j = min(range(n), key=lambda i: cnt[i])
    return 2 * cnt[j] <= len(D) + 1

def closure(n, S):
    F = set(S)
    changed = True
    while changed:
        changed = False
        for x in list(F):
            for y in list(F):
                z = x | y
                if z not in F:
                    F.add(z)
                    changed = True
    return F

def main():
    for n in (3, 4):
        total = bad = 0
        for F in all_union_closed(n):
            total += 1
            if not check_thm5(n, F):
                bad += 1
                print("COUNTEREXAMPLE n=%d F=%s" % (n, sorted(F)))
                if bad > 5:
                    break
        print("n=%d: %d union-closed families, %d violate Thm5" % (n, total, bad))
    # n=5 sampled
    random.seed(12345)
    A = list(range(1, 32))
    total = bad = 0
    for _ in range(300000):
        S = [x for x in A if random.random() < 0.35]
        F = closure(5, S)
        total += 1
        if not check_thm5(5, F):
            bad += 1
            print("COUNTEREXAMPLE n=5 F size %d" % len(F))
            if bad > 5:
                break
    print("n=5 sampled: %d families, %d violate Thm5" % (total, bad))

main()
