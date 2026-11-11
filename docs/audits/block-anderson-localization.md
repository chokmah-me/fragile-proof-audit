# Audit note — Block Anderson model localization scale in 1D, Lean formalization (arXiv:2611.09776, 2026-11-09)

**Verdict: PASS.** The pinned Lean artifact builds in full from
source on the self-hosted runner at the pinned commit, and all
twelve headline declarations depend on exactly the standard three
axioms (`propext`, `Classical.choice`, `Quot.sound`), no sorryAx,
no project axiom. The headline statements match the printed paper
(M1, from the 2026-11-09 probe): the localization scale, the model,
the bulk set, and Theorem 1.4's quantifier structure are the
paper's own. The 32 paper-to-Lean divergences graded at probe are
**zero load-bearing at headline level**; the SCOPE items are
intermediate only (weakest: Lemma 9.3's bound `‖K‖²_HS ≤ 32`
formalized with an existential constant) and are cataloged in M4.
This artifact ships no comparator configuration and no author
cache is consumed, so under the D1 grading rule the kernel receipt
is the full build plus the independent `#print axioms` pass; that
is the top tier available here, not a reduced one.

**Claim artifact:** Jun Yin, *Block Anderson model
localization scale in 1D*, arXiv:2611.09776 (189 pp.). Claim
(Theorem 1.4, (1.17)): the bulk localization length is
`ell_{W,g,L} = min{WL, max{W, W^2 g^2}}` up to an arbitrarily small
power of W: for 0 < kappa < 1/2 and D, tau > 0, for all large W,
uniformly over L >= 3 and g >= 0, the expected fraction of
eigenvalues in the bulk window whose eigenvector localization
length lies in `[W^{-tau} ell*, W^{tau} ell*]` is at least
`1 - W^{-D}`, with 0/0 = 0 by the paper's own convention.
Corollary 1.5 is the simultaneous form in polynomial volume.
**Harvest item:** CLAIM `block-anderson-localization-2611-09776`
in `incoming/harvests/2026-11-09.md` (harvest 2026-11-09).
**Campaign objects:**
`incoming/block-anderson-localization-2611-09776/PIN.md`.

**Canonical artifact (full detail in `PIN.md`):**
`JYin80/Lean-LSBA1d` @ `6faccdc2d8dd1fae2c622ec697c1c2e747e389ac`
(single commit, Apache-2.0) — 478 `.lean` files, 285,871 lines,
11,703 theorem/lemma declarations, all modules reachable from the
root module `LSBA`. Toolchain `leanprover/lean4:v4.36.0-rc1`;
only dependency Mathlib `v4.36.0-rc1`. Codeload tarball of the
pinned commit: 5,413,283 bytes, sha256 `12cd339f…6d38fd3`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
skills `lean-proof-forge` (forge pattern), harvest-loop M1–M4
standard · run dates `2026-11-09` (probe and registration),
`2026-11-09`/`2026-11-10` (forge runs 1–3), `2026-11-11` (evidence
read, this note). The forge workflow
(`.github/workflows/block-anderson-forge.yml`, deleted at this
close-out) was written by the main agent, passed the pre-dispatch
adversarial gate (K13/K14 + FM7) before its first dispatch, and
its source scans were pre-run clean against the pinned tree on
the VM. The probe (statement read, divergence grading, static
hygiene scan) is `~/workspace/block-anderson-probe-2026-11-09/PROBE.md`;
the M1 spot-check order it set (Lemma 9.3 first) is answered
structurally in M2, not by a separate re-read.

## The forge receipt (run 3, 42727661807)

Three dispatches from this repo: run 1 (42672119659, 2026-11-09)
died at startup in the GitHub Actions control-plane failure
cluster, zero jobs materialized; run 2 (42680112805) failed at
step 10 after 5h 08m with the step left in progress and **no**
evidence artifact (runner communication loss pattern, cause
unreceipted); run 3 (42727661807, from main@b23ecf4) completed
SUCCESS, forge wall 1h 31m on DESKTOP-7HDI2D1 (gate success in
7 s; all 14 forge steps success).

Evidence artifact `block-anderson-forge-evidence` (run
42727661807), 30,044 bytes, sha256
`cf6a351ef87dcdb1ff61e6533bee18349681921c32c0177e9ec7b73049055a7f`
(API digest, matched byte-for-byte on the downloaded zip; read
firsthand 2026-11-11; working copy
`~/workspace/ba-run3-evidence/`):

- `TARGET_HEAD`: `6faccdc2d8dd1fae2c622ec697c1c2e747e389ac` —
  matches the PIN exactly.
- `verdict.txt`, verbatim: `ROUTE: cache` / `BUILD-EXIT: 0` /
  `VERDICT: PASS`.
- `route.txt`: `cache`; `cache-exit.txt`: 0 (Mathlib dependency
  cache; manifest check `lake-manifest.json: OK` in
  `cache-get.log`). The cache is the dependency's, not the
  author's: no author oleans were consumed, the LSBA library
  itself was compiled from source.
- `build-exit.txt`: 0; `build.log` tail: "Build completed
  successfully (19066 jobs)."
- `lean-version.txt`: Lean 4.36.0-rc1, commit
  `c9afcddf514a6772bd4d649f7cfc04eff0b9f15e`, as pinned.
- `axioms-exit.txt`: 0; `axioms.txt`: each of the twelve headline
  declarations (`main_ratio_endpoint`, `lower_ratio_endpoint`,
  `simultaneous_endpoint`, `lower_simultaneous_endpoint`,
  `lower_count_endpoint`, `upper_count_endpoint`,
  `rough_density_endpoint`, `distribution_lemma`, `strong_upper`,
  `sharp_small_upper`, `compact_upper`, `large_upper`) "depends
  on axioms: [propext, Classical.choice, Quot.sound]". No
  sorryAx, nothing else.

**Comparator leg: none exists, by design.** The artifact ships
no `comparator.json` and no challenge module (PIN seam 1). There
is no missing comparator exit file; the build + axioms receipt
above is the whole kernel receipt for this target.

## M1 — Statement fidelity: PASS (probe 2026-11-09, line by line)

- The scale is verbatim: `ellScale W g = max W (W^2 g^2)`,
  `ellStar W L g = min (W*L) (ellScale W g)` (Model/Scales.lean
  19–22) = (1.7). The model `Hmat` is (1.3) with (1.2) GUE
  blocks; `bulkSet` is (1.16) in the paper's own two-case form
  with the Lemma 1.3 threshold as a parameter (any larger
  threshold is valid in the paper's lemma).
- `main_ratio_endpoint` carries Theorem 1.4's quantifier
  structure: kappa fixed, threshold, D and tau, then W_0 uniform
  in L >= 3 and g >= 0; the 0/0 = 0 convention is the paper's
  own text, not a Lean invention. Corollary 1.5's
  `L <= W^{B_L}` cap is likewise the paper's own ("Simultaneous
  bounds in polynomial volume"), not a Lean-added restriction.
- Lemma 1.2 is formalized in full as `distribution_lemma`
  (items (i)–(iii)); Lemma 1.3 as `rough_density_endpoint`;
  Theorems 3.1–3.4 predicates match (3.6)–(3.10) modulo the A/D
  exponent split, of which (3.6) is the diagonal case.
- The author's own `docs/PAPER-VS-LEAN.md` documents every
  statement difference; the probe graded all 32 against the
  LaTeX: headline level 12 items, all COSMETIC except item 8
  (SCOPE, prose facts around Lemma 1.2 not formalized, not items
  of the lemma, unused). Statement tests at probe: ST-1
  non-vacuity by the artifact's own compiled examples at concrete
  parameters (kappa 1/4, D 1, tau 1/2, L0 5; g = 1 and g = W^{-1};
  L = W and W^3); ST-4 boundary cases inside the claim as printed
  (g = 0 gives ell* = W on the block-diagonal model; L = 3 is
  exactly where `cycleAdj` becomes the true cycle adjacency).

## M2 — Argument correspondence: PASS at headline, SCOPE items intermediate

The endpoint proof terms assemble only in-repo results: the upper
count endpoint is `upperCount_of_averagedTail` applied to the
four Upper theorems, and the ratio endpoints are
`ratio_of_counts_rough` applied to the count endpoints. A complete
in-repo assembly cannot silently consume a missing lemma, so the
nine paper results with no Lean statement (probe item 30) are
route divergence, not a headline gap: each is argued bypassed in
the author's doc (Lemma 6.6 is a case of the formalized Lemma
A.21; Lemma 11.6 is bypassed by a stronger direct proof of Lemma
11.10). The admitted intermediate weakenings (M4 items) are
stated at levels the endpoints do not consume in weakened form:
Lemma 9.3's uses need only some constant, Lemma G.1's uses need
only the weaker rate, the fixed-time forms serve fixed-time
endpoints. That propagation judgment is the probe's structural
read of the assembly, recorded as such; it is not a line-by-line
re-audit of the ~460 proof files, which were covered by the forge
build itself.

## M3 — Credit honesty: PASS

- The divergence disclosure is the author's own: `docs/PAPER-VS-LEAN.md`
  (588 lines) lists every paper-to-Lean difference the probe
  found, including the one weakening the doc itself flags ("One
  bound is weaker", Lemma 9.3). Nothing the probe found was
  undisclosed by the author.
- AI assistance is disclosed in the repo README: the
  formalization is by the author with Claude Opus 5.5 and Claude
  Sonnet 5.5.
- The static hygiene scan at probe (whole tree): sorry/admit 0,
  declared axiom 0, native_decide 0, unsafe/extern/opaque 0;
  imports Mathlib and LSBA only. The forge receipt upgrades the
  load-bearing half of that scan from static to kernel-checked
  (build exit 0, axioms clean).

## M4 — Fine-print inventory (load-bearing items)

1. **Lemma 9.3 existential weakening** (probe item 20). The
   printed `‖K‖²_HS ≤ 32` (9.25) is formalized as `‖K‖²_HS ≤ C`
   with C existential; the author's doc states plainly the Lean
   statement does not imply the printed final one. Regime (ii)
   bounds (9.70), (9.77) are weaker by a power of W. Tag:
   risk-inducing at the lemma's own level; the endpoints consume
   only the existence of a constant, so the headline does not
   inherit it. This is the weakest admitted point in the library.
2. **Fixed-time class** (item 14). Eight Section 5/7/App C
   results whose print carries a supremum over time inside the
   probability are formalized at fixed time only; the Itô/BDG
   machinery is replaced by deterministic generator identities.
   Tag: SCOPE at those lemmas; endpoints are fixed-time
   statements and do not inherit the loss.
3. **Lemma G.1 rate** (item 21): averaged local law at
   `(W eta)^{-1/2}` against the printed `(W eta)^{-1}`. Uses
   need only the weaker rate.
4. **Weaker uniformity** (items 22, 23): Theorem 5.12's theta_*
   and Lemma A.7's rate constant are quantified after parameters
   the paper fixes earlier. Uses are at fixed values.
5. **Stronger hypothesis** (item 24): Lemma B.4 assumes the
   convolution weight the paper derives; all in-library callers
   supply it. Lemma 11.3's last sentence dropped (item 25),
   unused by the Lemma 11.4 proof.
6. **Release-candidate toolchain.** v4.36.0-rc1 for both Lean
   and Mathlib. The verdict is a statement about this artifact
   at this toolchain, as pinned; a future re-pin to a release
   toolchain would need a fresh build to carry the verdict over.
7. **Single author, single commit.** The repo is one commit by
   the paper's author (with disclosed AI assistance); there is
   no independent formalization to cross-check against. The
   audit's independence is the runner build, the axiom pass, and
   the probe's statement read, not a second implementation.

**Dangling check.** TARGET_HEAD matches the PIN; build,
cache, and axiom exits are all 0; the twelve axiom listings are
uniform and clean; the headline statements match the print with
zero load-bearing divergence. No contradiction between the
paper, the doc, the probe, and the forge receipt.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
audit of harvest 2026-11-09's Block Anderson CLAIM: **M1 PASS**,
**M2 PASS at headline with intermediate SCOPE items cataloged**,
**M3 PASS**, **M4 PASS as catalog** — overall **PASS**: the
formalization proves Theorem 1.4 and Corollary 1.5 as printed,
from source, on the standard three axioms alone.
