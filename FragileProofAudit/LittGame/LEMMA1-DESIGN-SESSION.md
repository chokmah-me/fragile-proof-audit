# Lemma 1 design session packet — LittGame M4 (ExactFairness)

Prepared 2026-11-18. This packet prepares the design session only. It changes
no Lean file and nothing in the 32-gate verdict lock.

Branch: `selfhosted-runner`. M4 head: `da62cb6`. Target file:
`FragileProofAudit/LittGame/ExactFairness.lean` (489 lines, 8 theorems,
builds clean, zero proof holes). Paper: Basdevant et al., "On cases where
Litt's game is fair", arXiv:2406.20049v2 (text on disk in the M4 working
folder, `basdevant.txt`).

## The six verified increments

All six landed 2026-10-05 on `selfhosted-runner`, each with a targeted
`lake build FragileProofAudit.LittGame.ExactFairness` at EXIT 0 and a source
grep showing zero proof holes.

1. `f622cbf` — theta/Cor bridge and phi well-definedness core.
   `sum_range_pow_lt`, `sum_pow_injective`, `overlapSet_eq_of_theta_eq`,
   `overlap_mem_swap`. Status: verified, complete.
2. `77a8785` — `OverlapTiling` structure, `OverlapTiling.word`,
   `OverlapTiling.phi` with the validity-preservation proof (index-reversal
   argument through `overlap_mem_swap`). Status: verified, complete.
3. `3a7be82` — `swapAB'_involutive` (data-level involution of the A/B swap).
   Status: verified. Open residue: the full structure equality
   `(T.phi hAA).phi hAA = T` is deferred in a file note; it follows from this
   lemma plus `List.reverse_reverse` plus proof irrelevance.
4. `5cfd1c4` — count swapping. `swap_eq_A_iff`, `count_swap_blocks`,
   `OverlapTiling.phi_count_swap`. Status: verified, complete.
5. `325a392` — pattern decomposition, definitions only. `Pattern`,
   `NoABSubword`, `interleaveGaps`, `PatternDecomp`. Status: compiles;
   existence and uniqueness of the maximal decomposition are NOT proved.
6. `da62cb6` — the `L_M(I)` deferral, documented. A concrete `L_M(I)` Finset
   built on `Finset.univ : Finset (Fin L → Fin q)` with computed `L` caused
   prohibitive typeclass search and was reverted. Documentation only;
   this is the stall this session exists to clear.

## The stalled goal, verbatim

From the file header's proof plan (step 4):

> 4. **Key lemma**: `L_M(n) = L_{φ(M)}(n)` (pattern counts preserved).

From the pattern-decomposition section of the file:

> Basdevant et al., Lemma 1: For a pattern `M = (E₁, ..., Eₖ)` (each `Eᵢ ∈ {A,B}`)
> and gap lengths `I = (i₀, ..., iₖ)`, let
> `L_M(I) = {Y = X₀ E₁ X₁ ... Eₖ Xₖ : Patt_{A,B}(Y) = M, |Xⱼ| = iⱼ}`.
> Then `|L_M(I)| = |L_{φ(M)}(I')|` where `I' = (iₖ, ..., i₀)`.

The deferral note at the end of the file, word for word:

```lean
-- Note: `L_M(I)` (the Finset of words with pattern `M` and gap lengths `I`)
-- requires bounded word enumeration (`wordsOfLength` via `List.ofFn`).
-- The `Finset.univ : Finset (Fin L → Fin q)` with computed `L` causes
-- prohibitive typeclass search; deferred to a dedicated increment.
-- Basdevant et al., Lemma 1: `|L_M(I)| = |L_{φ(M)}(I')|`.
```

The paper's own statement (Lemma 1): for any pattern `M = (E1, ..., Ek)` and
any `I = (i0, ..., ik)`, `LM(I) = |{Y = X0 E1 X1 ... Ek Xk : PattA,B(Y) = M;
for all j, |Xj| = ij}|`, and the claim is `|LM(I)| = |Lφ(M)(I')|` with
`I' = (ik, ..., i0)`.

## How the paper proves it (the product induction)

So the session opens at the argument, not at the statement:

- Product factorization. `L_M(I)` factors as
  `L_{E_1}(i_0, 0)` times the product over `j = 1..k-1` of
  `L_{(E_j, E_{j+1})}(0, i_j, 0)` times `L_{E_k}(0, i_k)`, where the factors
  count gap words with fixed boundary blocks. The `φ(M), I'` side is the same
  product in reverse order with each factor swapped.
- Mixed-boundary factors (one side ends A, the other starts B) match
  factor-by-factor directly.
- Equal-boundary factors reduce everything to two equalities, the paper's
  (4), for each `i ≥ 0`:
  `L_{(A,A)}(0, i, 0) = L_{(B,B)}(0, i, 0)` and `L_{(B)}(0, i) = L_{(A)}(i, 0)`.
- (4) is proved by strong induction on `i`. Base `i = 0` is clear. The step
  counts words `XA` by their maximal pattern decomposition:
  `L_{(A)}(i, 0) = 2^i − Σ |L_M(I)|` over patterns `M ≠ (A)` ending in `A`
  and gap tuples with all entries `< i`, applying Lemma 1 itself at those
  smaller tuples. Lemma 1 and (4) are mutually recursive; neither is proved
  first.

Downstream of Lemma 1: the main exact-fairness theorem (file header step 5)
is a counting corollary once pattern counts are preserved.

## The three decisions

### Decision 1 — How is `L_M(I)` represented?

The stall is here: the goal cannot even be stated until bounded word
enumeration exists in a form Lean will elaborate.

- **A. Count decompositions, not words.** `L_M(I)` is the Finset of
  `PatternDecomp` data with `pat = M` and gap lengths `I`; the lemma counts
  decompositions and transfers to word counts through existence and
  uniqueness of the maximal decomposition. Cost: increment 5 left existence
  and uniqueness unproved; they become hard prerequisites.
- **B. Enumerate words as lists, with instance discipline.** Build
  `wordsOfLength` by recursion on lists instead of `Finset.univ` over
  `Fin L → Fin q`, so no computed-length Fintype instance is ever searched.
  `L_M(I)` is a filter of the length-`L` words by a decidable pattern
  predicate. Cost: the pattern predicate (`Patt_{A,B}(Y) = M` with gap
  lengths) must be made decidable and tied back to `PatternDecomp`.
- **C. No Finset at all.** State the lemma as a `Fintype.card` equality
  between subtypes (words with pattern `M` and gap lengths `I` versus the
  `φ` side). Cost: the product factorization and the `2^i − Σ` counting step
  must be rebuilt as cardinal arithmetic on subtypes; the mixed case is
  natural, the equal case is not.

Unlocks: the statement of Lemma 1 itself. Every later choice is written
against whichever representation this decision fixes. The `da62cb6` evidence
rules out the naive form of the function-space route; any revival of it has
to show the instance discipline that avoids the blowup.

### Decision 2 — Product formula as in the paper, or a direct bijection?

- **A. Transcribe the paper.** Define the factor counts
  `L_{(E, E')}(0, i, 0)` and `L_{(E)}(i, 0)` as cardinals of explicit sets,
  prove the product factorization of `|L_M(I)|`, match the mixed factors
  directly, and reduce the equal factors to (4). Cost: the factorization
  proof needs words to split independently at the pattern blocks, which
  leans on Decision 1 and, under 1A, on decomposition uniqueness.
- **B. Direct bijection on words.** Blocked where it matters: no explicit
  bijection witnesses `L_{(A,A)}(0, i, 0) = L_{(B,B)}(0, i, 0)`. The paper
  proves that equality by counting and induction precisely because no map
  is available. Choosing B means finding a map the paper does not give;
  that is a research problem, not a transcription.
- **C. Counting assembly without named factors.** Prove (4) first (its
  induction needs only Lemma 1 at smaller tuples and the total count
  `2^i`), then assemble Lemma 1 by summing over decompositions rather than
  multiplying named factor counts. Cost: the bookkeeping of the sum over
  patterns is heavier; no reusable factor-count API comes out of it.

Unlocks: whether `PatternDecomp` existence and uniqueness are on the
critical path (yes under A, partly under C), and how many new definitions
enter the file before the first new theorem can be stated.

### Decision 3 — How is the mutual induction packaged?

Lemma 1 at gap bound `i` uses (4) at values up to `i`; (4) at `i` uses
Lemma 1 at all tuples with entries `< i`. The session must fix the
induction skeleton before any proof text is written.

- **A. One combined strong induction on `i`.** Prove
  `P(i) := (4) at i, and Lemma 1 for every (M, I) whose largest gap is i`
  by strong induction on `i`, doing (4) first inside each step (it only
  needs Lemma 1 below `i`) and Lemma 1 at bound `i` second (it needs (4)
  up to `i`). One induction, order inside the step is load-bearing.
- **B. Two separate inductions.** (4) by strong induction on `i`; Lemma 1
  by induction on total length `|I| + |M|`. Cost: the appeal from (4)'s
  step to Lemma 1 at smaller tuples has to be re-justified in the
  total-length measure, and the two skeletons can drift apart.
- **C. Well-founded recursion on (largest gap, tuple size).** Most
  flexible; most plumbing; the termination proof becomes its own
  increment.

Unlocks: the skeleton every proof in the Lemma 1 increment hangs on, and
whether the factor counts (if Decision 2A is taken) are defined for all
`i` up front, which all three options require.

## What the resulting proofs must satisfy (solo forge bar)

The eight theorems now in the file have never been through the solo axiom
forge (`scripts/forge/verify_lean_project.py`). They are:

1. `sum_range_pow_lt`
2. `sum_pow_injective`
3. `overlapSet_eq_of_theta_eq`
4. `overlap_mem_swap`
5. `swapAB'_involutive`
6. `swap_eq_A_iff`
7. `count_swap_blocks`
8. `OverlapTiling.phi_count_swap`

For the eight, and for every theorem the Lemma 1 work adds, to pass the
queued solo forge, the resulting state of the branch must satisfy all of:

- Full build at EXIT 0 on the pinned toolchain
  (`leanprover/lean4:v4.32.2` with the repo lakefile), run on the
  self-hosted runner lane, not hand-waved from a partial build.
- Source scan clean across all Lean sources: no `sorry`, no `admit`, no
  `sorryAx`, no `native_decide`, no local `axiom` declarations.
- Axiom audit clean: `#print axioms` for each of the eight theorems and
  each new Lemma 1 theorem reports only the standard three axioms,
  `propext`, `Classical.choice`, `Quot.sound`.
- No new axioms smuggled in by the Lemma 1 route: decomposition existence
  or uniqueness, factor counts, and the induction skeleton must all be
  proved or defined inside the kernel-checked file, so the audit above
  stays at the standard three. A route that needs an extra axiom is a
  failed route, however clean the counting looks.
- The 32-gate verdict lock is untouched by this work, as is every other
  milestone's file.
