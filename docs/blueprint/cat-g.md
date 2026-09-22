# Blueprint — CAT-G: the polynomial claim between (2.3) and (2.4)

**Status:** BREAK, locked as `cat_g`.
**Source:** Zhi-Wei Sun, *Catalan's constant is irrational*, arXiv:2609.04176v1
(3 Sep 2026). PDF metadata: author Zhi-Wei Sun, 20 pages,
`https://arxiv.org/abs/2609.04176v1`.
**Local PDF:** `incoming/sun-catalan-2609.04176.pdf`
**Gate:** `scripts/gates/cat_g.py`
**Control:** `scripts/controls/cat_g_break_control.py`

## Not the internal note

Zenodo [10.5281/zenodo.22830611](https://doi.org/10.5281/zenodo.22830611) is
Bilar, *A Numerical Test of the Quadratic Estimate in arXiv:2609.04176v1*, the
`catalan-sun-lean` paper. It is about Sun's §9. It is not this PDF. The gate
aborts if the pinned file's metadata or text is that note. Section 9 is not
this row.

## What the PDF prints

Theorem 2.1, pages 4–5. Equation (2.3), from the tail recurrence (1.4), is

```text
T_{i+j} = (-1)^j T_i + sum_{0 <= k < j} (-1)^{j-1-k} / (2(i+k)+1)^2.
```

The next sentence says that for `j ∈ {1,...,S}` and `B > S`,

```text
Pi_i / (2(i+j)+1) * sum_{0 <= k < j} (-1)^{j-1-k} / (2(i+k)+1)^2
```

is a polynomial in `i` of degree at most `2B-3`. `Pi_i` is

```text
Pi_i = prod_{h=1}^{B} (2(h+i)+1)^2.
```

The product starts at `h = 1`, so its first linear factor is `2i+3`. The
`k = 0` term in the sum has denominator `(2i+1)^2`. That factor is not in
`Pi_i`.

The display immediately after that sentence, still before (2.4), writes the
surviving tail as `T_{i+1}`. Equation (2.3) has `T_i`.

## The dead line

`B = 2`, `S = 1`, `j = 1`, `a = 0`. The order-4 forward difference the proof
sets to zero is

```text
3596288/99225 ≠ 0.
```

For `j = 1` the cleared numerator `(2i+3) prod_{h=2}^{B} (2i+2h+1)^2` equals
32 at `i = -1/2`, so the denominator `(2i+1)^2` is essential.

`T_0` is the sum of the positive groups
`1/(4t+1)^2 - 1/(4t+3)^2 = 8(2t+1)/((4t+1)^2(4t+3)^2)`. The first group is
`8/9` and the next is positive, so `T_0 > 8/9`. By (1.4) at `m = 0`,
`T_1 = 1 - T_0 < 1/9`. The printed index `i+1` is not the index in (2.3).

## What is later, and what is not a witness

Equation (1.4) holds by reindexing. Confirming it is not a verdict.

Equation (2.16) says `K(-3/2) = 0` because `D_λ(-3/2) = 0`. For
`S = 1`, `B = 2`, `λ_1 = 1`, the polynomial `D` in (2.9) is
`-(2X+3)(2X+5)^2`, and `D(-3/2) = 0`. The dossier's extra zero is not a
counterexample.

Equation (2.13) is downstream of the same off-by-one. With `A(i) = T_i D(i)`
as in (2.11) and the factor `(2X+3)^2` in (2.12),

```text
K(i) = D(i) D(i+1) * ((2i+3)^2/(2i+1)^2 - 1).
```

At `i = 0` the factor is 8 and `D(0) D(1) ≠ 0`, so `K(0) ≠ 0`. That is not
the earliest false line.

## Control

Apéry's ζ(3) weight `C(k,n)^2 C(k+n,n)^2` has degree `4n`. The same forward
difference vanishes at order `4n+1` and equals `(4n)!/(n!)^4` at order `4n`.
Apéry's recurrence for `a_n = sum_k C(n,k)^2 C(n+k,k)^2` has residual 0;
the coefficient 17 replaced by 18 does not.
