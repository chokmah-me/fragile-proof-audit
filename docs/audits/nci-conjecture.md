# Audit note — NCI conjecture (Track D#7) — SKIPPED, no finite gate

**Claim artifact:** the Non-Cancelling Intersections conjecture.
**Refutation artifact:** Wilhelm, H., arXiv:2608.27416v2, Theorem 8.1 /
Corollary 8.2.
**Campaign objects:** `docs/blueprint/nci-conjecture.md` (the full record),
`results/nci_skip_meta.json`, `incoming/nci-wilhelm-2608.27416.pdf`.
**There is no gate script, and none should be written.**

## Bug report

| Field | Content |
|---|---|
| **Lemma** | — |
| **Instance** | — |
| **False instance** | **Not available.** The refutation exhibits no witness. |

**Verdict: SKIPPED — no finite gate.** This is a scope decision, not a
BREAK and not a PASS. It is deliberately absent from `EXPECTED_VERDICT`.

## Why there is nothing to gate

Wilhelm's refutation is a **first-moment existence argument**. Lemma 7.2 picks
a marking `m` uniformly at random per line, bounds `Pr[T admissible]` by a
union bound over short traces, sums over candidate sizes `2p ≤ |T| ≤ 4p` to get
an expected admissible-set count `E_p < 1` for `p > 600`, and concludes that
*some* marking works — because a non-negative integer-valued random variable
with expectation below 1 must sometimes be zero.

**No marking is exhibited.** Nothing in the paper says which of the
`(C(p,w))^{p²+p}` candidate markings has the property. The paper's own §9 Open
Problems item 1 states that even a small-`p` explicit counterexample is
unsolved, so there is no smaller instance to fall back on either.

The only numerically checkable content in the paper — the double-counting
identities in (7.1) — is true of every finite point set unconditionally.
Testing it would be precisely the check-that-cannot-fail this campaign forbids
(`docs/GATE-BEFORE-PROVE.md`). Writing that script would have produced a green
tick and no information.

## The corpus-doc defect: fabrication, not corruption

This is the target that changed how the campaign reads its corpus.

`corpus/live-fragile-proofs-2024-2026.md` gives NCI a **full, well-formed
Target Identifier block** — unlike the Chung-Graham ghost row — and asserts:

> **Verifiable Gate / Counterexample**: Python script validating the
> non-existence of admissible sets between sizes … in the specified marked
> plane configuration.

No such gate exists in the source. This is categorically worse than the
image-corruption that hit Tang-Zhang, Thakur and Sárközy: there, formulas were
garbled and visibly so. Here a plausible, specific artifact was **invented**,
and the entry looked *more* trustworthy than the ones that were merely broken.

The same document contradicts itself about it — its ranking table row 7 lists
"Python/CPU Gate Runtime: N/A (Symbolic logic bound)".

## What this cost, and what it bought

It cost one session's fetch-and-read. It bought protocol step 0 in
`docs/GATE-BEFORE-PROVE.md`: pin and read the real paper before writing any
gate. The three Track D targets gated *before* this lesson had to be
retrofitted the following day, and one of them (Sárközy) turned out to have the
conjecture's own threshold wrong.

## Reopen condition

Only if a future paper exhibits an explicit marking `m`, or resolves Wilhelm's
§9 open problem 1. Absent that, do not write a gate — and do not let the corpus
doc's claimed one suggest otherwise.
