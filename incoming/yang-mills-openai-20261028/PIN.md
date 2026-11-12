# PIN — yang-mills-openai-20261028 (registered 2026-11-12)

Pinned 2026-11-12 at the user's tap (register as CLAIM now,
audit queued behind Aaronson-Ambainis). No verdict at pin
time. Recon: this side chat 2026-11-12 (repo README, checks
scope, evidence index, rerun doc read in full; key files
fetched at the pinned commit and hashed). Argon Arbiter
adjudication 2026-11-12 (google/gemini-4-argon, adjudicated
by the main agent): for us in kind, queued in time; record
~/workspace/ym-argon-2026-11-12/.

This is the third claim from the 2026-10-27 OpenAI
three-claims prep (siblings: openai-eth-disproof CLOSED
PASS, local-smoothing CLOSED PASS). It was carried as GAP
from 2026-10-27 because no public artifact existed (the
assessing panel was withholding it). The artifact landed
2026-11-10. That GAP is superseded by this registration.

## Claim

OpenAI's submission of 28 October 2026, assessed by the
Yang-Mills group in Assessment 1 (dated 2026-11-10). In
the group's words: the submission proves that a
relativistic quantum field theory satisfying the Wightman
axioms can be constructed as a scaling limit of
four-dimensional Wilson lattice gauge theory for any
simple compact gauge group. It does not prove that the
infinite-volume limit is unique or that there is a mass
gap. The group's checks document adds: no confinement,
no all-orders perturbative matching. The claim as scoped
by its own assessors is the registered claim; press
framing beyond that scope is not.

## Canonical artifact

github.com/yang-mills-group/YM, public, Apache-2.0,
created 2026-11-10T16:45:55Z, single commit
`55ba9fc36293b3f4d52c6b1f813169a0be76ee98` (9,789 blobs
in the recursive tree at pin time). Package:
`submissions/openai-20261028/` — `submission/` (original
sources, unchanged), `checks/` (the group's 43 review
modules), `verification/` (Comparator configs and tool
pins), `scripts/verify.py` (reproduction runner),
`evidence/` (dated records), `provenance/` (import
hashes).

- Original distribution: 9,508 files imported, 9,507
  source-manifest entries verified; archive sha256
  `976506d8db8c962f784ef772bc0ed56fdeac555048db69e0a9f1a257ee99fa05`
  (provenance/october-import.json; local archive obtained
  2026-10-28, OpenAI's send date not confirmed).
- Assessment 1 PDF (docs/assessment-1.pdf) sha256
  `8e658c00900bf723cbe90436eb1f78fca4f287e008a85c21fdceaf59e61db219`
- Submission toolchain: `leanprover/lean4:v4.32.0`
  (submission/lean-toolchain sha256
  `2773c517aa90b66ea8a2c52bddddf84393157797f8341be0df45294fff7fd32e`).
  Pinned Mathlib cache per the package manifest.
- Tool pins (verification/tool-pins.json sha256
  `2ab65d789bf76002b624b5956e5245d634ab547c3e01dc22c77f982a50d18d1b`):
  comparator `d03acab154d269c06e60e4de7e4cc85deebff94b`
  on Lean v4.34.0; lean4export
  `4e7915201d3f9f04470d9eae002fa695f7cdc589` on Lean
  v4.32.0. The same file records the mode gap verbatim:
  `"mode": "upstream-development-launcher"`,
  `"external_kernel": false`.
- Endpoints: `YangMills.jointExistence` (submitted),
  `YMReview.Acceptance.combined_acceptance` (A1–A7
  combined; frozen at review commit
  `1dec9fa5d3ab19794d082573bc885709ec68aa3a`),
  `YMReview.OPE.constructed` (A8, separate endpoint).

Key files (sha256, fetched at the pinned commit):

- `checks/AcceptanceSpec.lean` —
  `c303146d967bda49354b97ef6b7c6a4c94bd3952835a50aabeaa55a233b4f2e9`
- `checks/CombinedAcceptance.lean` —
  `40f8c57aa96db688784fe57491c87ad6cc69f061d58174802b8593ac83ef0d92`
- `checks/OPESpec.lean` —
  `3ea7ffb5f7b386036ddb9bab7753d5bcc3e198853aee70b09f06be67891813dc`
- `checks/OPECheck.lean` —
  `ef5926e323e8fa47b8096a04e5a4c4cdaeba7a90545be9613e77c6eda5f75578`
- `checks/CompleteOS.lean` —
  `4c4fdc2170e3443c86c55b66407752744f46783abf7a255476f8bc6b2e31936e`
- `verification/acceptance.json` —
  `710440530a850faf6cddb2daac24d43b4ab2b94351f647ef118cd63257d211f4`
- `verification/ope.json` —
  `60c4ac055447d037bcdf54d1f9ce8bd6be46b2571106116df16ee5fdf83946ad`
- `verification/submission.json` —
  `999fe22d03854bd94606516c212dbf5663976ff8151b1ed7efa086947ca08237`
- `scripts/verify.py` —
  `24e71f5e379502c68b35e3b85ab4bb2ea11fe75828ecc435f641c28fa9e2680f`
- `provenance/october-import.json` —
  `1ee2d290dfa6786ccd7888a4db7be48cbb55aad72a53e2533b2e1834b2ff1bb8`

## Prior checks (the group's, as recorded in evidence/)

- 2026-10-29: October source build passed, Lean 4.32.0,
  macOS arm64, pinned Mathlib cache, empty project build
  directory. 2,453 warnings recorded.
- 2026-10-30: submitted-endpoint Comparator passed for
  `YangMills.jointExistence`, standard permitted axioms.
- 2026-11-03: combined-endpoint Comparator passed for
  `YMReview.Acceptance.combined_acceptance`; four
  controls behaved as expected. Combined review build:
  41 modules at that snapshot, zero warnings.
- 2026-11-05: packaged replay passed — fresh compile of
  all 43 review modules, zero warnings, 13 audited
  declarations, 96 axiom reports, every reported axiom
  one of propext / Classical.choice / Quot.sound; OPE
  Comparator passed for `YMReview.OPE.constructed`.
- Mode of every run above: macOS development mode,
  `fake-landrun.sh`, no Linux/Landrun isolation, no
  external kernel. The packaged replay reused the
  verified October build cache for the source build
  (review modules compiled fresh).

Under this repo's D1 doctrine, legs fed by an author's
build cache are receipted only by an empty-environment
comparator run, and the recorded runs used neither
isolation nor an external kernel: the group's PASS legs
cap at PARTIAL here until our mode runs. Comparator's
own kernel did recheck the endpoints; the gaps are the
external kernel, the isolation, and the cache reuse, in
that order.

## M1 seams recorded at registration

1. A8/A7 witness seam: no theorem identifies the
   existential witness of `YMReview.OPE.constructed`
   with the witness chosen by
   `YMReview.Acceptance.combined_acceptance`. The two
   endpoints may be talking about different theories.
   ST-2 / ST-4 probe target.
2. OS correspondence: the bridge to the upstream
   OSreconstruction project is a normalized-text source
   comparison of four whole declarations
   (`OSInnerProduct`, `OsterwalderSchraderAxioms`,
   `OSArityLinearGrowthCondition`, `BorchersSequence`),
   with documented normalizations. The full upstream
   project is not rebuilt; the copied definitions are
   compiled with the construction. Text-level seam.
3. The earlier combined Comparator run predates the
   OPE adapter; the OPE endpoint's own evidence is
   separate (closed by the 2026-11-05 OPE run, in the
   same macOS mode).
4. The group's human assessment is explicitly pending:
   "Human review is still needed to establish that the
   definitions and statements express the intended
   physics and mathematics." M1–M4 open by the
   assessors' own statement.
5. Scalar bridge domain: the correlation functions are
   paired with zero-diagonal Schwartz tests; the group
   flags this domain choice for explicit review.
6. CombinedAcceptance quantifier order was handled
   carefully by the group (Wilson family chosen before
   the extraction order; one table and one Spec.Final
   witness per order). Verify at statement level, do
   not assume.
7. Source build carries 2,453 warnings (review modules
   are zero-warning). One warning is the intentional
   reference `sorry` in the Comparator reference module,
   by design.

## Forge seams (audit queued, no forge at registration)

- Empty-environment source build on Linux (recorded
  floor: ~3 h with warm Mathlib cache on the group's
  Mac; ~52 GiB completed tree). Budget above the floor;
  this practice's runners have multiplied such estimates
  before.
- Comparator on all three endpoints with Landrun
  isolation, leanexport at the pinned revision, and the
  nanoda external kernel; four controls must behave.
- 13-declaration axiom audit repeated in our mode.
- ST-1–ST-5 probes run after the Aaronson-Ambainis
  debut of the statement tests, per the queue.
- Queue position: behind the Aaronson-Ambainis audit.
  Lane decided at dispatch on runner health. The
  November 4, 2026 OpenAI submission (additional
  perturbative matching claims) is a separate package,
  work in progress at the group, out of scope here.
- Verdict lock untouched.
