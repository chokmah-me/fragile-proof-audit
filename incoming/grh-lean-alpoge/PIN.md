# PIN — grh-lean-alpoge (registered 2026-11-24)

Registered 2026-11-24 at the user's tap ("do it" on the
registration proposal). This is a triage-level registration:
a source-level triage ran 2026-11-23 at his tap, with a
follow-up reverse-trace and hExpl6 discharge pass the same
evening (record: ~/workspace/rh-triage-2026-11-23/TRIAGE.md).
No forge, no build, no kernel replay by us: a full
comparator replay needs ~100 GB RAM and the 62 GB export,
which is not a VM or runner job. What is registered is the
claim, the pins, the community kernel receipts (reported,
not ours), and our source-level findings with their bounds.
Board status: kernel-verified on community receipts,
statements faithful at source, live M1 seam on geometric
content. Neither settled RH nor a BREAK. Verdict lock
untouched.

## Claim

Levent Alpöge announced 2026-11-20 a Claude-assisted Lean
proof of the Riemann Hypothesis and GRH for Dirichlet
L-functions: a Lean-only formalization, ~17.4M lines, no
human-readable paper (the author cites a 250,000+ page
draft; the public remark is a personal essay with no
technical content bearing on the objection below). Five
headline theorems in Main.lean. The Lean/Mathlib joint
statement of 2026-11-21 certifies statement and proof.
Objection: Jenny Lorraine Nielsen, "Invalidity of the
Alpoge Proposed Proof of the Riemann Hypothesis",
PhilArchive NIEIOT-2 (posted 2026-11-21), arguing the
proof is vacuous at a geometric predicate (anyGeometry)
she places 8 dependency steps below riemannHypothesis,
plus a height-assignment point (hExpl6 discharged by rfl).

## Canonical artifact

Author's archive: 14-part tarball at alpo.ge, sha256
`9631b4f020199e580ba86178cb56c6e9b09f690c2369a80dc4334aa93f49c7fc`
(per the 2026-11-23 harvest record; not re-downloaded for
the triage). Source checked: third-party mirror
github.com/CocoSgt/riemann-hypothesis-lean @7cbf7a0c;
codeload tarball sha256
`8f21bc02afbd4efd6e4606e43b1a99b7ee6916cac196d3b6ed67565d6e2d0fe4`.
Extracted tree: exactly 175,187 .lean files, 1.4 GB.
Toolchain leanprover/lean4:v4.33.1, Mathlib pinned at
0df444a3 (harvest record). Remark (alpo.ge/remark.pdf)
sha256
`3fc97784b71ddd44ff8aa0a177e99622a1c61b13cfa843a0989ee4a7a0cfeb8d`.

## Kernel verification (community receipts, NOT ours)

Reported on Andrew Sutherland's page (updated 2026-11-22)
and the Lean blog post: all 175,187 modules compile with
zero errors; the five headline theorems depend only on the
standard three axioms; leanchecker replay 175,187/175,187;
nanoda accepts the full export; con-leche accepts
1,468,418 declarations and the con-leche/con-ron compare
justifies all five; an independent sandboxed build
reproduces the export byte-for-byte (61,570,595,788 bytes,
sha256 5ea74b91...244e). Per secondary updates 2026-11-23,
the standalone Comparator and the combined-export con-leche
checks later passed; the paranoid kernel replay was still
open. We ran none of this. It is recorded as reported
receipts behind the "kernel-verified" board status.

## Our findings (source-level triage, 2026-11-23)

- Statement fidelity: PASS. Main.lean's five theorems
  state the real thing. `RiemannHypothesis` is Mathlib's
  own definition; a full-tree search finds no local
  redefinition. The other four props are defined in
  Statements.lean directly over Mathlib's `riemannZeta`
  and `DirichletCharacter.LFunction` at full GRH strength.
  `UpperTheory.EveryCharacter` (CharacterBoxes/
  EveryCharacter.lean:13) is the plain nonvanishing
  statement for re > 1/2, and the bridge
  `Formalism.VW.rh_of_every` (CritLine.lean:29) is a real
  proof using Mathlib's `LFunction_modOne_eq` at modulus 1
  plus the functional equation.
- Nielsen's code claims: CONFIRMED at source.
  `def anyGeometry : GeoP := fun _ _ _ => True` verbatim
  at Development/AbelianVarietyTheory/Definitions/
  AutomorphicMembership/OverIx.lean:19, two lines below
  the substantive `geoOf`, which demands a real witness
  and a true surface. GeoCl's `base` constructor accepts
  any proof of the underlying predicate, so
  `GeoCl.base trivial` certifies every input under
  anyGeometry. anyGeometry appears in 24 files and is used
  in producing BOTH hypothesis-bundle families: Hyps via
  hypsE2 (EveryCharacterE.lean, `(geoCl anyGeometry)` at
  lines 57, 60, 64) and HypsAlt via
  hypotheses_nonempty_of_unramified_exponents_alt.
- Nielsen's invalidity conclusion: NOT established; the
  strong form is incorrect. A vacuous intermediate
  predicate cannot invalidate a kernel-checked proof of an
  unconditional, faithfully stated theorem. What the
  vacuity establishes is narrower and real: the geometric
  slot of the bundle carries no content on the routes that
  produce it, so the formalization does not validate the
  geometric argument its names advertise, and the joint
  certification does not address this.

## Seams

- S1 (geometric vacuity, confirmed): the GeoP slot is
  `True` on both bundle-production routes (Hyps, HypsAlt).
  Live M1 seam on geometric content.
- S2 (headline-route dependence, unverified, evidence
  against): the route Main.lean actually uses is
  MainConclusion.lean: FinalTheorems.everyCharacter :=
  everyCharacter_of_row
  galoisLocalGlobalStrong_recParameter :=
  LiteratureTheorems.every_character_of_literature_of_vWin
  with vwin_of_row. EveryCharacterE and TopPlug are
  parallel routes, not this one (an earlier triage draft
  mislabeled EveryCharacterE as the headline route; the
  correction is in TRIAGE.md). The four files carrying the
  headline chain contain zero mentions of anyGeometry or
  geoCl. A demand-driven textual reverse-trace (60,000
  declarations visited, cap hit with the queue unexhausted,
  max distance 8) reached no declaration whose own text
  mentions anyGeometry or geoCl; its 4 file-level hits all
  broke under hand-checking as name-resolution artifacts
  (tactic token `intro`, field name `sign`, generic
  `Full`, a `lamOf` suffix). Verified real hops on the
  route: everyCharacter_of_row -> LLC.recTExists ->
  LLC.TypeAt, a concrete tame-system condition; Row0b
  rests on ContraPair.PolarizedPair. Bounds: a textual
  cone is not the compiled dependency graph, so absence is
  not proven; Nielsen's "8 steps below riemannHypothesis"
  remains UNVERIFIED, with the textual evidence weighing
  against it.
- S3 (hExpl6, mechanism confirmed at one site): the field
  `h_eq : div.h = DV.hExpl6` in ExtraAt (AsmIface.lean:163)
  is discharged at its one found construction site,
  LedPart.pt (SetUnipotentTranslate.lean:381), by
  `h_eq := fun _ => rfl` (line 400), and the rfl is
  definitional: LedPart.ht is defined as DV.hExpl6 itself
  (line 379) and installed as the divisor's stored height
  by setDiv. The height is assigned the formula; the
  equality is then true by definition. For FamP
  (ParConsts.lean:73) no base construction naming the
  field exists in the tree; the field only propagates
  (FamP.raise) or enters as a hypothesis, and the one
  helper that would prove the equality, Inhab.h_eq_of,
  has no callers.
- S4 (not audited): whether another bundle field or bridge
  trivializes a step the analytic conclusion truly depends
  on needs a field-by-field audit of the Hyps/HypsAlt
  bundles across a 17.4M-line development. Campaign scale;
  not run.
- S5 (provenance): the checked source is a third-party
  mirror; the author's own tarball hash is recorded from
  the harvest, not re-verified by download in the triage.

## Queue

Registered as CLAIM with triage findings. A full audit
(field-by-field bundle audit, S4) or a compiled-graph
dependence check (S2) is a separate decision at the user's
tap; the compiled-graph check additionally needs the
62 GB export and ~100 GB RAM, beyond the current runners.
The audit queue is unchanged by this registration.
