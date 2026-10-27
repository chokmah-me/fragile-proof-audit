# PIN — Brualdi–Solheid completion (arXiv:2610.34905)

Audit opened 2026-10-27 at the user's pick (harvest
2026-10-27, CLAIM
maximum-spectral-radius-connected-graphs-order-size,
fragility 3, third in the ranked queue, issue #12).

## Claim

Dragan Stevanović, *The maximum spectral radius of
connected graphs with prescribed order and size*
(arXiv:2610.34905v1, 2026-10-26): completes the
Brualdi–Solheid (1986) classification for every feasible
(n, e) — no connected graph outside the dense family D_{n,e}
and the star family V_{n,e} is extremal, including at ties,
and the range n ≤ e+1 (where V_{n,e} is not defined) is
settled by the dense family alone. The final comparison
between D and V is Damnjanović's Propositions 4.1–4.2,
cited, not reproved (the paper's abstract says so).

## Artifact

The arXiv ancillary archive, carried inside the arXiv
source tarball (there is no separate repo; the reserved
Zenodo DOI 10.5281/zenodo.23650385 is stated unpublished,
so the arXiv ancillary is the only public copy). 43 files
under `anc/` plus the manuscript source
`lazy.walks.master.v35.tex`, all covered by
`anc/SHA256SUMS.txt` (43/43 verified at recon). Contents:
Python/SymPy exact certificate scripts (`anc/python/`),
a SageMath re-implementation of the same certificate
design (`anc/sage/`, historical 10.9 notebook only — no
new full Sage log exists, Sage absent from the packaging
environment and from this VM), `documentation/
PROOF_TO_CODE_MAP.md`, and a supplied complete Python run
log + exit file (`documentation/logs/`).

Certificate obligations per the map: analytic identities
(cone/quotient/walk/Bellman transfer formulas); virtual
star — four positive-coefficient cones (uniform k ≥ 60)
and 1,766 rational Sturm root exclusions (4 ≤ e ≤ 1769);
(J) coefficient signs + 38 exact small cases + ten
derivative-norm Sturm checks + denominator positivity;
(K2) rational identities and exceptional cases; (K1)(a)
positive coefficients; (K1)(MC) four polynomials;
(K1)(MA) 21 interior + 21 strict-face polynomials;
Damnjanović cubic and the three exact ties as
transcription checks only.

Analytic, not code-carried (the archive's own README
states the boundary): the Bellman induction, the graph
reductions/compression, dense-core domination, and
Damnjanović's comparison of the two surviving families.

## Pinned sources

- Paper PDF sha256
  `eb8c8dd628e619cec0f964ff711c32e371c3b0224b7dc53c22071860a7c874e4`
- arXiv source tarball (incl. ancillary) sha256
  `e8562ecf485e8a59cd1a3e43fcc339daec0d64bd13e9896cd15118e0c9e1ab45`
- Manuscript + all ancillary files: sha256 per
  `anc/SHA256SUMS.txt`, 43/43 verified at recon.
- Environment here: Python 3.12.3 (authors: 3.13.5),
  SymPy 1.14.0 and mpmath 1.3.0 (exact pins from
  `anc/python/requirements.txt`).

## Audit scope

- **V-A (certificate suite replay):** run both complete
  Python runners at the pin on this VM —
  `run_proof_only_fast.sh` (pure-Python strict boundary)
  and `run_proof_only.sh` (SymPy strict face) — each must
  exit 0 with its documented final PASS marker; compare
  the fast run's output against the supplied complete log
  (normalized). Sage suite not runnable here (no SageMath)
  and not claimed by the authors for v35 either; the
  Python suite is the complete leg.
- **V-B (independent spot recomputation):** the auditor's
  own code, built from the paper's definitions only:
  (1) the three exact ties — construct D_{n,e} and V_{n,e}
  quotient matrices from the definitions for (80,6),
  (60,10), (68,21), verify ρ(D) = ρ(V) = 9, 8, 9 exactly,
  and verify ω_e from eqs. (1)–(2) equals 80, 60, 68;
  (2) a sample of the virtual-star Sturm exclusions
  rechecked with the auditor's own Sturm implementation;
  (3) the SHA256SUMS verification (done at recon, 43/43).
- The analytic legs (Bellman induction, reductions,
  Damnjanović Props. 4.1–4.2) are read for M1–M4, not
  reproved; the verdict is scoped to the certificate layer
  plus the paper's stated dependency map, and names the
  analytic remainder plainly. No author contact. The
  verdict lock is not touched.

Hashes verified at recon 2026-10-27; working copies in
`~/workspace/brualdi-solheid-recon/`.

Addendum (2026-10-27, at close): the fast runner completed
in full (exit 0, output identical to the supplied log after
timing normalization). The SymPy alternative runner's
scripts 1–8 completed; its strict-face cross-check reached
3 of 21 faces (all PASS) across two attempts, each killed
by a VM reboot, the full script being ~2h of symbolic
expansion against this VM's ~2h reboot cycle. The
strict-face obligation itself is discharged by the
pure-Python implementation inside the fast runner (all 21
faces, RESULT: PASS). One environment repair was needed:
`templates_check.py` imports numpy, undeclared in
requirements.txt; numpy 2.5.4 was added. Audit CLOSED PASS
2026-10-27, note at
`docs/audits/brualdi-solheid-spectral-radius.md`; DEEPEN
pass in `~/workspace/brualdi-solheid-recon/DEEPEN.md`.
