# Audit note — Chen & Gu, minimum-autocorrelation constant (arXiv:2610.18888)

**Claim artifact:** Chen & Gu, *An improved lower bound for the
minimum-autocorrelation constant* (arXiv:2610.18888v1 [math.GM],
8 Oct 2026), and its arXiv ancillary Lean project `anc/lean`.
Headline: A >= 0.4103779774321214877852987..., improving
Russell's explicitly certified 0.39921356....
**Harvest item:** weekly harvest 2026-10-26
(`incoming/harvests/2026-10-26.md`, CLAIM
minimum-autocorrelation-0410377); picked at the user's tap
2026-10-26 over Schur.
**Campaign objects:** `incoming/minimum-autocorrelation/PIN.md`.
**Pinned sources:** paper PDF sha256 `7c28180f…47947b`;
e-print bundle sha256 `98aeea11…e1450df9a`; lake-manifest.json
sha256 `cb11b5e7…9f00fc` (matches the forge evidence exactly).
Evidence in `~/workspace/autocorrelation-recon/`
(`RECON-BRIEF.md`, `evidence-run-40430792374/`,
`evidence-run-40430792374-early/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-26` · harness pin via
`scripts/harness_pin.py`. A Grandmaster's Methods pass ran at
recon; a DEEPEN pre-verdict pass ran before the verdict was
finalized (tree-identity, axiom-name coverage, cache-substitution,
hidden-build-error, and supremum-scope questions; all resolved on
evidence below).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T01:45:10Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (build + axioms at the pin): PASS.** Forge run
  40430792374, details below. The 41-file project builds at
  Lean 4.19.0 + Mathlib c44e0c8e, and all 30 theorems printed by
  the authors' Audit.lean (25) and FiniteAudit.lean (7) depend
  on exactly the classical three axioms.
- **V-B (statement fidelity, M1): PASS at the contract layer.**
  The two witness claims match the paper exactly at the
  source level (integers, ratios, witness parameters), and the
  finite certificate statement matches the paper's Certified
  Inequalities lemma. The scope is the contract: the
  formalization covers the finite certificate, overlap
  integrals, admissibility, mass formula, and ordinary-function
  witness bounds, exactly as the paper's abstract states.
- **Scope (not a GAP in the audited claims):** the passage
  "Consequently A >= R" — the identification of the supremum
  constant A with the limiting ratio — is outside the
  formalization, by the authors' own disclosure
  (paper_entirely_formalized: false; STATUS.json
  excluded_claims: no definition of A as sSup, no equivalence
  proof). This audit does not certify that passage. The
  authors' STATUS.json cites `logs/current-run/*` evidence
  files that are not in the bundle; this forge run is that
  missing receipt, by the authors' own framing.

## Receipt

- Forge workflow `autocorr-forge` at this repo's main
  `e5c28bd` (dispatch gate PASS 2026-10-27T01:07:56Z chained
  to the push), lane [self-hosted, desktop]
  (DESKTOP-7HDI2D1), dispatched 2026-10-26 21:08 EDT,
  completed success in ~17 min (21:08 → 21:25 EDT) after
  ~9 min queued behind a `verify` run, all 16 steps success.
  Run: https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40430792374
- Run verdict file: `verdict=PASS`. Bundle pins asserted
  in-run on first attempt: tarball sha256 `98aeea11…`,
  PDF sha256 `7c28180f…`, authors' sums 67/67, toolchain
  file and installed lean both 4.19.0, Mathlib rev pin ok.
  Runner clock skew 9 s / 7 s / 10 s at the three checks.
- Evidence artifacts downloaded 2026-10-27T01:41Z, zip
  sha256s matching the digests shown on the run page:
  final `30741a2f…49038`, early `61731cc7…860ea`.
- Build: 287 s, exit 0, 2355 targets, "Build completed
  successfully." Mathlib cache: 6,312 oleans (above the
  1,000 floor; the 8,322 figure from the QuantumAlg audit is
  a newer Mathlib version, not an expectation here).
- Source scan (pre-build, project tree only, `.lake`
  pruned): exactly 41 files, 0 sorry/admit, 0 escape
  hatches; the early-evidence scan is identical, so the
  scan was not polluted by the build's own dependency
  tree. Independent classifier re-run against the artifact
  logs: 25 + 7 prints, 30 unique theorems, each on
  exactly {propext, Classical.choice, Quot.sound}, zero
  sorryAx/ofReduceBool in the axiom or build logs.
- Light Python gates on this VM at recon (not part of the
  forge verdict): authors' `original/verify.py` PASS;
  `independent_audit.py` PASS (11 checks, exact overlap
  integrals, Sturm counts 0, monotonicity); reconstructed
  verifier PASS (20 leaves, 367 coefficients) with its
  output matching the supplied checks file in every value
  (metadata only differed). Authors pin sympy==1.14.0;
  the VM ran sympy 1.12 — recorded, not a verdict input.

## M1 — statement fidelity

- Witness claims (paper thm:main, source level): an explicit
  witness F_{10^{-10}} with ratio >= R_F = N/D_F =
  0.4103779773482111379678143..., and for every q < R = N/D
  an ordinary f with ratio >= q. Lean `Ratios.lean`
  defines limitingRatio = N/D and explicitRatio = N/D_F
  with the exact integers in the PIN; `Profile.lean` has
  delta0 = 1/10^10 and gamma = 99999999/100000000;
  `Targets.lean` holds ExplicitMainClaim and
  LimitingMainClaim with an honest doc comment avoiding
  supremum identification. Recomputed N/D =
  0.4103779774321214877852987329..., matching the paper's
  headline digits. Russell comparator 2378625/5958277 =
  0.39921356... as stated.
- Finite certificate (paper Lemma, Certified Inequalities):
  P'(s) >= 0 on [0,1] and g_i(t) >= gamma on each g_i
  interval. Lean `finite_certificate` states exactly this
  (DP on [0,1]; gamma <= g_0 on [0,b], g_1 on [b,w],
  g_2 on [w,c], g_3 on [c,1]), with the doc comment that
  it contains no autocorrelation integral — the same
  boundary the paper draws.
- Parameters (paper eq:params vs Profile.lean): a =
  0.626600210121, b = 0.160189995012, gamma = 0.99999999,
  c = 1−b = c_0, w = 1−2b; breakpoint order theorem
  proved. P_matches_paper theorem present in the audited
  set. The six analysis targets (overlap_integral,
  witness_admissibility, mass_integral,
  uniform_correlation, explicit_main, limiting_main) are
  all in the 30 audited theorems.
- The M4 item from recon is closed, not open: the
  `mathlib-cache-single-worker.patch` touches only Mathlib
  `Cache/IO.lean` tar-unpack arguments (`--jobs 1`); it is
  not proof-relevant and explains the build log's
  "mathlib repository has local changes" warning.

## M2 — argument route

- The Lean route proves the finite certificate (Bernstein
  leaf certificates, 367 nonnegative integer coefficients
  after clearing denominators) and the analysis targets;
  the paper route adds the reconstructed exact-arithmetic
  checker and the original Sturm-based audit as algebraic
  cross-checks. The forge build reproduces the Lean route
  from the pinned bundle; the Python cross-checks were
  rerun on this VM at recon. The two routes agree on the
  certificate's content.
- The disclosed gap is exactly one step: from "for every
  q < R there is an ordinary f with ratio >= q" to
  "A >= R" via the supremum. That step is a separate
  mathematical argument in the paper, not a Lean theorem,
  and this audit records it as out of scope rather than
  certifying or disputing it.

## M3 — credit honesty

- The paper's abstract states the formalization's scope
  (finite certificate, overlap integrals, admissibility,
  mass formula, ordinary-function witness bounds) and the
  STATUS.json states what is excluded (sSup definition,
  equivalence proof, sparse-ruler bound, Fourier/weak-limit/
  difference-basis formalizations) with
  paper_entirely_formalized: false. No overclaim found.
- VERIFICATION_REPORT.md is candid that the archive is a
  recovered archive and Lean was not rerun in the
  preparation environment; the original run was Sept 17,
  2026 on Windows. This forge run closes that stated gap.
- The Russell comparator is credited in the paper; no
  third-party attribution issue was found in the
  audited scope. Mathlib is the only dependency, at the
  pinned revision.

## M4 — fine-print assumption inventory

- The audit's scope is the M1 contract: statement
  fidelity of the witness claims and the finite
  certificate, plus the build/axiom receipt. It does not
  certify optimality of the profile, the supremum
  passage, or any theorem the authors list as
  unformalized.
- The sympy version note (1.12 on the VM vs the authors'
  1.14.0 pin) touches only the Python cross-checks, which
  are exact-rational computations; it is recorded for
  reproducibility, not as a verdict input.
- Artifact freshness: the bundle sha asserted in-run
  equals the recon sha, and the manifest sha in the
  forge pins equals the recon manifest sha, so the forge
  built the tree that was reconned.

## Verdict

PASS
