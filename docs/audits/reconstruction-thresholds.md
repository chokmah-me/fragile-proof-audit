# Audit note — exact reconstruction thresholds and four-state tree capacity, statement-fidelity audit (openai/math family 229, 2026-10-14)

**Claim artifact:** the openai/math catalogue entry for family 229
("Exact three- and four-state reconstruction thresholds and
four-state tree capacity"). The entry advertises results for
three-state symmetric AND four-state ferromagnetic broadcasting on
regular and Poisson trees, plus four-state tree capacity and
three-state stochastic-block-model consequences. The mathematics
below is taken only from the catalogue entry, the scope doc, and
the linked Lean statements; the papers' mathematics was not
re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 3,
drift 8 — re-ranked "worse than ranked" on the 2026-10-14 fast
pass, because the catalogue's entire four-state half has no
formalized statement at all.
**Campaign objects:** `incoming/reconstruction-thresholds-229/`
(`PIN.md`, pinned sources, `sources/absence-search.md`).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-14`. The inventory entry, the scope doc, and both Lean
files were read at the pinned SHA above; all quotations below are
verbatim from those sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "Exact three- and four-state reconstruction thresholds and
> four-state tree capacity."

> "Proves the exact reconstruction threshold $`d\lambda^2\gt 1`$,
> with nonreconstruction at equality, for three-state symmetric and
> four-state ferromagnetic broadcasting on regular trees (<i>d</i>
> ≥ 2) and observed Poisson trees (mean <i>d</i> > 1 and <i>d</i>
> > 0, respectively), with Poisson advantage averaged without
> conditioning on survival. The three-state theorem allows both
> signs of <i>λ</i> and gives the exact weak-recovery threshold
> for the symmetric three-community stochastic block model.
> ([Lean](lean/docs/229.md))"

## The scope note (verbatim admissions)

> "The formalization proves the supercritical direction of
> reconstruction for the symmetric three-state broadcast channel,
> whose parameter satisfies $-1/2\le\lambda\le1$. On a regular
> $b$-ary tree, reconstruction holds when $b\lambda^2>1$; on an
> observed Poisson Galton–Watson tree of mean $d$, it holds when
> $d\lambda^2>1$. In each case the root-estimation advantage
> converges to a positive limit, with the Poisson advantage
> averaged over trees and spins."

> "The selected statements cover reconstruction above the
> Kesten–Stigum threshold. Non-reconstruction at or below the
> threshold and the stochastic-block-model consequences in the
> paper are outside them."

Note what the doc's own admissions cover — and do not. The
exclusion paragraph names two things outside the selected
statements (sub-threshold nonreconstruction; SBM consequences).
It does not name the absence of the entire four-state program,
which the headline promises and the title repeats.

## The formalized statements (verbatim, as pinned)

`lean/ComparatorChallenges/ThreeStateSupercritical.lean`
(`namespace OAI/ThreeState`; `Spin := Fin 3`;
`Admissible lam : Prop := -(1/2 : ℝ) ≤ lam ∧ lam ≤ 1`;
`Reconstructs (a : ℕ → ℝ) : Prop := ∃ L : ℝ, 0 < L ∧
Filter.Tendsto a Filter.atTop (nhds L)`):

> `theorem regular_supercritical (b : ℕ) (hb : 2 ≤ b) (lam : ℝ)`
>     `(h : Admissible lam)`
>     `(hcrit : 1 < (b : ℝ) * lam ^ 2) :`
>     `Reconstructs (regularAdvantage b lam h) := by`
>   `sorry`

> `theorem poisson_supercritical (d : ℝ) (hd : 1 < d) (lam : ℝ)`
>     `(h : Admissible lam)`
>     `(hcrit : 1 < d * lam ^ 2) :`
>     `Reconstructs (poissonAdvantage d hd lam h) := by`
>   `sorry`

The file also proves two supporting lemmas — `channel_nonneg`
and `channel_sum` (the three-state channel is a valid PMF) —
which are PMF-well-formedness scaffolding, not the headline
claims.

`lean/ComparatorChallenges/ThreeStateTreeClauses.lean`
(`namespace OAI/ThreeState.TreeClauses`; same `Spin := Fin 3` and
`Admissible`; `Reconstructs lam hlam offspring : Prop` states the
advantage tends to a positive limit):

> `theorem regular_reconstructs_above_KS (b : ℕ) (lam : ℝ)`
>     `(hlam : Admissible lam)`
>     `(hKS : 1 < (b:ℝ)*lam^2) :`
>     `Reconstructs lam hlam (PMF.pure b) := by`
>   `sorry`

> `theorem poisson_reconstructs_above_KS (d : ℝ≥0) (lam : ℝ)`
>     `(hlam : Admissible lam)`
>     `(hKS : 1 < (d:ℝ)*lam^2) :`
>     `Reconstructs lam hlam (poissonPMF d) := by`
>   `sorry`

Supporting proved lemmas in this file: `channelWeight_nonneg`,
`channelWeight_sum`, `poissonWeight_nonneg`,
`poissonWeight_mass`, and the `poissonPMF` construction — again
PMF hygiene, not reconstruction theorems.

All four catalogue-relevant theorems end in `sorry`: they are
Comparator *challenge* statements, not proven results.

## M1 — Statement correspondence: one-sided for the three-state half; the four-state half is ABSENT

Sentence by sentence against the catalogue text:

1. **"exact reconstruction threshold dλ²>1, with nonreconstruction
   at equality"** — only the strict-supercritical direction is
   stated (`1 < bλ² → Reconstructs`; `1 < dλ² → Reconstructs`).
   The "with nonreconstruction at equality" half has no statement
   at all. The doc admits this exclusion explicitly — this part
   of the drift is self-admitted.
2. **"for three-state symmetric and four-state ferromagnetic
   broadcasting"** — the three-state symmetric channel is
   formalized (as `sorry` challenges): `Spin := Fin 3`,
   `Admissible lam` with `-1/2 ≤ λ ≤ 1`. The four-state
   ferromagnetic channel has **no formalized statement
   anywhere in the repo** — see the absence search below.
3. **"on regular trees (d ≥ 2) and observed Poisson trees (mean
   d>1 and d>0, respectively)"** — regular `b`-ary trees with
   `b ≥ 2` and Poisson trees are formalized for the three-state
   half. The catalogue's `d>0` Poisson mean belongs to the
   four-state half (the tree-capacity paper's regime); it is
   absent with it.
4. **"Poisson advantage averaged without conditioning on
   survival"** — the definitions do average over the offspring
   PMF (which assigns positive mass to zero children, so
   extinction events are included, not conditioned out) and over
   spins; but the theorems carrying this convention are the
   three-state `sorry` challenges.
5. **"The three-state theorem allows both signs of λ"** —
   stated as hypothesis (`-1/2 ≤ λ ≤ 1`, so negative λ down to
   `-1/2` are admitted), inside the `sorry` theorems.
6. **"exact weak-recovery threshold for the symmetric
   three-community stochastic block model"** — no statement; the
   doc admits this exclusion explicitly.

So of the catalogue's six claim-components, two are admittedly
outside the statements (equality-side nonreconstruction; SBM),
two are stated as `sorry` challenges (strict supercritical
three-state; the λ-sign range as hypothesis), one is a
definitional convention inside `sorry` theorems (the Poisson
average), and the entire four-state program — ferromagnetic
thresholds and tree capacity, named in both the title and the
headline — has no formal home at all.

## The absence, established (`sources/absence-search.md`)

The four-state half's absence is not an inference from one doc —
it is the convergence of four complete enumerations at the pin:

- The doc's "accompanying paper(s)" section lists **exactly one
  paper** — the September 25 three-state paper. The headline's
  four-state results come from two *other* papers that live in
  the same repo's `preprints/` directory (October 5):
  *The Reconstruction Threshold for the Ferromagnetic Four-State
  Potts Model* (`four-state-potts.pdf`, 514,729 bytes) and *A
  Capacity Criterion for Four-State Potts Reconstruction on
  Trees* (`four-state-capacity.pdf`, 345,473 bytes).
- **Neither four-state paper is referenced by any of the 235
  scope docs** — all 235 were fetched and text-searched for both
  preprint directory names: zero hits.
- The challenge directory (811 files at the pin) contains **no
  four-state broadcasting challenge** — the only `*our*`
  matches are unrelated (`EinsteinFour`, `ExactFourier`,
  `FourRowPermanent`, `TraceReconstruction`); the only
  reconstruction-broadcasting challenges are the two
  `ThreeState*` files.
- The inventory lists exactly two challenges for family 229,
  both three-state; `n_formalized: 0`.

And the doc's exclusion paragraph — which does name
nonreconstruction-at-equality and the SBM consequences — never
names the four-state absence. A reader who follows the
catalogue's Lean link looking for the four-state results finds a
doc that does not mention them and challenges that cannot state
them.

## M2 — Argument correspondence: NOT APPLICABLE to the headline theorems; scaffolding lemmas are proved

All four reconstruction theorems end in `sorry` — there is no
derivation to compare against the source argument (the 266/017
precedent). One distinction from 266/017, handled exactly:
**the two files do contain proved lemmas** — `channel_nonneg`,
`channel_sum`, `channelWeight_nonneg`, `channelWeight_sum`,
`poissonWeight_nonneg`, `poissonWeight_mass`, and the
`poissonPMF` construction. These establish that the three-state
channel and the Poisson offspring law are well-formed PMFs —
mechanical hygiene for the challenge scaffolding, not
reconstruction results. Verified content for the *catalogue
claims* is zero; verified content for the *file scaffolding* is
nonzero. A future pick that fills the sorrys would owe the full
M2; per the scope note, the below-threshold direction and the
SBM transfer would sit outside that M2, prefiguring the same
*re-proved vs source-faithful* split the 3SUM note recorded.

## M3 — Credit honesty: the four-state half is over-credited by omission

Three layers, and the center layer is the finding:

- **The three-state exclusions are handled honestly.** The scope
  doc names exactly what is outside (sub-threshold
  nonreconstruction; SBM consequences) — the same candor the
  266 note recorded. Against the three-state paper alone, the
  doc is a fair account.
- **The catalogue credits a four-state program the Lean link
  cannot substantiate.** The headline — title and claim alike —
  promises four-state ferromagnetic thresholds and four-state
  tree capacity, and carries the `([Lean](lean/docs/229.md))`
  link. The linked doc lists only the three-state paper as
  accompanying, links only three-state challenges, and never
  says the four-state results are unformalized. This is not a
  quantitative weakening of a stated object (the 266/126
  pattern) and not a stated-but-unproven headline (the 017
  pattern): it is a **structural absence with no admission
  anywhere on the catalogue→doc→challenge path**.
- **No accusation against the papers.** The four-state papers
  exist in the repo; the finding is strictly about what the
  catalogue advertises under a Lean link versus what any doc or
  challenge states.

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statements, with residual lines:

1. **Kesten–Stigum framing.** The challenges encode only the
   strict inequality `1 < bλ²` / `1 < dλ²`. The catalogue's word
   "exact" needs the equality side too; that side is outside the
   statements (admitted). Residual: "exact threshold" survives
   for the supercritical direction only — the reader who
   inherits the headline inherits an unformalized equality
   case. Tag: **convenience-only** restriction of the
   formalization, **risk-inducing** for the headline.
2. **`Spin := Fin 3` is hardwired.** There is no `Fin 4` spin
   type, no four-state channel definition, no ferromagnetic
   coupling parameter in either file — the code-level mirror of
   the M3 absence. A four-state statement would need a new
   channel definition, not a parameter change. Dangling check:
   the four-state half of the headline dangles from the
   catalogue with no statement, no doc, and no definition
   anywhere on the Lean side.
3. **Parameter range `-1/2 ≤ λ ≤ 1`.** The symmetric three-state
   channel's natural range (row sums to 1 with nonnegativity
   forces exactly this interval — the proved `channel_nonneg` /
   `channel_sum` lemmas pin it). Tag: **source-faithful** per
   the doc's stated channel; the "both signs of λ" clause
   corresponds to this range.
4. **The no-survival-conditioning convention.** The Poisson
   advantage averages over the offspring PMF — zero-child
   (extinction) events carry mass `e^{-d}` and are included in
   the average, over both trees and spins. Tag:
   **source-faithful** to the catalogue's stated convention,
   definitional rather than proven; it lives inside the `sorry`
   theorems, so its formal status tracks theirs.
5. **The `d>1` / `d>0` split in the catalogue.** "mean d>1 and
   d>0, respectively" — the `d>1` belongs to the three-state
   challenges (`hd : 1 < d` in `poisson_supercritical`;
   `TreeClauses` allows `(d : ℝ≥0)` but its KS hypothesis forces
   `d > 1`). The `d>0` half belongs to the four-state
   tree-capacity regime — absent with the four-state program.
   A reader attributing `d>0` coverage to the Lean link is
   misled on two counts.
6. **Trusted base and status.** Lean `v4.34.1` + Mathlib
   `d13f23b` (upstream pins); sidecar JSONs permit exactly
   `{propext, Quot.sound, Classical.choice}`. The four headline
   theorems are `sorry` challenge statements — current verified
   status of the catalogue claims: **zero**. The proved lemmas
   are PMF hygiene. (Fine print, not an accusation: the files
   are labeled `ComparatorChallenges` upstream; the catalogue's
   Lean link does not say so.)

## Receipt

- `incoming/reconstruction-thresholds-229/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes,
  toolchain/Mathlib pins, and the absence-search evidence, as
  read 2026-10-14.
- **GAP (explicit):** no independent forge build and no
  Comparator run were performed in this audit — M1–M4 are a
  statement audit, and compilation is never its acceptance
  criterion. A build would not change any finding above: the
  four headline theorems end in `sorry`, and the four-state
  absence is a statement inventory, not a compilation
  question. Closing this GAP would require a build-bearing pick
  on whatever fills the sorrys — and a statement pick for the
  four-state program, which has no challenge file at all.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — the
three-state supercritical direction is stated (as `sorry`
challenges); equality-side nonreconstruction and the SBM
consequences are excluded (admitted); the four-state
ferromagnetic thresholds and tree capacity have no formalized
statement anywhere in the repo at the pin (un-admitted);
**M2** not applicable to the headline theorems (`sorry`);
proved lemmas are PMF scaffolding only; **M3** — the
three-state exclusions are honestly disclosed, but the
catalogue credits a four-state program the Lean link cannot
substantiate, with the absence named nowhere on the
catalogue→doc→challenge path; **M4** inventoried above (the
four-state half dangles with no statement, no doc, no
definition; the `d>0` Poisson regime belongs to it).
