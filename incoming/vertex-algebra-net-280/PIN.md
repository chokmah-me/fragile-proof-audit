# PIN — openai/math family 280 (Unitary vertex operator algebras and conformal nets)

Statement-fidelity pick from the statement-drift shortlist (rank 8,
drift 7), 2026-10-15. The 2026-10-14 two-path sweep established
that the family's single challenge carries a sorry-free solution
module; this note is the first statement-level reading of either
path.

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; the same pin as the family
  266/017/229/227/281 notes; verified to serve `lean/docs/280.md`,
  the challenge file, the sidecar, the solution module, and the
  accompanying preprint read below)
- Scope doc: `lean/docs/280.md` (full text, 1,162 bytes; the
  local recon inventory's scope field matches it in full,
  584 chars)
- Selected statement (the family's only Comparator challenge
  file, its single theorem ending in `sorry`):
  `lean/ComparatorChallenges/VertexAlgebraNet.lean` (830 lines,
  `OAI.MinimalVertex.main`); permitted axioms `propext`,
  `Quot.sound`, `Classical.choice` on the sidecar JSON;
  `enable_nanoda: false`.
- Solution module (named by the sidecar JSON's
  `solution_module` field; read at the pin, sorry-free at the
  top-level file — transitive sorry status is a build
  question, GAP): `lean/OAI/RepresentationTheory/VertexAlgebra/MinimalComparator.lean`
  (690 lines, proves `OAI.MinimalVertex.main` at the exact
  challenge signature at line 676). Its single import is
  `OAI.RepresentationTheory.VertexAlgebra.MainClauseOne`, the
  substantive development; the visible file's own work is a
  battery of definitional-equality bridges between the
  challenge's cloned code layer and that development.
  Dependency scale, enumerated per-directory via the contents
  API at the pin (the recursive tree API truncates on this
  repo — the 229 limitation): the
  `lean/OAI/RepresentationTheory/VertexAlgebra/` tree holds
  143 files, all at the directory root.
- Accompanying paper (read at the pin from `preprints/`):
  "Strongly rational unitary vertex operator algebras and
  conformal nets" (OpenAI, September 25, 2026; SHA-256
  first 16 `b5f09142bda3ec3d`). Its Theorem 1.1 has five
  clauses; the challenge file's header names the selected
  statement "the strongly rational unitary vertex operator
  algebra main result, clause (1)."
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612`
  (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-15, SHA-256 first 16)

| File | Hash |
|---|---|
| `sources/280.md` | `0958014bafcb7baa` |
| `sources/VertexAlgebraNet.lean` | `1cbcd552d19be323` |
| `sources/VertexAlgebraNet.json` | `0ac4d5543f762c58` |
| `sources/MinimalComparator.lean` (solution module) | `7f89202fb23a6d70` |
| `sources/formalization.yaml` (upstream catalog, full file) | `2dcbd0d6e6a22475` |
| `sources/inventory-280.json` (family-280 entry from `~/workspace/openai-math-recon/work/inventory.json`) | `1e36b44e4781d019` |

## The `n_formalized: 0` flag, reconciled

The inventory entry carries `"n_formalized": 0` alongside
`"n_challenges": 1`. On the interpretation established in the
227 note (the flag counts the family's accompanying papers
carrying a solution-module claim in the upstream catalog —
best-supported reading; the generating script is not
preserved), 0 is exactly consistent with the catalog itself,
as it was for family 281:

- Upstream `lean/formalization.yaml` v0.4 ("Catalog of papers
  with a formalized main result") contains **zero**
  occurrences of `VertexAlgebraNet` or `VertexAlgebra` in its
  1,668 lines — this family's challenge config does not
  appear in the catalog at all.
- The sidecar layer therefore claims more than the catalog
  layer: the sidecar names a solution module, the module
  exists at the pin and is sorry-free at file level, yet the
  upstream catalog of formalized results is silent about this
  family. The flag is a catalog-claim count, not a
  verification; it neither certifies nor contradicts the
  module.
- Transitive sorry status of the solution module is a build
  question (GAP).

All sources reached; nothing unreachable.
