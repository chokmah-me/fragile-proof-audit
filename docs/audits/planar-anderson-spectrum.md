# Audit note — Localization and delocalization in the Anderson model, statement-fidelity audit (openai/math family 261, 2026-10-15)

**Claim artifact:** the openai/math catalogue entry for family 261
("Localization and delocalization in the Anderson model"). The
entry advertises a two-sided resolution of the Anderson
spectral contrast: in dimension two, every positive disorder
strength gives almost surely pure-point spectrum; in every
fixed dimension d ≥ 3, sufficiently weak positive disorder
gives purely absolutely continuous spectrum on a fixed open
interval with nonzero spectral weight. The mathematics below
is taken from the catalogue entry, the scope doc, the linked
Lean statement, and the two accompanying preprints, all read
at the pin; the preprints' arguments were not re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 10,
drift 6. The 2026-10-14 two-path sweep established that the
family's single challenge carries a sorry-free solution
module; this note is the first statement-level reading of
either path, and it closes the shortlist's full-note queue.
**Campaign objects:** `incoming/planar-anderson-261/`
(`PIN.md`, pinned sources including the full upstream catalog).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-15`. The inventory entry, the scope doc, the challenge
file, the sidecar JSON, the solution module, the upstream
formalization catalog, and both accompanying preprints were
read at the pinned SHA above; all quotations below are verbatim
from those sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "Localization and delocalization in the Anderson model."

> "Resolves the predicted spectral contrast for the lattice
> Anderson model with independent uniform site potentials. In
> dimension two, every positive disorder strength gives almost
> surely pure-point spectrum. In every fixed dimension
> $d \ge 3$, sufficiently weak positive disorder gives purely
> absolutely continuous spectrum on a fixed open interval with
> nonzero spectral weight. ([Lean](lean/docs/261.md))"

## The scope note (verbatim; full upstream text)

> "The linked formalization proves a supporting spectral
> statement for the nearest-neighbor Anderson operator on
> $\mathbb Z^2$. For every disorder strength $h>0$ with
> independent site potentials uniform on $[-h,h]$, it
> constructs the bounded self-adjoint operator almost surely
> and identifies its spectrum as the real interval
> $[-4-h,4+h]$."

> "This selected statement identifies the spectral set. It does
> not assert the pure-point spectral type claimed in the
> accompanying paper."

The doc lists **one** accompanying paper ("Pure-Point Spectrum
for the Two-Dimensional Anderson Model at Every Positive
Disorder," OpenAI, September 23, 2026) and one comparator
result. That preprint's **Theorem 1.1** is a four-part
conclusion for each fixed h > 0, almost surely: the operator
has pure-point spectral type; it admits a complete orthonormal
eigenbasis; its spectrum is σ(H_v) = [−4−h, 4+h]; and its
eigenvalues are dense in that interval. The catalogue's
second sentence is a **second preprint** ("Absolutely
Continuous Spectrum for Weak-Disorder Anderson Models in
Dimensions at Least Three," same date), which the doc does
not list, name, or exclude.

## The formalized statement (as pinned)

Challenge file — 35 lines, self-contained, one theorem ending
in `sorry`:

- `PlanarAndersonSpectrum.lean`: `theorem anderson_spectrum_ae {h : ℝ} (hh : 0 < h) : ∀ᵐ v ∂disorderLaw h, ∃ H : Hilbert →L[ℂ] Hilbert, IsAndersonOperator v H ∧ IsSelfAdjoint H ∧ spectrum ℂ H = spectralInterval h := by sorry`
  where `Hilbert = ℓ²(ℤ²; ℂ)`, `IsAndersonOperator` is the
  pointwise action `(Hu)(x) = u(x+e₁) + u(x−e₁) + u(x+e₂) +
  u(x−e₂) + v(x)·u(x)` (the preprint's displayed operator
  (1.1)), `disorderLaw h` is the infinite product of uniform
  laws on `[−h,h]`, and `spectralInterval h` is the real
  interval `[−4−h, 4+h]` embedded in `ℂ`. *One sorry theorem.*

Solution module — the sidecar JSON names
`OAI.MathematicalPhysics.PlanarAnderson.Spectrum`, which
**exists** at the pin and is sorry-free **at the top-level
file** (verified by reading; it imports Mathlib only, so the
file-level scan is the complete OAI-side dependency picture —
see the Receipt for what GAP remains):

- `Spectrum.lean` (767 lines) proves `anderson_spectrum_ae`
  at the exact challenge signature with a genuine argument:
  the operator is built as hopping + multiplication potential
  (norm ≤ 4 + h, self-adjoint, giving `spectrum ⊆ interval`);
  the reverse inclusion is a Weyl-sequence construction —
  cut-off plane waves are approximate eigenfunctions of the
  free operator, near-constant potential patches of every
  size occur almost surely (an i.i.d. Borel–Cantelli step,
  `iid_exists_ae` / `constant_boxes_ae`), and translating a
  cut wave onto such a patch yields approximate
  eigenfunctions for every energy in the interior, with the
  endpoints by closure.
- The same file **defines the preprint's full Theorem 1.1**
  as `MainStatement` — `PurePoint H ∧
  HasCompleteOrthonormalEigenbasis H ∧ spectrum ℂ H =
  spectralInterval h ∧ closure (eigenvalues H) =
  spectralInterval h`, with `PurePoint` formalized in the
  preprint's own terms ("the closed span of the eigenvectors
  is the entire Hilbert space") — and proves two conditional
  bridges toward it (`purePoint_of_completeOrthonormalEigenbasis`;
  `spectrum_eq_closure_eigenvalues_of_completeOrthonormalEigenbasis`).
  **`MainStatement` is never proved and never invoked by any
  theorem in the file** (verified by full-text search: it
  occurs only at its definition). The proved theorem is the
  spectrum conjunct alone.

## M1 — Statement correspondence: the spectral set, exactly; the spectral type as unproved scaffolding; the second paper nowhere

Claim-part by claim-part:

1. **"In dimension two, every positive disorder strength
   gives almost surely pure-point spectrum"** — the
   *spectral-type* content of Theorem 1.1 (pure point,
   complete eigenbasis, dense eigenvalues) is **absent from
   the challenge statement**, and the doc admits the
   exclusion in terms ("It does not assert the pure-point
   spectral type claimed in the accompanying paper").
   **Absent-and-admitted** — with a refinement the
   challenge-only reading could not see: the excluded
   content is not absent from the solution *tree*. It sits
   inside the single solution file as `MainStatement`, a
   faithful formalization of Theorem 1.1 in full, accompanied
   by two proved bridges from an eigenbasis hypothesis —
   and is itself never proved. The family's pure-point
   status is therefore neither "formalized" nor "nowhere":
   it is stated, correctly, and left unproved, one definition
   away from the theorem that is proved.
2. **The spectrum identification, σ(H_v) = [−4−h, 4+h]
   almost surely** — **corresponds, and is proved.** It is
   Theorem 1.1's third conjunct, and the only one the
   selected statement carries. The doc's "supporting spectral
   statement" is accurate and, if anything, modest: the
   challenge also fixes the operator itself (the pointwise
   action determines it uniquely — the solution proves
   `anderson_unique`), its self-adjointness, and the
   per-fixed-h almost-sure quantifier exactly as the
   preprint states it ("The probability-one event in this
   statement is allowed to depend on h").
3. **"In every fixed dimension d ≥ 3, sufficiently weak
   positive disorder gives purely absolutely continuous
   spectrum…"** — the second preprint's theorem. **Absent
   everywhere**: no statement, no challenge, no solution —
   and, unlike 281's MaxCut sentence, the excluded content's
   *paper* is not even listed in the doc, which presents its
   single-paper list as the family's accompanying papers.
   **Absent-and-un-admitted.** The catalogue title's second
   word ("delocalization") names exactly this half.

So of the catalogue's two-sided claim: one side's supporting
conjunct is formalized and proved; that side's headline
property stands formalized-but-unproved inside the solution
file; and the other side has no presence on either path or
in the doc.

## M2 — Argument correspondence: NOT APPLICABLE to the challenge theorem; the solution is a single self-contained file with a real proof

The challenge theorem ends in `sorry` — no derivation to
compare (the 266/017/229 precedent). The solution module
proves the exact signature, and its dependency structure is
the strongest among the noted families: it imports Mathlib
only, so there is no OAI subtree whose transitive sorry
status could hide — the file-level scan exhausts the
repository-side dependency picture, and the proof is a real
one (Weyl sequences over almost-surely-occurring constant
patches), not an assembly of targets. What is NOT
established here: that the file *builds* — no forge build
and no Comparator run were performed, so elaboration-level
soundness rests on upstream's own (unpreserved) runs.
Verified content for the spectrum claim is therefore
**unverified-but-complete-at-file-level**; for the pure-point
claim it is **defined-but-unproved**, a distinction this note
keeps separate throughout.

## M3 — Credit honesty: the doc is honest about the exclusion it names, and silent about the second paper

- **The doc admits its central weakening.** "It does not
  assert the pure-point spectral type claimed in the
  accompanying paper" is exactly the right sentence, in the
  doc's own text — the 266-style candor.
- **The doc's paper list is incomplete against the
  catalogue.** The entry's claim spans two preprints (the
  inventory counts two manuscripts); the doc lists one and
  scopes "the accompanying paper" in the singular. A reader
  who follows the catalogue's Lean link learns the
  pure-point exclusion and never learns a delocalization
  paper exists in the family. The 281 pattern (a catalogue
  sentence with no doc home) one level up: here it is a
  whole paper with no doc home.
- **The catalogue's "Resolves the predicted spectral
  contrast" voice** presents both preprints' theorems as the
  family's resolved content; the formalization resolves
  neither theorem — it proves a conjunct of one. The doc
  walks this back for the 2D side only.
- **The `n_formalized: 0` flag is reconciled** (see PIN):
  upstream's `formalization.yaml` catalog contains no entry
  for this family at all — the sidecar names a solution
  module the catalog never lists, the same sidecar/catalog
  divergence as families 281 and 280.
- **The doc's "The linked formalization proves…" phrasing**
  applies to a sorry challenge statement (the 017 finding,
  recorded here as fine print rather than accusation); the
  solution module is what makes the verb defensible — and
  for this family, unusually, defensible on a single-file
  reading.

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statement, with residual lines:

1. **`MainStatement` is defined, not proved — and it is the
   paper's theorem.** The solution file's most quotable
   object is a definition: the full Theorem 1.1, present in
   the tree, formally precise, and carrying no proof. A
   search-driven reader (or a downstream catalog) that
   greps for "pure point" in this tree will find `PurePoint`
   and `MainStatement` and can over-credit the family; the
   proved theorem `anderson_spectrum_ae` never mentions
   either. Tag: **risk-inducing** for credit, harmless for
   the spectrum claim itself. This is the family's sharpest
   fine print, and it is invisible from the challenge path.
2. **The almost-sure event is per-disorder-strength.** The
   statement is `∀ h > 0, ∀ᵐ v` — no single probability-one
   event serves all h at once. The preprint states the same
   caveat in its own Theorem 1.1. Tag: **source-faithful**.
3. **The disorder law is the product uniform law, and the
   operator is pinned pointwise.** `disorderLaw` is
   `Measure.infinitePi` of `cond volume (Icc (−h) h)` —
   independence and uniformity are definitional, matching
   "independent uniform site potentials"; `IsAndersonOperator`
   fixes the action on every vector, so the existential
   `∃ H` is a construction, not a choice among operators
   (uniqueness proved in the solution). Tag:
   **source-faithful**.
4. **The interval is a set in ℂ.** `spectrum ℂ H` for a
   bounded operator on a complex Hilbert space, equated to
   `{z | z.im = 0 ∧ −4−h ≤ z.re ≤ 4+h}` — the real interval
   in its ℂ embedding; self-adjointness makes the spectrum
   real, so nothing is gained or lost in the embedding.
   Tag: **definitional**, standard.
5. **No eigenbasis hypothesis is hidden in the proved
   theorem.** The two bridge lemmas are conditional on
   `HasCompleteOrthonormalEigenbasis H`, which nothing in
   the file establishes; they do not feed
   `anderson_spectrum_ae`. Recorded so the bridges are not
   misread as steps toward a proved pure-point result.
   Tag: **definitional** scaffolding.
6. **Trusted base and status.** Permitted axioms on the
   sidecar are exactly `{propext, Quot.sound,
   Classical.choice}` — the forge allowlist;
   `enable_nanoda: false`. Status: one challenge theorem
   `sorry`; the solution module sorry-free and single-file
   (no OAI subtree; residual transitive question = the
   un-run build only). The file is labeled
   `ComparatorChallenges` upstream; the catalogue's Lean
   link does not say so.

## Receipt

- `incoming/planar-anderson-261/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes,
  toolchain/Mathlib pins, both preprints' hashes, the
  single-file dependency structure of the solution module,
  and the `n_formalized: 0` reconciliation against the full
  upstream catalog.
- **GAP (explicit):** no independent forge build and no
  Comparator run were performed — M1–M4 are a statement
  audit. Unlike 227/280/281, there is no unswept solution
  subtree behind this GAP: the solution is one Mathlib-only
  file, read in full. A build-bearing pick would test
  elaboration, not coverage.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — the
spectrum identification corresponds and is proved at the
exact signature; the pure-point spectral type is
absent-and-admitted at the statement level, and present in
the solution file only as the defined-but-unproved
`MainStatement` (the preprint's Theorem 1.1 in full, with two
conditional bridges); the d ≥ 3 absolutely-continuous half is
absent-and-un-admitted, its preprint not even listed in the
doc; **M2** not applicable to the sorry challenge theorem —
the solution is a single self-contained Mathlib-only file
with a genuine Weyl-sequence proof, the strongest dependency
position of any noted family (residual = un-run build);
**M3** — the doc is honest about the pure-point exclusion
and silent about the second paper; the catalogue's
"Resolves…" voice covers two theorems of which the
formalization proves a conjunct of one; `n_formalized: 0`
reconciled as the upstream catalog's silence; **M4**
inventoried above (the defined-not-proved `MainStatement` as
the sharp fine print; per-h almost-sure quantifier;
source-faithful disorder law and operator pinning; allowlist
axioms).
