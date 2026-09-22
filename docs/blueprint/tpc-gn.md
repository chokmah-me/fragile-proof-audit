# Blueprint — TPC-GN: the evaluation display in Proposition 3.4

**Status:** BREAK, locked as `tpc_gn`.
**Source:** Parikshit Chalise, Antwan Clark, and Edinah K. Gnang, arXiv:2410.13840v2 (23 Oct 2024).
**Local PDF:** `incoming/gnang-tpc-2410.13840v2.pdf`
**sha256:** `943968bc54e737bb10b79f2bbafa97a0866733960d1fbfe732b0357d13eaf378`
**Pages:** 15
**Gate:** `scripts/gates/tpc_gn.py`
**Control:** `scripts/controls/tpc_gn_break_control.py`

## What the paper claims

Theorem 1.9: every sequence of augmented functional trees admits a complete labeling. Proposition 3.4 says the canonical representative of the tree-packing polynomial is not the zero polynomial if and only if the set \(\Phi(g)\) of complete labelings is nonempty. The proof identifies that representative with a sum over \(\Phi(g)\), and then prints a single formula for every term.

## The dead line

Page 7, inside the proof of Proposition 3.4. For every \(\sigma\in\Phi(g)\),

```text
P_g(sigma, y)
  = ∓ prod_{k in Z_n} (k!)^n
    * prod_{0 <= i < j < n}
        prod_{u in Z_{i+1}, v in Z_{j+1}}
          ((y - k)(y - v) - (y - j)(y - u))
  ≠ 0.
```

The right-hand side does not depend on which complete labeling is substituted, except for the sign. The letter \(k\) in the edge factor is the index of the factorial product. It is not one of \(i,j,u,v\).

## Witness

\(n=3\), augmented stars \(g=((0,1,2),(0,0,2),(0,0,0))\). Both of the following are in \(\Phi(g)\):

```text
sigma_A = ((0,1,2), (1,0,2), (2,0,1))
sigma_B = ((0,1,2), (2,0,1), (1,0,2))
```

Each Vandermonde factor equals \(-8\), and \(\prod_k (k!)^3 = 8\). The coefficient of \(y^3\) in \(P_g(\sigma,y)\) is

```text
sigma_A: -3072
sigma_B:  6144
```

The two polynomials are not negatives of each other. Both are nonzero, so the clause \(\neq 0\) is not the failure. The factorial factor of the display matches \(|V|\). The product of differences over every pair of edges in looped \(K_3\) is the same for both labelings, because both labelings use that whole edge set. The cross-tree product is the factor that moves.

## What is not the witness

Lemma 3.10, the composition lemma, is downstream of this display. The live arXiv record's v3 (1 Sep 2026) withdraws the paper and names an error in that lemma, citing arXiv:2202.03178v2. v3 has no proof PDF. This row's calculation uses v2, page 7, and does not reuse the \(Q^{[1]}\) witness from the Kotzig–Ringel–Rosa manuscript.

The Gyárfás–Lehel tree packing conjecture is untouched. No Lean file.
