# Discrimination control receipt — shuffle-squares ceremony gate

**Date:** 2026-10-12 · **Status:** PASS (exit 0)
**Instrument:** `scripts/gates/shuffle_squares_control.py`
(`sha256 09048499d260a115bcd678aabb8d1ef7652ffcb135a7443e61da20ab65c5ba04`),
which reuses the exact instrument of
`scripts/gates/shuffle_squares_independent.py`
(`sha256 c1db5658f52862e343a3eca1f70e5b61a29ae89ef48e8239272f214fbfabb9df`):
the same paper-derived smoothness predicate, the same exact
support-partition shuffle-square decision procedure, the same
enumeration bound (all words over {1,2}, even lengths ≤ 16).

**Perturbation (single definition flipped, everything else fixed):**
odd Parikh — both letters occur an *odd* number of times — instead of
even Parikh (tangram).

**Command:** `python3 scripts/gates/shuffle_squares_control.py`
**Exit code:** 0

**Output (verbatim):**
```text
odd-Parikh smooth non-shuffle words (length <= 16): 222
sample: ['1121', '11211212', '112112122112', '11211212211211', '1121121221121122', '112112122121', '1121121221211221', '1121121221221121']
CONTROL PASS: count 222 != 34; the instrument discriminates on the Parikh condition.
```

**Reading:** the instrument returns 222 under the perturbed definition
versus 34 under the claim's definition. A "34" from the ceremony gate is
therefore not a tautology of the instrument — the count moves sharply
when the load-bearing definition moves. This receipt is instrument
evidence, not a claim-lock row.
