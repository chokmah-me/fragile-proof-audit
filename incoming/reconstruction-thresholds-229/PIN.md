# PIN — openai/math family 229 (exact reconstruction thresholds / four-state tree capacity)

Statement-fidelity pick from the statement-drift shortlist (rank 3,
drift 8, re-ranked "worse than ranked" on the 2026-10-14 fast pass:
the catalogue's entire four-state half has no formalized statement
at all), 2026-10-14.

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; the same pin as the family
  266/017 notes; verified to serve `lean/docs/229.md` and both
  challenge files read below)
- Scope doc: `lean/docs/229.md`
- Selected statements: `lean/ComparatorChallenges/ThreeStateSupercritical.lean`,
  `lean/ComparatorChallenges/ThreeStateTreeClauses.lean`
  (sidecar JSONs read: `threeStateSupercritical` names
  `OAI.ThreeState.regular_supercritical` +
  `OAI.ThreeState.poisson_supercritical`; `ThreeStateTreeClauses`
  names
  `OAI.ThreeState.TreeClauses.Tree.regular_reconstructs_above_KS`
  + `...poisson_reconstructs_above_KS`; permitted axioms
  `propext`, `Quot.sound`, `Classical.choice`)
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612` (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-14, SHA-256 first 16)

| File | Hash |
|---|---|
| `sources/229.md` | `58030cb8b8a8b994d5bb` |
| `sources/ThreeStateSupercritical.lean` | `ba58eb22214f0b6530f8` |
| `sources/ThreeStateSupercritical.json` | (read from API, not stored-by-hash; see note) |
| `sources/ThreeStateTreeClauses.lean` | `70eabccad9babe5153f5` |
| `sources/ThreeStateTreeClauses.json` | (read from API, not stored-by-hash; see note) |
| `sources/inventory-229.json` (family-229 entry from `~/workspace/openai-math-recon/work/inventory.json`) | `cdfc68783eb2f6f7` |
| `sources/absence-search.md` | absence-search evidence (four-state papers exist in `preprints/`, unlinked by any of the 235 scope docs; no four-state challenge exists) |

## Note

- `docs/audits/reconstruction-thresholds.md` — M1–M4
  statement-fidelity audit note.
- No Lean build and no Comparator run were performed for this pick
  (statement-level audit; see Receipt in the note). The two
  `.lean` files above are the pinned sources read for M1. All four
  catalogue-relevant theorems end in `sorry`; the proved
  lemmas in the two files are PMF-well-formedness scaffolding
  (`channel_nonneg`, `channel_sum`, `channelWeight_nonneg`,
  `channelWeight_sum`, `poissonWeight_nonneg`,
  `poissonWeight_mass`, `poissonPMF`).
