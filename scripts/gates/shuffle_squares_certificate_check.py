#!/usr/bin/env python3
"""Independent ceremony gate for arXiv:2610.02262 (shuffle squares in smooth
binary words), lengths 18-40 certificate claim.

Derived SOLELY from the definitions in the paper (paper.tex, pinned in
incoming/shuffle-squares-smooth-binary-words/PIN.md). NOT derived from the
author's verifier script.

Claim under test (Proposition 2.1 / finite base): every smooth tangram of
even length 18..40 is a shuffle square, witnessed by an empty-to-empty
FIFO control recorded in smooth-even-base-certificate.json.

Definitions used (paper):
  * smooth: repeated finite derivative D reaches the empty word, where
    D deletes a boundary run of length 1 (crossing deletions -> empty).
  * tangram: both letters occur an even number of times.
  * FIFO certificate (Lemma 1.4): scan w left to right with a queue; a
    control letter U appends the current symbol; a control letter D
    requires the current symbol to equal the queue front and pops it.
    An empty-to-empty control certifies a shuffle square.

Method:
  1. Regenerate ALL smooth words through length 40 bottom-up, by
     induction on the derivative: w (nonempty) is smooth iff it is
     differentiable and D(w) is smooth. Preimages of a smooth parent v
     are built from v's symbols as interior run-lengths with optional
     singleton boundary runs (a=1 iff r_1=1 deletes; a=0 requires the
     first interior run to have length 2, i.e. v starts with '2', and
     symmetrically for b). |D(w)| < |w| for nonempty w, so the
     induction is well-founded. This generator is structurally
     independent of the naive enumerator in shuffle_squares_independent.py;
     their smooth sets are cross-checked for lengths <= 16.
  2. Check totals against the certificate: 16146 smooth words, 4204
     smooth tangrams through 40.
  3. Exact coverage: the set of positive smooth tangrams at even
     lengths 18..40 must equal the key set of "positive_controls"
     exactly (no missing, no invented words).
  4. Replay every one of the 4170 FIFO controls empty-to-empty.

Exit 0 iff every check passes (claim holds). Stdlib only, no randomness.
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(os.path.dirname(HERE))
INCOMING = os.path.join(
    PROJECT, "incoming", "shuffle-squares-smooth-binary-words")
CERT_JSON = os.path.join(INCOMING, "smooth-even-base-certificate.json")


def runs(w):
    out = []
    for ch in w:
        if out and out[-1][0] == ch:
            out[-1][1] += 1
        else:
            out.append([ch, 1])
    return [(s, n) for s, n in out]


def deriv(w):
    if not w:
        return ""
    rl = [n for _, n in runs(w)]
    t = len(rl)
    lo = 1 if rl[0] == 1 else 0
    hi = t - 1 if rl[-1] == 1 else t
    if lo >= hi:
        return ""
    return "".join("1" if rl[i] == 1 else "2" for i in range(lo, hi))


def build_word(run_lengths, first_symbol):
    parts = []
    s = first_symbol
    for r in run_lengths:
        parts.append(s * r)
        s = "2" if s == "1" else "1"
    return "".join(parts)


def smooth_words_through(nmax):
    """All smooth words of length <= nmax, by induction on D.

    w smooth, |w| = n >= 1  <=>  w differentiable, D(w) = v smooth,
    |v| < n. Preimages: interior run-lengths are v's symbols; a (resp. b)
    marks a deleted boundary singleton run. a=1 iff r_1=1; a=0 requires
    v nonempty starting with '2' (else D would delete r_1 too).
    """
    by_len = {0: {""}}
    for n in range(1, nmax + 1):
        got = set()
        for k in range(n):
            for v in by_len[k]:
                interior = [int(c) for c in v]
                for a in (0, 1):
                    if v and a == 0 and v[0] != "2":
                        continue
                    for b in (0, 1):
                        if v and b == 0 and v[-1] != "2":
                            continue
                        rl = ([1] if a else []) + interior + ([1] if b else [])
                        if sum(rl) != n:
                            continue
                        for s in ("1", "2"):
                            w = build_word(rl, s)
                            # safety: D(w) must be exactly v
                            assert deriv(w) == v, (w, v)
                            got.add(w)
        by_len[n] = got
    return by_len


def is_tangram(w):
    return w.count("1") % 2 == 0 and w.count("2") % 2 == 0


def replay_fifo(w, control):
    """True iff control is an empty-to-empty FIFO certificate for w."""
    if len(control) != len(w):
        return False
    queue = []
    head = 0
    for sym, c in zip(w, control):
        if c == "U":
            queue.append(sym)
        elif c == "D":
            if head >= len(queue) or queue[head] != sym:
                return False
            head += 1
        else:
            return False
    return head == len(queue)  # queue fully drained


def main():
    cert = json.load(open(CERT_JSON))
    exceptions = set(cert["exceptions"])
    controls = cert["positive_controls"]
    failures = []

    print("regenerating smooth words through 40 (bottom-up on D)...")
    by_len = smooth_words_through(40)
    # Convention note: the empty word is smooth by definition (D(eps)=eps)
    # and is a tangram and a shuffle square, but the author's regeneration
    # counts start at length 1 (the paper's height-one roots). Compare on
    # nonempty words.
    all_smooth = {w for ws in by_len.values() for w in ws} - {""}
    print("nonempty smooth words through 40: %d (certificate says %d)"
          % (len(all_smooth), cert["smooth_word_count"]))
    if len(all_smooth) != cert["smooth_word_count"]:
        failures.append("smooth word total mismatch")

    tangrams = {w for w in all_smooth if is_tangram(w)}
    print("smooth tangrams through 40: %d (certificate says %d)"
          % (len(tangrams), cert["smooth_tangram_count"]))
    if len(tangrams) != cert["smooth_tangram_count"]:
        failures.append("smooth tangram total mismatch")

    # Cross-check with the naive enumerator's smooth sets for n <= 16.
    sys.path.insert(0, HERE)
    import shuffle_squares_independent as indep
    for n in range(0, 17, 2):
        naive = {w for w in indep.all_words(n) if indep.is_smooth(w)}
        if naive != by_len[n]:
            failures.append("smooth-set mismatch vs naive enum at n=%d" % n)
    print("bottom-up smooth sets agree with naive enumeration (n<=16): "
          + ("True" if not any("naive" in f for f in failures) else "False"))

    # Exact coverage: per the paper ("one FIFO control for each of the 4170
    # positive smooth tangrams through length 40"), the control keys must
    # be exactly the positive smooth tangrams at every length.
    positives = {w for w in tangrams if w not in exceptions}
    control_keys = set(controls.keys())
    print("positive smooth tangrams through 40: %d; controls: %d"
          % (len(positives), len(control_keys)))
    if positives != control_keys:
        missing = sorted(positives - control_keys)[:5]
        extra = sorted(control_keys - positives)[:5]
        failures.append("coverage mismatch: missing=%s extra=%s"
                        % (missing, extra))
    else:
        print("control coverage is exact (no missing, no invented words)")

    # Replay every FIFO control.
    bad = 0
    for w, ctl in controls.items():
        if not replay_fifo(w, ctl):
            bad += 1
            if bad <= 5:
                print("BAD control for %r: %r" % (w, ctl[:60]))
    print("FIFO controls replayed: %d/%d valid empty-to-empty"
          % (len(controls) - bad, len(controls)))
    if bad:
        failures.append("%d invalid FIFO controls" % bad)

    if failures:
        print("\nFAIL:")
        for f in failures:
            print(" -", f)
        return 1
    print("\nPASS: 16146 smooth words / 4204 smooth tangrams regenerated "
          "independently (nonempty; eps is smooth but uncounted by the "
          "author's convention); all 4170 FIFO controls valid and covering "
          "exactly the positive smooth tangrams through length 40.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
