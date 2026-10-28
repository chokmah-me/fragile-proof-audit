# PIN — Wang's planar D-coloring conjecture (arXiv:2610.33322)

Audit opened 2026-10-28 at the user's pick (harvest
2026-10-27, CLAIM Wang planar D-coloring, fragility 1,
eighth in the ranked queue, issue #12).

## Claim

Harshit Verma, *A proof of Wang's planar D-coloring
conjecture*. A D-coloring is a proper edge-coloring in
which every subgraph isomorphic to K4 minus an edge
(a diamond) is rainbow. Wang's conjecture: every planar
graph has a D-coloring with 9 colors if Δ = 4, 10 if
Δ = 5, and 2Δ−1 if Δ ≥ 6. Hu–Kong–Wang proved Δ ≤ 5
and Δ ≥ 33 (cited, not part of this artifact). This
paper's main theorem: for every D ≥ 6, every finite
simple planar graph with Δ(G) ≤ D has a D-coloring
with at most 2D−1 colors. The proof is discharging;
the case D = 6 is computer-assisted.

The computer input is confined to two lemmas:

- Generic certificates (Lemma 7.7 in the ancillary
  README's numbering; `lem:generic` in the text): each
  of the 72 full-link generic templates at D = 6
  (9 sorted degree triples from {4,5,6} × 8 tip words)
  is list-colorable from the Lemma (counts) bounds.
  Certificates: 59 greedy removal orders + 13 nonzero
  graph-polynomial coefficients.
- One-spine certificates (Lemma 7.10; `lem:onespine`):
  each of the 1,220 one-spine bases at D = 6 is
  list-colorable with the h* subtraction of the budget
  lemma. Certificates: 971 greedy + 249 CN.

Certificate criteria (paper's own lemmas, read at
recon): greedy — a removal order v_1..v_m of the
conflict graph H on the ordered edge set U is valid
iff each v_i has fewer than f(v_i) neighbors among
v_{i+1}..v_m (lem:greedy); CN — the coefficient of
X^t in the graph polynomial P_H = prod over conflict
pairs (X_i − X_j), with sum t_i = |E(H)|, is nonzero
(lem:cn, Alon–Tarsi). Section 8 carries an 18-vertex
example, checked by a separate script.

## Artifact

arXiv ancillary files (no separate repo): Python 3
standard library only. `d6_generic_sharp.jsonl`
(72 records), `d6_one_baseline.jsonl` (1,220 records),
`tmpl.py` (template reconstruction from Section 7
definitions), `check_records.py` (the Appendix A.3
verifier: rebuilds every template, checks the key sets,
compares U/conflicts/f against records, verifies greedy
orders directly, recomputes every CN coefficient by
three methods — frontier DP, vertex elimination,
Alon–Tarsi signed count), `atcoef.py` (method
self-test against brute-force expansion),
`fourwheel_d6_example.py` (Section 8 example).

## Pinned sources

- Paper PDF sha256
  `2dc544abdc1d72a5cc3739d07636a9f1dd67a4e083d7493cf01f86fd90017a46`
- arXiv source tarball (paper + ancillary) sha256
  `430e947e8eaa9f1b0e67976d5b40bb17e4bf5126a9502ab682aea4a00d2d3cc6`

## Audit scope

- **V-A:** run the ancillary suite on the pinned tree:
  `check_records.py` (expect 59+13 generic, 971+249
  one-spine, failures: 0), `atcoef.py` (self-test),
  `fourwheel_d6_example.py` (Section 8 example),
  `tmpl.py` (template counts).
- **V-B (auditor's own, from the raw records only):**
  key accounting (72 / 1,220 records; the uniqueness
  keys parameter_degrees+tipmask+linkmask
  [+boundary_spines] duplicate-free); greedy criterion
  re-implemented from lem:greedy and applied to all
  1,030 greedy records using only the stored
  U/conflicts/f/order fields; every CN coefficient
  recomputed by the auditor's own sparse polynomial
  multiplication (an independent fourth method) and
  compared with the stored coefficient and exponent
  vector (including sum t_i = |E(H)| and nonzeroness);
  the Section 8 example's D-coloring re-verified from
  the script's graph and coloring data by the auditor's
  own code (proper edge-coloring; every diamond
  rainbow). V-B deliberately does not import tmpl.py:
  the U/conflicts/f fields it checks are the same
  fields V-A's verifier compares against an independent
  reconstruction from the Section 7 definitions, so the
  two legs pin the records from both sides.
- **M1 by read:** main theorem and corollary against
  the abstract's claim; the two certificate lemmas'
  counts and semantics against the record files.
- Out of scope: the human discharging proof for
  D ≥ 7 and the D = 6 prose reductions (fenced, as in
  the Brualdi–Solheid analytic remainder); the cited
  Hu–Kong–Wang cases. The verdict covers the
  computer-assisted leg and the claim's statement
  fidelity, and says so.
- No author contact. The verdict lock is not touched.

Hashes verified at recon 2026-10-28; working copies in
`~/workspace/wang-recon/`.
