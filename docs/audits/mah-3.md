# Audit note — MAH-3 (Chen–Li–Xi–Xu, 3D Mahler conjecture)

**Claim artifact:** Shibing Chen, Yuanyuan Li, Dongmeng Xi, Zhe-Feng Xu,
"The Mahler Conjecture in Three Dimensions", arXiv:2605.09334v3 (15 June 2026).
**Campaign objects:** `docs/blueprint/mah-3.md` (if present),
`scripts/gates/mah_3.py`, `scripts/analysis/mah_3_stress_5b.py`,
`results/mah_3_gate_meta.json`, `incoming/mah-3-2605.09334v3.pdf`
(SHA-256 `cd2b5f801f3015e3b7bfc883103f9fa33e8e20817729ed8072ec50af1ad4405f`,
493,186 bytes; PDF metadata confirms title and all four authors).

## Disposition: WATCH (counting layer PASS, prose clean, connectedness ungated)

**Verdict: WATCH — not a full PASS.** The finite counting core (Lemma 5.1)
survives an exact gate with discrimination; the variational (§4), counting
(§5), connectedness (Proposition 6.4), and symmetric (§7) arguments all survive
a line-by-line prose audit with no defect found; two floating-point stress
probes of Proposition 6.4's finite dependencies pass. But Proposition 6.4
(connectedness of the sublevel sets C̃_{N,a}) is an irreducibly topological
argument — no finite scalar gate captures it — so per the dossier's own
instruction the target is demoted to the watch list rather than promoted to
PASS. **The 24/24 BREAK lock is untouched**: no lemma statement was falsified.

## Route audited

1. Minimize the volume product over polytopes with ≤ N vertices (C_N).
2. Minimizers and their Santaló polars admit only trivial shadow flows (§4,
   Lemmas 4.1–4.2).
3. Exact counting bound Lemma 5.1:
   `dim A_θ(P) ≥ F(P) − V(P) + Δ(P) + 1`.
4. Lemma 5.3: terminal polytope is a tetrahedron (Δ=d=3, V=F, then V=4 by Euler).
5. Proposition 6.4: sublevel sets C̃_{N,a} connected for a ≥ 64/9.
6. Kim–Reisner local stability (Theorem 6.5, cited) → equality characterization.
7. §7: symmetric companion proof.

## Gate 5a — Lemma 5.1, exact rational arithmetic: PASS

`scripts/gates/mah_3.py` implements the facet-affine constraint map defining
A_θ(P) over `fractions.Fraction` (exact). Facet lists are hardcoded per
polytope but **verified by the script**: exact supporting-plane checks,
Euler's formula, and vertex-extremality spot checks. θ is taken parallel to a
maximal facet, as the lemma requires.

| polytope | V | F | Δ | dim A_θ | bound | margin |
|---|---|---|---|---|---|---|
| square pyramid | 5 | 5 | 4 | 5 | 5 | 0 |
| octahedron | 6 | 8 | 3 | 6 | 6 | 0 |
| cube | 8 | 6 | 4 | 6 | 3 | 3 |
| triangular prism | 6 | 5 | 4 | 4 | 4 | 0 |
| pentagonal pyramid | 6 | 6 | 5 | 6 | 6 | 0 |
| cube, one corner truncated | 10 | 7 | 5 | 7 | 3 | 4 |
| elongated square pyramid | 9 | 9 | 4 | 7 | 5 | 2 |

Discrimination control: the same computation with a deliberately wrong θ
(not parallel to G₀) breaks the bound visibly — square pyramid
(dim 4 < bound 5), pentagonal pyramid (dim 4 < bound 6) — so the instrument
is not a tautology machine. Exit 0; verdict recorded in
`results/mah_3_gate_meta.json` and pinned PASS in `scripts/gates/check.py`.

## Gate 5b — Proposition 6.4 dependencies: stress probes PASS

Connectedness itself has no finite gate; the script
`scripts/analysis/mah_3_stress_5b.py` (NumPy/SciPy, floating point —
explicitly an illustration, not the decisive exact gate) stresses the two
finite dependencies:

- **Lemma 6.3** (nontrivial shadow flow strictly decreases P on one side):
  on the square pyramid, the computed 1-dim space of nontrivial admissible
  speeds yields P strictly below P(0) on *both* sides of t=0 with the face
  lattice preserved — consistent with the lemma's disjunctive statement.
  Reproduced.
- **Lemma 6.2** (P(K^{z_τ}) ≤ P(K^{c(K)}) along the centroid→Santaló segment):
  on the truncated cube corner (chosen because c(K) ≠ s(K), so the segment
  is non-vacuous), max excess 6.9e-14. Holds.

Two implementation bugs were found and fixed during probe development, both
in the probe (not the paper): (1) Qhull duplicates the base plane of a
pyramid, so facet reconstruction must dedupe coplanar hull triangles;
(2) the Lemma 6.2 baseline is P(K^{c(K)}) = |K^{c(K)}|·|K| (via (2.1) and
biduality), **not** P(K) — an early "violation" was the probe comparing
against the wrong quantity. Both fixed and re-verified.

## Prose audit (no defect found)

- **§4, Lemmas 4.1–4.2.** Interior minimum along a short shadow flow forces
  trivial speed; a bounded-vertex-class minimizer and its Santaló polar admit
  only trivial shadow flows. Variational logic sound.
- **Lemma 5.1.** Matches the dossier statement exactly; the affine-restriction
  injectivity argument (Definition 3.1 facet constraints) is coherent.
- **Lemma 5.3.** Δ=d=3, V=F from (5.8)+(5.10) plus degree bounds; 2E=3F=3V
  with Euler gives V=4. Sound. Its every-direction hypothesis matches what
  Proposition 6.4's Claim establishes.
- **Proposition 6.4.** Checked step by step: component compactness (closed in
  compact metric); minimizer [Q] exists; Q-flow contradiction via Lemma 3.8
  (face-lattice persistence) + Lemma 6.3 + path-connectedness of the
  component; polar path [L^{z_τ}] via Lemma 6.2, biduality
  (L^{s(Q)} = Q), and Lemma 2.2 vertex count V(L^{z_τ}) = F(L) = V(Q) ≤ N;
  equality chain (6.2) from Lemma 2.1 applied both ways plus minimality;
  polar-flow contradiction via M_t = L_t^{s(L_t)} (V(M_t) = F(L_t) ≤ N);
  Lemma 5.3 → tetrahedron; all components share [Δ₃] → connected. Sound.
- **§7 (symmetric companion).** Counting argument and terminal classification
  read; no defect identified.
- **Taken as cited:** Kim–Reisner Theorem 6.5 (simplex strict local minimum);
  compactness of C̃_N via the paper's John-position argument; continuity of
  the Santaló point and of polarity in the Banach–Mazur metric.

## Not done, on purpose

- No finite gate for Proposition 6.4's connectedness itself — this is the
  reason for WATCH rather than PASS.
- Did not re-derive Kim–Reisner [28] or the John-position compactness setup.
- Did not search for a published rebuttal; none was found during the read.

## Lean

None this landing. WATCH disposition; nothing to formalize against.
