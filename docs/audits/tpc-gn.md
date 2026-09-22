# Audit note — TPC-GN evaluation display — BREAK

**Claim artifact:** the displayed evaluation of \(P_g(\sigma,y)\) in the proof of Proposition 3.4.
**Paper:** Parikshit Chalise, Antwan Clark, and Edinah K. Gnang, arXiv:2410.13840v2 (23 Oct 2024), page 7.
**Campaign objects:** `docs/blueprint/tpc-gn.md`, `scripts/gates/tpc_gn.py`,
`scripts/controls/tpc_gn_break_control.py`, `results/tpc_gn_gate_meta.json`,
`incoming/gnang-tpc-2410.13840v2.pdf`.
**Lock:** `tpc_gn` → BREAK.

## Bug report

| Field | Content |
|---|---|
| **Lemma** | For every complete labeling, \(P_g(\sigma,y)\) equals one displayed polynomial in \(y\), up to sign |
| **Instance** | \(n=3\), stars \(g=((0,1,2),(0,0,2),(0,0,0))\), two members of \(\Phi(g)\) |
| **False instance** | Coefficient of \(y^3\) is \(-3072\) at one labeling and \(6144\) at the other |

**Verdict: BREAK.** Both labelings orient looped \(K_3\). Both have Vandermonde factor \(-8\). The cross-tree edge products differ by more than a sign.

## What this does not say

The factorial factor in the same display is right: \(\prod_k(k!)^3=8=|V|\). The product of differences over all pairs of edges in looped \(K_3\) agrees on the two labelings. A check that only asked whether \(P_g(\sigma,y)\) is the zero polynomial would accept both.

Lemma 3.10 is not this witness. On 1 Sep 2026 the authors withdrew the manuscript and named an error in that lemma, pointing at arXiv:2202.03178v2. The withdrawal PDF is not on arXiv. The \(Q^{[1]}\) congruence locked as `krr_cl` is a different display in a different paper.

The Gyárfás–Lehel conjecture is untouched.
