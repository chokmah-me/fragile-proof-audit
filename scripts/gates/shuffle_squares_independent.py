#!/usr/bin/env python3
"""Independent ceremony gate for arXiv:2610.02262 (shuffle squares in smooth
binary words), exception-count claim.

Derived SOLELY from the definitions in the paper (paper.tex, pinned in
incoming/shuffle-squares-smooth-binary-words/PIN.md). NOT derived from the
author's verifier script, which is treated as a black-box instrument.

Claim under test (Corollary 1.2): there are EXACTLY 34 smooth binary
tangrams that are not shuffle squares; all have length <= 16.

Definitions (paper, section "Preliminaries"):
  * runs: maximal constant factors of a word over {1,2}.
  * differentiable: every run length r_i is in {1,2}.
  * D(w): the word r_1...r_t with r_1 deleted if r_1 == 1 and r_t deleted
    if r_t == 1; if the deletions cross, the result is empty. D(eps) = eps.
  * smooth: repeated D reaches eps (every iterate is over {1,2} by
    construction; differentiability is checked at each step).
  * tangram (even-Parikh): both letters occur an even number of times.
  * shuffle square: positions can be partitioned into two increasing
    supports i_1<...<i_m, j_1<...<j_m with w[i_t] == w[j_t] for all t.
    Equivalent: exists I with |I| = n/2 such that the subsequence of w at
    I equals the subsequence at the complement of I.

Method: naive full enumeration of all 2^n words over {1,2} for even
2 <= n <= 16 (odd lengths cannot be tangrams). For every smooth tangram,
exact support-partition search decides shuffle-square status. The
resulting exception set must equal the author's 34-word table
(smooth-even-exceptions.md "By length" list) element-for-element, and the
per-length (smooth, tangram, negative) counts must match the paper's
Table 1 as recorded in the certificate JSON's "counts".

Exit 0 iff every check passes (claim holds). Stdlib only, no randomness.
"""

import itertools
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(os.path.dirname(HERE))
INCOMING = os.path.join(
    PROJECT, "incoming", "shuffle-squares-smooth-binary-words")
EXCEPTIONS_MD = os.path.join(INCOMING, "smooth-even-exceptions.md")
CERT_JSON = os.path.join(INCOMING, "smooth-even-base-certificate.json")


def runs(w):
    """Maximal constant factors of w, as a list of (symbol, length)."""
    out = []
    for ch in w:
        if out and out[-1][0] == ch:
            out[-1][1] += 1
        else:
            out.append([ch, 1])
    return [(s, n) for s, n in out]


def deriv(w):
    """Finite derivative D(w) per the paper's definition."""
    if not w:
        return ""
    rl = [n for _, n in runs(w)]
    t = len(rl)
    lo = 1 if rl[0] == 1 else 0
    hi = t - 1 if rl[-1] == 1 else t
    if lo >= hi:
        return ""
    return "".join("1" if rl[i] == 1 else "2" for i in range(lo, hi))


def is_differentiable(w):
    return all(n in (1, 2) for _, n in runs(w))


def is_smooth(w):
    """True iff repeated differentiation reaches the empty word."""
    cur = w
    while cur:
        if not is_differentiable(cur):
            return False
        cur = deriv(cur)
    return True


def is_tangram(w):
    """Even Parikh: both letters occur an even number of times."""
    return w.count("1") % 2 == 0 and w.count("2") % 2 == 0


def is_shuffle_square(w):
    """Exact support-partition decision procedure."""
    n = len(w)
    assert n % 2 == 0
    m = n // 2
    idx = range(n)
    # Subsequence of w at a set of positions.
    for I in itertools.combinations(idx, m):
        inset = set(I)
        a = "".join(w[i] for i in I)
        b = "".join(w[i] for i in idx if i not in inset)
        if a == b:
            return True
    return False


def all_words(n):
    return ("".join(t) for t in itertools.product("12", repeat=n))


def author_exception_set():
    """Parse the 34-word flat list from the author's exceptions md."""
    words = []
    with open(EXCEPTIONS_MD) as f:
        for line in f:
            s = line.strip()
            if s and all(c in "12" for c in s):
                words.append(s)
    return words


def main():
    cert = json.load(open(CERT_JSON))
    table_counts = {int(k): v for k, v in cert["counts"].items()}
    author_words = author_exception_set()
    assert len(author_words) == 34, (
        "author table does not list 34 words: %d" % len(author_words))
    assert sorted(author_words) == sorted(cert["exceptions"]), (
        "md exception list != certificate JSON exception list")
    author_set = set(author_words)

    failures = []
    mine = set()
    print("length | smooth | tangram | negatives | table-ok")
    for n in range(2, 17, 2):
        n_smooth = n_tangram = n_neg = 0
        for w in all_words(n):
            if not is_smooth(w):
                continue
            n_smooth += 1
            if not is_tangram(w):
                continue
            n_tangram += 1
            if not is_shuffle_square(w):
                n_neg += 1
                mine.add(w)
        want = table_counts[n]
        ok = (n_smooth, n_tangram, n_neg) == tuple(want)
        print("%6d | %6d | %7d | %9d | %s (table %s)"
              % (n, n_smooth, n_tangram, n_neg, ok, want))
        if not ok:
            failures.append("count mismatch at n=%d: got (%d,%d,%d), "
                            "table %s" % (n, n_smooth, n_tangram, n_neg,
                                           want))

    print("\nmy exception count: %d; author count: %d" % (len(mine),
                                                          len(author_set)))
    if mine != author_set:
        only_mine = sorted(mine - author_set)
        only_author = sorted(author_set - mine)
        failures.append("exception SET mismatch: only-mine=%s only-author=%s"
                        % (only_mine, only_author))
    else:
        print("exception sets match element-for-element: True")

    if failures:
        print("\nFAIL:")
        for f in failures:
            print(" -", f)
        return 1
    print("\nPASS: exactly the author's 34 exceptions, all length <= 16; "
          "per-length counts match Table 1.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
