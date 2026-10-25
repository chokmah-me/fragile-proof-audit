# Input pin — Binder, Ivrii, Prause, Smirnov, Brennan's Conjecture and the Universal Integral Means Spectrum (arXiv:2610.23853)

Pinned 2026-10-25. Source: Emergent Mind harvest 2026-10-20
(fragility 1, ranked #2 in its batch); M1 pre-check at the user's
tap 2026-10-25 (PASS, ~/workspace/brennan-recon/M1-PRECHECK.md);
full audit opened at the user's tap the same day. Scope of the
pick: **M1–M4 statement-fidelity audit of the paper as two verdict
objects — V-A, the non-strict bound B_b(t) ≤ t²/4 on [−2,2]
(the argument actually printed in the note); V-B, the strictness
assertion (strict inequality on ]−2,2[∖{0}, carrying the
Kraetzer-failure consequence and the B(t) corollary), whose proof
the authors explicitly defer to a separate paper** — plus
statement-level consumption checks of the two OpenAI preprints
the note validates and of Makarov's identity. The verdict lock
is not touched. No author contact.

## The paper

- Ilia Binder, Oleg Ivrii, Istvan Prause, Stanislav Smirnov,
  *Brennan's Conjecture and the Universal Integral Means
  Spectrum*, arXiv:2610.23853v1, submitted 2026-10-16. 7 pages,
  single TeX file. Headline: a drastically shorter proof of a
  significantly stronger statement than the October 2026 OpenAI
  Brennan/Kraetzer preprints.
  - PDF: `brennan-2610.23853.pdf`
    `415931c428e582ec42c0df3204b93dac57fcb7aaaf022753e2d858ee7b9150a5`
  - E-print tarball: `brennan-2610.23853-eprint.tar.gz`
    `0ae5cfdf546e3ff33c31754fdb0100285fa0f63a6f34c7de41a39d600900d998`
  - `main.tex` (in tarball):
    `d7adc1819e6d83f9fea9e3768bda99a0415b1528662a148c3776795231ba167a`
  - No ancillary files, no code, no supplementary information;
    arXiv-only preprint (no journal ref in the record), so no
    peer-review file is published. Working copies and per-check
    evidence in `~/workspace/brennan-recon/` (`M1-PRECHECK.md`,
    `VERIFY.md`, `checks.py`, `DEEPEN.md`).

## Consumed sources (as cited by the paper)

- OpenAI, *Brennan's conjecture and sharp inverse-square integral
  means*, OpenAI Math Release preprint, September 24, 2026.
  Pinned from the openai/math repo at
  `1581d4cbdd69a0faf34b2089614fe2a814316a6a` (path
  `preprints/Brennans-conjecture-and-sharp-inverse-square-integral-means-September-24-2026/paper.pdf`),
  downloaded 2026-10-25.
  - PDF (31 pp): `27a773e887282fd97d9de50d45c1a28b335713a4d2707d613f54a6a8ebc593bd`
  - Proves Brennan's conjecture and the sharp inverse-square
    exponent B_S(−2) = 1 for the normalized schlicht class.
- OpenAI, *A strict inverse-first-power bound for univalent
  functions*, OpenAI Math Release preprint, September 24, 2026.
  Same repo commit (path
  `preprints/A-strict-inverse-first-power-bound-for-univalent-functions-September-24-2026/paper.pdf`).
  - PDF (15 pp): `b258aff1bca50ec32ec39d26b3e501e3b31df5e4e6db2807d3073c15826c196f`
  - Proves B_b(−1) < 1/4, i.e. Kraetzer's conjecture fails at
    t = −1. This is the only strictness point proved anywhere in
    the consumed record.
- Makarov's identity B(t) = max{B_b(t), 3t−1}, cited by the paper
  as Theorem 5.4 of Makarov's survey; consumed at statement level
  for the Brennan reduction (B(−2) = B_b(−2), since 3t−1 = −7 at
  t = −2) and for the corollary B(t) < t²/4 on ]−2, 6−4√2[∖{0}.
  Not re-proved in this audit (classical input, fenced in M4).
