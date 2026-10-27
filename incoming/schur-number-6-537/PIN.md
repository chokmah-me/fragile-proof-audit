# Input pin — Chen, Schur number S(6) >= 537 (arXiv:2610.31362)

Pinned 2026-10-26. Source: weekly harvest 2026-10-26
(`incoming/harvests/2026-10-26.md`, CLAIM schur-number-6-537,
fragility 0); picked at the user's tap 2026-10-26 as the parallel
second audit, laptop lane, while the minimum-autocorrelation forge
ran on the desktop lane. Scope of the pick: **M1–M4 audit of the
explicit certificates** — the main 6-coloring of [1,537], the
standalone 8-coloring of [1,5372], and the 131-partition collection
with its mod-538 and inequivalence claims. The SAT search itself is
not replayed; a lower-bound claim stands on its explicit
certificate. The verdict lock is not touched. No author contact.

## The paper

- Chen, *A new lower bound for the sixth Schur number: S(6) >= 537*
  (arXiv:2610.31362). Repo-carried PDF `paper/main.pdf`
  sha256 `e432c91827047c9742cae2c5396bb741e29f8f5d74ba78a30548a73dfd2c25cf`.
- Claim: {1,...,537} partitions into six sum-free sets (x, y not
  necessarily distinct), improving Fredricksen–Sweet 536 (2000);
  derived S(8) >= 5372, S(11) >= 204208, S(13) >= 2042082,
  R_6(3) >= 539.

## The code

- github.com/jeffchen006/Schur-Number-6 @
  `92a9d5f1336a5a064b2bfe6597d967f59191e365` (also the tip at recon
  and at forge dispatch, 2026-10-26).
- Authors' SHA256SUMS: 21 entries, all OK at the pin.
- certificate.col sha256
  `5f950ad88a5437108a0c6ab4b9d40cc2832a43dd474b5c4b269e02ac81258315`
- solutions537.txt sha256
  `fcae1cd5165c585ea41028059410ea47cdfa514a5488a1c876fc8591ce4631b6`
- data/S8_n5372.txt sha256
  `d0abd71d8de5749bcd12c6bbbb909033a3f8baa17a624364751669b6cb586d24`

## Our verifier

- `~/workspace/schur-recon/independent_verify.py`, sha256
  `813b80c792365cc4cf556250c6dfdd100a669b3d161b9c26e57a201f009d4925`,
  written from the paper's definitions; embedded byte-identical in
  the forge workflow and in the run's evidence artifact.
- Working copies and evidence: `~/workspace/schur-recon/`
  (`RECON-BRIEF.md`, `evidence-run-40431910885/`).
