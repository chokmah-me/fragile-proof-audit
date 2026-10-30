# Audit — 1-extension, Lean formalization (arXiv:2610.31212)

**Claim.** Heaton & Winter, *An Algebraic Proof of
1-Extension*: for d ≥ 2, a 1-extension (Henneberg move
type II) of a generically rigid graph satisfying
Maxwell's count is generically rigid, proved without a
special-position argument; Lemma 1: a weak d-orientation
balanced at an affinely independent placement gives a
nonzero self-stress. The formalization claim audited
here is the one the paper itself makes in its
Formalization subsection: the main theorem and the
weak-stress lemma are formalized in Lean 4, with the
Asimow–Roth equivalence at generic placements retained
as an explicit background hypothesis.

**Pinned artifacts.** Paper PDF sha256
2b1f3cde4a32ae1a7b2badaf00d2cb3f85dd6a9fc116f9084159b4e328915c79;
arXiv source sha256
0b6dcfa8e9182b357b0395e6a4afa7e97b96a2b7c4e95b1174f2b5ef09be894d;
Zenodo record 23503394 (DOI 10.5281/zenodo.23503394),
one-extension-lean-1.0.0.zip sha256
cfd11ee0c41a13dbb87770e9e49d2622d6f87ca7115b6e3236c516082daf19fb
(md5 e7c938ad8ef21e87fe6ba18ec786b552 matches the Zenodo
record). Toolchain leanprover/lean4:v4.28.0; manifest
pins Mathlib 8f9d9cff6bd728b17a24e163c9402775d9e6a365
(v4.28.0) plus eight further dependencies. PIN at
`incoming/one-extension-lean/PIN.md`.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-30T01:49:21Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills:
ai-failure-mode-hygiene, chokmah-research-engine,
computational-claim-gate, contract-breaker,
contract-certifier, lean-proof-forge,
manuscript-integrity-gate, paper-robustness-check,
release-sync, testforge, verification-reviewer.

Evidence in `~/workspace/one-extension-recon/`
(`EVIDENCE.md`, `PIN.md`, the pinned zip/pdf/source,
`argon-deepen.md`).

## 1. Build replay (forge)

Two dispatches of one-extension-forge on
DESKTOP-7HDI2D1 against the pinned zip. Run #1
(40900231842): fetch, hash check, toolchain and cache
all passed; lake build exit 0 in 305 s, "Build
completed successfully (8075 jobs)", MATHLIB_OLEANS
7655. The run then failed in the auditor's own scan
step: the sorry-location grep had been written without
-n, so its output carried no line numbers and the
Tableaux.lean:247 match could never succeed. Harness
defect, not an artifact defect; fixed at main@ec65452
(hits captured to a file with -Rn; proven locally in
three directions: real tree passes, an added sorry
refuses, the documented sorry removed refuses) and
re-dispatched. Run #2 (40987949269): all steps
success. In-run SOURCE-SHA256 re-verification 52/52;
build exit 0 in 296 s, again exactly 8075 jobs,
matching the authors' shipped BUILD.log job count.

## 2. Source identity

The archive ships its own manifest: SOURCE-SHA256.txt
covers the 49 Lean sources and the three build
configuration files. All 52 entries verified OK against
the extracted tree at recon, and re-verified in-run by
the forge (section 1). The only .lean file not in the
manifest is verification/CheckAxioms.lean, the authors'
own audit file.

## 3. Axiom audit

Run #2 ran the authors' verification/CheckAxioms.lean
as-is (5 reports) and the auditor's superset file
(11 reports). Every one of the 16 reports is exactly
[propext, Classical.choice, Quot.sound]; no sorryAx
appears in either output; the verdict step classified
all 16 mechanically and printed PASS. The build log
contains zero "declaration uses 'sorry'" warnings
across the whole tree, so no unexamined declaration
hides a sorry either (the tree contains no warn.sorry
setting that could silence one, section 6).

The eleven: exists_genericPlacement, lemma_weak_stress,
WeakDOrientation.exists_nonzero_selfStress_of_balancedAt,
OneExtension.IsOneExt.theorem_one_extension,
OneExtension.IsOneExtension.theorem_one_extension,
OneExtension.theorem_one_extension_oneExtGraph,
theorem_main_Maxwell_locally_flexible,
corollary_characterization,
theorem_balanced_equivalent_to_selfstress,
corollary_affine_Maxwell_infinitesimally_flexible,
lemma_red_blue_equiv_straighten_to_zero.

## 4. The sorry token

A text scan of all 51 .lean files finds exactly one
`sorry` token: Tableaux.lean line 247, inside a block
comment. The commented-out statement is a strengthening
of the red-blue lemma with no height hypothesis; the
archive documents it as FALSE at height n = 0, ships
the formalized counterexample
(RedBlue.not_redBlue_equiv_straightensToZero_of_height_zero),
and proves the corrected version with hypothesis
0 < n in RedBlue.lean. The comment is not compiled;
the build log carries no sorry warning, and no audited
theorem's axiom report contains sorryAx. Zero
native_decide / ofReduceBool / sorryAx tokens and zero
axiom declarations in the tree.

## 5. Statement fidelity — the Asimow–Roth seam

The 1-extension theorems carry the Asimow–Roth
equivalence as explicit hypotheses hAR (for G) and
hAR' (for G'), typed:

    hAR : ∀ pp : V → Fin d → ℝ, GenericPlacement d pp →
      (LocallyFlexible G pp ↔ InfinitesimallyFlexible (G := G) pp)

Read against the source: this is exactly the classical
equivalence (local flexibility iff infinitesimal
flexibility at a generic placement), once per graph.
It is not an axiom, so it does not appear in axiom
reports; it is not the conclusion (the conclusion is
GenericallyRigid d G); and it is not stronger than the
cited theorem in any way the audit could detect: the
LocallyFlexible side is the standard continuous-motion
notion (IsFlex: a continuous q with q 0 = p, all bar
lengths preserved at all times, and some vertex-pair
distance changed — a changed pair is automatically a
non-edge pair, since edge distances are pinned by the
preservation clause).

The construction data were read field by field.
Vert' o is the subtype {v : V // v ≠ o}, so the new
vertex is not a vertex of G' at all. IsOneExtension
(and IsOneExt) carry exactly: q injective (the d+1
neighbours are pairwise distinct); adj_o (the new
vertex's neighbours are exactly the q i); adj_sub
(inside V', G's edges are G's edges with only
(q 0, q 1) removed); adj_12 (the deleted edge is an
edge of G'). The single extra field, omin in IsOneExt
(the new vertex is smallest in the auxiliary order),
is bookkeeping and is removed by the
order-independence theorem; it carries no mathematical
content.

Definitions, read from Rigidity.lean:
GenericPlacement d p is algebraic independence over ℚ
of the coordinates; GenericallyRigid d G is
∀ generic p, ¬ LocallyFlexible G p; LocallyFlexible is
existence of a continuous flex; MaxwellCount d G is
#E + C(d+1,2) = d·|V|, stated without subtraction.
Generic placements are proved to exist
(exists_genericPlacement, axioms exactly the classical
three), so the genericity quantifier is not vacuous.

Theorem 1 of the paper (d ≥ 2, G' generically rigid,
Maxwell count, |V'| ≥ d+1, (1,2) ∈ E', G the explicit
1-extension) maps to theorem_one_extension in its three
variants (normalized order, order-free, and the
explicitly constructed oneExtGraph). Lemma 1 of the
paper maps to lemma_weak_stress verbatim, including
its (redundant, and separately discharged) sink
hypothesis.

## M1 — statement

The formalized statement is the paper's Theorem 1 in
the form the paper's own formalization claim scopes
it: conditional on the Asimow–Roth equivalence at
generic placements for the two graphs involved. That
conditioning is disclosed in the paper's Formalization
subsection, the archive README, VERIFICATION.md and
PAPER-TO-LEAN.md. The Lean conclusion
(GenericallyRigid d G, a graph-level statement over
all generic placements) is the paper's conclusion;
the paper's per-placement phrasing ('let p extend p',
p generic; then (G,p) is generically rigid') quantifies
over an arbitrary generic extension, the same content.

## M2 — argument

The Lean proof follows the paper's stress-contradiction
argument: the central quadratic identity is proved as
a full identity (bigPsi_span: the cleared entry
restricted to s·P₁ + t·P₂ is the single mixed term,
for all real s, t), not evaluated at one chosen vector;
supporting adaptations (orientation construction,
exceptional denominators by a finite affine argument)
are documented by the authors in PROOF-FIDELITY.md and
match the source as read. The audit replays the build
and the axiom closure; it does not re-derive the
mathematics line by line.

## M3 — credit

The paper and archive credit the formalization to the
authors with assistance from Aristotle (Harmonic),
disclosed in the paper's AI-usage statement, the
archive README and its provenance/ directory, which
preserves the original Aristotle documents. The
development derives from the authors' earlier
generic-rigidity formalization, cited in the README.
Nothing in the archive overstates this: VERIFICATION.md
explicitly warns that its axiom report does not remove
the hAR/hAR′ hypotheses.

## M4 — fine print

Scope limits, all disclosed by the authors and
confirmed against the source: the generic-evaluation
lemma is proved for signed tableau multisets (integer
coefficients); the rational-coefficient wrapper is not
a separate formal theorem. The papers' illustrative
examples and the unnumbered efficient-denominator
refinement (with its |E| column bound) are not
formalized. The abstract Grassmannian quotient-ring
presentation is not separately formalized; the
determinant-polynomial and exchange criteria it would
supply are proved. The retained hypothesis |V'| ≥ d+1
is unused by the formal proof (an author-noted linter
warning). This audit does not prove Asimow–Roth; the
unconditional 1-extension theorem inherits exactly the
status of that classical result.

## 6. DEEPEN adjudication

An Argon DEEPEN pass ($0.0221, raw answer
argon-deepen.md) attacked the provisional verdict on
five lines. Adjudication:

- "hAR may be stronger than Asimow–Roth, and
  LocallyFlexible is untested dead weight" — REJECTED
  as a defect, SUSTAINED as a scope note. IsFlex was
  re-read verbatim (section 5): it is the standard
  continuous-motion definition. That the proof core is
  infinitesimal and hAR is the outer wrapper is the
  paper's own architecture, disclosed as such; the
  formalization claim does not assert Asimow–Roth, and
  whether the published theorem covers the paper's
  definitional package is the paper's citation,
  recorded under M4.
- "The IsOneExtension combinatorics were never read" —
  SUSTAINED as a recon gap and closed: the structure
  fields are quoted in section 5 and are exactly the
  paper's construction, with no smuggled
  non-degeneracy or ordering content in the headline
  (order-free) variant.
- "Quantifier shift between the paper's (G,p) and the
  Lean graph-level statement; Lemma 1 possibly
  vacuous" — REJECTED on both halves. The paper's
  Theorem 1 hypothesizes a generically rigid graph G'
  and its abstract states a graph property; the Lean
  rendering matches. Lemma 1's conclusion is
  ∃ w : OrientedEdge G → ℝ, w ≠ 0 ∧ IsSelfStress p w,
  with IsSelfStress the standard equilibrium equations;
  weights live only on edges by the index type.
- "A PASS on pending axiom checks; warn.sorry could
  silence the sorry warnings; add lean4checker" —
  SUSTAINED procedurally (this note files only on the
  completed re-run), REJECTED on the mechanism: the
  tree contains no warn.sorry setting, no
  implemented_by, no extern and no unsafe (the
  set_option lines present are display and instance
  options), and #print axioms is warning-independent.
  A second-kernel replay is outside this audit's trust
  basis, which is the stock Lean 4.28.0 kernel at
  build time, as in prior forge audits.
- "MaxwellCount might hide Nat truncation or dropped
  hypotheses" — REJECTED on the statement as read:
  Nat.choose, no division; hd : 1 < d, hV' and hM'
  are all present.

Disposition of the legs: build replay PASS (8,075
jobs, exit 0); source identity PASS (52/52 manifest);
axiom closure PASS (16 reports across the two files,
every one exactly the classical three, no sorryAx);
statement fidelity PASS at the scope the paper itself
sets (Asimow–Roth retained as a hypothesis, disclosed
at every level); the archive's examples, rational
wrapper and denominator refinement are out of scope by
the authors' own statement, recorded under M4.

**Verdict: PASS** — the archive proves Theorem 1 and Lemma 1 in exactly the scoped form the paper claims for its formalization.
