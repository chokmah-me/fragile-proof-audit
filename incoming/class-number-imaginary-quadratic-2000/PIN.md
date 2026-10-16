# Input pin — imaginary quadratic fields of class number at most 2000 (arXiv:2610.21511)

Pinned 2026-10-16 for the October 16 harvest (issue #6, recon rank 1,
fragility 2, signals `disclosed_llm_help`; single author). Picked by the
user in chat 2026-10-16 ("Pick recon #1: class number ≤ 2000, pin it and
start the audit"). Scope of the pick: **M1–M4 statement-fidelity audit
plus data gates and a forge build receipt** — the verdict lock is not
touched. The sieve's full re-run is out of scope (author's runs:
188 processes on a 96-core Threadripper); the audit says so where it
matters.

- Paper: Iwao Kimura, *Imaginary quadratic fields of class number at
  most 2000*, arXiv:2610.21511v1, math.NT, 20 pages, published
  2026-10-15. Headline (Thm 1.2 / thm:main): exactly 16,453,493
  imaginary quadratic fields with class number at most 2000; largest
  |d_K| = 1,062,350,083, attained at h = 1978.
  - PDF: `arXiv-2610.21511.pdf`
    `1d23022a6c743a61964b31b0b7394e51eeffdf7122a9a32d8480763324a8ae8a`
  - E-print tarball: `arXiv-2610.21511-eprint.tar.gz`
    `d78b7ebae3ceae2d108585423f822766855216de0852ac0c46dc2e7122418387`
    (both retrieved 2026-10-16 from arxiv.org; working copies in
    `~/workspace/class-number-audit/`, not committed).
- Code, formalization, data:
  - Repo: https://github.com/iwaokimura/cln-imq-2k
  - Pinned commit: `7133a32cfce5f541c98dc4d65c98c9704747c406`
    ("README: cite arXiv:2610.21511", 2026-10-16T17:01:20+09:00).
    This is exactly one commit after the recon snapshot
    `e451afc7f277f6cbc1f197302689aef98df2c10c` (2026-10-15); the diff
    `e451afc..7133a32` is one README line (the arXiv citation), verified
    with `git diff --stat` (1 file, +1/−1). No claim-bearing content
    moved between the recon pin and this pin.
  - Toolchain (under `lean/`, not the repo root — the recon ledger's
    "toolchain: not pinned" was a root-only check):
    `leanprover/lean4:v4.34.1` (`lean/lean-toolchain`); Mathlib
    `d13f23b723b8a846827a245b89c10fc7d3f11612`, LeanCert
    `7f91b6eb3567437f6cfac03ed279706603ee22f4`, LeanArchitect
    `468e8f58fb4ad6e6ad672a08da6d0d0531e95a97` (`lean/lake-manifest.json`).
    353 `.lean` files repo-wide; the B4 proof files are ~20 files in
    `lean/` plus `lean/vendor/` (upstream OAI SiegelZeros at 301488868,
    PrimeNumberTheoremAnd, TauCeti, AINTLIB — see the audit brief).
  - Key file hashes at the pin:
    - `lean/B4ClassNumber.lean`
      `eadf5d157481253e4b9b81787ff098952cd329504012fb8823fc2024384e2b06`
    - `lean/B4Chi8.lean`
      `93d3e404374e858b14787bd38a3db138d756c1783b2847e9a19da7cfb3997246`
    - `lean/B4ZeroGap.lean`
      `edb4471f9ad4078bcefbc79c2a6411ac379576a21b25027730a6aeda1f8ac7d9`
    - `lean/Challenge/B4ClassNumber.lean`
      `ae70d69bd900ce078c0c8fc903f7a7acb3542c43809bb58b51c46aa372f77f20`
    - `lean/Challenge/B4ZeroGap.lean`
      `660573e68478c3effdc4a83223d07efb742c32e387968554a027003fd04e7166`
    - `lean/B4Build.txt`
      `3eefff1288d7165a551151472347519111dbeca5499234b679fc3c57931365cd`
    - `lean/B4Replay.txt`
      `67c621eef256f5426f470ffd3243a4e21121167505a7185cb8e4dcfafba4b927`
    - `lean/comparator/B4Comparator.txt`
      `068c05a13a189c5d868e06cd271bce3087baefd4c669613e324739cf5e36e75b`
    - `qsieve/qsieve.c`
      `b053152d6b6a703e6f0b1d91237860409346b5dec7075809c6217ea9a7e38baf`
    - `computations/mj_extract.py`
      `0709c50906fadd2c438e3b02fd35d6619d1bdfc51455884a228d90a4f3d9ab9c`

## Data gate already run at pin time (2026-10-16, this VM)

Against `lists/` at the pin, decompressed with `xz -dc`:

- `imq_h2000.txt` SHA-256
  `07100ea3589ab2b490122fa69b438cd5393bdcd2e547dfc29bb3b5c86f9f24c0`
  — matches the value printed in the paper (§ Data and code
  availability) and the repo's `lists/SHA256SUMS`.
- `imq_h1000.txt` SHA-256
  `075a201c8e7cce6c0b6013423a5d96c6308452afab2fa79882388fc46d8b0c45`
  — same, matches.
- Line counts: h2000 list 16,453,493; h1000 list 4,115,897 — both
  exact against the paper.
- h2000 list: d strictly increasing (0 violations), every h in
  [1, 2000], max h = 2000, last line `1062350083 1978` — the paper's
  largest |d_K| at h = 1978.
- The h1000 file is exactly the h ≤ 1000 subset of the h2000 list
  (same (d, h) pairs, both directions).

These checks validate the shipped lists against the paper's printed
commitments. They do not validate the sieve, the tables, or the Lean
proofs; those are the audit's remaining paths (brief:
`~/workspace/class-number-audit/brief-paths.md`, 14 paths).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run date
`2026-10-16`.
