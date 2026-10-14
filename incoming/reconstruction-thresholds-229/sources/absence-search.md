# Absence search — family 229's four-state half (2026-10-14)

Question: does anything in `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` formalize or document the
**four-state** half of family 229's catalogue headline
("four-state reconstruction thresholds and four-state tree
capacity")?

Method (public GitHub API + raw file reads at the pinned SHA):

1. **The doc's own links** (`lean/docs/229.md`, 18 lines): the
   "Comparator links" table lists exactly two challenges —
   `ThreeStateSupercritical.lean` and `ThreeStateTreeClauses.lean`,
   both three-state. The "accompanying paper(s)" section lists
   exactly one paper: *The exact reconstruction threshold for the
   three-state symmetric channel* (September 25, 2026).

2. **The inventory's challenge list** (family-229 entry,
   `n_challenges: 2`): `["ThreeStateSupercritical",
   "ThreeStateTreeClauses"]` — both three-state; `n_formalized: 0`.

3. **Challenge-directory sweep** (full `lean/ComparatorChallenges`
   listing at the pin, 811 files): files matching
   `four|ferro|potts` are only `EinsteinFour.*`, `ExactFourier.*`,
   `FourRowPermanent.*`, `TraceReconstruction.*` — none
   broadcasting/four-state related. No `FourState*` challenge
   exists. Only `ThreeState*` challenges relate to this family.

4. **All 235 scope docs swept**: the `lean/docs` directory listing
   (235 files) contains no name suggesting four-state /
   ferromagnetic / Potts / broadcasting / tree-capacity coverage;
   and every one of the 235 docs' full text was fetched and
   searched for the two four-state preprint directory names —
   **zero hits in any doc**.

5. **The four-state papers exist but are unlinked**: `preprints/`
   at the pin contains
   - `A-Capacity-Criterion-for-Four-State-Potts-Reconstruction-on-Trees-October-5-2026/`
     (`four-state-capacity.pdf`, 345,473 bytes; README.md)
   - `The-Reconstruction-Threshold-for-the-Ferromagnetic-Four-State-Potts-Model-October-5-2026/`
     (`four-state-potts.pdf`, 514,729 bytes; README.md; `build/`;
     `verification/`)
   Neither paper is referenced by any scope doc or challenge file.

6. **Limitation recorded**: the API's recursive git tree at the pin
   returns `truncated: true`, so a repo-wide filename tree could
   not be relied on; the absence claim above rests on (1)–(5), all
   complete enumerations, not on the truncated tree.

Conclusion: the four-state program named in the catalogue headline
has no formalized statement, no scope doc, and no challenge
anywhere in the repo at the pin — and `lean/docs/229.md` never
names its absence.
