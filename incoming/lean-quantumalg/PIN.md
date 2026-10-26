# Input pin — Zhang, Jing, Zhao, Liu, Wang, Lean-QuantumAlg (arXiv:2610.30216)

Pinned 2026-10-25. Source: the user's Feed (unit b5909076,
"Lean-QuantumAlg lets AI agents build quantum algorithms to
trust"); recon and full audit opened at the user's tap
2026-10-25. Scope of the pick: **M1–M4 statement-fidelity audit
with two verdict objects — V-A, the kernel-grade build and axiom
audit of the nine endpoint mains at the repo pin; V-B, statement
fidelity of the `Solves` contract, its success bounds, and the
paper's review-effort headline** — plus the reproducibility of
Table 1's measurement. The verdict lock is not touched. No
author contact.

## The paper

- Lei Zhang, Mingrui Jing, Yusheng Zhao (QudeLeap, Shanghai);
  Jiahong Liu, Xin Wang (HKUST Guangzhou), *Lean-QuantumAlg*
  (arXiv:2610.30216v1 [quant-ph], submitted 2026-10-21). 22
  pages. Headline: AI agents produce verified quantum-algorithm
  formalizations with under 1% of lines needing human review.
  - PDF: `~/workspace/lean-quantumalg-recon/paper.pdf`
    `1c4862d9a9f2ceee6e2547d4da027b2c6e362b81b8ceef5f018ae6d8600f2091`
  - E-print tarball (main.tex + figures only; no measurement
    scripts): `~/workspace/lean-quantumalg-recon/arxiv-source.tar`
    `230845069789d5d5…` (full hash in the recon workdir)

## The code

- github.com/QudeLeap/Lean-QuantumAlg @
  `3d8829fe23d394173e2850e629b26e4f5cccf241` (2026-10-20),
  Apache-2.0. Lean / Mathlib v4.33.1
  (`leanprover/lean4:v4.33.1`); lake-manifest.json sha256
  `888ee829542ff4f39d2da2734009167dd59756cbbcad3c1f45abaa5bb076b8b7`
  (matches the forge evidence pins.txt exactly).
- Local clone: `~/workspace/lean-quantumalg-recon/repo/` at the
  pin. Working copies and per-check evidence in
  `~/workspace/lean-quantumalg-recon/` (`RECON-BRIEF.md`,
  `FIDELITY.md`, `FORGE-RUN-1-LOG.md`, `FORGE-RUN-2-LOG.md`,
  `run3-evidence/`, `run3-evidence-early/`).

## The forge

- Workflow `quantumalg-forge` in this repo, v2 at main
  `a24fdc84810344fb3691e974c987015abc2ab49b` (byte-identical to
  the reviewed candidate in the recon workdir, `forge-v2/`).
  Lane [self-hosted, desktop] (DESKTOP-7HDI2D1), fail-closed
  verdict inside the run.
- Runs: #1 `40251813868` failed (infrastructure, no verdict);
  #2 `40286503255` failed (infrastructure, no verdict);
  #3 `40323638441` completed success 2026-10-26T17:55:07Z —
  the verdict run for V-A.
