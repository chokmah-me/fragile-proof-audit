# Audit note — Chung–Graham–Spiro gap-set conjecture (Track D#6)

**Claim artifact:** Chung–Graham–Spiro (2020): the `ℓ`-step gap sets `D_ℓ`,
`U_ℓ` of the down-integer/up-integer partition of `ℤ_{≥2}` agree, `D_ℓ = U_ℓ`,
for every `ℓ ≥ 1`.
**Refutation artifact:** Aliabadi, M., arXiv:2609.04473, Theorem 1.1.
**Campaign objects:** `docs/blueprint/chung-graham-spiro.md`,
`scripts/gates/chung_graham_spiro.py`,
`scripts/controls/chung_graham_break_control.py`,
`results/chung_graham_spiro_gate_meta.json`,
`results/chung_graham_break_control_meta.json`,
`incoming/chung-graham-spiro-2609.04473.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | `D_ℓ = U_ℓ` for every `ℓ ≥ 1` |
| **Instance** | `ℓ = 4`, witness `9` |
| **False instance** | `9 ∈ U₄ \ D₄` — witnessed by the up-block `8, 11, 14, 16, 17`, and absent from every 5-consecutive down-block up to `N = 50 000` |

**Verdict: BREAK.** Attack type **F**.

## Worst provenance in the campaign

The corpus doc has **no body section for this target at all.** It appears only
as row 6 of the final ranking table — no arXiv ID, no Works Cited entry, and
the name itself incomplete: "Chung-Graham Gap-Set", missing **Spiro**.

A table row is not a lead; it is a rumour. The refutation was located by live
web search, and the paper read from the pinned PDF. This is the target that
turned "cross-check the corpus doc's section headers before trusting a table
row" into a habit — and, a day later, into protocol step 0.

## What was gated — two independent representations

- **Path A — direct representation.** The down/up classification computed from
  the closed representation. Anchored against the paper's own published lists:
  `D ∩ [2,17] = {2,5,7,9,10,12,13,15}` and `U ∩ [2,17] =
  {3,4,6,8,11,14,16,17}` both match, as does the paper's `D ∩ [2,113]`.
- **Path B — slow walk simulation.** An independent dynamic simulation of the
  same partition, run to `N = 220`. Of these, 192 are unambiguous (the walk
  ties on the rest, and ties are *excluded* rather than guessed); on the
  unambiguous subset there are **0 disagreements** with Path A.
- **Fast-path self-test.** The fast representation is required to reproduce a
  brute-force computation coefficient-for-coefficient to `N = 1000` (0
  mismatches) before it is used for the deep scan.
- **Depth.** The extended down-scan runs to `N = 50 000` and finds no
  5-consecutive down-block spanning 9.

The five witness integers `8, 11, 14, 16, 17` are required to be unambiguous
and confirmed by **both** paths. Note that `9` itself is reported
informationally only: Path B ties on it, so it is deliberately **not** gating.
The witness is the block, not the integer's own class — a distinction the gate
keeps explicit rather than quietly folding in a tie as agreement.

## Meta/source drift — fixed 2026-09-21

The `false_instance` string said the scan reached `N = 20 000` while
`DEPTH_N = 50 000`; the two had drifted apart. The string is now interpolated
from `DEPTH_N`, so it cannot drift again. The claim was *understated*, not
overstated, but a receipt that misreports its own depth is unusable either way.

## Control

`scripts/controls/chung_graham_break_control.py` — **NO FALSE POSITIVE.**

- **Matched claim:** at `ℓ = 1, 2` the gate's machinery *confirms* `D_ℓ = U_ℓ`,
  which is the paper's own true theorem. The instrument therefore agrees with
  the conjecture where the conjecture holds — the sharpest available evidence
  that it is not an always-BREAK detector.
- **Negative window:** `ℓ = 3`, the case the paper itself flags as open,
  checked to `N = 5000` without a spurious verdict.
- Path B depth and transcription checks as above.

## Lean

None. The partition and gap sets are in principle tractable, but the verdict
rests on a bounded scan to `N = 50 000`; formalizing it would need a verified
search. Not attempted.

## Not done, on purpose

Did not attempt `ℓ ≥ 5`, nor to characterise which `ℓ` admit gaps. Did not
resolve `ℓ = 3`, which the paper leaves open — and deliberately did not let the
gate report anything about it.
