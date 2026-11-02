# PIN — cop-prisoner: Raychev, guaranteed indirect delivery (extremal M(n,m))

## Claim
- Paper: Angel Ivanov Raychev, "Guaranteed indirect delivery in directed
  networks: the joint extremal function and explicit attaining constructions".
- Exact value of M(n, m) (maximum number of ordered nonadjacent
  source-recipient pairs with guaranteed delivery) and an explicit attaining
  graph for every admissible (n, m). Piecewise: sparse growth, main interval
  2n <= m <= n(n-3) with M = n(n-1) - m, dense staircase, zero above n(n-2);
  finite tables for small orders.
- The Lean development is PARTIAL by the author's own statement, in the paper
  abstract, the site release manifest, and the Lean README: it verifies the
  complete formula for n >= 12 and m >= 24, the claimed scores of prescribed
  constructions at every admissible pair, and further finite upper bounds.
  The full extremal classification is NOT a Lean theorem. This audit's
  verdict is scoped to the Lean snapshot below, not to the paper's full
  classification.

## Sources (snapshot pin, taken 2026-11-02)
No git repository. Living companion site, pinned by content hash:
- Site index: https://angelraychev.com/cop-prisoner/
- Release manifest: https://angelraychev.com/cop-prisoner/release.json
  sha256 aad1d1cc34de6b3d291e2acad7f10d3db1556ea441611b840fc6a2b5e10d1491
  (prepared_at_utc 2026-10-29T06:21:08Z; status line: "Reviewed manuscript
  prepared for arXiv; not submitted. Lean verification remains partial.")
  Its artifact_snapshots.lean entry (date 2026-10-23, scope "Unchanged
  preceding partial formalization snapshot, not complete Lean
  classification") pins the two Lean artifacts below; the downloaded copies
  match both the manifest's files[] hashes and the snapshot hashes.
- Lean archive: https://angelraychev.com/cop-prisoner/lean-proofs.zip
  sha256 e826ac3e497ed94b965de7035286e26e917139568efb341bf4951b82c4de2d28
  (48,483,469 bytes; flat lean/ tree, 6,551 .lean modules, no lakefile)
- Author verification record:
  https://angelraychev.com/cop-prisoner/lean-verification.json
  sha256 de081cf0af03f87934e076c0edca30d668868a112b2b1861aac32a7d5bd804bf
  (verified_at 2026-10-24T06:17:02Z; per-file source_sha256 for 6,555 files;
  per-module rebuild record: 6,551 modules, all exit 0, all_passed true)
- Paper as published: arXiv:2610.39469v1 [math.CO] 29 Oct 2026
  PDF sha256 0c7be38c8b8f2f22a3953f184b3e2b2136c233431564d46f05d4ff2782fbe297
  e-print sha256 07246d63ebe385ecf9feea5f3e1370f6a251d84b67c6e3343f9f856920ad7b0f
- Companion PDF (also in the manifest's files[]):
  guaranteed-indirect-delivery.pdf
  sha256 2377da1c52e7dc4c1abf452f17d6ca064f00cb233b8cf5933e280344c0b9def3

Snapshot copies are archived at ~/workspace/cop-prisoner-recon/ (VM side).
If the live site's bytes differ from these hashes at dispatch time, the
forge fails at the pin step by design; a changed site means a new snapshot
and a deliberate re-pin, never a silent substitution.

## Toolchain
- lean-toolchain in the archive: leanprover/lean4:v4.33.1 (author's record:
  Lean 4.33.1, commit 819816b2e0a3bf405af45ae5c7af2491d8f5bee6).
- External imports across all 6,551 modules are exactly: Std,
  Init.Data.List.Sort.Lemmas, Init.Data.Nat.Bitwise.Lemmas. NO Mathlib.
  Modules import each other by flat basename.

## Build method (auditor's driver, not the author's)
- The author's check.py (inside the archive) is NOT run: untrusted author
  code never runs on the runner boxes. The forge compiles with an
  auditor-written driver: parse imports, topologically sort the 6,551
  modules, compile each with `lean -o` in parallel (bounded by nproc),
  recording per-module exit code and output.
- The driver is resumable: oleans persist in a per-snapshot cache dir on the
  runner; a module whose olean already exists for this exact archive hash is
  skipped and counted as cached. Source bytes are hash-pinned, so a cached
  olean is bound to the pinned source and toolchain.
- Author's recorded single-thread total: 38,875.9 s across 6,551 modules
  (median 4.2 s, heaviest 243.8 s, 22 modules over 60 s). Wall time on the
  Dell is an estimate, not a bound; the job timeout is set to 600 min and
  the resumable cache bounds the cost of a timeout to one re-dispatch.

## Expected results at the pin
- All 6,555 source_sha256 entries from lean-verification.json match the
  extracted archive (verified at prep time, rechecked on the runner).
- Source scans: zero `sorry` tokens; zero `native_decide` in .lean files;
  zero declared axioms under the tactic/declaration-aware pattern
  (line-start `axiom <lowercase-name>`); `admit` occurs once in the whole
  tree, as doc prose in SemanticCompleteness.lean:78 ("obligations admit a
  common bound"), so the admit scan targets tactic position only.
- Build: 6,551 modules compiled, 0 failures. Compiler warnings are expected
  (the author's record shows output for 6,492 modules, linter warnings) and
  are not failures.
- Axiom audit: the author's Audit.lean carries 115 `#print axioms`
  declarations over the headline theorems (dense classification, main
  interval, sparse attainment, small tables, semantic completeness, and the
  rest). On rebuild, all 115 printed sets must be subsets of the classical
  three {propext, Classical.choice, Quot.sound}; sorryAx must not appear.
  The author's per-module record shows only four distinct axiom sets across
  all 6,551 modules, each a subset of the classical three (5,173 full;
  1,310 {Quot.sound, propext}; 66 empty; 2 {propext}) — consistent with the
  scans: no declared axioms, no sorry, no native_decide anywhere in sources.
- Permitted axiom universe for this audit: the classical three ONLY.
  Lean.ofReduceBool, Lean.trustCompiler, sorryAx, and any declared axiom
  are all failures.

## Verdict shape
- PASS: pins and hashes match, scans clean, 6,551/6,551 modules rebuild with
  exit 0 under v4.33.1, and all 115 Audit.lean axiom sets are within the
  classical three.
- BREAK: any hash mismatch, any scan hit, any module failing to compile, or
  any axiom outside the permitted set.
- Scope note (M3): the verdict covers the Lean snapshot's rebuild and its
  headline-theorem axiom base. It does not certify the paper's full
  classification, which the author states is not fully formalized, and it
  does not cover the finite-strategy certificates or research archives
  (separate site artifacts, out of scope for this forge).
