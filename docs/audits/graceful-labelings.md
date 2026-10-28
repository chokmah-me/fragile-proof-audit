# Audit note — Graceful labelings of trees (Shisheng Li, arXiv:2610.34877)

**Claim artifact:** Shisheng Li, *Rainbow maps and the
number of graceful labelings of trees*
(arXiv:2610.34877v1), main theorem: for N ≥ 3,
|log τ(N) − (N log(2N/π) − N)| ≤ 152·Λ⁴,
Λ = 1 + log(N+1), via the comparison
τ(N) ≤ W(N) ≤ τ(N)·exp(151·Λ⁴) (Theorem 1.1) and the
Whitty-number size estimate (Theorem 1.2). The artifact
is the arXiv ancillary Lean project (package PerM, 70
files, Lean v4.29.0-rc6, Mathlib @
921b8d39f71a5c813b526f38e4033417d40b4c3d); no separate
repo.
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
graceful-labelings Lean, recon fragility 2, issue #12);
picked at the user's tap 2026-10-27.
**Campaign objects:** `incoming/graceful-labelings/PIN.md`.
**Pinned sources:** paper PDF sha256
f093b5b36022b503fe4184ade8ce3bbda81a29b0327e3f9022ec1e9ebb8610bc;
arXiv source tarball sha256
da5f84c4de1ef6beb19d67605314562f50c459a734b062ecb1dd2957661243d3;
toolchain `leanprover/lean4:v4.29.0-rc6`; Mathlib rev
`921b8d39f71a5c813b526f38e4033417d40b4c3d`; forge
evidence artifact sha256
009464d9259c8709b5df024b78b6bc70199ce14d0cb9761f03590039858ebd09
(run 40647987696). Evidence in
`~/workspace/graceful-recon/` (`EVIDENCE.md`,
`evidence-run-40647987696/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-28` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: a direct read of what the
statement architecture actually does); the pre-verdict
deepening was a DEEPEN challenge pass (below), run after
independent re-verification of the evidence.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-28T07:31:29Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## M1 — statement fidelity (read, not assumed)

- τ(N): paper defines it as the number of spanning trees
  of the complete graph on {0,…,N} whose N edges have
  distinct lengths. Lean `graceful N` (TauDefs.lean):
  `Nat.card` of `lo : Fin N → Fin (N+1)` with
  `IsLS` (edge d+1 joins `lo d` and `lo d + d + 1`,
  inside the vertex set) and `lsGraph N lo` a tree.
  One edge of each length 1…N by construction; a tree
  on N+1 vertices has exactly N edges, so no collapsed
  or duplicated edge can pass the IsTree condition.
  Matches the paper's definition, including the
  OEIS A033472(N+1) identification.
- `PerM.compare` (CombMain.lean): `graceful N ≤ perM N ∧
  perM N ≤ graceful N * Real.exp (151 * Lam N ^ 4)` —
  Theorem 1.1 exactly.
- `PerM.main_unconditional` (CombMain.lean):
  `|Real.log (graceful N) - (N * Real.log (2 * N / π) - N)|
  ≤ 152 * Lam N ^ 4`, N ≥ 3 — the paper's main theorem
  exactly, built from generic `main_theorem` (the same
  bound for any τ satisfying the comparison) plus
  `compare`. `Lam N = 1 + Real.log (N + 1)` (MainThm.lean)
  — the paper's Λ.
- `PerM.perM_sandwich` first assertion:
  `(1/7)(2/π)^(N−1)·(N−1)! ≤ perM N` — Theorem 1.2's
  lower bound with m = N−1, as the paper states it.
  Statements are stated once each (single project,
  single module graph); no twin-definition seam.

## M2 — argument (machine-checked legs)

- Forge run 40647987696 (workflow graceful-forge, commit
  8eda9ec, DESKTOP-7HDI2D1, 16m34s run / 10m23s job):
  all 12 steps success. Toolchain install + Mathlib
  cache exit 0 (7,849 oleans). `lake build` exit 0,
  8,288 jobs, 0 errors. Sorry scan 0, escape scan empty
  (no native_decide/ofReduceBool/admit). The author's
  verify.sh ran as-is against the built tree: ALL GREEN,
  19/19 axiom reports, whitelist clean.
- Axiom reports (CheckAx, kernel-level, parsed by the
  forge classifier, verdict PASS): 19 reports, every set
  inside {classical three, wilson_integral,
  gamma_abs_sq_prod, stirling_re, stirling_real}, and
  the load-bearing three exact: `main_unconditional` =
  classical three + wilson_integral + gamma_abs_sq_prod;
  `main_theorem` = the same; `compare` = classical three
  only. The combinatorial theorems (card_RM, card_RST,
  card_fiber_le, compare_RM, constant_151,
  graceful_le_card_RM, repair, sum_ncyc_le, altSum
  even/odd) are classical-three only. Moment theorems
  add wilson_integral only; sandwich/log_perM add
  wilson_integral + gamma_abs_sq_prod; perM_fine adds
  wilson_integral + stirling_re; log_perM_fine adds all
  four. All six runner key-file hashes match the
  auditor's pinned-tarball extraction byte-for-byte.
- Run #1 (40610777534) failed at the sorry-scan step on
  a harness bug, not a project defect: grep's exit 1 on
  zero matches under the runner's `bash -eo pipefail`
  aborted the step. The fix (guard the grep with
  `|| true`; `wc -l` alone is insufficient under
  pipefail) was proven both directions locally before
  re-dispatch. Incident recorded in the daily log.

## M3 — credit honesty

- The formalization is the author's own ancillary
  material for his own paper; no third-party credit is
  claimed or needed. The search/discovery leg is not
  part of this claim (the theorem is a human proof,
  formalized). The four axioms are cited results, not
  the author's own theorems, and are labeled as such in
  Axioms.lean and in the README's dependency table.

## M4 — fine print

- FOUR cited-result axioms exist, not two (the harvest
  card said two): wilson_integral (W, Wilson 1980 /
  DLMF 18.25.2 at n = 0), gamma_abs_sq_prod (P, DLMF
  5.8.3), stirling_re (S, DLMF 5.11.1 real part on rays),
  stirling_real (S′, DLMF 5.11.1 real axis). Only W and
  P reach the main theorem; S and S′ serve only
  Theorem A.1 (perM_fine/log_perM_fine). The verdict is
  therefore conditional on W and P as cited results, and
  on nothing else outside Lean's three axioms.
- V-B (auditor's own checks, mpmath 50 digits):
  (W) quadrature exact to ~50 digits at three
  (α,β,γ) points; (P) exact to ≤6.43e-39 relative error
  at four (a,x) points with a polygamma series tail
  (a first crude tail left residuals that were exactly
  the first neglected Euler–Maclaurin term, confirmed
  case by case); (S)/(S′) scaled discrepancies bounded
  and converging to 1/360, the B₄ term, as the
  expansion predicts. The axiom statements were also
  read against their citations (form, domains,
  normalizations). These checks verify that the assumed
  statements are the cited, true ones; they are not
  proofs of the identities, and the verdict does not
  pretend otherwise.
- Disclosed route divergence (README): the analytic
  Lean files follow an earlier version of the paper
  (Appendix B involution route) rather than Sections
  7.1–7.2 of the current text; the statements are the
  same. Recorded, not graded: statements govern, and
  the sandwich statement was checked against Theorem
  1.2 directly.
- Fence: the paper's combinatorial argument is verified
  only insofar as the Lean proof is machine-checked;
  no human re-proof of the 70 files was attempted, and
  none is needed for the claim as formalized. The
  analytic remainder in the paper's prose is inside the
  Lean proof where it is used, not cited.

## DEEPEN pre-verdict pass

Run against the assembled case; nothing moved. Attacks
killed on facts: self-reporting CheckAx (the reports are
kernel output from oleans built on the runner from the
hash-pinned tarball, re-run independently by verify.sh
with the same whitelist result); twin-definition drift
(statements stated once, composition via generic
main_theorem, no second statement file); axiom
misstatement (statement reads + numeric signatures at
multiple points, including the 1/360 Stirling
signature); route divergence (statements checked
directly against the paper's theorems); stale cache
(cache exit 0 + 7,849 oleans + full rebuild from the
pinned toolchain). The one live finding in the run was
the harness's own scan bug, fixed and proven before
re-dispatch, not a project defect.

**Verdict: PASS** — the main theorem is machine-checked
on Lean's three axioms plus the two disclosed, cited
results W and P (both verified as the cited, true
statements by the auditor's numeric checks); the
comparison theorem is axiom-clean; no sorry, no
escapes, author's acceptance script ALL GREEN.
