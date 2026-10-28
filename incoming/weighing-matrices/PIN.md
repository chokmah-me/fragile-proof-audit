# PIN — Weighing matrices W(n,k) to n = 108 (arXiv:2610.33976)

Audit opened 2026-10-28 at the user's pick (harvest
2026-10-27, CLAIM weighing matrices W(n,k) to n=108,
fragility 1, seventh in the ranked queue, issue #12).

## Claim

Adrián Macías-Quintero, *Explicit weighing matrices
W(n,k) for all n ≡ 0 (mod 4) with 4 ≤ n ≤ 108, and all
1 ≤ k ≤ n* (arXiv:2610.33976v1, October 2026). Main
theorem: for every (n,k) in S = {(4m,k): 1 ≤ m ≤ 27,
1 ≤ k ≤ 4m} — |S| = 1,512 — a weighing matrix W(n,k)
exists (n×n, entries in {−1,0,1}, WW^T = kI_n). The
proof is the catalogue itself: 1,512 explicit matrices
with an exact integer check each. Composition claimed
in the abstract: 961 from classical constructions
(identity, direct sums, Kronecker products, Paley,
skew-Hadamard doubling), 551 Goethals–Seidel (24 by
exhaustive search, n ≤ 24; 527 by simulated annealing,
n ≥ 28). Side content not under audit: a parity
obstruction for GS matrices W(4m,4m−1) with m even, and
13 matrices whose parameters appear unresolved in
historical tables (no priority claimed by the author).

## Artifact

GitHub repo adrianmaciasquintero/weighing-matrices,
release v1.1.0, archived at Zenodo
doi:10.5281/zenodo.23484194 (Apache-2.0).
`solutions/W{n}_{k}/solution_001.json` per pair: matrix,
symbolic form, method, recipe, GS generators when
applicable. Author's verifier `verify_weighing.py`
(int64, no floating point in the verdict: entries,
row/column weights, WW^T and W^TW against kI, plus
method-consistency warnings).

## Pinned sources

- Paper PDF sha256
  `cc572b97b21303e45c303a46104a00e145880bc70dd282df694a682cffaf4ca6`
- arXiv source tarball sha256
  `6f194b0b30234787c6699ab35e178ea8f74442538ef6ad634c2a6558cf2dff49`
- Repo codeload tarball, tag v1.1.0, sha256
  `b9d917bcf03e344b31037907869ff6ce26ad6ecf37580deb9643be6e1bf38aff`
- Zenodo record 23484194 file
  `adrianmaciasquintero/weighing-matrices-v1.1.0.zip`,
  3,100,397 bytes, md5 cd61b706eeb791c9eb413a1ddfd5f40c
  (record metadata; the downloaded zip is hashed at
  audit time and its solutions tree compared file by
  file against the codeload extraction).

## Audit scope

- **V-A:** run the author's `verify_weighing.py` on the
  pinned repo tree; verdict = its exit code and counts,
  warnings itemized.
- **V-B (auditor's own, independent code):** assert the
  file set is exactly S (no missing, no extra pairs);
  for every matrix: folder ↔ JSON (n,k) agreement,
  shape n×n, entries in {−1,0,1}, WW^T == kI in exact
  int64 arithmetic (numpy, auditor-written), each row
  of weight k. Pure-Python integer re-verification
  (no numpy) of a structured sample: all k = n
  (Hadamard) cases, all n = 108 cases, the GS cases at
  n ≤ 24, and a seeded random sample. Method counts
  reconciled against the abstract's 961/551 split and
  the GS 24/527 split as far as the stored metadata
  supports. Zenodo zip solutions tree compared against
  the GitHub tag tree hash by hash.
- **M1 statement fidelity by read:** the definition and
  the main theorem in the paper against the JSON spec
  the checkers enforce.
- Out of scope: reproductions of the searches
  (exhaustive/annealing) — the theorem's validity does
  not depend on them, per the paper's own framing;
  the parity obstruction and the 13 historical-table
  parameters are fenced, not graded.
- No author contact. The verdict lock is not touched.

Hashes verified at recon 2026-10-28; working copies in
`~/workspace/weighing-recon/`.
