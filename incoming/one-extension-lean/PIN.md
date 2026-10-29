# PIN — 1-extension Lean formalization (arXiv:2610.31212)

Audit opened 2026-10-29 at the user's pick (harvest
2026-10-26, CLAIM one-extension-algebraic-lean, ranked 4th
of 4; Schur, autocorrelation and Lehmer from the same
harvest already closed). Heaton & Winter, *An Algebraic
Proof of 1-Extension*: the 1-extension theorem (Henneberg
move type II preserves generic rigidity, all d >= 2,
without a special-position argument) and its weak
d-orientation self-stress lemma, formalized in Lean 4.

## Pins

- paper.pdf (arXiv:2610.31212): sha256 2b1f3cde4a32ae1a7b2badaf00d2cb3f85dd6a9fc116f9084159b4e328915c79
- arXiv source tar.gz: sha256 0b6dcfa8e9182b357b0395e6a4afa7e97b96a2b7c4e95b1174f2b5ef09be894d
- Zenodo record 23503394 (DOI 10.5281/zenodo.23503394),
  one-extension-lean-1.0.0.zip: sha256
  cfd11ee0c41a13dbb87770e9e49d2622d6f87ca7115b6e3236c516082daf19fb
  (md5 e7c938ad8ef21e87fe6ba18ec786b552, matches the
  Zenodo record's checksum)
- Inside the zip: lean-toolchain leanprover/lean4:v4.28.0;
  lake-manifest pins mathlib 8f9d9cff6bd728b17a24e163c9402775d9e6a365
  (v4.28.0) + 8 further deps; SOURCE-SHA256.txt covers
  49 Lean sources + 3 build files, all 52 verified OK
  against the extracted tree at recon.

## Claim seams recorded at recon

- The Asimow–Roth equivalence is NOT proved and NOT an
  axiom: it is an explicit hypothesis hAR / hAR' of the
  theorems that use it, typed as
  ∀ pp, GenericPlacement d pp → (LocallyFlexible G pp ↔
  InfinitesimallyFlexible G pp), per graph. The paper
  itself discloses this (main.tex, Formalization
  subsection) and so do README / VERIFICATION /
  PAPER-TO-LEAN in the archive.
- Definitions are the standard ones: GenericPlacement =
  coordinates algebraically independent over Q (existence
  proved, GenericExists.lean); GenericallyRigid d G =
  ∀ generic p, ¬ LocallyFlexible G p; LocallyFlexible =
  existence of a continuous flex; MaxwellCount stated as
  #E + C(d+1,2) = d|V|.
- The single `sorry` token in the tree (Tableaux.lean:247)
  sits inside a block comment: a deliberately commented-out
  FALSE strengthening (false at height n = 0), with the
  counterexample formalized in RedBlue.lean and the
  corrected 0 < n version proved there.
- Authors' self-verification (VERIFICATION.md + preserved
  verification/BUILD.log, AXIOMS.txt): fresh build exit 0,
  8075 jobs, 134 linter warnings; #print axioms on 5
  theorems = exactly [propext, Classical.choice,
  Quot.sound]. The audit re-runs the build and an
  11-theorem axiom superset independently on the forge.

Evidence in ~/workspace/one-extension-recon/ (zenodo-record.json,
the pinned zip/pdf/source, extracted tree under zip/).
