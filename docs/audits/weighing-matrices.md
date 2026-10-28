# Audit note — Weighing matrices W(n,k) to n = 108 (Macías-Quintero, arXiv:2610.33976)

**Claim artifact:** Adrián Macías-Quintero, *Explicit
weighing matrices W(n,k) for all n ≡ 0 (mod 4) with
4 ≤ n ≤ 108, and all 1 ≤ k ≤ n* (arXiv:2610.33976v1).
Main theorem: for every (n,k) in S = {(4m,k): 1 ≤ m ≤ 27,
1 ≤ k ≤ 4m} (|S| = 1,512) a weighing matrix W(n,k)
exists. The proof is the catalogue: one explicit matrix
per pair, each checked in exact integer arithmetic.
Artifact: GitHub repo
adrianmaciasquintero/weighing-matrices, release
v1.1.0, archived at Zenodo doi:10.5281/zenodo.23484194
(Apache-2.0).
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM weighing
matrices to n=108, recon fragility 1, issue #12);
picked at the user's tap 2026-10-28.
**Campaign objects:** `incoming/weighing-matrices/PIN.md`.
**Pinned sources:** paper PDF sha256
cc572b97b21303e45c303a46104a00e145880bc70dd282df694a682cffaf4ca6;
arXiv source tarball sha256
6f194b0b30234787c6699ab35e178ea8f74442538ef6ad634c2a6558cf2dff49;
repo codeload tarball (tag v1.1.0) sha256
b9d917bcf03e344b31037907869ff6ce26ad6ecf37580deb9643be6e1bf38aff;
Zenodo zip sha256
f425f6ec3dcdf73beca13b33c900caa5d1ad5251323d27617f63a0fd39f00ea3.
Evidence in `~/workspace/weighing-recon/` (`EVIDENCE.md`,
`my_checks.py`, run logs).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-28` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: a direct read of what the
statement architecture actually does); the pre-verdict
deepening was a DEEPEN challenge pass (below), run after
independent re-verification of the evidence.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-28T07:54:41Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## M1 — statement fidelity (read, not assumed)

- The paper's definition: W(n,k) is n×n, entries in
  {−1,0,1}, WW^T = kI_n. The catalogue stores exactly
  one matrix per (n,k) ∈ S, with S spelled out in the
  paper as {(4m,k): 1 ≤ m ≤ 27, 1 ≤ k ≤ 4m} and
  |S| = 4·Σm = 1,512. The auditor's checker takes its
  target set from that formula, not from the file
  listing, so a missing or extra pair is a finding,
  not a silent pass.
- Theorem statement and stored objects agree: the
  JSON fields (n, k, matrix) are what both checkers
  enforce; the folder name W{n}_{k} agrees with the
  JSON (n,k) in all 1,512 cases.

## M2 — argument (the catalogue is the proof)

- V-A: the author's `verify_weighing.py` replayed on
  the pinned tag tree: exit 0, 1,512 OK / 0 FAIL /
  0 consistency warnings (verbose run). The shipped
  report.csv agrees (1,512 rows, all OK). The verifier
  is exact by construction (int64, np.array_equal, no
  floating point in the verdict; entries, row and
  column weights, WW^T and W^TW all checked).
- V-B: the auditor's own checker, written from the
  definition only: file set == S exactly (0 missing,
  0 extra); numpy int64 pass 1,512/1,512 (shape,
  entries, row and column weights, both Gram
  identities); pure-Python integer pass 198/198 over
  a structured sample (all 27 Hadamard cases k = n,
  all 108 cases at n = 108, all 24 small GS cases,
  40 seeded-random others). Environment: Python
  3.12.3, numpy 2.5.4.
- Provenance: the Zenodo archive's solutions tree is
  byte-identical to the GitHub v1.1.0 tag tree
  (recursive diff clean; zip md5 matches the Zenodo
  record). The catalogue that was checked is the
  catalogue that was archived.

## M3 — credit honesty

- Method counts tallied from the stored metadata by
  the auditor's code: dsum 672, kron 201, h2blocks 27,
  identity 27, paley1 16, paley1_h 8, paley2 4,
  skew_hadamard 6 = 961 classical; gs 551, split
  24 at n ≤ 24 (exhaustive) and 527 at n ≥ 28
  (annealed). Both totals and both splits match the
  abstract's claims exactly.
- The author claims no priority for the 13 matrices
  whose parameters appear unresolved in historical
  tables, and says so in the paper. Nothing in the
  catalogue overclaims: each file names its method and
  recipe, and the GS files store their generators
  (the author's verifier re-derives the GS array from
  them as a consistency warning check; 0 warnings).

## M4 — fine print

- Search reproduction is out of scope by the paper's
  own framing, correctly: the theorem's validity rests
  on the stored matrices and the exact check, not on
  the exhaustive search or the annealing that found
  them. The audit follows that framing; the annealing
  runs were not reproduced and do not need to be.
- int64 exactness: Gram entries are sums of at most
  108 products of {−1,0,1} values, so every intermediate
  is an integer of magnitude ≤ 108; no overflow or
  rounding is possible in int64, and the pure-Python
  sample passes through a second, independent
  arithmetic path.
- Side content fenced, not graded: the parity
  obstruction for GS matrices W(4m,4m−1) with m even
  (a short proof in the paper, not part of the main
  theorem's evidence), and the 13 historical-table
  parameters (their matrices are inside the 1,512 and
  are verified as matrices; their literature status is
  the author's open question, explicitly not claimed).

## DEEPEN pre-verdict pass

Run against the assembled case; nothing moved. Attacks
killed on facts: silent pair omission (target set
computed from the paper's formula, set equality
asserted, 0 missing / 0 extra); float contamination
(int64 throughout, magnitudes ≤ 108, plus a no-numpy
integer pass on 198 matrices); repo/archive drift
(byte-identical solutions trees, md5-pinned zip);
count inflation (both method totals and both GS splits
recomputed from stored metadata, exact match to the
abstract); symbols/matrix divergence (author's verifier
treats it as a warning and reports none; the audit's
verdict rests on the numeric matrices, which are the
claim objects).

**Verdict: PASS** — all 1,512 pairs in S carry an
explicit matrix satisfying the paper's definition in
exact integer arithmetic, verified twice over (author's
verifier replayed, auditor's independent checker),
with method counts and provenance reconciled.
