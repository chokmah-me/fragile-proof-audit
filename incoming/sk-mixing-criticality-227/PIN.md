# PIN — openai/math family 227 (Critical SK autocorrelation processes and dynamics)

Statement-fidelity pick from the statement-drift shortlist (rank 6,
drift 7 — confirmed on the 2026-10-14 fast pass with refinement:
the formalization is broader than the truncated inventory copy
suggested, but the sharpest catalogue claims stay outside),
2026-10-14.

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; the same pin as the family
  266/017/229 notes; verified to serve `lean/docs/227.md` and all
  five challenge files read below)
- Scope doc: `lean/docs/227.md` (full text, 4,377 bytes —
  **note:** the local recon inventory's copy of this scope note
  is truncated mid-word at 1,500 characters; the truncation
  point is marked in `sources/inventory-227.json`. The note
  below quotes the full upstream doc.)
- Selected statements (all Comparator challenge files, all
  ending in `sorry`):
  `lean/ComparatorChallenges/SKHighTemperature.lean` (`OAI.SKGap.sk_main`),
  `lean/ComparatorChallenges/SKRatio.lean` (`OAI.SKRatio.ratio_cutoff`),
  `lean/ComparatorChallenges/CriticalSKMixing.lean` (`OAI.CriticalSK.critical_mixing_bounds`),
  `lean/ComparatorChallenges/CriticalSK.lean`
  (`OAI.CriticalSK.realized_equilibrium_initial_states`,
  `OAI.CriticalSK.covariance_and_linear_tests`,
  `OAI.CriticalSK.critical_mixing_lower_bounds`),
  `lean/ComparatorChallenges/SKBarriers.lean` (`OAI.SK.main`);
  permitted axioms `propext`, `Quot.sound`, `Classical.choice`
  on all five sidecar JSONs.
- Solution modules (named by the sidecar JSONs' `solution_module`
  fields; all read at the pin, all sorry-free at the top-level
  file — transitive sorry status is a build question, GAP):
  `lean/OAI/Probability/SKGap/Main.lean` (120 lines,
  proves `sk_main` via `FullMain.quenched_poincare`),
  `lean/OAI/Probability/SKRatio/Main.lean` (40 lines, proves
  `ratio_cutoff`),
  `lean/OAI/MathematicalPhysics/CriticalMixing/Main.lean`
  (50 lines, proves `critical_mixing_bounds`),
  `lean/OAI/Probability/SKBarriers/Main.lean` (61 lines,
  proves `SK.main`),
  `lean/OAI/MathematicalPhysics/CriticalSK/Rayleigh.lean`
  (626 lines, 59 theorems/lemmas, proves
  `covariance_and_linear_tests` at line 607;
  `CriticalSK/Main.lean` is an import aggregator).
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612`
  (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-14, SHA-256 first 16)

| File | Hash |
|---|---|
| `sources/227.md` | `ecacd9dd0af0bf4f` |
| `sources/SKHighTemperature.lean` | `9645fa7fe2545c28` |
| `sources/SKRatio.lean` | `c3bad5ef4a04ee33` |
| `sources/CriticalSKMixing.lean` | `16c41c4533f545eb` |
| `sources/CriticalSK.lean` | `d365331a7e2c669d` |
| `sources/SKBarriers.lean` | `70b833ec6c74952f` |
| `sources/inventory-227.json` (family-227 entry from `~/workspace/openai-math-recon/work/inventory.json`; scope field truncated at 1,500 chars upstream of the inventory, marked inline) | `7b1ca614bfd55f62` |
| Solution modules | read at the pin from `lean/OAI/...` (not copied; URLs in note) |

## The `n_formalized: 1` flag, reconciled

The inventory entry carries `"n_formalized": 1` alongside
`"n_challenges": 5`. The script that generated
`formalized_by_family.json` is not preserved in the recon
workspace, so the flag's construction is reconstructed from
the surviving evidence (best-supported interpretation):

- `formalized_by_family.json` maps family 227 to exactly one
  paper title: "Critical slowing down in the
  Sherrington–Kirkpatrick model" — one of the four accompanying
  papers in `lean/docs/227.md`.
- Upstream `lean/formalization.yaml` v0.4 is explicitly "Catalog
  of papers with a formalized main result"; its
  `related_formalizations` section maps challenge configs to
  solution declarations. Of family 227's five challenge
  configs, exactly two appear there (`CriticalSK`,
  `CriticalSKMixing`), both belonging to the "Critical slowing
  down" paper (the criticality paper); the other three
  challenges (`SKHighTemperature`, `SKRatio`, `SKBarriers`)
  have no catalog entry.
- Hence `n_formalized: 1` = the upstream catalog's count of the
  family's accompanying papers carrying a solution-module claim
  — **not** an independent verification of proved content.
  Consistent with the evidence: the solution files exist and
  are sorry-free at top level (see above); the challenge
  statements are all-sorry; transitive sorry status of the
  solution modules is a build question (GAP).

All sources reached; nothing unreachable.
