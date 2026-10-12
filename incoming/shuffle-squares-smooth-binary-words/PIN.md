# Intake pin — shuffle-squares-smooth-binary-words

**Paper:** Kory Kilpatrick, *Shuffle squares in smooth binary words and the
Kolakoski sequence*, arXiv:2610.02262 (announced 2026-10-01; revised
2026-09-28 per paper date line).
**Paper URL:** https://arxiv.org/abs/2610.02262
**Retrieval:** 2026-10-12, via `curl -sL https://arxiv.org/e-print/2610.02262`
(single pinned download; the e-print tarball ships the ancillary `anc/`
directory with it).
**Harvest item id:** `shuffle-squares-smooth-binary-words`
**Claim under test:** every smooth binary tangram (both letters even
multiplicity) of length ≥ 18 is a shuffle square; exactly 34 smooth
tangrams are not shuffle squares, all of length ≤ 16 (Corollary 1.2 of the
paper); a finite FIFO certificate covers all positive smooth tangrams at
lengths 18, 20, …, 40.

## Pinned input files (sha256)

All files below were extracted from the single pinned e-print tarball;
the tarball itself is pinned first, so the extraction is reproducible.

| File | sha256 |
|---|---|
| `arXiv-2610.02262-eprint.tar.gz` (the pinned download) | `07d3712334bd4daeed63133a01e0a011866807b56df719070211069735c1222e` |
| `paper.tex` | `bf06bb930b7514f51a3fa776cf3170f1a20e82d8183f7270848d15e0436b6fb9` |
| `anc/README.md` | `cb66059f0b5c26d87e53823a5816c1f247720f176d3ed8fe641b8c5577f011bb` |
| `anc/SHA256SUMS` (author's own checksums) | `a4e41ef89ee997c0e7afbda0caf787f5faea7163869d7fe58e0f0c955335460f` |
| `anc/smooth-even-base-certificate.json` (291550 bytes) | `d04eb188c2529a67ac5ee7161fe83940fe316b3ac54f7d42fbdd59be7936b42f` |
| `anc/smooth-even-exceptions.md` | `52328ce19ca5019f93ec002d1e61e83ccaebfa2e901d4e4843b15cd83716838e` |
| `anc/verify_smooth_even_certificate.py` | `05d3fcb4515953e93c916bd66975b4b485055177c3025f1b732db4400ec52f6c` |

**Integrity cross-check:** the author's own `SHA256SUMS` entries for
`README.md`, `smooth-even-base-certificate.json`,
`smooth-even-exceptions.md`, and `verify_smooth_even_certificate.py`
all match the hashes computed above. The canonical certificate hash
`d04eb188…` also matches the value printed in the paper (§5) and in
`README.md` / `smooth-even-exceptions.md`. No listed file is missing;
no file was invented. All 8 expected objects present.

## Scope note

The audit targets the *computational* claims (exact 34-exception count,
certificate coverage through length 40). The infinite part of the proof
(parity-atom induction, Kolakoski corollaries) is prose mathematics and
is out of scope for this gate.
