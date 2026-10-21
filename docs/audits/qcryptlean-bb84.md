# Audit note: QCryptLean BB84 (arXiv:2610.17286, 2026-10-12)

**Claim artifact:** Maor Ben Shahar (MIT CTP), Jonathan Morag
(MIT RLE), Dirk Englund (MIT RLE/EECS), Kfir Sulimany (MIT RLE),
*Quantum Cryptography and Autoformalization in Lean*
(arXiv:2610.17286v1, submitted 2026-10-12, 11 pages, CC BY 4.0).
The paper reports an end-to-end machine-checked composable
finite-key security proof of entanglement-based qubit BB84
against coherent attacks, built by an LLM-agent pipeline with
human review, plus a new conditional-entropy variance cap found
by the same pipeline.
**Campaign objects:** none (no PIN was landed with the original
note; see the re-land notice below).
**Pinned sources:** paper PDF sha256
`f398b4486c630b383e35585d146898db09a4e083848f218e9da13322e1d2bfb5`;
e-print source sha256
`3cb9de879b2a28820643477d1ddc2e781812b7a18c1f6b915fcd03b90e9151c9`
(single `main.tex`, 644 lines; no separate supplementary
material published). Lean repo `maorbenshahar/QCryptLean`
@ `2eaa1067c4fb5b580c544c77b6286415b72e83fc` (single "Initial
commit", 2026-10-10; 807 Lean files; library 112,982 LOC, tests
11,313 LOC; Apache-2.0). Toolchain `leanprover/lean4:v4.34.1`;
Mathlib rev `d13f23b723b8a846827a245b89c10fc7d3f11612`.
Upstream CI at that SHA green (run 38075970083, 2026-10-10).
Working copies and evidence: `~/workspace/qkd-lean-recon/`
(RECON.md, paper), `~/workspace/qcryptlean-audit/` (brief,
build, axiom receipt).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`.
Original audit run 2026-10-18; re-land and provenance recheck
2026-10-21 (below). The paths that could carry or kill the
claims were enumerated before the checks (15 paths, P1 to P15,
in `~/workspace/qcryptlean-audit/brief-paths.md`, sha256
`ab0f4f1dbd672fcd79eb7f113b820bb62342d5f3fc3c278fc691a10c98524eb1`):
sorry/admit surface, extra axioms, Thm 1 statement drift,
security-definition weakening, LOCC Program constructibility,
transcript exposure to Eve, the postselection prefactor
(proved vs assumed), the paper's two flagged hidden-assumption
repairs, Thm 2 direction and hypotheses, Thm 3 exact form and
consumption, vacuity, Prop 4 scope, build surface, provenance,
scope fences.

**Re-land notice (2026-10-21).** The closing record of
2026-10-18 reports this note as landed at `main@fe7f64c`. On
2026-10-21 that commit is not on origin/main (fetched HEAD
`bd126e6eb8d31297865770d19401f047744a868e`) and this file is
absent from the tree; the discrepancy was first banked as an
unresolved side observation on 2026-10-20 during the Banks
audit preparation. This file is a reconstruction from the
surviving record (the 2026-10-18 dated notes, RECON.md, the
P1 to P15 brief, the build log, and the axiom receipt named
above). It is not byte-identical to the lost original. Verdicts,
pins, and numbers are the recorded ones; wording is new where
the original wording does not survive, and every place where
the surviving receipts are narrower than the closing record
says so explicitly. The verdict lock is not touched.

**Scope of this audit:** M1 statement fidelity, M2 argument
correspondence, M3 credit honesty, M4 fine-print inventory,
plus an independent build of the pinned repo on this VM and a
`#print axioms` receipt for the headline theorems. No author
contact.

## Verdict

**PASS.** M1 qualified, M2 qualified, M3 PASS, M4 catalogued
with one GAP (provenance, below). The closing record reports
10/10 machine checks passed.

- Thm 1: composable finite-key BB84 security vs coherent
  attacks. Lean: `QKD.BB84.Parameters.isSecure_of_bellRenyiConditions`
  (`QCryptLean/QKD/BB84/Security/BellRenyi.lean:217`).
  eps_QKD = eps_EV + g_{n,4} (eps_PA + 2 eps_bar +
  2 sqrt(2 eps_AT)), with the postselection prefactor
  g_{n,4} = C(n+3,3), reduced from the generic C(n+15,15) via
  Pauli symmetry and translation-equivariant error correction.
- Thm 2: honest-channel abort bound,
  eps_quota + eps_test + eps_EC. Lean:
  `QKD.BB84.Parameters.one_sub_abortBound_le_acceptProbability`.
- Thm 3: variance cap V(W|B) <= log2^2(sqrt(d_W) + sqrt(d_W - 1));
  qubit cap C* = log2^2(1 + sqrt(2)) ~ 1.6168, against the
  Dupuis-Fawzi 5.39. Lean:
  `InfoTheory.Renyi.condVariance_le_logb_sq`. The cap is the
  one consumed by Thm 1's finite-size penalty, not a parallel
  restatement (P10).
- Prop 4: a translation-equivariant error-correction scheme
  exists (linear syndrome, averaging argument). Existence
  only: no explicit code, no efficient decoder; the paper
  says the same.

## M1 to M4

- **M1, qualified.** The statement read was done against
  paper Sec. II to V: the LOCC `Program` type (constructible
  only from local actions), `Program.denote` with public
  announcements exposed to Eve, and `QKD.Protocol.IsSecure`
  (real vs ideal channel, half diamond distance, accepted
  keys classical and joint with transcript and Eve). The
  qualification is the paper's own: faithfulness of the
  IsSecure / Eve model rests on the authors' manual review
  layer (paper Sec. II, Fig. 1). The kernel checks the
  derivation from those definitions; it cannot check that
  the definitions mean what the paper intends.
- **M2, qualified.** Qualified on the two hidden-assumption
  repairs the paper itself flags: (a) the CKR09 diamond norm
  restricted to density-operator inputs, with Hermiticity
  preservation; (b) the Dupuis-Fawzi Lemma IV.1 support
  condition. Both are carried in the Lean statements (P8).
  The C(n+3,3) prefactor reduction is proved inside the
  development, not assumed as a hypothesis of Thm 1 (P7).
- **M3, PASS.** Credit and LLM disclosure are plain in the
  paper: Claude and GPT agents translated statements and set
  tasks; a locally hosted GLM-5.3-Flash, run through the
  authors' loopy sequencer, worked on named parts (Sec. VI);
  the companion tools (loopy-prover, lean-graph-tools) are
  released open source. The one defect under this heading is
  the provenance GAP below: the disclosure is honest, the
  record behind one sentence of it is not public.
- **M4, catalog with GAP.** Fine print, all stated openly in
  the paper: entanglement-based BB84 only (no
  prepare-and-measure, no decoy states); authenticated
  classical channel assumed; all registers
  finite-dimensional; Prop 4's decoder is nonconstructive;
  Thm 2's honest channel is memoryless (sigma^tensor N) with
  a per-raw-key error-correction failure bound as a
  hypothesis. **GAP (provenance):** paper Sec. VI states GLM
  worked on the generalization of Thm 1 to a free
  privacy-amplification error, the Renyi offset and deviation,
  and the relative-entropy tails of Thm 2 and Prop 4, and
  that "Claude and GPT reviewed its PRs before they were
  merged into the library." The public repo is one squashed
  initial commit, so no PR or review record for that work is
  in the git record. This GAP was enumerated pre-audit as
  P14 (as an M3 candidate) and recorded as a GAP in the
  closing record. It concerns the trusted base for the
  review claim only; it does not touch the kernel receipts.

## Receipt

Independent build on this VM of the pinned repo
(`~/workspace/qcryptlean-audit/build/`): `lake build`
completed, "Build completed successfully (4635 jobs)",
`EXIT:0` (build.log tail). Axiom receipt
(`~/workspace/qcryptlean-audit/axiom_audit.out`, sha256
`dc69e129ac4475da7831be60bf3f8b8c3de76192621c7519c6c36b803d85604c`),
run read-only via `lake env lean` from outside the checkout,
exit 0:

```text
'QKD.BB84.Parameters.isSecure_of_bellRenyiConditions' depends on axioms: [propext, Classical.choice, Quot.sound]
'QKD.BB84.Parameters.one_sub_abortBound_le_acceptProbability' depends on axioms: [propext, Classical.choice, Quot.sound]
'InfoTheory.Renyi.condVariance_le_logb_sq' depends on axioms: [propext, Classical.choice, Quot.sound]
EXIT:0
```

Repo-wide grep at recon and audit time found no `sorry`,
`admit`, `native_decide`, or `axiom` declarations in the
library or test tree (hits were English words in comments).
The test tree's `QCryptLeanTest/QKD/BB84/PublicAPI.lean`
exercises both security theorems through the single Security
import with `assert_no_sorry` (P11, P13).

Receipt narrowing, stated plainly: the 2026-10-18 closing
record says Prop 4 also printed exactly the same three
axioms. The surviving axiom file covers the three theorems
only; no Prop 4 axiom line survives as an artifact. That
part of the record is a dated-note claim, not a receipt.

## Recheck of the provenance GAP, 2026-10-21

Live GitHub check at the user's word, 2026-10-21:

- Main is unchanged: still the single squashed commit
  `2eaa106`. Three branches exist: `main`,
  `minimal-stinespring`, `trace-norm`.
- Three PRs exist in total. **#1** (merged 2026-10-06):
  "Bump Lean and Mathlib to v4.34.1", 6 commits, base
  `d78e12c`, head `2bed6e1`; 0 GitHub reviews, 0 comments.
  It survives in the PR database despite the Oct 10 history
  squash, and two commit messages record applying reviews
  ("Apply the review of the v4.30.0 bump"; "Apply the reviews
  of the v4.32.2 and v4.34.1 bumps"), so review of that bump
  happened somewhere off GitHub. Bump only: no theorem work,
  no GLM.
- **#2** (open, created 2026-10-15): "Trace norm: duality,
  Hölder inequalities for products and unitary invariance",
  head `d6d98d7` (2 commits, 2026-10-14). PR body: written by
  GLM-5.3 through ZCode from a written specification, an
  earlier GPT draft served as reference, Claude reviewed each
  draft and sent back two rounds of fixes, author reviewed
  locally before the PR.
- **#3** (open, created 2026-10-15): "Minimal Stinespring
  dilations", head `e18ac0b`. PR body: written by GLM-5.3
  through ZCode, Claude reviewed the draft and sent back one
  round of fixes, author reviewed locally before the PR.

**Recheck verdict: the GAP stands, narrowed.** PRs #2 and #3
are post-paper (arXiv v1 is 2026-10-12), open and unmerged,
and cover new modules, not the audited theorems. They show
the authors now publish exactly the per-PR provenance the
audited snapshot lacks. No PR or review record corresponding
to the Sec. VI claim (GLM on Thm 1 / Thm 2 / Prop 4, reviewed
by Claude and GPT before merge) exists in the public repo as
of 2026-10-21. The PASS verdict is unaffected: the GAP is
about the review claim's record, not about proof soundness.

One leg of the recheck is unverified: the unauthenticated
GitHub API returned a 403 rate limit while the review and
comment counts for PRs #2 and #3 were being pulled, and the
check stopped there. Those counts could add detail to #2/#3;
they cannot change the verdict for the merged library.

## GAP list

1. Provenance GAP (M4): the Sec. VI PR-review claim has no
   public PR or review record for the audited library.
   Rechecked 2026-10-21: stands, narrowed as above.
2. Receipt GAP: Prop 4's axiom print survives only as a
   dated-note claim (see Receipt).
3. Record GAP, closed by this re-land: the original note
   (recorded at `main@fe7f64c`) is not on origin/main; this
   reconstruction replaces it.
