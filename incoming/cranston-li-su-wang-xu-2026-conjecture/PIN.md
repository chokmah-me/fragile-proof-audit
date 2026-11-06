# Intake pin — cranston-li-su-wang-xu-2026-conjecture

**Paper:** Dave Goel, *The Cranston--Li--Su--Wang--Xu (2026)
conjecture is true*, arXiv:2610.40863. Submitted 2026-10-29
(13 pages, 1 table). ID, title, author verified on the abs page
2026-11-05. The arXiv text is the SHORT paper (e-print source
`p002_short.tex`); the Lean AUDIT.md keys its rows to "SHORT
v1.59" line numbers.
**Paper URL:** https://arxiv.org/abs/2610.40863
**Harvest item id:** `cranston-li-su-wang-xu-lean` (harvest
2026-11-05, recon Card 10, fragility 1: `single_author`,
`pinned_toolchain`).
**Pick:** at the user's tap 2026-11-05 ("Use argon to proceed to
execute"): the harvest shortlist was double-checked by Argon
(google/gemini-4-argon, $0.044576; adjudication at
~/workspace/replaygate-harvest-argon-2026-11-05/ADJUDICATION.md),
which overturned the fit ranking's #1 (theta sign patterns) in
favor of this item; the main agent accepted the swap. Deciding
factors: immutable tag pin, 55 files, author AUDIT.md +
kernel_replay.sh, and an absolute abstract claim ("all results
proved in Lean 4 from Lean's standard axioms alone") from the
author of the Hibi-Li formalization, which passed only
conditionally on an unrefereed preprint axiom (audit closed
2026-11-05). The live audit question is the adaptation check:
has any unproved input moved from an `axiom` declaration (which
#print axioms catches) into a structure/locale hypothesis (which
it does not)?

**Claim under test:** for every finite abelian group A with
|A| >= 4, any two nowhere-zero A-flows on an all-even-degree
graph are joined by a chain of cycle changes through nowhere-zero
flows (Theorem 2.3: every even graph is A-flow-connected), and
likewise for integer flows with values in {1,...,k-1} in absolute
value, k >= 4 (Theorem 8.1: every even graph is k-flow-connected).

## Canonical artifact

The arXiv comments field names a tag, not a branch:
`github.com/david44hello/papers_supporting_materials/tree/cranston-li-su-wang-xu-2026-conjecture-v1.59/cranston-li-su-wang-xu-2026-conjecture`.
Tag `cranston-li-su-wang-xu-2026-conjecture-v1.59` @
`7c03e0ba9a2c34e578472f477237a64d5c181e02` (verified via the
GitHub API 2026-11-05). The repo's `main` HEAD (f26bde87,
pushed 2026-11-05) is a moving multi-paper tree and is NOT
canonical. The Lean project sits in the folder's `lean/`
subdirectory (library `EulerFlow`), pinned in this directory as
`repo-v1.59/` (the tag's folder contents: README.md + lean/).
Fetched as the codeload tag tarball, sha256
`7a6d466bf3258791aa4622eea085bfbfb0fcb35a003d1586b3128994b266aa5f`.

- Toolchain `leanprover/lean4:v4.35.0`; Mathlib v4.35.0
  (manifest rev `56a005855ea17e0b0958f73ec801ae140b0a1679`).
- 55 `.lean` files. Author's own check: `scripts/check.sh`
  (build + forbidden-construct scan + `scripts/audit.py`, which
  regenerates AUDIT.md from `#print axioms`); plus
  `scripts/kernel_replay.sh` (author-stated about 20 min).
- AUDIT.md at the pin: **106 rows, all PROVED, cited-axioms
  column empty on every row**; its Trust line states there is
  NO `EulerFlow/Cited/` folder and no project axiom. In the
  Hibi-Li artifact the corresponding table had 19
  PROVED-FROM-CITED rows; here the claim is 106/0. Recorded as
  the author's declaration; the forge run tests it.

## Hash pins (sha256)

- `paper.pdf` (arXiv:2610.40863, as fetched 2026-11-05):
  `ba3ba003f080dad9e672afe693efcb91d7013668ced8f8ea572b02343dc8e264`
- `arXiv-2610.40863-eprint.tar.gz`:
  `89fc244f4b6069dcbd9d9ca0b6be9180487612c85905d2808ce98cd56b9e3660`
- `p002_short.tex` (from the e-print):
  `380a5c59fe53f07edca07268d29c8568331598e17bf5e1d6bb4437008b2fcce8`
- `repo-v1.59/lean/AUDIT.md`:
  `ff84d6fc5b5f1b93aa2c784fa9600d050a406bf679cac865dbe04e4bf8970376`
- `repo-v1.59/lean/lean-toolchain`:
  `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c`
- `repo-v1.59/lean/lake-manifest.json`:
  `bec74b1449642236cb569fc91e1144ffb06785b0cf3e4861335bde5a9da683a3`

No supplementary information or peer-review file exists for
this preprint (arXiv comments point only to the Lean repo);
the download set is complete per the standing SI rule.

## Recon-level statement read (M1, 2026-11-05, not a verdict)

- Tree-wide grep over the 55 `.lean` files at the pin: **zero**
  hits for `axiom`, `sorry`, `native_decide`, `ofReduceBool`
  outside scripts. (The forge's axiom receipt is the verdict
  instrument; this grep is recon only.)
- Headline statements in `EulerFlow/Paper/Statements.lean`
  carry exactly the paper's hypotheses and nothing else:
  `thm_2_3 (A : Type) [AddCommGroup A] [Fintype A]
  (hA : 4 <= Fintype.card A) (G : MGraph V E) (hev : G.IsEven)
  : G.FlowConnected A`; `thm_2_4` the ZMod m form;
  `thm_8_1 (hk : 4 <= k) ... : G.KFlowConnected k`.
  No ClassicalInputs-style Prop structure, no extra hypothesis
  fields on the headline theorems — the hypothesis-smuggling
  adaptation Argon hypothesized is **not present at statement
  level** in the pinned tag. Definition-level fidelity
  (FlowConnected, IsEven, MGraph vs the paper's graph model)
  is the audit's M1/M4 work, not settled here.
- AUDIT.md rows 10, 48-51, 69-72, 94+ include results the table
  itself marks "not in the short paper (long paper v0.30
  only)": the Lean proves more than the arXiv text states.
  Scope direction is superset, not subset; M1 at pick maps the
  short paper's claims only.
