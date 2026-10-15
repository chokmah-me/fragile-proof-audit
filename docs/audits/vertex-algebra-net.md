# Audit note — Unitary vertex operator algebras and conformal nets, statement-fidelity audit (openai/math family 280, 2026-10-15)

**Claim artifact:** the openai/math catalogue entry for family 280
("Unitary vertex operator algebras and conformal nets"). The
entry advertises the strongly rational case of the
strong-locality conjecture in full: every simple unitary
strongly rational complex vertex operator algebra generates a
completely rational conformal net, its simple modules are
unitarizable, and its representation category agrees with the
net's finite-index sectors as a braided unitary tensor
category. The mathematics below is taken from the catalogue
entry, the scope doc, the linked Lean statement, and the
accompanying preprint, all read at the pin; the preprint's
argument was not re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 8,
drift 7. The 2026-10-14 two-path sweep established that the
family's single challenge carries a sorry-free solution
module; this note is the first statement-level reading of
either path.
**Campaign objects:** `incoming/vertex-algebra-net-280/`
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
formalization catalog, and the accompanying preprint were
read at the pinned SHA above; all quotations below are verbatim
from those sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "Unitary vertex operator algebras and conformal nets."

> "Proves the strongly rational case of the strong-locality
> conjecture: every simple unitary strongly rational complex
> vertex operator algebra generates a completely rational
> conformal net. Its simple modules are unitarizable, and its
> representation category agrees with the net's finite-index
> sectors as a braided unitary tensor category.
> ([Lean](lean/docs/280.md))"

## The scope note (verbatim; full upstream text)

> "The linked formalization proves the first construction step
> relating strongly rational unitary vertex operator algebras
> to conformal nets. For a simple unitary strongly rational
> vertex operator algebra, it establishes polynomial energy
> bounds and strong locality and constructs an irreducible
> conformal net with the stated covariance, vacuum, and
> positive-energy properties."

> "The selected statement does not include complete rationality
> of the net, unitarizability of all simple modules, the
> braided tensor equivalence, or the classification of local
> extensions described in the paper."

The doc lists one accompanying paper ("Strongly rational
unitary vertex operator algebras and conformal nets," OpenAI,
September 25, 2026) and one comparator result. The preprint's
**Theorem 1.1 has five clauses**: (1) polynomial energy bounds
and CKLW-strong locality, the local algebras forming an
irreducible conformal net; (2) complete unitarity —
unitarizability of simple grading-restricted modules *and*
positive-definiteness of the canonical fusion forms; (3)
strong integrability of every unitary finite-length module;
(4) complete rationality of the net; (5) the
Carpi–Weiner–Xu braided unitary tensor equivalence. The
challenge file's own header names the selected statement
"the strongly rational unitary vertex operator algebra main
result, clause (1)."

## The formalized statement (as pinned)

The challenge file (830 lines) is a self-contained
definitional development — vertex algebra, CFT-type VOA,
admissibility, rationality, unitarity, circle diffeomorphisms,
Möbius geometry, smeared fields, local algebras — culminating
in one theorem, ending in `sorry`:

- `VertexAlgebraNet.lean`: `theorem main (_hSimple : A.toVertexAlgebra.IsSimple) (hSR : A.IsStronglyRational.{u,v}) : A.PolynomialEnergyBounds ∧ OAI.MinimalVertex.CKLWStrongLocal U hSR.2.2 ∧ Nonempty (OAI.MinimalVertex.IrreducibleConformalNetStructure (OAI.MinimalVertex.intervalAlgebra U hSR.2.2)) := by sorry`
  where `A` ranges over CFT-type VOAs on a complex inner-product
  space and `U` is a chosen unitary structure. `IsStronglyRational`
  unpacks to self-contragredient ∧ rational (every admissible
  weak module completely reducible) ∧ C2-cofinite, matching the
  preprint's definition ("of CFT type, isomorphic to its graded
  contragredient, rational, finite-dimensional V/C₂(V)";
  `c2` is the preprint's `span{a₍₋₂₎b}` verbatim).
  `IrreducibleConformalNetStructure` packages separability,
  isotony, locality, Möbius covariance with continuity, a
  diffeomorphism action extending the Möbius action, vacuum
  (norm-one, invariant, unique, cyclic), a self-adjoint
  Hamiltonian with positive energy whose flow is rotation, and
  irreducibility (commutant = scalars). *One sorry theorem.*

Solution module — the sidecar JSON names
`OAI.RepresentationTheory.VertexAlgebra.MinimalComparator`,
which **exists** at the pin and is sorry-free **at the
top-level file** (verified by reading; transitive sorry status
is a build question — GAP):

- `MinimalComparator.lean` proves `OAI.MinimalVertex.main` at
  the exact challenge signature (line 676). Its architecture
  is the finding: the challenge file is self-contained *by
  duplication* — it re-defines the development's operator
  layer under `OAI.MinimalVertex.Code.*` names — and the
  solution (i) re-states that cloned layer, (ii) proves a
  battery of twelve definitional-equality bridges between the
  clones and the originals in the imported development
  (`smearedMap_eq`, `smoothSmearedField_eq`,
  `closedSmoothField_eq`, `localGraphData_eq`,
  `intervalAlgebra_eq`, `CKLWStrongLocal_eq`, `resolvent_eq`,
  `boundedGenerator_eq`, `approximatingFlow_eq`, `flow_eq`,
  `projectiveStandardAction_eq`, `cloned_entry_eq`), (iii)
  re-packages the original net structure field by field
  (`netStructure_of_original`, rewriting the two fields whose
  statements pass through the flow and the standard action),
  and (iv) closes with `main` := the development's
  `U.source_main_clause_one` transported across the bridges.
  The substantive mathematics sits in the imported
  `VertexAlgebra.MainClauseOne` development — 143 files in
  `lean/OAI/RepresentationTheory/VertexAlgebra/`.

## M1 — Statement correspondence: clause (1) of five, exactly; the headline fuses covered and excluded clauses

Claim-part by claim-part, against the preprint's Theorem 1.1:

1. **"every simple unitary strongly rational complex VOA
   generates a … conformal net"** — **clause (1), and it
   corresponds in detail.** `PolynomialEnergyBound` is the
   preprint's displayed bound (1.1), `‖a₍ₙ₎b‖ ≤ C(1+|n|)^p
   ‖(1+L₀)^k b‖`, with `energyShift = 1 + virasoroMode 0`
   (and `virasoroMode 0` acting as `L₀` by the structure's
   `conformal_energy` field).
   `CKLWStrongLocal` is the preprint's own definition:
   energy-bounded and `A_V(I) ⊆ A_V(I′)′` for the complementary
   arc. `intervalAlgebra` is the preprint's (1.3),
   `A_V(I) = W*{Y(a,f) : supp f ⊂ I}` — including the
   preprint's gloss that the algebra generated by closed
   operators is taken through their bounded graph data, which
   is exactly the challenge's `ClosedGraphData.entry`
   construction. The net axioms in
   `IrreducibleConformalNetStructure` are the doc's "stated
   covariance, vacuum, and positive-energy properties," plus
   irreducibility. The hypothesis side also corresponds:
   simplicity and strong rationality as the preprint defines
   them (above), unitarity as a PCT structure with the
   standard invariant-form adjoint identity.
2. **"… a *completely rational* conformal net"** — clause
   (4) (split, strongly additive, finite µ-index). **Absent
   from the statement; the doc names the exclusion.** The
   catalogue's lead sentence fuses this excluded clause into
   the generation claim, so the sentence as printed is half
   covered, half not.
3. **"Its simple modules are unitarizable"** — clause (2),
   first half. **Absent; admitted by the doc.**
4. **"its representation category agrees with the net's
   finite-index sectors as a braided unitary tensor
   category"** — clause (5). **Absent; admitted by the doc.**
   The doc likewise names the classification of local
   extensions (the preprint's Corollary 9.3 material) as
   excluded.
5. **What neither the catalogue nor the doc's exclusion list
   names:** clause (2)'s second half (canonical fusion forms
   positive definite) and clause (3) (strong integrability of
   finite-length modules, with the closed-field equality
   (1.4)) are *also* outside the selected statement, and the
   doc's "does not include" list does not mention them. The
   list reads as a fair summary, but against the preprint's
   five clauses it is representative, not exhaustive — a
   refinement of the shortlist's drift-7 line, which was
   drawn from the doc alone.

So of Theorem 1.1's five clauses, exactly one — the first
construction step, as the doc says — is formalized, and it is
formalized faithfully. The remaining four are excluded, three
and a half of them by the doc's own admission.

## M2 — Argument correspondence: NOT APPLICABLE to the challenge theorem; the solution is a comparator bridge over a 143-file development

The challenge theorem ends in `sorry` — no derivation to
compare (the 266/017/229 precedent). The solution module
proves the exact signature with a real proof body, but its
visible content is *transport*, not the clause-(1) argument:
the argument lives in `U.source_main_clause_one` inside the
imported 143-file `VertexAlgebra` development. The
comparator architecture deserves recording in its own right,
because it is this family's correspondence risk: the
challenge restates the development's definitions as clones,
so a drift between clone and original would silently change
what the challenge asserts — and the solution's twelve
`*_eq` bridges are precisely the checks that no such drift
occurred. Those bridges are proved at file level (several by
real arguments — `flow_eq` goes through uniqueness of limits,
`resolvent_eq` through the resolvent's graph property; the
algebra-level ones close by unfolding and `rfl`). What is NOT
established here: whether any of the 143 imported files
contains a `sorry` — a build question, recorded as GAP.
Verified content is **unverified-but-structurally-substantial,
not zero** (the 227/281 status).

## M3 — Credit honesty: the doc is honest and specific; the catalogue's lead sentence fuses a covered clause with an excluded one

- **The doc admits its exclusions by name.** Complete
  rationality, unitarizability, the braided equivalence, and
  the extension classification are each stated as not
  included, and its positive claim ("the first construction
  step") matches the preprint's clause structure exactly —
  the 266-style candor, sharpened by the challenge header's
  own "clause (1)" label.
- **The catalogue entry's lead sentence overclaims by
  fusion.** "…generates a completely rational conformal net"
  attaches clause (4)'s conclusion to clause (1)'s
  construction; a reader of the entry alone gets one theorem
  where the formalization (and the doc) have a first step.
  The entry's remaining two sentences are exactly the
  excluded clauses (2) and (5), in the same "Proves that…"
  register.
- **The doc's exclusion list is not exhaustive against the
  preprint** (clause (2)'s fusion-form positivity and
  clause (3)'s strong integrability go unlisted — M1.5).
  Recorded as a refinement, not an accusation: the four named
  exclusions are the ones the catalogue advertises.
- **The `n_formalized: 0` flag is reconciled** (see PIN):
  upstream's `formalization.yaml` catalog contains no entry
  for this family at all — the sidecar names a solution
  module the catalog never lists, the same sidecar/catalog
  divergence as family 281. The flag is a catalog-claim
  count, orthogonal to the module's existence.
- **The doc's "The linked formalization proves…" phrasing**
  applies to a sorry challenge statement (the 017 finding,
  recorded here as fine print rather than accusation); the
  solution module is what makes the verb defensible at file
  level.

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statement, with residual lines:

1. **Junk-value totalization in the core constructions.**
   `smearedMap`, `smoothSmearedField`, `resolvent`, `flow`,
   and `projectiveStandardAction` are all defined by
   `if h : ∃ (witness) then h.choose else 0` (else `1` for
   the action): outside the regime where the existence
   condition holds, the "smeared field" is the zero operator,
   the "flow" is zero, the "standard action" is trivial. The
   theorem statement quantifies over these definitions
   without displaying the case split; the net in the
   conclusion is the preprint's net only where the
   existence conditions hold — which is what the solution's
   `*_eq` bridges establish at file level. Tag:
   **risk-inducing** if the statement is read without the
   definitions; discharged by the bridges, transitively GAP.
2. **Rationality is universe-bounded.** `IsStronglyRational.{u,v}`
   defines rationality over admissible weak modules
   `W : Type v` only. The preprint's "complete reducibility
   of admissible modules" carries no size restriction; the
   Lean statement's is the standard universe compromise.
   Tag: **definitional**, standard for this formalization
   style; would matter to a claim about *all* modules at
   once.
3. **Unitarity is split between the context and a chosen
   structure.** The ambient `V` already carries
   `[NormedAddCommGroup V] [InnerProductSpace ℂ V]` — a
   chosen inner product is part of the theorem's context
   before any hypothesis — and the PCT data is a universally
   quantified argument `U : A.UnitaryStructure`; the net is
   built on `Completion V`. The preprint's unitarity is a
   property of `V` (existence of a normalized positive
   invariant form and its PCT involution). Tag:
   **definitional**, source-faithful in effect (the
   challenge's `UnitaryStructure.invariant` is the standard
   adjoint formula), but the "for a unitary VOA" of the
   headline is, formally, "for a VOA equipped with this
   data."
4. **The net is a property-package, and its space is the
   completion.** `IrreducibleConformalNetStructure` is a
   structure whose fields are the net axioms (data fields:
   the Möbius and diffeomorphism homomorphisms, the vacuum
   vector, the Hamiltonian); the conclusion is its
   `Nonempty` over the *constructed* `intervalAlgebra` on
   `Completion V`. Existence-of-a-net-on-these-algebras is
   what is asserted — matching the preprint, whose fields
   also close on the Hilbert completion. Tag:
   **source-faithful**.
5. **Simplicity rides as a named-but-separate hypothesis.**
   The challenge's `main` takes `_hSimple` and `hSR` as two
   hypotheses; strong rationality as defined in the file
   does not include simplicity (nor does the preprint's
   definition — Theorem 1.1 states "simple unitary strongly
   rational" as three adjectives). Tag: **source-faithful**.
6. **Trusted base and status.** Permitted axioms on the
   sidecar are exactly `{propext, Quot.sound,
   Classical.choice}` — the forge allowlist;
   `enable_nanoda: false`. Status: one challenge theorem
   `sorry`; the solution module top-level sorry-free
   (transitive status = build GAP, over a 143-file subtree).
   The file is labeled `ComparatorChallenges` upstream; the
   catalogue's Lean link does not say so.

## Receipt

- `incoming/vertex-algebra-net-280/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes,
  toolchain/Mathlib pins, the preprint's hash, the
  solution-subtree enumeration (143 files, via per-directory
  contents listings — the recursive tree API truncates on
  this repo), and the `n_formalized: 0` reconciliation
  against the full upstream catalog.
- **GAP (explicit):** no independent forge build and no
  Comparator run were performed — M1–M4 are a statement
  audit. As with 227/281, a build-bearing pick here could
  genuinely change findings: the transitive sorry status of
  the 143-file development is the open question, and this
  note's M2 is conditional on it.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — exactly
clause (1) of the preprint's five-clause Theorem 1.1 is
formalized, and it corresponds in detail (energy-bound shape,
CKLW definition, the (1.3) algebra construction through graph
data, hypothesis definitions verbatim); complete rationality
is excluded-and-admitted but fused into the catalogue's lead
sentence; unitarizability and the braided equivalence
excluded-and-admitted; fusion-form positivity and strong
integrability excluded-and-unlisted; **M2** not applicable to
the sorry challenge theorem — the solution proves the exact
signature by transporting the development's clause-(1)
theorem across twelve proved definitional bridges, so
verified content is unverified-not-zero (transitive status =
build GAP); **M3** — the doc is honest and specific; the
catalogue's lead sentence overclaims by fusion, and its
exclusion list is representative rather than exhaustive;
`n_formalized: 0` reconciled as the upstream catalog's
silence, not an absence of a solution module; **M4**
inventoried above (junk-value totalization in the core
constructions; universe-bounded rationality; unitarity split
between context and chosen structure; allowlist axioms).
