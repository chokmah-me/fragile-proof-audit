# PIN — openai/math family 017 (irrationality exponent of π)

Statement-fidelity pick from the statement-drift shortlist (rank 2, drift 9), 2026-10-14.
Second full check off the shortlist (family 266 was first, note at main@3590482).

## Upstream pins

- Repo: `openai/math` @ `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (2026-10-06, "Initial commit"; only commit touching `lean/docs/017.md`;
  read via public GitHub raw at this SHA)
- Scope doc: `lean/docs/017.md`
- Selected statement: `lean/ComparatorChallenges/PiExponent.lean`
  (challenge statement; ends in `sorry`)
- Toolchain: `lean/lean-toolchain` = `leanprover/lean4:v4.34.1`
- Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612` (per `lean/lake-manifest.json`)

## Source hashes (as fetched 2026-10-14)

| File | SHA-256 (first 16) |
|---|---|
| `sources/017.md` | `a738f64b79494db1` |
| `sources/PiExponent.lean` | `6b50d65255870bd4` |
| `sources/inventory-017.json` (family-017 entry from `~/workspace/openai-math-recon/work/inventory.json`) | `8b119b915af4fdda` |

## Note

- `docs/audits/pi-exponent-flint-hills.md` — M1–M4 statement-fidelity audit note.
- No Lean build and no Comparator run were performed for this pick
  (statement-level audit; see Receipt in the note). The `.lean`
  file above is the pinned source read for M1.
