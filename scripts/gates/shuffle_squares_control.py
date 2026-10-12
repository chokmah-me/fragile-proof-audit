#!/usr/bin/env python3
"""Discrimination control for the shuffle-squares ceremony gate.

Same instrument as scripts/gates/shuffle_squares_independent.py, with ONE
definition perturbed: odd Parikh (both letters occur an ODD number of
times) instead of even Parikh. Everything else is held fixed: the same
smoothness predicate from the paper, the same exact support-partition
shuffle-square decision procedure, the same enumeration bound (even
lengths <= 16).

Purpose: prove the instrument is not tautological. If the instrument
returned "34" regardless of the Parikh condition, the ceremony's exact
equality would be evidence of nothing. The control must return a count
DIFFERENT from 34 (and a different word set).

Exit 0 iff the perturbed count differs from 34. Stdlib only.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import shuffle_squares_independent as indep


def is_odd_parikh(w):
    return w.count("1") % 2 == 1 and w.count("2") % 2 == 1


def main():
    n_neg = 0
    neg = set()
    for n in range(2, 17, 2):
        for w in indep.all_words(n):
            if not indep.is_smooth(w):
                continue
            if not is_odd_parikh(w):
                continue
            if not indep.is_shuffle_square(w):
                n_neg += 1
                neg.add(w)
    print("odd-Parikh smooth non-shuffle words (length <= 16): %d" % n_neg)
    print("sample: %s" % sorted(neg)[:8])
    if n_neg == 34:
        print("CONTROL FAILED: perturbed definition also yields 34 -- "
              "instrument may be tautological")
        return 1
    print("CONTROL PASS: count %d != 34; the instrument discriminates on "
          "the Parikh condition." % n_neg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
