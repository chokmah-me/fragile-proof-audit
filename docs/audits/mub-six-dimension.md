# Audit note — mutually unbiased bases in dimension six, statement-fidelity audit (openai/math family 266, 2026-10-14)

**Claim artifact:** the openai/math catalogue entry for family 266
("Exactly three mutually unbiased bases in dimension six"). The entry
names two accompanying preprints — *The maximum number of mutually
unbiased bases in dimension six* (September 24, 2026) and *Exact
Fourier certificates for complex Hadamard matrices of order six*
(September 24, 2026) — exactly as the scope doc lists them. The
mathematics below is taken only from the catalogue entry, the scope
doc, and the linked Lean statements; the papers' mathematics was not
re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 1,
drift 10 — catalogue headline outruns the linked Lean scope note.
**Campaign objects:** `incoming/mub-six-266/` (`PIN.md`, pinned
sources).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-14`. The inventory entry, the scope doc, and both Lean files
were read at the pinned SHA above; all quotations below are verbatim
from those sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "Exactly three mutually unbiased bases in dimension six."

> "Proves $`N(6)=3`$, resolving Zauner's dimension-six mutually
> unbiased bases conjecture: three such bases exist in ℂ<sup>6</sup>,
> but four cannot. The exclusion is a complete certified computation
> under the stated binary64 arithmetic and compiler conditions. An
> independent companion proves the Matolcsi–Ruzsa–Weiner
> Fourier-vanishing conjecture for order-six complex Hadamard matrices
> outside Tao's cubic equivalence class. ([Lean](lean/docs/266.md))"

## The scope note (verbatim admissions)

> "The linked formalization proves a weaker family bound: every
> family in its mutually unbiased bases model has at most five
> members."

> "The selected statement does not establish the paper's upper bound
> of three or its computer-assisted exclusion of four arbitrary
> bases."

> "The paper's full character-sum vanishing theorem and its mutually
> unbiased bases bound are outside this selected statement."

## The formalized statements (verbatim, as pinned)

`lean/ComparatorChallenges/MUBSix.lean` (in `namespace OAI/MUB6`;
`Coord := Fin 6`; `IsMUBFamily {n : ℕ} (B : Fin n → Basis)` states
`Complex.normSq (inner ℂ (B r i) (B s j)) = (1 : ℝ) / 6` for `r ≠ s`;
`Attainable (n : ℕ) : Prop := ∃ B : Fin n → Basis, IsMUBFamily B`):

> `theorem fourier_and_family_bound :`
>     `(∀ H : CMatrix, IsHadamard H → ¬Equivalent H tao →`
>       `∀ π : Equiv.Perm Coord, g H (permuteCharge π alpha) = 0) ∧`
>     `(∀ n : ℕ, Attainable n → n ≤ 5) := by`
>   `sorry`

`lean/ComparatorChallenges/HadamardCubeFiber.lean`
(`namespace OAI/HadamardSix`):

> `lemma rowRatio_cubeFiber_sum_zero {H : Matrix6} (hH : IsComplexHadamard H)`
>     `(hs : IsComplexHadamard (entrywiseSquare H)) {i j : Index} (hij : i ≠ j)`
>     `(a b : ℂ) (hne : a ≠ b)`
>     `(hab : ∀ k, rowRatio H i j k ^ 3 = a ∨ rowRatio H i j k ^ 3 = b) :`
>     `∑ k ∈ cubeFiber (rowRatio H i j) a, H i k * star (H j k) = 0 := by`
>   `sorry`

Both files end in `sorry`: they are Comparator *challenge*
statements — unsolved challenge statements, not proven results.

## M1 — Statement correspondence: NOT ESTABLISHED (headline); partial statements are weakened versions

The catalogue claims `N(6) = 3`: three bases exist, four cannot. The
formalized statements claim:

1. `∀ n, Attainable n → n ≤ 5` — an upper bound of **five**, not
   three. This is the bound the scope note calls "weaker."
2. No existence statement at all — nothing proves (or states)
   `Attainable 3`. The "three such bases exist" half of the headline
   has no formal counterpart.
3. No exclusion of four bases — neither as a theorem nor as an
   assumption. The catalogue's "complete certified computation"
   exclusion is entirely outside the formalization.
4. A Fourier character-sum vanishing statement for order-six complex
   Hadamard matrices outside Tao's equivalence class, uniform over
   coordinate permutations (`permuteCharge π alpha`), and a cube-fiber
   cancellation lemma — these are weakened/scope-limited versions of
   the companion results, per the scope note's own admission that
   "the paper's full character-sum vanishing theorem … [is] outside
   this selected statement."

So M1 is the drift, confirmed against the Lean text itself: the
formalized statement does not state the catalogue's headline claim.
The scope note discloses exactly this — the drift is self-admitted,
not hidden.

## M2 — Argument correspondence: NOT APPLICABLE (proofs are `sorry`)

Both formalized statements end in `sorry`. There is no derivation to
compare against the source argument — no faithful-formalization vs
independent-proof question arises at all. A future pick that fills
these sorrys would owe the full M2 audit; per the scope note, the
reduction to the Tao-equivalence class and the certified-computation
exclusion sit outside the selected statements, so any future M2 would
meet the same *re-proved vs source-faithful* split the 3SUM note
recorded for its reduction steps.

## M3 — Credit honesty: scope note PASS; catalogue framing NOT (relative to the formalization)

Two layers, different answers:

- **The scope doc is unusually honest.** It states the weakened bound
  in the first paragraph, repeats that the selected statement "does
  not establish the paper's upper bound of three or its
  computer-assisted exclusion of four arbitrary bases," and closes
  with "the paper's full character-sum vanishing theorem and its
  mutually unbiased bases bound are outside this selected
  statement." Nothing about the formalization's actual content is
  over-claimed in the doc.
- **The catalogue entry credits more than the linked formalization
  contains.** The headline "Exactly three mutually unbiased bases in
  dimension six" and "Proves $`N(6)=3`$, resolving Zauner's …
  conjecture" carry a `([Lean](lean/docs/266.md))` link — but the
  linked doc says the formalization proves at most five and does not
  establish the bound of three. A reader following the Lean link to
  check `N(6) = 3` finds `n ≤ 5` plus two `sorry` challenge
  statements. The catalogue also advertises "a complete certified
  computation" exclusion as part of the linked claim; that
  computation is nowhere in the formalization.

## M4 — Fine print (first live use, adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statements, with residual lines:

1. **The MUB model is the standard definition, not a weakened
   model.** `IsMUBFamily` uses `OrthonormalBasis` over
   `EuclideanSpace ℂ (Fin 6)` with cross-inner-product norm-squared
   `1/6` — the textbook definition of mutually unbiased bases. No
   modeling gap vs "arbitrary bases in ℂ⁶" is visible in the defs;
   the numerical weakening (≤5 vs ≤3) is not a definitional issue.
   Tag: **source-faithful**. Residual: if this encoding failed, the
   bound would evaporate; it survives.
2. **No existence content.** `Attainable n` is the right shape for an
   upper-bound direction, but nothing proves `Attainable 3` — the
   "three exist" half of the headline has no formal home at all.
   Dangling check: a genuine instance of the source claim (3 bases
   attained, 4 excluded) *satisfies* the formalized statements
   vacuously (3 ≤ 5) — they are compatible with the claim but do not
   entail it. No contradiction; the gap is one-sided weakness.
3. **Fourier-branch exclusions** (`¬Equivalent H tao`, fixed charge
   `alpha := ![1, 1, 1, -1, -1, -1]`, uniformity over
   `permuteCharge π`): these restrict the statement to the
   non-Tao branch, matching the paper's stated conjecture scope
   (outside Tao's cubic equivalence class). Tag: **source-faithful
   restriction**. Residual: the reduction *every* order-six complex
   Hadamard matrix is either Tao-class or covered lies outside the
   selected statements (per the scope note) — the full theorem's
   inheritance stops there.
4. **The certified-computation exclusion (binary64 arithmetic +
   compiler conditions).** The paper's headline exclusion of four
   bases rests on this machine model; it is *entirely* outside the
   formalization. As a load-bearing assumption of the catalogue
   claim: it **evaporates** from the formalization's inheritance
   chain (the Lean statements inherit nothing from it), and it is
   the assumption whose failure would sink the headline while the
   `n ≤ 5` bound — proved by different machinery — survives.
   Tag: **risk-inducing** for any reader who takes the Lean link as
   evidence for the exclusion.
5. **Trusted base:** Lean `v4.34.1` + Mathlib `d13f23b` (upstream
   pins). Both files `import Mathlib` and live in
   `ComparatorChallenges/` — they are challenge statements awaiting
   solutions, with `sorry` proofs. Current verified status of these
   statements: **zero** — they are not proven results. (This is
   fine-print, not an accusation: the files are labeled
   `ComparatorChallenges` upstream; but the catalogue's Lean link
   does not say so.)
6. **Definitional choices in the Fourier part:** `Equivalent` uses
   full Hadamard equivalence with arbitrary unit phases
   (`source-faithful`); the `alpha` charge vector is a specific
   probe charge whose uniformity over permutations is built into
   the statement (**convenience-only**, mitigated by the explicit
   `∀ π`); `omega := Complex.exp (2πi/3)` is standard. None of
   these is load-bearing against M1.

## Receipt

- `incoming/mub-six-266/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes, and
  toolchain/Mathlib pins as read 2026-10-14.
- **GAP (explicit):** no independent forge build and no Comparator
  run were performed in this audit — M1–M4 are a statement audit,
  and compilation is never its acceptance criterion. Note that the
  two statements currently end in `sorry`, so a build would not
  change any finding above; closing this GAP would require a
  build-bearing pick on whatever fills the sorrys.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — the catalogue's
headline claim (`N(6) = 3`) is not stated by the formalized
statements (bound ≤5, no existence, no exclusion); the drift is
confirmed against the Lean text and is exactly what the scope note
discloses; **M2** not applicable (both statements end in `sorry`);
**M3** — scope note honest, catalogue framing over-credits the
formalization; **M4** inventoried above (the certified-computation
machine model is the risk-inducing load-bearing assumption of the
headline, entirely outside the formalization).
