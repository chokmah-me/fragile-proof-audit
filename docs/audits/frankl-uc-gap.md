# Audit note — FRK-UC Demontis union-closed — proof GAP (type G)

**Target:** harvest dossier II, Hit 2 (FRK-UC), "claimed full proof" of
Frankl's union-closed sets conjecture.
**Paper:** Roberto Demontis, "The union-closed set conjecture is true",
arXiv:2405.03731v1 [math.CO], 6 May 2024. v1 only; never withdrawn.
PDF (104,779 bytes) SHA-256
`f7c748d33c8721841b7ffe8a77ee0de7c89f72a91dc4416a8c18d1a0137cf6c3`;
extraction clean, 8 pages, no figures.
**Date:** 2026-09-23. **Recon:** `corpus/recon-frankl-uc.md` (full lemma
map, verbatim load-bearing statements).
**Campaign objects:** `scripts/analysis/frankl_uc_thm5_probe.py` (control
probe, not a gate).

**Dossier discrepancy (recorded, not repaired):** the dossier attributes
this paper to "S. Schäge" and describes an entropy-method argument. The
actual paper is by Roberto Demontis and uses combinatorial
deletion-sequence machinery (bases, "optimal sequences", "quasiminimal"
elements). Do not trust the dossier's description — the paper was read.

## Claim under test

Theorem 1: every finite union-closed `F ⊆ 2^[n] − {∅}` has an element in
at least half its sets. Frankl's conjecture (1979) is open; the community
still treats it as open (no v2, no published rebuttal, no journal
acceptance in 28 months).

## The defect (proof-logical, not computational)

The decisive inference is Theorem 4 → Theorem 5. Theorem 5
(`2|D^j| ≤ |D|+1` for `j` minimal on `D = A − F`, `|D| > 1`) feeds
Theorem 1 through sound arithmetic. The inference establishing it is
invalid in two places.

**Theorem 4's statement is an ill-formed conditional:**
`∃i[(∃Y quasiminimal(i,D,Y)) → 2|(D∪Y)^i| ≤ |(D∪Y)|+1]` — `Y` is bound in
the antecedent but free in the consequent.

**Theorem 4's proof, Case 1** (verbatim load-bearing sentences):
"Suppose that for some i that satisfy the theorem for Dt−1 … If we could
choose Y such that i quasiminimal on D for Y, we could do as follows. …
By definition i quasiminimal on Dt−1. Thus, by inductive hypothesys,
`2|(Dt−1 ∪ {Xt; Xt+1} ∪ Y)^i| ≤ |(D ∪ Y)| + 1`."
Four defects: (a) "i that satisfy the theorem" is meaningless for an
∃-statement; (b) the proof proceeds on the undischarged hypothesis "If we
could choose Y"; (c) "by definition i quasiminimal on Dt−1" is false —
quasiminimality (Def 9) is relative to an exhibited `Y ⊂ F`, none given;
(d) the induction hypothesis yields `∃i'[antecedent → consequent]`, not
the inequality for *this* `i`. Case 2 is no better: it concludes
`|Dt| = 1` "proved at the inductive step" from a degenerate subcase, and
writes `2|(Dt ∪ {Y1; Xt+1} ∪ {Y2})^i| = 2|Dti| + 4` although Def 9(2)
requires `i ∉ Y1`.

**Theorem 5's proof** (verbatim): "By Theorem 4, it exists i, not
necessarily different from j, such that for the set {Xt; Xt+1} i
quasiminimal on Dt−1 for {Xt; Xt+1} and
`2|(Dt−1 ∪ {Xt; Xt+1})^i| ≤ |Dt−1 ∪ {Xt; Xt+1}| + 1`."
Two defects: (a) **quantifier confusion** — Theorem 4's `∃i[A(i) → B(i)]`
is upgraded to `∃i[A(i,Y₀) ∧ B(i)]` for the *specific*
`Y₀ = {X_t, X_{t+1}}`, which nothing provides (the optimal sequence is for
`j`, and Theorem 4's `i` carries no quasiminimality guarantee for this
`Y₀`); (b) **type error against Definition 9** — quasiminimality requires
`Y = {Y1;Y2} ⊂ F`, but `X_t, X_{t+1} ∈ D = A − F`. "Quasiminimal on
D_{t−1} for {X_t; X_{t+1}}" is ill-typed per the paper's own Def 9.

No easy repair is visible: instantiating at `i := j` still needs Theorem
4's implication for *all* `i`, which is not what Theorem 4 states or
proves. A repair would have to prove a strictly stronger Theorem 4 —
essentially as hard as Theorem 5 itself.

## Why no finite gate can catch this

Theorem 5 *is* universal over families and finitely falsifiable — but the
defect is in the *inference*, which no family enumeration can detect.
Control probe (`scripts/analysis/frankl_uc_thm5_probe.py`): **all 61**
union-closed families on n=3, **all 2480** on n=4, and 300,000 sampled
union-closed families on n=5 satisfy Theorem 5 with **zero violations**.
Any enumeration gate would PASS and miss the real defect. The dossier's
hypothesized gate (falsify the lemma statement by enumeration) tests the
wrong object — the Sárközy failure mode in reverse: here the statement
survives and the proof doesn't.

## Disposition

**Proof GAP (type G) — route refuted, theorem untouched.** The paper's
argument does not establish Theorem 5, hence not Theorem 1.

**Explicitly NOT a BREAK:** no lemma statement was falsified
(Theorem 5 holds on every family checked), and Frankl's conjecture itself
is unaffected by this finding. The 23/23 verdict lock is untouched.

## Reproduction

1. Fetch arXiv:2405.03731v1; verify the SHA-256 above.
2. Read Theorem 4's statement and proof (Case 1) and Theorem 5's proof;
   check the quoted lines against the PDF — the quantifier shape and the
   Def-9 domain mismatch are visible on the page.
3. `python3 scripts/analysis/frankl_uc_thm5_probe.py` — expect 0
   violations (this is the control, confirming the finding is scoped to
   the inference, not the statement).

## Re-examination under the GAP evidentiary standard (2026-09-23)

Independent second reading (verbatim against arXiv HTML 2405.03731v1):
GAP confirmed real. Two defects — (a) Theorem 4's quantifier confusion
(delivers ∃i[(∃Y Q)→C] at best; Theorem 5 uses ∃i[Q∧C] for a specific
Y₀, an unlicensed upgrade) and (b) a type error against the paper's own
Definition 9 (quasiminimality requires Y ⊂ F; the invocation's
{X_t,X_{t+1}} ⊂ D) — plus an unjustified "2|D^j|=2|D^i|" step and a
failed Case-1 induction in Theorem 4's proof. **Repairability: fatal to
the route as written** — no patch within the paper's machinery works;
a uniform strengthening of Theorem 4 would be ≈ as hard as Theorem 5
itself. Frankl's conjecture untouched (statement holds on all checked
families). Existing note assessed accurate; no material overstatement.
Full memo: `drafts/gap-rework-memo.md`.
