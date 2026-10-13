# Input pin — truly subquadratic 3SUM / truly subcubic APSP (arXiv:2610.06783)

Pinned 2026-10-13 for the October 12 harvest (issue #5, recon rank 3,
fragility 2, top signal `formal_subset_of_claim`). Scope of the pick:
**M1 statement-fidelity audit, read-only** — no build was run.

- Paper: Josh Alman, Virginia Vassilevska Williams, *Truly Subquadratic
  3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs*,
  arXiv:2610.06783v1, announced 2026-10-05.
  - E-print tarball: `arXiv-2610.06783-eprint.tar.gz`
    `d94af3a900befd6a706ab55644f80f91fb652afaf1a2a242c65fd6e52b0ceb0e`
    (retrieved 2026-10-13 from `https://arxiv.org/e-print/2610.06783`;
    working copy in `~/workspace/three-sum-apsp-audit/`, not committed).
- Lean formalization:
  - Repo: https://github.com/anthropics/formal-math (project `3sum-apsp/`)
  - Pinned commit: `e1a4e6508154ea59f030480661590a9fe3018011`
    (branch `main`; verified still the `main` HEAD on 2026-10-13, repo
    last pushed 2026-10-06).
  - Tarball at that commit: `formal-math-e1a4e65.tar.gz`
    `fb46cde59a8b1a319c3e95869809eaf4bf014d795987278927e518cd0836d5b1`
    (working copy in `~/workspace/three-sum-apsp-audit/`, not committed).
  - Toolchain: `leanprover/lean4:v4.33.1`; Mathlib `v4.33.1` at
    `0df444a360eaa60ab8c11dca51a86af692955474` (lake-manifest.json).
- Key file hashes (all inside `3sum-apsp/` at the pinned commit):
  - `EndStatement.lean` (139 lines, imports nothing)
    `4291e3f05781cea42f9d672ff73ceac1f6d1a0c3021038e94372fa8f7e1ad987`
  - `PaperStatements.lean`
    `2ee2dca7adcc4e1612ec057f3b063c7d6bc64ec89107244018fea247e9ead4c3`
  - `README.md`
    `9fe93a17e28685323af873a64cc083fc9ea88cd333ee6d772842734929cc08ef`
  - `comparator-endstatement.json`
    `8f7fb88c5f613b96303804c611ac4968d677204ecd8d8f68d154c631673474e0`
  - `comparator-paperstatements.json`
    `243ec2526765598505ab263693e345434f610588b4f3cfe04d4cc1cc9e5afb9e`
  - `lake-manifest.json`
    `484af05025301c3920dfeb644f6dbb7f02b05f596bf48831c9324e383694db25`
