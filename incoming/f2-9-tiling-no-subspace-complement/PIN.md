# Intake pin — f2-9-tiling-no-subspace-complement

**Paper:** Samuel J. Ferguson and Joshua Iosevich, *Tiling without a
subspace complement: a sharp counterexample in dimension nine over the
field with two elements*, arXiv:2610.42005 (submitted 30 Oct 2026;
verified on the abs page 2026-11-05).
**Paper URL:** https://arxiv.org/abs/2610.42005
**Retrieval:** 2026-11-05, via `curl -sL https://arxiv.org/pdf/2610.42005`
and `curl -sL https://arxiv.org/e-print/2610.42005` (the e-print tarball
ships the ancillary `anc/` directory and the single LaTeX source).
**Harvest item id:** `f2-9-tiling-no-subspace-complement`
(weekly harvest 2026-11-02, recon Card 10, fragility 0).
**Claim under test:** an explicit 64-point subset E of F2^9 tiles by
translation but has no linear-subspace tiling complement; exactly 512
tiling complements and 64 spectra, one translation class each; the
subspace-complement property holds exactly for d <= 8. The d <= 8 leg
is out of replay scope (see Scope note).

## Intake discrepancy (harvest error, recorded)

The harvest sweep and the audit brief stated 15 ancillary files
(`README.md`, `comparison_data.json`, `example.json`,
`verify_tilings.py`, `verify_no_subspace_complement.py`, plus 10 more).
That is wrong. The abs page (checked 2026-11-05, live) and the e-print
tarball both list exactly **5** ancillary files, with different script
names: `README.txt` (not `.md`), `comparison_data.json`,
`example.json`, `verify_comparison.py`, `verify_example.py`. The
tarball listing is `00README.json`, `Binary_Tiles_Threshold.tex`,
`anc/{README.txt, comparison_data.json, example.json,
verify_comparison.py, verify_example.py}` — 7 files total. No listed
file is missing; the other 10 harvest files do not exist and were not
invented. The audit proceeds on the true 5-file set.

## Pinned input files (sha256)

| File | sha256 |
|---|---|
| `paper.pdf` (468125 bytes, from arxiv.org/pdf) | `71b9a592374017a13b8ed16dc8e27c7de254b52df1a344f132ec97450d1e2f97` |
| `arXiv-2610.42005-eprint.tar.gz` (the pinned download) | `83a63ac99b5d342055c7d802f3e4063bf66cd2b5570c282ba73666b2bfd87579` |
| `paper.tex` (extracted from the tarball) | `cf2c5216450de37804e4e8009c62aa3728ecfb1073f56803590cf092e7bf81d5` |
| `00README.json` (extracted from the tarball) | `53816eb8c602092603a3a9ecbb38ad5952579f18bdb3efb32a14eda3ab5f2329` |
| `anc/README.txt` | `9fd1a3df7b31d4bf84551c787c3d4ef0a61cbd8bbfd1e213accbba809aefd9c6` |
| `anc/comparison_data.json` | `53a4c379d7fe5e064ca1af79564e0f8cb70685a67c9871e0d341da63f909b061` |
| `anc/example.json` | `6c98b0834efb902768b5d093770558ebbbb8246017779c6032815d7b2f50e60f` |
| `anc/verify_comparison.py` | `b65f6bd4e55226b77d3b6c03ac2a7d7b760b9eefef7384f327f3d205b1ec5201` |
| `anc/verify_example.py` | `3ac1a2dbde6951df9b3c7eb82519536cf4adc21dab01fab714240e312789c14c` |

All ancillary files below were extracted from the single pinned
e-print tarball, so the extraction is reproducible. No author
SHA256SUMS file is shipped; there is no second hash source to
cross-check against (unlike shuffle-squares). The `example.json`
set E and the layer bases were instead cross-checked against
Table 1 / equations (2.3)-(2.4) of the paper by both verification
routes.

## Scope note

The audit targets the *computational* claims for the d=9
counterexample: |E| = 64, tiling, the exhaustive census (512
complements, 64 spectra), and the absence of any subspace (indeed
any affine) complement. The "exactly for d <= 8" direction rests on
the authors' previously established theorem (Theorem 1.1 of their
earlier preprint, Lemma 6.5 therein) via the classification of
perfect binary codes of length 15. That leg is external trust: it is
recorded in the audit note's M4 inventory, not replayed, and the
verdict is scoped accordingly.
