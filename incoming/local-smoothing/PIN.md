# Input pin — OpenAI local smoothing formalization (openai/math, LocalSmoothing)

Pinned 2026-10-30. Source: OpenAI 2026-10-26 announcement
(three model-produced claims; ETH disproof audited PASS,
note docs/audits/openai-eth-disproof.md); picked by the
user 2026-10-30 after recon
(~/workspace/local-smoothing-recon/RECON.md). Scope:
V-A, runner build + axiom audit of the solution module
at the repo pin; V-B, statement fidelity of the six
comparator theorems against the challenge statement,
with the twin-definition seam settled by a
challenge-env vs solution-env #print corpus (the ETH
audit method). The accompanying natural-language
manuscript is out of scope, as is the Yang-Mills claim
(no public artifact). The verdict lock is not touched.
No author contact. Shepherds named in the announcement
explicitly do not certify.

## The claim

- Local smoothing for the wave equation in all
  dimensions at the conjectured sharp regularity,
  formalized in Lean, with the consequences drawn in
  the same module: Bochner-Riesz in the full strict
  range (including p = infinity), spherical restriction
  in the full strict range, Kakeya maximal bounds with
  delta^{-eps} loss, Stein's square function in the
  conjectured range, and full Hausdorff dimension of
  every Kakeya set (no measurability assumed).

## The code

- Repo: github.com/openai/math @
  `7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a` (same pin
  as the ETH audit; head == origin head at ETH run
  time; local sparse copy at ~/workspace/eth-recon/math
  is at this commit, challenge file sha256
  58dd1d878cd08f8d32850b1142e451a5efd4b0cdcf538ba80efbd01ea83cd9fd
  verified against a fresh fetch).
- Challenge: `lean/ComparatorChallenges/LocalSmoothing.lean`
  (+ `.json`): solution module
  `OAI.Analysis.Fourier.LocalSmoothing.Comparator`,
  six theorems (euclidean_local_smoothing,
  bochner_riesz, spherical_restriction, kakeya_maximal,
  kakeya, stein_square), permitted axioms = classical
  three.
- Solution module subtree:
  `lean/OAI/Analysis/Fourier/LocalSmoothing/`, 73 .lean
  files, 284,021 bytes. Comparator.lean imports
  OAI.Analysis.Fourier.SquareFunction.Square.Literal;
  Main.lean imports WavePackets.AllScales and
  WavePackets.PositivePacketSolvability, so the build
  closure extends into the Fourier subtree (vendoring:
  the whole lean/OAI/Analysis/Fourier subtree, with an
  in-forge import-closure check).
- Toolchain `leanprover/lean4:v4.34.1`; Mathlib rev
  `d13f23b723b8a846827a245b89c10fc7d3f11612` (same as
  the ETH audit).

## Addendum 2026-11-03 (run #3 design: closure-manifest vendoring)

Runs #1 (41021417933) and #2 (41021802409) both died at the
vendoring step's import-closure check, before any build: the
check scans every vendored file's OAI imports, and Fourier
files import modules outside any vendored area set. Run #1
vendored the Fourier subtree (76 external imports); run #2
vendored OAI/Analysis + OAI/Geometry + OAI/MeasureTheory
(about 46,800 files) and still failed. The pinned tree holds
162,416 OAI .lean files in 27 areas, so area widening has no
stopping point. Diagnosis and design were double-checked with
Argon under the Stunspot System Design Request prompt
(adjudication: ~/workspace/local-smoothing-recon/argon-sdr/).

Run #3 design (Design A): vendor the exact transitive import
closure of the two roots (solution Comparator module +
challenge file), computed at prep time against the pinned
commit. The closure is 2,262 .lean files (Analysis 2,209,
LinearAlgebra 27, MeasureTheory 25, lean/OAI.lean 1; notably
zero Geometry), pinned as
incoming/local-smoothing/closure-manifest.txt (2,263 lines
including the challenge .json; sha256
da921cacb6d9c3bef4446e84019a1c401e4298907b0985c5796856febc5a2c1b).
Run #2's failure is explained by the closure: it never
vendored the 27 LinearAlgebra files or lean/OAI.lean, and it
paid for 14,443 Geometry files the closure never touches.
Prep proof: the workflow's verbatim closure-check blocks pass
on the materialized closure (challenge sha256 matches this
PIN), and removing one imported file makes the same check
fail naming exactly that module (simulation record:
~/workspace/local-smoothing-recon/sim.log). The workflow
sparse-checks-out exactly the manifest at the pin, asserts
vendored .lean count == manifest count, and keeps the
tree-wide closure check unchanged as a guard. All other legs
(cache gate, builds, sorry scans, corpus comparison, axiom
verdict) are unchanged from runs #1/#2.

Run #3 (41593282506, main@59e99b9) died at the clone/vendor
step in 1m48s: the manifest was fed to git sparse-checkout
through xargs, whose default 128 KB argument cap split the
2,263 patterns (about 135 KB) into two invocations; the second
set call replaced the first batch's patterns and removed the
challenge file, and the following silent test -f killed the
step (log shows exit 1 immediately after rev-parse, no FAIL
line; the split reproduces locally on the same manifest). The
step also uploaded the previous run's stale evidence files
(VENDORED_COUNT.txt still read 46810 from run #2), because the
self-hosted workspace persists between runs. Run #4 fixes:
sparse-checkout reads the manifest via --stdin (single call,
no argument cap; git 2.43 verified), the presence checks fail
loudly by name, and the clone step first deletes every stale
evidence output so a dead step cannot upload a prior run's
files.

Run #4 (41594242540, main@294cb1a) ran 2h24m09s and died
at step 11, the sorry-warning scan, after both builds
succeeded (challenge 8,924 jobs in 11s; solution 9,833 jobs
in 8,361s; cache 8,548 Mathlib oleans; vendored count 2262
= manifest). Cause: the scan greps for
declaration uses 'sorry' with straight quotes, but Lean
v4.34.1 prints the warning with backticks
(declaration uses `sorry`); the challenge log holds exactly
six such lines (lines 84, 99, 109, 120, 129, 134) and the
solution log holds none, so the scan read 0/0 and failed the
challenge leg. The formalization substance is intact: 6
challenge sorries by design, 0 solution sorries. Run #5 fix:
the scan pattern matches either quote form
(grep -cE "declaration uses ['\`]sorry['\`]"), verified
against the run #4 logs as 6/0 before landing.
