# Blueprint — Phase 2(f): Rogers–Ramanujan q-expansion (arXiv:2608.05480 / 2608.15219)

**Status:** extract + gate complete — **PASS** on Type-D q-expand; OreReduce (34) **capability-limited**  
**Sources:**
- Kenny Lau–Ken Ono, *Modularity of Point Counts for the Curves \(X^a=Y^b\)*, arXiv:2608.05480  
- Yifeng Huang–Kenny Lau–Ken Ono–Peter Paule, *Algebraic geometric framework of Rogers–Ramanujan identities*, arXiv:2608.15219  
**Local PDFs:** `incoming/rr-2608.05480.pdf`, `incoming/rr-2608.15219.pdf`  
**Attack type:** D (finite q-expansion) + E (Ore/CAS replay — blocked on this stack)  
**Gate:** `scripts/gates/rr_qexpand.py` → `results/rr_qexpand_gate_meta.json`

## Claims (quoted)

### HJO identity (both papers)

For coprime \(a,b>1\), Huang–Jiang–Oblomkov define an Eulerian series \(Z_{a,b}(q)\) from the gap set
\(\mathcal{G}_{a,b}=\mathbb{N}\setminus\langle a,b\rangle\) and a quadratic form \(Q_{a,b}\), and a charge product

\[
P_{a,b}(q)=\prod_{i\ge 1}(1-q^i)^{-r_{a,b}(i)},
\quad
r_{a,b}(i)=\min\{a,b,\mathrm{dist}(ai,(a+b)\mathbb{Z})\}-1+\mathbf{1}_{(a+b)\mathbb{Z}}(i).
\]

**Conjecture (HJO):** \(Z_{a,b}(q)=P_{a,b}(q)\) for \(|q|<1\).

### What 2608.05480 proves

**Theorem 1.1:** for every integer \(b>3\) coprime to \(3\),

\[
P_{3,b}^{\mathrm{pt}}(q)=Z_{3,b}(q)=P_{3,b}(q).
\]

Equation **(5)** in that paper is the *published* HJO geometric identity
\(S_q=Z_{a,b}(q^{-1})\prod(1-q^{-n})^{-1}\), used only to identify the normalized
point count with \(Z\). It is **not** an unpublished q-series (harvest/Pith lead
corrected at extract).

### What 2608.15219 proves

**Theorem 3:** HJO for \((a,b)\in\{(3,4),(3,5),(3,7),(3,8)\}\), via a finer
**sum-to-sum** conjecture (their Conjecture 5 / eqs. (6)–(7)), established for
those four \(b\). Cases \(b=4,5,7\) are elementary q-Vandermonde; **\(b=8\)** uses
qMultiSum + HolonomicFunctions, with independent-verification claim resting on
operator identity **(34)** (OreReduce cofactor relation).

## Gate contract

1. **Type D (executable, SymPy/pure-Python, no Sage).**  
   Truncated power-series identity \(Z_{3,b}\equiv P_{3,b}\pmod{q^{N+1}}\) for
   \(b\in\{4,5,7,8\}\) at campaign degrees, plus classical harness \(Z_{2,3}\equiv P_{2,3}\)
   (first Rogers–Ramanujan). Exact integer coefficients only.
2. **Sum-to-sum sample (15219 Lemma 12, \(b=4\)).**  
   For several fixed \(r_1\), compare both sides as truncated polynomials in \(q\).
3. **Type E OreReduce (34).**  
   Requires RISC `HolonomicFunctions` Ore algebra (Mathematica). **Not available**
   on the campaign laptop stack (Python mpmath/Fraction/SymPy only). Record as
   **capability-limited**; do not invent cofactors or claim Magma-equivalence.
4. **PASS** if all executable checks match — escalate; do not force a kill.  
   **BREAK** if any \(Z\)/`P` coefficient or Lemma-12 side disagrees.

## Abort

If \(Z_{a,b}\) / \(P_{a,b}\) cannot be transcribed into an executable series checker
from the quoted definitions → **BREAK underspecified**. Do not substitute a
different product formula.
