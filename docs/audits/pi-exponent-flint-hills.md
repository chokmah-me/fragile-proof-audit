# Audit note — irrationality exponent of π, statement-fidelity audit (openai/math family 017, 2026-10-14)

**Claim artifact:** the openai/math catalogue entry for family 017
("The irrationality exponent of <i>π</i> is 2"). The entry names one
accompanying preprint — *The irrationality exponent of π is 2*
(September 24, 2026) — exactly as the scope doc lists it. The
mathematics below is taken only from the catalogue entry, the scope
doc, and the linked Lean statement; the paper's mathematics was not
re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 2,
drift 9 — catalogue headline advertises a consequence outside the
selected Lean statement.
**Campaign objects:** `incoming/pi-exponent-017/` (`PIN.md`, pinned
sources).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-14`. The inventory entry, the scope doc, and the Lean file
were read at the pinned SHA above; all quotations below are verbatim
from those sources. This is the second full check off the
statement-drift shortlist (family 266 was first, main@3590482) and
follows that note's precedent on the standard-vs-template calls.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "The irrationality exponent of <i>π</i> is 2."

> "Proves that the irrationality exponent of <i>π</i> is exactly 2:
> for every <i>ε</i> &gt; 0 and all sufficiently large denominators
> <i>q</i>, every rational $`p/q`$ satisfies
> $`|\pi-p/q|\ge q^{-2-\varepsilon}`$. This also proves convergence
> of the Flint–Hills series
> $`\sum_{n\ge1}1/(n^3\sin^2 n)`$, with angles in radians.
> ([Lean](lean/docs/017.md))"

## The scope note (verbatim admissions)

> "The formalization proves that the irrationality exponent of
> $\pi$ is exactly two. For every $\nu>2$, all sufficiently large
> positive denominators $q$ satisfy $|\pi-p/q|\ge q^{-\nu}$ for every
> integer numerator $p$. It also states the exact supremum
> characterization using infinitely many rational approximations."

> "The paper's convergence consequence for the Flint–Hills series is
> outside this selected statement."

## The formalized statement (verbatim, as pinned)

`lean/ComparatorChallenges/PiExponent.lean` (in `namespace
OAI/PiExponent`):

> `theorem main :`
>   `(∀ ν : ℝ, 2 < ν → ∃ Q : ℤ, 2 ≤ Q ∧`
>     `∀ p q : ℤ, Q ≤ q →`
>       `(q : ℝ) ^ (-ν) ≤ |Real.pi - (p : ℝ) / (q : ℝ)|) ∧`
>   `sSup {ν : ℝ | 0 < ν ∧`
>     `Set.Infinite {r : ℚ | 2 ≤ r.den ∧`
>       `0 < |Real.pi - (r : ℝ)| ∧`
>       `|Real.pi - (r : ℝ)| < (r.den : ℝ) ^ (-ν)}} = 2 := by`
>   `sorry`

The file ends in `sorry`: a Comparator *challenge* statement — an
unsolved challenge statement, not a proven result.

## M1 — Statement correspondence: HEADLINE STATED (but unproven); advertised consequence EXCLUDED

Sentence by sentence:

1. **"The irrationality exponent of π is 2" — the formalized
   statement states this in full, unlike family 266.** It states
   both directions the claim needs: (a) for every `ν > 2`, all
   sufficiently large denominators `q` satisfy `|π − p/q| ≥ q^{−ν}`
   for every integer numerator `p` (the `2 ≤ Q ∧ Q ≤ q` shape forces
   `q ≥ 2`, i.e. positive denominators) — the exponent-`≤ 2` half;
   and (b) the exact supremum characterization `sSup … = 2` over
   exponents with infinitely many good rational approximations
   (with `2 ≤ r.den` and the explicit `0 < |π − r|` non-equality)
   — the exponent-`≥ 2` half. So at the statement level the headline
   claim *is* present. The caveat is status, not content: the file
   ends in `sorry`, so the statement is claimed, not established —
   its verified content today is zero.
2. **"This also proves convergence of the Flint–Hills series … with
   angles in radians" — not present anywhere.** Neither the Lean
   statement nor the scope doc mentions the Flint–Hills series; the
   scope note states explicitly that the consequence "is outside
   this selected statement." So M1 for the second catalogue sentence
   is: not established, and excluded by selection.

## M2 — Argument correspondence: NOT APPLICABLE (proof is `sorry`)

The formalized statement ends in `sorry`. There is no derivation to
compare against the source argument — no faithful-formalization vs
independent-proof question arises. A future pick that fills the
sorry would owe the full M2 audit; the bridge from `μ(π) = 2` to
Flint–Hills convergence (a μ-below-5/2 argument) would sit outside
the selected statement, so any future M2 would meet the same
*re-proved vs source-faithful* split the 3SUM note recorded for its
reduction steps.

## M3 — Credit honesty: scope note honest on scope; two layered over-claims

- **The scope doc is honest about what is excluded.** It says the
  selected statement covers the exponent and the supremum
  characterization, and states in plain words that the Flint–Hills
  consequence is outside it. Nothing in the doc pretends the
  formalization covers the series.
- **The catalogue entry conflates the paper's result with the
  formalization's coverage.** "This also proves convergence of the
  Flint–Hills series …, with angles in radians" is followed
  directly by `([Lean](lean/docs/017.md))` — a reader verifying the
  convergence claim through the Lean link finds only the exponent
  statement plus a scope note saying the series consequence is
  outside. The consequence is real (the scope doc calls it "the
  paper's convergence consequence"), so this is primarily a
  **statement-selection problem, not a false theorem claim**: the
  catalogue sentence is true of the paper as far as the sources here
  state it, but the Lean link beside it cannot substantiate it.
- **One further overstatement, in the scope doc itself.** "The
  formalization proves that the irrationality exponent of π is
  exactly two" — the selected statement ends in `sorry`. The
  formalization *states* the exponent claim; it does not *prove*
  it. (Recorded here as fine-print honesty, not an accusation: the
  file is labeled a Comparator challenge upstream; but the word
  "proves" is load-bearing for a reader who does not open the Lean
  file.)

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statement, with residual lines:

1. **The irrationality-exponent definition is the standard
   two-part characterization.** The `ν > 2`-eventually half plus
   the `sSup … = 2` half over exponents with infinitely many good
   approximations is the textbook definition of μ(π) = 2. Tag:
   **source-faithful**. Residual: if this encoding failed, the
   whole headline would evaporate; it survives as written.
2. **Challenge status.** `sorry` — current verified status of the
   statement is **zero**. The scope doc's "proves" is aspirational
   for a challenge statement. Tag: **risk-inducing** for any reader
   who takes the doc's "proves" at face value without opening the
   Lean file.
3. **The Flint–Hills consequence and its bridge.** The excluded
   consequence needs the bridge "μ(π) = 2 ⇒ convergence of
   ∑ 1/(n³ sin²n)" (an exponent-below-5/2 argument), which is
   *entirely* outside the selected statement. As a load-bearing
   assumption of the catalogue's second sentence: it **evaporates**
   from the formalization's inheritance chain — anyone citing the
   Lean link as evidence for the series convergence inherits
   nothing.
4. **"with angles in radians."** The catalogue's only named
   convention. Lean's `Real.pi` is radians by construction, so a
   formalized series statement would match the convention — but
   there is no series statement, so this is moot today and would be
   load-bearing only if the consequence were ever formalized.
   Tag: **convenience-only** (as used), with a note that it would
   become source-faithful-or-fatal if the series were selected.
5. **Quantifier encoding details.** `∃ Q : ℤ, 2 ≤ Q ∧ ∀ p q : ℤ,
   Q ≤ q` forces positive denominators; `p` ranges over all
   integers; `2 ≤ r.den` and `0 < |π − r|` in the infinite set are
   the explicit shape of "all sufficiently large denominators" and
   non-trivial approximations. No mismatch with the catalogue's
   "for every ε > 0 and all sufficiently large denominators" is
   visible. Tag: **source-faithful**.
6. **Trusted base:** Lean `v4.34.1` + Mathlib `d13f23b` (upstream
   pins). Dangling check: a proof filling the `sorry` would
   establish both statement halves; a *weaker* result (e.g.
   exponent ≤ 2.5) would lose the headline but still support the
   Flint–Hills consequence — the two catalogue sentences have
   different sensitivity to weakening, which is exactly why the
   selection, not the paper, is the problem.

## Receipt

- `incoming/pi-exponent-017/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes, and
  toolchain/Mathlib pins as read 2026-10-14.
- **GAP (explicit):** no independent forge build and no Comparator
  run were performed in this audit — M1–M4 are a statement audit,
  and compilation is never its acceptance criterion. Note that the
  statement currently ends in `sorry`, so a build would not change
  any finding above; closing this GAP would require a build-bearing
  pick on whatever fills the sorry.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — the headline
statement (μ(π) = 2, both directions) *is* stated by the
formalized statement but ends in `sorry` (claimed, not
established); the advertised Flint–Hills convergence is absent
from the statement and explicitly excluded by the scope note;
**M2** not applicable (proof is `sorry`); **M3** — the scope note
is honest on scope, but the catalogue's "This also proves
convergence … ([Lean]…)" conflates the paper's consequence with
the formalization's coverage, and the scope doc's "proves"
overstates the challenge statement's status; **M4** inventoried
above (the consequence bridge evaporates from the
formalization's inheritance chain; "radians" is moot without a
series statement).

## Correction (2026-10-14): solution-module re-check

A follow-up re-check (same method as the family-227 note: the
challenge file's sidecar JSON `solution_module` field, read at
openai/math@`adc7f1241b42e322a6451854ab7e4b4c146bf78a`)
found a solution module the original note did not read. The
original text above is unchanged; this section supersedes its
status-and-coverage claims.

**Findings.**
- `lean/ComparatorChallenges/PiExponent.json` names
  `OAI.NumberTheory.PiExponent.Main`.
  `lean/OAI/NumberTheory/PiExponent/Main.lean` (36 lines,
  `sorry` count 0) proves `theorem main` with the full
  μ(π) = 2 statement, sorry-free proof body (`refine ⟨…⟩`;
  `change irrationalityExponent Real.pi = 2`; `exact
  pi_irrationalityExponent_eq_two`).
- The same module proves `theorem flint_hills_summable :
  Summable (fun n : ℕ => 1 / (((n + 1 : ℕ) : ℝ)^3 *
  Real.sin (n + 1 : ℕ)^2))` — convergence of
  ∑_{n≥1} 1/(n³ sin²n) — via
  `flintHills_positive_summable_of_eventual_lower_bound
  pi_eventual_lower_bound`.
- The transitive sorry status of the imported `Approximation`
  modules is a build question — receipt stays GAP.

**Corrected assessment.**
- **M1 reverses on status.** The headline is not merely
  stated-but-unproven: the solution module the catalogue
  path leads to proves it, sorry-free at the top-file level.
  The Flint–Hills convergence is **not** absent from the
  formalization — the solution module proves exactly the
  advertised consequence.
- **M2 reverses.** A derivation exists (the solution proofs);
  M2 moves from N/A to pending-a-build.
- **M3 reverses on the central point.** The catalogue's "This
  also proves convergence of the Flint–Hills series
  ([Lean](lean/docs/017.md))" **is** substantiated by the
  linked Lean. The original note's "statement-selection
  problem" framing was scoped to the challenge file, not the
  solution the catalog path leads to. What remains true: the
  scope doc's "outside this selected statement" is accurate
  only for the *selected statements* (the challenges); its
  "The formalization *proves*…" phrasing is accurate at the
  solution level.
