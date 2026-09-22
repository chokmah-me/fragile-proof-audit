# Audit note — Baste–Fürst–Henning–Mohr–Rautenbach domination inequality (Track D#2)

**Claim artifact:** Baste, Fürst, Henning, Mohr, Rautenbach (2019/2020):
every finite regular graph of positive degree satisfies `γ(G) ≤ γ_e(G)`.
**Refutation artifact:** Afrasyab, K., arXiv:2609.10783v1, Theorem 1.
**Campaign objects:** `docs/blueprint/baste-domination.md`,
`scripts/gates/baste_domination.py`,
`scripts/controls/baste_break_control.py`,
`results/baste_domination_gate_meta.json`,
`results/baste_break_control_meta.json`,
`incoming/baste-afrasyab-2609.10783.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | `γ(G) ≤ γ_e(G)` for every finite regular graph `G` of positive degree |
| **Instance** | The 50-vertex cubic formula-incidence graph: 15 variable pairs (30 literal vertices) + 20 clause vertices, 75 edges |
| **False instance** | `γ(G) = 16 > 15 = γ_e(G)` |

**Verdict: BREAK.** Attack type **F**. False already at `Δ = 3`.

## What was gated — both bounds, independently

This is the Track D target where the campaign closed the most on its own.

- **Regularity**, not assumed: "every signed literal occurs exactly twice" is
  *checked* from the raw clause list, which is what forces 3-regularity. 50
  vertices, 75 edges, all degree 3.
- **`γ_e(G) = 15`, closed on both sides.** Upper: the matching
  `M = {v_j⁻v_j⁺ : j = 1..15}` is verified to be a valid *maximal* matching
  (the 20 unsaturated clause vertices are pairwise non-adjacent). Lower: in a
  cubic graph an edge is adjacent to at most four others, so one edge dominates
  at most five, and `|M| ≥ ⌈75/5⌉ = 15` — a general argument about any maximal
  matching in any cubic graph, not a property of this witness.
- **`γ(G) ≤ 16`**: the explicit dominating set is verified to dominate every
  vertex, with the undominated list empty.
- **`γ(G) ≥ 16`**: closed by **this campaign's own exact branch-and-bound**,
  not by re-implementing the paper's `2²⁰` clause-subset reduction — 8 856 929
  nodes explored, no timeout, no dominating set of size ≤ 15 exists. An
  independent route to the same bound.

If the budget is exceeded the gate reports `BREAK_PARTIAL` rather than
asserting a bound it did not prove. It did not need to.

## Provenance (re-audited 2026-09-21)

Originally built from a live arXiv HTML fetch with no PDF pinned. The PDF is
now pinned, and the result is the strongest confirmation in Track D:

- All **twenty clauses** match the paper's Section 2 display verbatim.
- The labelling `v_j⁻ = 2(j−1)`, `v_j⁺ = 2(j−1)+1`, `c_a = 29+a` matches.
- The paper's `D₀` (Section 4) is
  `{0,2,5,7,8,13,15,30,31,32,33,35,37,42,46,48}` — **character-identical to
  the witness the gate had found independently.**

The graph itself is not new: it is the public 50-vertex cubic graph previously
used to refute the stronger `i(G) ≤ γ_e(G)`. The new content is its *ordinary*
domination number, which is what this gate closes.

## Control

`scripts/controls/baste_break_control.py` — **NO FALSE POSITIVE.**

The sharpest question here is whether the branch-and-bound solver can ever find
a small dominating set when one exists, or whether it just always reports
"none". Tested on graphs with known answers: K₄ (budget 1 → found), Petersen
(budget 3 → found; budget 2 → correctly declines, below the textbook minimum),
and the target graph at budget 16 → found. A real bug (`n = NUM_VERTICES`
hardcoded instead of `n = len(adj)`) surfaced the moment the control tried a
non-target graph, and is fixed.

The transcription check was rewritten in the re-audit: it had been
substring-matching a prose summary against itself. It now compares the gate's
clause list, labelling and `D₀` against an independent second transcription of
the PDF.

## Order-minimality

Combined with Gupta's theorem that every cubic graph on ≤ 48 vertices satisfies
the inequality, this counterexample is order-minimal among cubic ones. The gate
does **not** verify Gupta's theorem; that is cited, not checked.

## Lean

None. Finite simple graphs are tractable in mathlib in principle, but the
`γ ≥ 16` half is an exhaustive search over a 50-vertex graph — a formalization
would need either a verified search or the paper's set-cover recurrence. Not
attempted.

## Not done, on purpose

Did not re-implement the paper's `2²⁰ = 1 048 576` clause-subset enumeration,
its two derived lower bounds, or its 893 049-node proof-tree certificate. The
independent branch-and-bound reaches the same conclusion by a different route,
which is worth more than replaying theirs.
