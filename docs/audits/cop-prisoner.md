# Audit note — cop-prisoner: guaranteed indirect delivery, Lean snapshot (Raychev, arXiv:2610.39469)

**Claim artifact:** Angel Ivanov Raychev, *Guaranteed indirect
delivery in directed networks: the joint extremal function and
explicit attaining constructions*, arXiv:2610.39469v1 [math.CO]
29 Oct 2026. Claim: the exact value of M(n, m) (maximum number of
ordered nonadjacent source-recipient pairs with guaranteed
delivery) and an explicit attaining graph for every admissible
(n, m). The Lean development is **partial by the author's own
statement** (paper abstract, site release manifest, Lean README):
it verifies the complete formula for n >= 12 and m >= 24, the
claimed scores of prescribed constructions at every admissible
pair, and further finite upper bounds. The full extremal
classification is not a Lean theorem.
**Campaign objects:** `incoming/cop-prisoner/PIN.md` (snapshot
pins, permitted axiom universe, expected results, verdict shape).
**Snapshot pin:** no git repository; living companion site
https://angelraychev.com/cop-prisoner/ pinned by content hash:
release.json sha256
`aad1d1cc34de6b3d291e2acad7f10d3db1556ea441611b840fc6a2b5e10d1491`,
lean-proofs.zip sha256
`e826ac3e497ed94b965de7035286e26e917139568efb341bf4951b82c4de2d28`
(48,483,469 bytes; 6,551 flat Lean modules, no lakefile),
lean-verification.json sha256
`de081cf0af03f87934e076c0edca30d668868a112b2b1861aac32a7d5bd804bf`.
Toolchain leanprover/lean4:v4.33.1; no Mathlib (external imports
exactly Std, Init.Data.List.Sort.Lemmas,
Init.Data.Nat.Bitwise.Lemmas).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
harness: one-shot forge workflow `cop-prisoner-forge.yml`
(gate job + forge job on the Dell self-hosted runner), auditor
written build driver (the author's check.py was never run),
pre-dispatch gate per `docs/PRE-DISPATCH-CHECKS.md`; run dates
`2026-11-02`.

**Status:** CLOSED 2026-11-02 — verdict **PASS** (standalone
verify/audit; the 32-gate verdict lock is untouched). Scope of
the PASS, stated once and binding on every summary of this note:
the verdict covers the pinned Lean snapshot's rebuild and its
headline-theorem axiom base. It does not certify the paper's
full classification, which the author states is not fully
formalized, and it does not cover the finite-strategy
certificates or research archives on the companion site.

## Forge record

- Run #1 (41500245788, main@f5323d3) died in 1m48s at the gate
  job: the gate step grepped for a pattern dispatch_gate.sh
  never prints. Run #2 (41506252716, main@d6b3c63) died in 24s
  at the pin step: a variable assigned without export was read
  back from the environment in the same step, after all three
  download hashes had already matched. Both deaths were the
  auditor's harness, not the claim; both fixes were proven by
  exact-step simulation before re-dispatch, and both failure
  modes are now refused before dispatch by the FM8 check in
  `scripts/harness/pre_dispatch_checks.py` (main@0ac2a07).
- Run #3 (41516098996, main@8f8ff1a) completed **SUCCESS** in
  5h22m46s (2026-11-02T20:06:15Z to 2026-11-03T01:29:01Z). Gate
  job success; forge job success on dell-laptop, all 10 steps
  success.
- Evidence artifact `cop-prisoner-forge-evidence` (id
  13196707095, 4,081 bytes, expires 2026-12-03) downloaded
  2026-11-02; zip sha256
  `465e185b7659470e3d2b4f3a71074c03e7eb8571941edab7389d82492adebbc1`
  matches the GitHub API digest exactly. Every file in it
  (verdict.txt, download-hashes.txt, source-hash-check.txt,
  scans.txt, lean-version.txt, build-summary.json,
  build-driver.txt, audit-classifier.txt, modules/Audit.log)
  was checked against the PIN before this note was written.
  verdict.txt reads `cop-prisoner-forge verdict: PASS`.

## M1 — statement correspondence: PASS

- The flagship spot check from recon holds in the rebuilt
  tree: `Delivery.DenseSharpClassification.maximum` (the dense
  classification headline, 11 <= n and n(n-3) <= m shape as in
  the README) is among the 115 Audit.lean prints and depends
  only on the classical three.
- The 115 prints cover the development's own headline surface:
  dense classification, main interval, sparse attainment,
  small tables, semantic completeness (Audit.log, checked in
  full). SemanticCompleteness and SparseAttainment prints are
  present with classical-three sets.
- The snapshot itself is the object the author describes: the
  release manifest's status line says the Lean verification
  remains partial, and its artifact snapshot entry (dated
  2026-10-23) scopes itself as the preceding partial
  formalization snapshot, not a complete classification. The
  audit's scope matches the author's own description.

## M2 — execution correspondence: PASS

- Pins held at dispatch time on the runner: all three download
  hashes in the evidence match the PIN exactly, and release.json
  internal consistency passed (forge step 3).
- Source integrity: all 6,555 source_sha256 entries from
  lean-verification.json match the extracted archive on the
  runner (rechecked from prep); 6,551 modules.
- Scans clean: no `sorry`, no `native_decide`, no declared
  axioms, no tactic-position `admit` (the one `admit` in the
  tree is doc prose, SemanticCompleteness.lean:78, recorded in
  the PIN).
- Build reproduced from scratch: the auditor's topo/parallel
  driver compiled **6,551 of 6,551 modules, 0 failed, 0
  cached** (no olean reuse; a full build), 19,275.8 s of driver
  time across the 42 topological generations verified at prep.
  Toolchain on the runner reports Lean 4.33.1, commit
  819816b2e0a3bf405af45ae5c7af2491d8f5bee6, matching the PIN.
  This reproduces the author's per-module record (6,551
  modules, all exit 0) in our hands, with our driver.
- Axiom audit: all 115 Audit.lean prints classify inside the
  classical three only: 96 full {propext, Classical.choice,
  Quot.sound}, 9 {Quot.sound, propext}, 1 {propext}, 9 with no
  axioms. No sorryAx, no Lean.ofReduceBool, no
  Lean.trustCompiler, no declared axiom anywhere. The
  permitted universe for this audit was the classical three
  only, and nothing outside it appears.

## M3 — credit honesty: PASS

- The partial scope is the author's own wording in three
  places (abstract, manifest, README), and the manifest's
  status line also discloses the manuscript's submission state
  ("prepared for arXiv; not submitted" at manifest time). No
  surface we checked overstates the formalization.
- The author's verification record (per-module exit codes and
  axiom sets, all within the classical three) is accurate
  against our independent rebuild: same module count, same
  all-pass result, same axiom universe.

## M4 — fine-print assumption inventory

- Trusted base of this PASS: the Lean 4.33.1 kernel and the
  classical three. Nothing else: no Mathlib, no declared
  axioms, no compiler-trusted evaluation (no ofReduceBool /
  trustCompiler in any printed set).
- The author's check.py inside the archive was never executed,
  on any machine; the build used an auditor-written driver
  over hash-pinned sources.
- The companion site is living. The forge binds to the PIN: if
  the site's bytes ever differ from the pinned hashes, the
  forge fails at the pin step by design. This verdict speaks
  only for the 2026-10-23 snapshot pinned in the PIN, whatever
  the site serves later.
- Compiler warnings are present in the build, as the author's
  record shows (output for 6,492 modules, linter warnings);
  warnings are not failures and do not enter the verdict.
- Out of scope, not checked: the paper's full extremal
  classification beyond the formalized parts, the
  finite-strategy certificates, and the research archives
  (separate site artifacts).
