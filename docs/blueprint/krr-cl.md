# Blueprint — KRR-CL: the \(Q^{[1]}\) congruence in Lemma 25

**Status:** BREAK, locked as `krr_cl`.
**Source:** Edinah K. Gnang, arXiv:2202.03178v3 (31 Jan 2025).
**Local PDF:** `incoming/gnang-krr-2202.03178.pdf`
**sha256:** `72d59ffb72fd8b9baf262212ef66ec6945dc0569066222a27674fd8289adb2ac`
**Gate:** `scripts/gates/krr_cl.py`
**Control:** `scripts/controls/krr_cl_break_control.py`

## What the paper claims

Lemma 25, the composition lemma: for \(n>3\), if \(|f^{(n-1)}(\mathbb{Z}_n)|=1\) and \(G_f\) has diameter at least 3, then

```text
score(f^{(2)}) ≤ score(f),
```

where `score` is the maximum, over relabelings, of the number of distinct absolute edge differences. Theorem 26 then says every functional tree is graceful, by iterating the lemma down to a constant function.

## The dead line

Page 27, inside the proof of Lemma 25, after the monochromatic summand is isolated. With \(\Phi(g)\) the set of permutations whose conjugate of \(g\) is gracefully labeled,

```text
Q^{[1]}_{f,g}
  ≡ c * sum_{sigma in Phi(g)}
      (sigma(f^{(2)}(n-1)) - sigma(f(n-1)))^m
      * L(x_{f^{(2)}(n-1)}; sigma(f^{(2)}(n-1)))
      * L(x_{f(n-1)}; sigma(f(n-1))).
```

The exponents are the ones printed with that summand: \(m\) counts the pairs in the \(r\)-product plus the triples in the \(s\)-product, and \(c=2^{|r\text{-pairs}|}\).

## Witness

\(f=(0,0,1,2)\) on \(\mathbb{Z}_4\). Semigroup form, sibling block \(\{3\}\), parent \(2\), diameter \(3\). The partial iterate in the proof is \(g=(0,0,1,1)\). Then \(m=6\), \(c=1\), and the left side is \((x_1-x_2)^6\).

At \(\sigma=(0,3,1,2)\in\Phi(g)\):

```text
left  = 64
right = 128
```

\(\Phi(g)\) has 12 permutations. Two of them, \((0,3,1,2)\) and \((2,3,1,0)\), satisfy \(\sigma(1)=3\) and \(\sigma(2)=1\). The sum does not see any other coordinate.

`score(f)=score(g)=4`. The sentence being gated is the congruence, not the inequality in the lemma statement, and not the Kotzig–Ringel–Rosa conjecture.
