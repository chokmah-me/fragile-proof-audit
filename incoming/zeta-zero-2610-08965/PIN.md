# Input pin — zeta-zero records (arXiv:2610.08965)

Pinned 2026-10-12 for the October 12 harvest run (pick #1 of the shortlist).

- Paper: arXiv:2610.08965 (Kristian Muri Knausgård), announced 2026-10-06.
  - Source tarball: `2610.08965.src` (this directory), arXiv e-print as served 2026-10-12.
- Lean formalization + certificate data + reference programs:
  - Repo: https://github.com/kristianmk/839
  - Pinned commit: `b280d51bef5ab32b3280b0955d040085ed522d59`
  - Commit date: 2026-10-09 10:09:47 +0200 ("Add link")
  - Local copy: `lean-repo/` (this directory), full clone.
  - Repo ships `CHECKSUMS.sha256` covering every file except six dotfile settings
    (which arXiv strips from its ancillary copy; repo copy is authoritative here).
- Upstream library pinned by the author: anthropics/formal-math `zeta23/`
  at `fbdc36bbf17d20af3fd0447c6d1a8a02773c9844`, Lean v4.33.0-rc2,
  Mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.

Build assembly follows the repo's `lean/README.md` ("Build" section) verbatim.
