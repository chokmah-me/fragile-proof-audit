# PIN — openai/math family 261 (Localization and delocalization in the Anderson model)

Statement-fidelity pick from the statement-drift shortlist (rank 10,
drift 6), 2026-10-15. The 2026-10-14 two-path sweep established
that the family's single challenge carries a sorry-free solution
module; this note is the first statement-level reading of either
path, and it closes the shortlist's full-note queue.

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; the same pin as the family
  266/017/229/227/281/280 notes; verified to serve
  `lean/docs/261.md`, the challenge file, the sidecar, the
  solution module, and both Anderson preprints read below)
- Scope doc: `lean/docs/261.md` (full text, 1,085 bytes; the
  local recon inventory's scope field matches it in full,
  473 chars)
- Selected statement (the family's only Comparator challenge
  file, its single theorem ending in `sorry`):
  `lean/ComparatorChallenges/PlanarAndersonSpectrum.lean`
  (35 lines, `OAI.PlanarAnderson.anderson_spectrum_ae`);
  permitted axioms `propext`, `Quot.sound`, `Classical.choice`
  on the sidecar JSON; `enable_nanoda: false`.
- Solution module (named by the sidecar JSON's
  `solution_module` field; read at the pin, sorry-free at the
  top-level file): `lean/OAI/MathematicalPhysics/PlanarAnderson/Spectrum.lean`
  (767 lines, proves `anderson_spectrum_ae` at the exact
  challenge signature). **Dependency structure — a first among
  the noted families:** the module imports Mathlib only. There
  is no OAI subtree beneath it; the file-level sorry scan is
  the complete OAI-side dependency picture, and the only
  remaining transitive question is the un-run build itself.
- Accompanying papers (read at the pin from `preprints/`):
  "Pure-Point Spectrum for the Two-Dimensional Anderson Model
  at Every Positive Disorder" (OpenAI, September 23, 2026;
  SHA-256 first 16 `17487e3a2720b36f`) — the only paper the
  scope doc lists — and "Absolutely Continuous Spectrum for
  Weak-Disorder Anderson Models in Dimensions at Least Three"
  (OpenAI, September 23, 2026; `0d971c56f6ba1641`), which the
  catalogue entry's second sentence covers but the scope doc
  does not list. A search of the full inventory confirms the
  second paper attaches to this family alone.
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612`
  (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-15, SHA-256 first 16)

| File | Hash |
|---|---|
| `sources/261.md` | `05afb984b4c333c1` |
| `sources/PlanarAndersonSpectrum.lean` | `476c0769acc7d2ba` |
| `sources/PlanarAndersonSpectrum.json` | `8a9842028104663f` |
| `sources/Spectrum.lean` (solution module) | `dcbc0fed2d27a452` |
| `sources/formalization.yaml` (upstream catalog, full file) | `2dcbd0d6e6a22475` |
| `sources/inventory-261.json` (family-261 entry from `~/workspace/openai-math-recon/work/inventory.json`) | `09cd08849d9b63c9` |

## The `n_formalized: 0` flag, reconciled

The inventory entry carries `"n_formalized": 0` alongside
`"n_challenges": 1` (and `"n_mss": 2` — the family's two
manuscripts). On the interpretation established in the 227
note (the flag counts the family's accompanying papers
carrying a solution-module claim in the upstream catalog —
best-supported reading; the generating script is not
preserved), 0 is exactly consistent with the catalog itself,
as it was for families 281 and 280:

- Upstream `lean/formalization.yaml` v0.4 ("Catalog of papers
  with a formalized main result") contains **zero**
  occurrences of `PlanarAnderson` in its 1,668 lines — this
  family's challenge config does not appear in the catalog at
  all.
- The sidecar layer therefore claims more than the catalog
  layer: the sidecar names a solution module, the module
  exists at the pin and is sorry-free, yet the upstream
  catalog of formalized results is silent about this family.
  The flag is a catalog-claim count, not a verification; it
  neither certifies nor contradicts the module.
- Transitive sorry status: the solution module imports
  Mathlib only, so there is no OAI subtree left unswept; the
  residual GAP is the un-run build, not an unread tree.

All sources reached; nothing unreachable.
