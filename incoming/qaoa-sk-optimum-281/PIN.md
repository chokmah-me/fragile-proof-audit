# PIN — openai/math family 281 (QAOA attains the SK optimum in the thermodynamic-first limit)

Statement-fidelity pick from the statement-drift shortlist (rank 7,
drift 7), 2026-10-15. First full note for this family: the
2026-10-14 fast pass did not cover it; the 2026-10-14 two-path
sweep established that both challenges carry sorry-free
solution modules, and this note is the first statement-level
reading of either path.

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; the same pin as the family
  266/017/229/227 notes; verified to serve `lean/docs/281.md`,
  both challenge files, both sidecars, both solution modules,
  and both accompanying preprints read below)
- Scope doc: `lean/docs/281.md` (full text, 2,330 bytes; the
  local recon inventory's scope field matches it in full —
  unlike 227, no truncation issue: the field is 1,336 chars)
- Selected statements (both Comparator challenge files, both
  ending in `sorry`):
  `lean/ComparatorChallenges/SKValue.lean`
  (`OAI.SKValue.value_consequences`),
  `lean/ComparatorChallenges/SKFullSupport.lean`
  (`OAI.ZeroTemperatureSK.full_support`);
  permitted axioms `propext`, `Quot.sound`, `Classical.choice`
  on both sidecar JSONs; `enable_nanoda: false` on both.
- Solution modules (named by the sidecar JSONs'
  `solution_module` fields; both read at the pin, both
  sorry-free at the top-level file — transitive sorry status
  is a build question, GAP):
  `lean/OAI/Probability/SKValue/Main.lean` (28 lines, proves
  `value_consequences` as `⟨scalar_value_target,
  finite_gaussian_target, ground_state_parisi_target⟩` from
  `GroundState.MainConclusions`; 9 direct imports),
  `lean/OAI/Probability/SKSupport/Main.lean` (66 lines, proves
  `full_support` via `minimizer_full_support_actual` plus a
  diffusion-uniqueness transfer; 7 direct imports).
  Dependency scale, enumerated per-directory via the contents
  API at the pin (the recursive tree API truncates on this
  repo — the 229 limitation): the `SKValue` subtree holds
  212 files, the `SKSupport` subtree 135 files — 347 files
  under the two solution trees, all in on-topic subdirectories
  (Control/Equations/Evolution/Gaussian/GroundState;
  Backward/Diffusion/Foundations/Parabolic/Regularity/Support).
  No file in either tree is named for QAOA, circuits, angles,
  or MaxCut.
- Accompanying papers (read at the pin from `preprints/`):
  "QAOA attains the SK ground-state energy in the
  thermodynamic-first limit" (OpenAI, September 25, 2026;
  SHA-256 first 16 `4d07ebe181b03157`) and "Full support of the
  zero-temperature Sherrington–Kirkpatrick order parameter"
  (OpenAI, September 27, 2026; `86256ac3e995c880`).
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612`
  (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-15, SHA-256 first 16)

| File | Hash |
|---|---|
| `sources/281.md` | `244155dd6e7310ab` |
| `sources/SKValue.lean` | `1c059a9b0e733ab4` |
| `sources/SKValue.json` | `6a6c5c7039e3a475` |
| `sources/SKFullSupport.lean` | `d8694501338ef271` |
| `sources/SKFullSupport.json` | `15a00a19f702bd58` |
| `sources/SKValue-Main.lean` (solution module, saved under this name to avoid the `Main.lean` collision) | `390733e213a313ee` |
| `sources/SKSupport-Main.lean` (solution module) | `99bee3ef9c623855` |
| `sources/formalization.yaml` (upstream catalog, full file) | `2dcbd0d6e6a22475` |
| `sources/inventory-281.json` (family-281 entry from `~/workspace/openai-math-recon/work/inventory.json`) | `2264c111724ab7ec` |

## The `n_formalized: 0` flag, reconciled

The inventory entry carries `"n_formalized": 0` alongside
`"n_challenges": 2`. On the interpretation established in the
227 note (the flag counts the family's accompanying papers
carrying a solution-module claim in the upstream catalog —
best-supported reading; the generating script is not
preserved), 0 is exactly consistent with the catalog itself:

- Upstream `lean/formalization.yaml` v0.4 ("Catalog of papers
  with a formalized main result"; `related_formalizations` at
  line 822) contains **zero** occurrences of `SKValue`,
  `SKFullSupport`, or `QAOA` in its 1,668 lines — neither of
  family 281's challenge configs appears in the catalog at all.
- The sidecar layer therefore claims more than the catalog
  layer: both sidecars name solution modules, both modules
  exist at the pin and are sorry-free at file level, yet the
  upstream catalog of formalized results is silent about this
  family. The flag is a catalog-claim count, not a
  verification; it is not in tension with the solution
  modules' existence, and it does not certify them either.
- Transitive sorry status of the solution modules is a build
  question (GAP).

All sources reached; nothing unreachable.
