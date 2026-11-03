# Audit note — OpenAI local smoothing, Lean formalization (openai/math, LocalSmoothing)

**Claim artifact:** OpenAI 2026-10-26 announcement (three
model-produced claims); this audit covers the local-smoothing
claim only: local smoothing for the wave equation in all
dimensions at the conjectured sharp regularity, formalized in
Lean, with the consequences drawn in the same module:
Bochner-Riesz in the full strict range (including p =
infinity), spherical restriction in the full strict range,
Kakeya maximal bounds with delta^{-eps} loss, Stein's square
function in the conjectured range, and full Hausdorff
dimension of every Kakeya set (no measurability assumed).
**Campaign objects:** `incoming/local-smoothing/PIN.md`
(pins, permitted axiom universe, expected results, verdict
shape, run #3/#4/#5 addenda) and
`incoming/local-smoothing/closure-manifest.txt` (the exact
2,262-file transitive import closure, sha256
`da921cacb6d9c3bef4446e84019a1c401e4298907b0985c5796856febc5a2c1b`).
**Source pin:** github.com/openai/math @
`7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a`; challenge
`lean/ComparatorChallenges/LocalSmoothing.lean`, sha256
`58dd1d878cd08f8d32850b1142e451a5efd4b0cdcf538ba80efbd01ea83cd9fd`;
solution module
`OAI.Analysis.Fourier.LocalSmoothing.Comparator`.
Toolchain leanprover/lean4:v4.34.1, Mathlib rev
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Permitted
axioms: the classical three only (propext,
Classical.choice, Quot.sound); sorryAx never.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
harness: one-shot forge workflow `local-smoothing-forge.yml`
(gate job + forge job on the Dell self-hosted runner),
pre-dispatch gate per `docs/PRE-DISPATCH-CHECKS.md`;
Stunspot System Design Request prompt double-checked with
Argon for the run #3 design (adjudication in the auditor's
working papers); run dates `2026-11-03`.

**Status:** CLOSED 2026-11-03 — verdict **PASS** (standalone
verify/audit; the 32-gate verdict lock is untouched). Scope
of the PASS, stated once and binding on every summary of
this note: the verdict covers the pinned solution module's
rebuild at the pin, the six comparator theorems' axiom base
(classical three only), and the twin-definition seam
(challenge-env vs solution-env #print corpus identical over
16 definitions + 6 theorems). It does not certify the
accompanying natural-language manuscript (out of scope per
the PIN), the Yang-Mills claim (no public artifact), or any
statement beyond the six theorems named below. The
`verification_code/` Python mirror was not replayed.

## Forge record

- Runs #1 (41021417933) and #2 (41021802409) both died at
  the vendoring closure check before any build: the check
  scans every vendored file's OAI imports, and area
  vendoring has no stopping point in a 162,416-file,
  27-area tree (run #2 vendored ~46,800 files and still
  missed modules).
- Run #3 (41593282506, main@59e99b9) died in 1m48s at the
  clone/vendor step: the 2,263-pattern manifest was fed to
  git sparse-checkout through xargs, whose 128 KB default
  argument cap split it into two set calls; the second call
  replaced the first batch and removed the challenge file,
  and a silent test -f killed the step. The step also
  uploaded the previous run's stale evidence files.
- Run #4 (41594242540, main@294cb1a) ran 2h24m09s and died
  at step 11, the sorry-warning scan, after both builds
  succeeded: the scan grepped for `declaration uses
  'sorry'` with straight quotes, but Lean v4.34.1 prints
  the warning with backticks; the challenge log held
  exactly six backtick lines and the solution log none.
- Run #5 (41613290838, main@593d577) completed **SUCCESS**
  in 2h24m10s (2026-11-03T09:43:10Z to 12:07:20Z). Gate job
  success; forge job success on dell-laptop, all 19 steps
  success. Evidence artifact `local-smoothing-evidence`
  (id 13229920015, 62,591 bytes, zip sha256
  `8c7cd025496002edd12d3d85df11ecb62d785222989fac7518b49bba3f9ce093`,
  matching the API digest) verified against the PIN by the
  auditor: OAI commit = pin; vendored count 2262 =
  manifest; scan 6 challenge sorry warnings / 0 solution;
  corpus-challenge.txt == corpus-solution.txt (187 lines
  each); manifest copy sha256 = committed manifest.

## Results

- Challenge build: 8,924 jobs, exactly 6 sorry warnings
  (lines 84, 99, 109, 120, 129, 134), the six statement
  sorries by design.
- Solution build: 9,833 jobs, 0 sorry warnings; Mathlib
  cache gate 8,548 oleans (>= 1000).
- Axiom reports, all six comparator theorems, each
  depending on axioms exactly [propext, Classical.choice,
  Quot.sound]: euclidean_local_smoothing, bochner_riesz,
  spherical_restriction, kakeya_maximal, kakeya,
  stein_square. No sorryAx, no ofReduceBool, no
  trustCompiler, no other axioms.
- Verdict file in the evidence artifact reads PASS.

## Failure modes banked (auditor harness, not the claim)

- Area vendoring cannot close an import closure: vendor
  the exact transitive closure, computed at prep and
  pinned as a manifest, with a count-parity assert on the
  runner (Design A, Argon double-checked).
- xargs splits long pattern lists at its 128 KB cap and
  state-replacing commands (sparse-checkout set) silently
  lose the first batch: feed the manifest via --stdin.
- Lean's sorry warning quote form is version-dependent:
  match either quote form in the scan pattern.
- A self-hosted runner workspace persists across runs:
  the clone step deletes every stale evidence output
  before starting, so a dead step cannot upload a prior
  run's files.
- FM9 candidate (not landed): a pre-dispatch check
  refusing xargs feeding a state-replacing command.
