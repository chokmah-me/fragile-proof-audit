# PIN — spectral-graph-conjectures-2611-03879 (harvest 2026-11-09)

Pinned 2026-11-09 at the user's tap (register both probed claims
and run both forges on the desktop runner). No verdict at pin
time. Probe: ~/workspace/spectral-probe-2026-11-09/PROBE.md
(definitions read in full, CSV-to-Lean reconciliation, 20-row
statement sample, static hygiene scan; no build).

## Claim

Tristan Cazenave, arXiv:2611.03879 (HAL hal-05372716), single
author, pipeline built with Claude Code. From 305,755
auto-generated spectral-graph conjectures, the pipeline refuted
162,964 and proved 117,390 with no unproved hypothesis, of which
79,505 are "verified end to end in Lean" (verifiee = oui): a
machine-generated Lean theorem for every connected graph,
quantifying over Mathlib's SimpleGraph with invariants
(Laplacian / adjacency eigenvalue extrema, Zagreb and Randic
indices, rank, trace, diameter, radius, degree extrema).

## Canonical artifact

There is no git repository. The artifact is the author's
archive, linked from the paper (HTML section 8):

- `preuves_spectrales.zip` —
  https://www.lamsade.dauphine.fr/~cazenave/papers/preuves_spectrales.zip
  18,212,753 bytes, sha256
  `aa113f4a64c0a05260e381987de19c8ad7d66f8c372639f2543f1dd08c6ed500`
- Toolchain: `leanprover/lean4:v4.36.0-rc1` (lean-toolchain
  sha256 `d581a24b57a4ae9e0b2132ca8ac7cc3ac336a9fc2751fe6b29414e2d434d54c4`);
  Mathlib `v4.36.0-rc1` (lakefile.toml sha256
  `243e37f92edde2bf5881e4acf71cdb42e4eff95a500f1dad9b60332b133d2857`;
  lake-manifest.json sha256
  `22990f2c1c8e1a7b6e19a6ccd80a0e4388b256b8c625b92a0087cd2690acef5e`).
- Tree (extracted, measured at probe): `index_conjectures.csv`
  (305,755 rows; sha256
  `0fe17238cd725ea6237bb24d18c6da48e9d17488b26d79c682ed8c8bcad46aec`),
  `lemmes.csv` (738 lemma rows), `documents/`, `prouveur/`
  (pipeline: generator, provers, Lean exporter), and `lean/`:
  3,673 `.lean` files = the SpectralLean library (22 files +
  root module) and `Preuves/` with exactly 3,650 proof files in
  10 lot directories. The author's own recompile script and log
  ship in the archive (`lean/verifier_tout.sh` sha256
  `f2a07499d7f782ae5f83d95af1ea6e9eddec4e574ff1cb0020a948b70d1b60a2`;
  `lean/verification.log`: 3,650 OK, 0 failures, author's
  machine).

Key files (sha256):

- `lean/SpectralLean/Invariants.lean` (the definitions the whole
  claim rests on) —
  `bbd66c4854db14410aa46fc804ec0ffb7eaeb2154f6186851cb2fa503da02cd5`
- `lean/SpectralLean.lean` —
  `2cddfb8e86dd4a155936e94a3ece29b8b5c5ab9e8db447d58ecd13d170d62250`
- `lean/SpectralLean/Prelude.lean` —
  `1f900b4bce85bc2655cc0eeb4e6609738a28b310830fa82b586f407f972166f7`
- `prouveur/lean_export.py` (CSV-to-Lean exporter) —
  `199b030dcc86af064dd73e22107e016f3aac5c901ce593161c347734f49d33cb`
- `LISEZMOI.md` —
  `4fc93e985005fee78228b2a5025529b20d7e95ad1b3e6d148d99d1b6857b44a9`

## M1 first read (probe 2026-11-09, statement level)

- The claim denotes 305,755 CSV rows (statuses: 162,964 refuted,
  117,390 proven "demonstree", 14,150 open, 11,251 open-refuted;
  3,798 conditionnelle rows are a separate hypotheses column,
  never counted as verified). The 79,505 verifiee = oui ids are
  set-equal to the `theorem g<id>` declarations on disk (80,179
  g signatures in 3,650 files; 674 are duplicate declarations in
  Lot04, copies of Lot03_entiers with identical statements).
- Invariants.lean matches the standard definitions (Laplacian
  L = D - A over a Fintype vertex type; eigenvalues as the sorted
  spectrum of the Hermitian matrices; Zagreb M1/M2, Randic,
  energy as the sum of |eigenvalues| of A). Every one of the
  80,179 g signatures ranges over connected graphs only
  (`2 <= n` and `G.Connected` in every signature, zero
  exceptions), matching the paper's "for every connected graph".
- The exporter (`prouveur/lean_export.py`) applies exactly three
  translation atoms when a conjecture mentions them:
  rank(L) becomes n - 1, tr(L) becomes 2m, tr(A) becomes 0 in the
  Lean statement. All three are standard identities for a
  connected graph (rank of the Laplacian, trace of the
  Laplacian, zero diagonal of the adjacency matrix); Lean never
  proves the substitutions, so the verified count reads
  "statements modulo these three rewrites". tr(A) carries zero
  verified rows; the other two carry the Lot01/02/06 rows that
  mention them. The c theorem in each file is the real-arithmetic
  core, the g theorem the graph-level statement.
- Bookkeeping GAP, author's side: 22 rows in Lot07_fms carry
  statut ouverte with verifiee = oui; their theorems exist on
  disk and are faithful. The CSV lags the Lean tree, not the
  reverse. Recorded; it does not block the audit.
- 20-row statement sample across all lots: every sampled
  statement faithful modulo the three rewrites and the
  generator's definedness conjuncts (n >= 2, m >= 1,
  2m <= n(n-1), eigenvalue ordering), which the generator adds
  to c and g signatures alike.
- Static hygiene at probe (whole `lean/` tree): `sorry`/`admit`
  word hits 0, `native_decide` 0, declared `axiom` 0, the word
  "axiom" itself 0.

## Pin seams (forge questions, recorded at pin)

1. **The 3,650 proofs are not a Lake target.** `lake build`
   compiles only the 23-file SpectralLean library; each Preuves
   file is standalone (`import Mathlib`, `import
   SpectralLean.*`). The author's own route (verifier_tout.sh)
   is cache get + lake build + per-file `lake env lean` in
   parallel. The forge mirrors that route exactly and counts a
   file compiled only on exit 0 with no "error" in its log.
2. **No comparator config, no challenge module.** The kernel
   receipt is the per-file compile itself (each file elaborated
   by the toolchain's Lean from an empty environment against
   the built library) plus a `#print axioms` sample: copies of
   sampled Preuves files (one per lot, plus the Lot07 anomaly
   file F18099) with axiom prints appended, run under
   `lake env lean`.
3. **Archive is the only source.** The forge downloads the zip
   from the author's site and verifies the pinned sha256 before
   extraction; a changed or unreachable archive fails the run
   closed at the pin step.
4. **Release candidate toolchain.** v4.36.0-rc1, same pin as
   the Block Anderson artifact; Mathlib cache route recorded
   in the evidence either way.

Next step: forge (this pin's companion workflow,
.github/workflows/spectral-graph-forge.yml), desktop runner,
dispatched 2026-11-09 at the user's word.
