# Input pin — Improved lattice-packing bounds (Zubrilina, AstroNinja389/lattice-packing-bound)

Pinned 2026-10-27. Source: fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
improved-lattice-packing-bounds-small-dimensions, recon
fragility 5, issue #12); picked at the user's tap 2026-10-27.
Scope of the pick: **V-A, exact replay of all 83 certificates
(dimensions 9–91) by the repo's four independent verifiers
(Taylor, Bernstein, PARI root-counting, Descartes for even
dimensions) on this VM at the repo pin, with the driver's
manifest-hash validation and reference-log comparison
intact; V-B, an independent scalar recomputation of the
budget arithmetic (caps B/A, weights, kappa, rho_+, density
and Hermite claim checks) from the certificate data in the
auditor's own implementation of the verification contract,
for all 83 certificates** — plus the headline comparisons
(n=16 against the rigorous three-point value 0.024995; the
67-dimension improvement set; the four smallest exact gains).
The proof of Theorem 1 in the paper is read for M1–M4, not
formalized; this is a certificate replay, not a Lean audit.
Comparisons for n ≥ 17 are against published *numerical*
Cohn–Elkies values (Afkhami-Jeddi et al.), recorded as such,
not audited as rigorous bounds. The verdict lock is not
touched. No author contact.

## The claim

- Nina Zubrilina, arXiv:2610.35830 (2026-10-26): certified
  lattice-packing density upper bounds tighter than the
  rigorous Cohn–de Laat–Salmon three-point bound for
  11 ≤ n ≤ 16 (n=16: 0.0187461206 vs 0.024995, a 25.00%
  gain) and below the published numerical Cohn–Elkies
  values in 67 dimensions, n in [17,23] ∪ [25,40] ∪
  [43,57] ∪ [62,75] ∪ [83,91]; smallest gains 0.01171%
  (n=62) and 0.01668% (n=91). Certificates also cover
  n=9, 10 (comparison only; stronger lattice bounds exist
  there) and the non-improvement dimensions in 9–91,
  n=24 named a control in the README.
- The method modifies Cohn–Elkies: the auxiliary function
  may be positive on a short interval beyond the minimum
  distance, and per-class short-vector counts modulo 2 are
  bounded by the B/A caps of Theorem 1.
- Paper Section 1 discloses: "The numerical exploration
  of the linear program was performed by GPT-6 Astra."
  The search leg is AI; the exact certificates are the
  proof leg (author's own framing, repo README agrees:
  "The numerical search supplies candidates; it is not
  part of the proof.").
- Paper sha256 (arXiv PDF)
  `e26fc57262e32566ff1941659f910a68cfac2bea6c8a9182a4efc866d1df0d16`;
  arXiv source tarball sha256
  `76ca3f6b3ad52b0761caeb3d93194679eed02e7d33f44225b82216a6eaf6525e`;
  the repo's `paper/main.tex` is byte-identical to the
  arXiv source `main.tex`.

## The code

- Repo: github.com/AstroNinja389/lattice-packing-bound @
  `340a0e93bb95942c2b1b80092be43149504970eb` (single commit,
  created 2026-10-26; handle does not match the author
  name; README: licence selection pending, no licence
  granted). Codeload tarball sha256
  `e3afc19993b8578a4d6be13b61dec51013dc4711622e0a2cd64da3a328c227a1`.
- Contents: 83 certificates `certificates/n009.json` …
  `n091.json` (exact integer/fraction strings; n016 cert
  sha256
  `1d6f40a3ca0812758a696750a378dbbafb4dea3f97bdf43f114502aefa43f5b1`),
  `manifest.json` (per-certificate sha256 + claims),
  `data/results.json`, four verifiers under `verify/`
  (taylor.py, bernstein.py — Python stdlib only; pari.py +
  verify.gp — PARI/GP; descartes.py — python-flint, even
  dimensions only), reference logs under `logs/`, method
  notes + verification contract under `notes/`.
- Audit environment deltas (recorded, not hidden): README
  tests Python 3.14.6 / PARI-GP 2.19.0 / python-flint
  0.9.0; this VM runs Python 3.12.3, PARI-GP 2.15.4
  (apt), python-flint 0.9.0 (exact pin match, venv).
- Working copies and recon: `~/workspace/lattice-packing-recon/`
  (`paper.pdf`, `source.tar.gz`, extracted `repo/`).
- Replay 2026-10-27 on this VM: Taylor 83/83, Bernstein
  83/83, PARI 83/83, Descartes 41/41 even, all driver
  exit 0 with reference-log comparison on; auditor's
  scalar gate 83/83 claims, failures=0. Audit CLOSED PASS
  2026-10-27, note at `docs/audits/lattice-packing-bounds.md`;
  DEEPEN pass in `~/workspace/lattice-packing-recon/DEEPEN.md`.
