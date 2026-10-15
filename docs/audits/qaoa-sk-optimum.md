# Audit note — QAOA attains the SK optimum in the thermodynamic-first limit, statement-fidelity audit (openai/math family 281, 2026-10-15)

**Claim artifact:** the openai/math catalogue entry for family 281
("QAOA attains the SK optimum in the thermodynamic-first limit").
The entry advertises a QAOA convergence theorem — QAOA
approaches the ground-state energy of the Gaussian zero-field
Sherrington–Kirkpatrick model, system size tending to infinity
before circuit depth, with finite depth and deterministic
angles achieving any prescribed accuracy — and a corollary of
leading-order optimal expected MaxCut values on large-degree
random regular graphs. The mathematics below is taken from the
catalogue entry, the scope doc, the linked Lean statements, and
the two accompanying preprints, all read at the pin; the
papers' arguments were not re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 7,
drift 7. The 2026-10-14 two-path sweep established that both
challenges carry sorry-free solution modules; this note is the
first statement-level reading of either path.
**Campaign objects:** `incoming/qaoa-sk-optimum-281/`
(`PIN.md`, pinned sources including the full upstream catalog).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-15`. The inventory entry, the scope doc, both challenge
files, both sidecar JSONs, both solution modules, the upstream
formalization catalog, and both accompanying preprints were
read at the pinned SHA above; all quotations below are verbatim
from those sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "QAOA attains the SK optimum in the thermodynamic-first limit."

> "Proves that QAOA approaches the ground-state energy of the
> Gaussian zero-field Sherrington–Kirkpatrick model when system
> size tends to infinity before circuit depth. For every
> accuracy, finite depth and deterministic angles independent
> of size and disorder achieve the required limiting expected
> energy per spin. This also yields leading-order optimal
> expected MaxCut values on large-degree random regular graphs,
> with size tending to infinity before degree.
> ([Lean](lean/docs/281.md))"

## The scope note (verbatim; full upstream text)

> "The linked formalization supplies variational identities for
> the Gaussian zero-field Sherrington–Kirkpatrick ground-state
> energy used in the paper's QAOA argument. Conditional on an
> admissible Parisi minimizer and its associated diffusion, it
> proves convergence of the finite-system ground-state energy,
> identifies its limit with the Parisi value, and gives
> equivalent terminal-martingale and integrated-curvature
> formulas."

> "It also proves convergence of finite Gaussian coefficient
> sums to the curvature integral, which approaches the
> ground-state value as the terminal time tends to one. The
> selected statement covers these value and approximation
> results; it does not itself assert convergence of QAOA
> circuit energies."

> "The formalization proves that every admissible integrable
> minimizer of the zero-temperature Parisi functional for the
> pure zero-field Sherrington–Kirkpatrick model has full
> relative Stieltjes support on $[0,1)$. Equivalently, the
> order parameter increases strictly between every two overlap
> values below one, so its support has no gap. The covariance
> normalization is $\xi(t)=t^2/2$."

> "The statement also constructs the associated diffusion and
> proves its selected self-consistency moment identities. It is
> conditional on the order parameter being a minimizer and does
> not separately assert existence of a minimizer."

The doc lists two accompanying papers (the QAOA preprint of
September 25, 2026 and the full-support preprint of September
27, 2026) and two comparator results mapped to the two
challenges. What the doc does NOT mention anywhere: MaxCut,
random regular graphs, or any graph-theoretic corollary — not
even as an exclusion.

## The formalized statements (as pinned)

Challenge files — both catalogue-relevant theorems end in
`sorry` (two in total):

- `SKValue.lean`: `theorem value_consequences :` a three-part
  conjunction, every part conditional on `IsMinimizer W γ`
  (and, for the first two, on a diffusion `IsDiffusion W γ X`):
  (1) `ScalarValueConclusion` — the expected ground-state
  sequence converges to `groundStateValue`, with a terminal
  martingale representation and the three identities
  `groundStateValue = E|X₁| − ∫₀¹ t·γ(t) dt`,
  `= E[U·B₁]`, `= ∫₀¹ E[curvature] dt`, plus interval
  integrability of the curvature integrand; (2)
  `FiniteGaussianConclusion` for `0 < T < 1` — the shifted
  finite Gaussian coefficient sums converge to the curvature
  integral over `[0,T]`, and the curvature integral tends to
  `groundStateValue` as the upper limit tends to `1⁻`;
  (3) `groundStateValue = parisi W γ`. *One sorry theorem.*
- `SKFullSupport.lean`: `theorem full_support (W : BrownianSystem Ω) (γ : OrderParameter) (hmin : IsMinimizer W γ) : FullSupportConclusion W γ := by sorry`
  where `FullSupportConclusion` = a Stieltjes measure for `γ`
  exists; a diffusion exists; **every** Stieltjes measure of
  `γ` has `μ.support = univ` on `Time = Ico 0 1`; `γ` is
  strictly increasing between any two points of `[0,1)`; and
  every diffusion satisfies the moment identities
  `squareMoment = t` and `∫ curvature² = 1`. *One sorry
  theorem.*

Solution modules — each sidecar JSON names a `solution_module`,
and both **exist** in the repo at the pin and are sorry-free
**at the top-level file** (verified by reading; transitive
sorry status is a build question — GAP):

- `OAI.Probability.SKValue.Main` proves `value_consequences`
  at the exact challenge signature (28 lines), as the triple
  `⟨scalar_value_target, finite_gaussian_target,
  ground_state_parisi_target⟩` imported from
  `SKValue.GroundState.MainConclusions`, over a 212-file
  subtree (Control, Equations, Evolution, Gaussian,
  GroundState, and further subdirectories);
- `OAI.Probability.SKSupport.Main` proves `full_support` at
  the exact challenge signature (66 lines), via
  `minimizer_full_support_actual` — support and strict
  monotonicity from a contact/gap-curvature argument
  (`SupportDeterministic.Variation`), the moment identities
  first for the constructed diffusion, then transferred to
  every diffusion by a uniqueness theorem — over a 135-file
  subtree (Backward, Control, Density, Diffusion, Foundations,
  Moments, Parabolic, Regularity, Support).

Neither challenge file and neither solution module mentions
QAOA, circuits, angles, depth, MaxCut, or graphs of any kind;
and no file in either solution tree (347 files, enumerated
per directory at the pin) is named for any of them.

## M1 — Statement correspondence: the input is formalized; the theorem and its corollary are not

Claim-part by claim-part:

1. **"QAOA approaches the SK ground-state energy … size
   before depth; for every accuracy, finite depth and
   deterministic angles achieve the required limiting expected
   energy per spin"** — this is Theorem 1.1 of the QAOA
   preprint, and **no statement on either path asserts any
   part of it**: no circuit, no depth parameter, no angles, no
   cost Hamiltonian or mixer appears in either challenge or
   either solution tree. The doc admits the exclusion in
   terms ("it does not itself assert convergence of QAOA
   circuit energies"). What is formalized instead is exactly
   what the QAOA preprint itself isolates as its **"scalar
   input"** (§3.1): the value identities it imports from the
   companion full-support paper. **Absent-and-admitted** —
   with the refinement that the paper's own architecture
   names the covered part an *input* to the theorem, so the
   gap is between the catalogue's headline and the
   formalization, not between the paper and its companion.
2. **"This also yields leading-order optimal expected MaxCut
   values on large-degree random regular graphs"** — the
   preprint's Corollary 1.2 (§1.3, proved in its §7). **No
   statement anywhere**: not in the doc (which does not
   mention MaxCut even to exclude it), not in any challenge,
   not in either solution tree. **Absent — and, unlike the
   QAOA admission, unnamed on the doc's exclusion path.** The
   same structural-absence pattern as 227's universal-limits
   sentence and 229's four-state half, here a single
   catalogue sentence with no doc trace at all.
3. **The value identities (SKValue)** — **correspond**,
   clause by clause. The doc's "convergence of the
   finite-system ground-state energy, identified with the
   Parisi value, with terminal-martingale and
   integrated-curvature formulas" is `ScalarValueConclusion`
   plus conjunct (3); the "finite Gaussian coefficient sums"
   sentence is `FiniteGaussianConclusion`. These are
   precisely the companion results the QAOA preprint quotes
   as its scalar input: `P(γ) = Φ(0,0) − ½∫tγ(t)dt` is the
   challenge's `parisi`; `E[u(t,X_t)²] = t`, `E[a(t,X_t)²] = 1`
   and `P* = ∫₀¹ E[a(t,X_t)] dt` are the moment identities
   and the curvature formula; the strip bound
   `0 ≤ P* − ∫₀ᵀ E[a] dt ≤ 1 − T` is the shape of the
   `T < 1` convergence conjunct. One elision in the doc's
   prose: "finite-system ground-state energy" — the
   formalized sequence is the **expected** maximum per spin,
   `(1/n)·E_J[sup_σ H_n(J,σ)]`, which is the preprint's own
   limiting object ("limiting expected energy per spin"), so
   the object is standard and the elision is verbal only.
4. **Full support (SKFullSupport)** — **corresponds**. The
   preprint's admissible class (nonnegative, nondecreasing,
   right-continuous, integrable on `[0,1)`) is the challenge's
   `OrderParameter` structure field for field; the Stieltjes
   convention `μ_γ([0,t]) = γ(t)` is `IsStieltjesMeasure`
   verbatim (`μ (Iic t) = ENNReal.ofReal (γ.val t)`); full
   relative support on `[0,1)` is `μ.support = univ` over
   `Time = Ico 0 1`, with strict increase stated separately;
   conditionality on the order parameter being a minimizer,
   with existence not asserted, is admitted by the doc and
   matches the preprint's own hypothesis.

So of the catalogue's three claim-parts: the headline theorem
absent-and-admitted, its MaxCut corollary absent-and-un-admitted,
and the supporting value/full-support content corresponding
closely on both paths.

## M2 — Argument correspondence: NOT APPLICABLE to the challenge theorems; solution modules exist and are top-level sorry-free

Both challenge theorems end in `sorry` — no derivation to
compare (the 266/017/229 precedent). The solution modules
prove the exact challenge signatures with real proof bodies:
SKValue's is a pure assembly of three target lemmas from
`GroundState.MainConclusions`, so all of its argument content
sits in the 212-file subtree; SKSupport's carries a genuine
top-level step (the constructed diffusion's moment identities
are transferred to *every* diffusion via uniqueness, which is
what the challenge's `∀ X, IsDiffusion → …` conclusion
requires). What is NOT established here: whether any imported
supporting module contains a `sorry` — that is a build
question, recorded as GAP. Verified content is therefore
**unverified-but-structurally-substantial, not zero** (the
227 status). A future build-bearing pick would owe the full
M2, including the transitive sorry scan of 347 files.

## M3 — Credit honesty: the doc is honest about its scope; the catalogue headline and the MaxCut sentence have no home

- **The doc admits its weakenings.** QAOA non-coverage,
  conditionality on a minimizer, and non-assertion of
  existence are all named in the doc's own text — the 266-style
  candor. Against the two preprints it scopes, the doc is a
  fair account; the QAOA preprint itself calls the covered
  content an input (§3.1) and credits its proofs to the
  companion, which is exactly the doc's framing.
- **The catalogue entry's "Proves that…" voice overclaims.**
  The entry's first two sentences state the QAOA preprint's
  Theorem 1.1 as the family's proved content, in the same
  register the doc then has to walk back to "variational
  identities … used in the paper's QAOA argument." The
  headline is the preprint's title, which is legitimate as a
  title; the desc's voice is not the doc's.
- **The MaxCut sentence has no home on the Lean side.**
  "This also yields leading-order optimal expected MaxCut
  values on large-degree random regular graphs" — no doc
  sentence, no challenge, no solution module, and no file in
  either solution tree named for it. It is the only catalogue
  claim-part for this family that the doc does not even
  exclude by name.
- **The `n_formalized: 0` flag is reconciled** (see PIN):
  upstream's `formalization.yaml` catalog contains no entry
  for either of this family's challenges — the sidecars name
  solution modules the catalog never lists. On the 227
  interpretation (the flag counts catalog solution-claims),
  0 is consistent with the catalog and orthogonal to the
  modules' existence: the sidecar layer claims more than the
  catalog layer records. The reverse of 227's CriticalSK
  mismatch, where both records existed but pointed at
  different files.
- **The doc's "The formalization proves…" phrasing** applies
  to sorry challenge statements (the 017 finding, recorded
  here as fine print rather than accusation); the solution
  modules are what make the verb defensible at file level.

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statements, with residual lines:

1. **The conditionality stack is the real hypothesis set.**
   Every conclusion on both paths is conditional on
   `IsMinimizer W γ`; the value conclusions additionally
   assume a diffusion exists (`IsDiffusion W γ X` as a
   hypothesis). Existence of a minimizer and the
   Auffinger–Chen identification of `min P(γ)` with the
   ground-state constant — which the QAOA preprint imports
   from its reference [2] and the full-support preprint takes
   as its hypothesis — are outside both paths and outside
   both preprints' formalized content. Tag: **risk-inducing**
   for the headline (its theorem needs the minimizer and the
   identification), **source-faithful** as the doc's stated
   scope.
2. **The value functional is Brownian-space-relative.**
   `parisi`, `IsMinimizer`, and the control value `phi` are
   defined relative to a chosen `BrownianSpace W` (a
   structure packing a probability space and a Brownian
   motion); conjunct (3) of `value_consequences` quantifies
   over all `W`, so the identification of the
   `W`-independent `groundStateValue` with `parisi W γ` is
   asserted for every model at once rather than built once.
   A reader who skips the definitions will miss that the
   "Parisi value" in the statement is a per-model
   reconstruction. Tag: **definitional**, benign as stated.
3. **`groundStateValue` is a `limUnder`, and convergence is
   claimed, not smuggled.** The constant is defined as the
   filter limit of the expected-energy sequence; for a
   divergent sequence that definition returns a junk value,
   and the statement's first conjunct asserts the `Tendsto`
   explicitly. Tag: **source-faithful** modeling, discharged
   inside the statement.
4. **Hamiltonian and covariance conventions match the
   preprints verbatim.** `H_n(σ) = (√n)⁻¹ Σ_{i<j} J_ij σ_i
   σ_j` with the ground state as the expected supremum is the
   full-support preprint's displayed definition ("its
   ground-state problem asks for the limiting maximum energy
   per spin"); `ξ(t) = t²/2` is stated by the doc and the
   preprint alike. Tag: **source-faithful**.
5. **Two non-identical order-parameter structures.** SKValue's
   `OrderParameter` is a coefficient on all of `ℝ` with its
   four admissibility fields restricted to `Ico 0 1`;
   SKFullSupport's is a function on the subtype `Time = Ico 0
   1` with global monotonicity. Same mathematical class (the
   preprint's `U`), two formalizations; values of the first
   outside `[0,1)` are unconstrained and unused. Tag:
   **convenience-only**, no content impact.
6. **Trusted base and status.** Permitted axioms on both
   sidecars are exactly `{propext, Quot.sound,
   Classical.choice}` — the forge allowlist; `enable_nanoda:
   false` on both. Status: two challenge theorems `sorry`;
   two solution modules top-level sorry-free (transitive
   status = build GAP, over a 347-file subtree). The files
   are labeled `ComparatorChallenges` upstream; the
   catalogue's Lean link does not say so.

## Receipt

- `incoming/qaoa-sk-optimum-281/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes,
  toolchain/Mathlib pins, both preprints' hashes, the
  solution-subtree enumeration (212 + 135 files, via
  per-directory contents listings — the recursive tree API
  truncates on this repo), and the `n_formalized: 0`
  reconciliation against the full upstream catalog.
- **GAP (explicit):** no independent forge build and no
  Comparator run were performed — M1–M4 are a statement
  audit. As with 227, a build-bearing pick here could
  genuinely change findings: the transitive sorry status of
  the 347-file solution subtree is the open question, and
  this note's M2 is conditional on it.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — three
claim-parts assessed: the QAOA convergence theorem
absent-and-admitted (the formalization covers exactly the
preprint's self-described "scalar input"); the MaxCut
corollary absent-and-un-admitted (no doc sentence, no
statement, no module); the value identities and the
full-support result correspond clause by clause on both
paths; **M2** not applicable to the two sorry challenge
theorems — but both solution modules prove the exact
signatures and are top-level sorry-free, so verified content
is unverified-not-zero (transitive status = build GAP);
**M3** — the doc is honest about its scope; the catalogue
desc's "Proves that…" voice and its MaxCut sentence have no
home on the Lean side; `n_formalized: 0` reconciled as the
upstream catalog's silence, not an absence of solution
modules; **M4** inventoried above (the minimizer/existence
conditionality stack; the Brownian-space-relative value
functional; `limUnder` modeling discharged in-statement;
source-faithful Hamiltonian conventions; allowlist axioms).

## Addendum (2026-10-15) — full-subtree text scan

At the user's direction, the transitive question left as GAP
above was narrowed by a full-text scan of both solution trees
at the same pin (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`,
fetched fresh by sparse checkout and verified at that commit):
all 347 files (SKValue 212, SKSupport 135; 50,201 lines)
were searched for `sorry`, `admit`, `sorryAx`, the word
`axiom` in any position, `native_decide`, and
`Lean.ofReduceBool`/`ofReduceNat`. **Zero occurrences of
every pattern.** There is no explicit sorry, admit, or stray
axiom declaration anywhere in either tree. What remains open
after this scan is elaboration only — whether every file
builds at the pinned toolchain/Mathlib combination — which
is exactly what a forge build would test; the note's GAP is
narrowed accordingly, not closed. Original text above
untouched.
