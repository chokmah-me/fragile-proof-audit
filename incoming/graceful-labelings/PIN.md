# PIN — Graceful labelings / rainbow maps (arXiv:2610.34877)

Audit opened 2026-10-27 at the user's pick (harvest
2026-10-27, CLAIM graceful labelings of trees — Lean
formalization, fragility 2, fifth in the ranked queue,
issue #12).

## Claim

Shisheng Li, *Rainbow maps and the number of graceful
labelings of trees* (arXiv:2610.34877v1, 2026-10-26;
TAOCP exercise 7.2.2.3–106): τ(N), the number of graceful
labelings of trees with N edges, satisfies
|log τ(N) − (N log(2N/π) − N)| ≤ 152·Λ⁴ for all N ≥ 3,
Λ = 1 + log(N+1) (paper's main theorem), via the
comparison τ(N) ≤ W(N) ≤ τ(N)·exp(151·Λ⁴) with the Whitty
number W(N) (Theorem 1.1) and the size estimate for W(N)
(Theorem 1.2). The Lean formalization is claimed complete
for the main theorem.

## Artifact

The arXiv ancillary Lean project (`anc/lean/` in the
source tarball; no separate repo): package PerM, 70 Lean
files, Lean v4.29.0-rc6, Mathlib @
921b8d39f71a5c813b526f38e4033417d40b4c3d. `PerM.lean`
imports all modules; `PerM/CheckAx.lean` prints axioms
for 19 theorems; `verify.sh` is the author's acceptance
script (checker positive control, explicit-module build,
sorry count, axiom whitelist, ends ALL GREEN;
self-reported, no public CI or third-party rebuild).

The formalization declares FOUR cited-result axioms in
`PerM/Axioms.lean` (recon corrects the harvest card's
two): wilson_integral (W, Wilson 1980 / DLMF 18.25.2 at
n=0), gamma_abs_sq_prod (P, DLMF 5.8.3), stirling_re (S,
DLMF 5.11.1 real part on rays), stirling_real (S', DLMF
5.11.1 real axis). Per the README's dependency table the
main theorem (PerM.main_unconditional) depends on W and
P only; S and S' serve only Theorem A.1
(perM_fine/log_perM_fine), which the main theorem does
not need. Theorem 1.1 (PerM.compare) is claimed
axiom-clean (classical three only).

Disclosed route divergence (README): the analytic Lean
files follow an earlier version of the paper (Appendix B
involution route) rather than Sections 7.1–7.2 of the
current text; the statements are the same.

## Pinned sources

- Paper PDF sha256
  `f093b5b36022b503fe4184ade8ce3bbda81a29b0327e3f9022ec1e9ebb8610bc`
- arXiv source tarball (paper source + ancillary) sha256
  `da5f84c4de1ef6beb19d67605314562f50c459a734b062ecb1dd2957661243d3`
- Toolchain leanprover/lean4:v4.29.0-rc6; Mathlib rev
  921b8d39f71a5c813b526f38e4033417d40b4c3d (lake-manifest).

## Audit scope

- **V-A (build and axiom audit, desktop runner forge):**
  fetch the tarball at the pin (sha256 asserted in-run),
  toolchain install, `lake exe cache get` (a cache miss
  on the RC toolchain is a GAP outcome, not a multi-hour
  source build), `lake build`, sorry/escape scans, and
  `lake env lean PerM/CheckAx.lean`. The 19 axiom reports
  are classified against expectations; the load-bearing
  three must be exact: main_unconditional == {propext,
  Classical.choice, Quot.sound, wilson_integral,
  gamma_abs_sq_prod}, compare == classical three,
  main_theorem == main_unconditional's set. The author's
  verify.sh is also run as-is against the built tree.
- **V-B (the four axioms as statements):** each axiom's
  Lean statement read against its cited source
  (Wilson/DLMF 18.25.2 n=0 total mass; DLMF 5.8.3 product;
  DLMF 5.11.1 Stirling with O(z^-3) remainder after the
  1/(12z) term), and spot-verified numerically by the
  auditor (mpmath, 50 digits): (P) at four (a, x) points
  with tail-corrected products, (W) at three
  (α, β, γ) points by quadrature, (S) and (S') by
  boundedness of the scaled discrepancy. Axioms are
  assumptions, not proved facts: V-B grades whether what
  is assumed is the cited, true statement — no more.
- **M1 statement fidelity by read:** graceful/TauDefs
  against the paper's τ(N) definition; main_unconditional
  against the paper's main theorem (152·Λ⁴, N ≥ 3);
  compare against Theorem 1.1 (151·Λ⁴). The disclosed
  proof-route divergence (Appendix B vs Sections 7.1–7.2)
  is recorded, not graded: statements govern.
- No author contact. The verdict lock is not touched.

Hashes verified at recon 2026-10-27; working copies in
`~/workspace/graceful-recon/`.
