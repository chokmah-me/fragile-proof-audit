# Intake pin + canonical-artifact recon — hibi-li-conjecture-lean

**Paper:** Dave Goel, *The Hibi--Li (2016) conjecture is fully
resolved*, arXiv:2610.40703. v1 submitted 2026-10-28 (15 pages);
**v2, 2026-11-02 (17 pages, 3 figures) is current** and is the
version pinned here. ID, title, author verified on the abs page
2026-11-05.
**Paper URL:** https://arxiv.org/abs/2610.40703
**Harvest item id:** `hibi-li-conjecture-lean` (weekly harvest
2026-11-02, recon Card 3, fragility 3: `single_author`,
`formal_subset_of_claim`).
**Claim under test:** for every finite poset P, the order polytope
O(P) has at most as many k-faces as the chain polytope C(P) for
every k, and equality for some 2 <= k <= n-1 forces unimodular
equivalence; equality for k = 1 fails (counterexample on the
5-element poset X). The paper states all its proofs are formally
verified in Lean 4.

## Canonical-artifact adjudication (the recon question)

The harvest sweep left three candidate artifacts unreconciled.
Checked live 2026-11-05; the fight dissolves — two of the three
candidates do not exist as described, and the third is not a Lean
artifact at all:

1. **The arXiv comments link is the canonical pointer, and it
   names tags, not a blob and not a branch.** v1's comment:
   `github.com/david44hello/papers_supporting_materials/tree/hibi-li-2016-conjecture-v2.10/hibi-li-2016-conjecture`;
   v2's comment: the same path at `hibi-li-2016-conjecture-v4.60`.
   Both names are **git tags** in `david44hello/papers_supporting_materials`
   (v2.10 -> `f9e99ba3bbf7369b6a52a6ec80efffe0f9eb276e`;
   v4.60 -> `a936b943f1ad442f46ac4e38c3e3dd11d0f33c55`), each a
   single "supporting materials" commit. The folder contains a
   complete Lean project at `hibi-li-2016-conjecture/lean/`
   (162 `.lean` files at v4.60), **not** a single `.lean` file.
   The repo's `main` HEAD (`ac511503...`) is a moving multi-paper
   tree and is NOT canonical.
2. **The sweep's single-file blob (`davegoel/LeanProofs`,
   `Hibi-Li.lean`) does not exist:** the GitHub user `davegoel`
   and the repo both return 404 (checked 2026-11-05). Phantom
   candidate, most likely a garbling of `david44hello`.
   Nothing to pin.
3. **Zenodo 23601975 is the concept DOI** of *The Hibi–Li (2016)
   conjecture is fully resolved, with miscellanea on marked
   chain-order polytopes* (a longer paper version). Its latest
   version record is 23885483 (v2.29, 2026-11-02; both file md5s
   verified against the record). It contains a paper PDF and a
   `programs.zip` of **Python** certificate programs (SymPy /
   stdlib checks for Theorems 9.42 and 9.47 of the long version).
   **No Lean content.** Not a candidate for the Lean audit.
   Separately, the repo README cites Zenodo 23704735 as "the
   paper" (a paper-only record, one PDF); also not a Lean
   artifact.

**Canonical artifact for the audit (arXiv v2):**
`david44hello/papers_supporting_materials` tag
`hibi-li-2016-conjecture-v4.60` @
`a936b943f1ad442f46ac4e38c3e3dd11d0f33c55`, folder
`hibi-li-2016-conjecture/lean/`, pinned in this directory as
`lean-v4.60/`. Toolchain `leanprover/lean4:v4.35.0`, Mathlib
`v4.35.0` (manifest rev `56a005855ea17e0b0958f73ec801ae140b0a1679`).
The author's own check is `./check.sh` (`lake exe cache get` +
`scripts/check.sh`); `scripts/audit.py` regenerates `AUDIT.md`
from `#print axioms` over `HibiLi/Paper/Statements.lean`.

**Version skew to carry into the audit:** the arXiv v2 text is
the paper's internal v4.70 (`hibi_li_short_v4.70.tex` in the
e-print), while its comment links the Lean at v4.60 and
`AUDIT.md` keys its claim rows to v4.60 line numbers. Minor, but
M1 must map `Statements.lean` against the version the Lean claims
to formalize, and note where v4.70 wording differs.

## The axiom picture (signature find, from the pinned source)

`lean-v4.60/HibiLi/Cited/` holds every cited result. Exactly four
`axiom` declarations exist at v4.60:

- `fourier_prop_5_2` — **G. Fourier, Proposition 5.2 (relative
  transversality), from the unrefereed preprint "The Hibi-Li
  face-number conjecture", arXiv:2609.23629v1** (Ghislain Fourier;
  v1 2026-09-20, v2 2026-10-29 — the axiom cites v1). The file
  header states it plainly: "The preprint is not yet refereed.
  Proposition 5.2 is taken as an AXIOM ... every claim whose
  AUDIT.md row lists it is conditional on it (in particular
  Theorem 4.1, Corollary 5.3 and the headline)."
- `hibiLi_thm_2_1` — Hibi–Li 2016, Theorem 2.1 (published,
  Math. Scand. 118 (2016)).
- `hlss_thm_2_1` — Hibi–Li–Sahara–Shikama 2017, Theorem 2.1
  (published, Discrete Math. 340).
- `ziegler_face_figure` — Ziegler, *Lectures on Polytopes*,
  Ch. 2 face figures (published book; the file candidly notes the
  "Proposition 2.4" numbering was not checked against the book).

NOT axioms at v4.60: Fourier Lemma 4.1 (proved,
`Proofs/Fourier41.lean`), Fourier Theorem 1.1 and Proposition 6.1
(derived), CJK Lemma 2 (proved, `Polytope/CJKProof.lean`).

The author's `AUDIT.md` (generated from `#print axioms`):
**177 claims, 158 PROVED, 19 PROVED-FROM-CITED.** The headline
row, `conj_1_1_resolved` (#175), and `thm_1_2` (#173),
`cor_5_3` (#172), and `thm_4_1` (#135) all list
`fourier_prop_5_2` among their cited axioms. So the equality case
— and with it the "fully resolved" headline — is, in Lean,
conditional on one unrefereed-preprint proposition. The harvest's
"two results of a Fourier preprint as axioms" was the v1 picture
and is now imprecise: at v2.10 (arXiv v1) BOTH Fourier Lemma 4.1
and Proposition 5.2 were axioms (167 claims, 142/25, 159 files);
by v4.60 the author had proved Lemma 4.1 and CJK, narrowing the
unrefereed dependency to the single Proposition 5.2. Credit
honesty in the artifact itself is unusually good: the dependency
is disclosed in the paper abstract, the Cited file header, and
the generated audit table. The audit's job is to verify that
disclosure is accurate (build + independent `#print axioms`), and
to grade the headline accordingly (M3), not to discover a hidden
axiom.

## Pinned input files (sha256)

Retrieval: 2026-11-05. Paper via `curl -sL
https://arxiv.org/pdf/2610.40703v2` and the v2 e-print; Lean tree
from a sparse checkout of the tag above (files byte-identical to
the tag tree; aggregate hash below covers the whole tree).

| File | sha256 |
|---|---|
| `paper-v2.pdf` (462 KB) | `1fb2b3b1306497429e6694038b8d683d4969602a747a9d6b0ff43a5fdd4565bf` |
| `arXiv-2610.40703v2-eprint.tar.gz` | `b96712183e1324a48d5afb61d6648df00b408db965152eb7a283a3e93416a618` |
| `hibi_li_short_v4.70.tex` (from the tarball) | `d1b4e7781e63c4c8c9f9860d43f118564acad9d06ca9daa7e2dd1d7956be358e` |
| `lean-v4.60/` aggregate (sorted sha256sum of all files, hashed) | `45014f2cd959ff469306ffad3cab3a557c5fda92b9826f25473f12932fe61e87` |
| `lean-v4.60/HibiLi.lean` | `3a1d4271413fce029a1884298e4a5d06062dd7f5ae72cf0a9ac221e6d1f7e1fd` |
| `lean-v4.60/HibiLi/Cited/Fourier.lean` | `bdb173d37c005426bf63ed3f6dbbdd2db476f4622d380723506546c798cdb3c7` |
| `lean-v4.60/HibiLi/Cited/Others.lean` | `a1f5b7bfe0214f9ecd7855d401f6ac8f1fcb33aceb71c338d35af3113483ef82` |
| `lean-v4.60/HibiLi/Cited/CJK.lean` | `088aff58ecebb0d89581b42c85d15051a6259b8e1cbaf0b6c2f7a7c0279861b5` |
| `lean-v4.60/AUDIT.md` (author-generated) | `4c2f90ad7b02efd7652868ee385cfe9ced05b5e35db13a5b530ae1e1c58c7ef1` |
| `lean-v4.60/HibiLi/Paper/Statements.lean` | `8bded29dd875a31801675ce0dcf47578c8038020b06bb586b40d69f05bb88b89` |
| `lean-v4.60/lean-toolchain` | `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c` |
| `lean-v4.60/lakefile.toml` | `0e6b03f729105477b37f0c6c1a05bd758475e7e6042b88dd16196ad789b69e29` |
| `lean-v4.60/lake-manifest.json` | `95838acbb79175a7e4beba4b59485e55c6a0c00535af49f06920318e646f3aad` |

## Scope note

Recon only — nothing has been built. The build leg (forge on a
self-hosted runner per house rules: `lake exe cache get`, `lake
build`, the author's `scripts/audit.py` rerun, plus an
independent `#print axioms` on the headline theorems and a
sorry/native_decide scan) waits for the dispatch word. M1 will
compare `Paper/Statements.lean` against the paper (v4.60 wording
per AUDIT.md, v4.70 as submitted); M3 grades the headline against
the verified axiom set, with `fourier_prop_5_2` as the named
condition.
