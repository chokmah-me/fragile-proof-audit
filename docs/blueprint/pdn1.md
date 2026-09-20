# Blueprint — Phase 2(g): PDN1 congruences (arXiv:2503.00004)

**Status:** extract + gate complete — **PASS** on Type-D; notebook/(4.8) **capability-limited**  
**Claim artifact:** Julia Q.D. Du & Olivia X.M. Yao, *Congruences modulo arbitrary powers of 5 and 7 for Andrews and Paule’s partition diamonds…*, arXiv:2503.00004  
**Local PDF:** `incoming/pdn1-2503.00004.pdf`  
**Supplements (pinned):** `incoming/pdn1/mod5/`, `incoming/pdn1/mod7/` (from github.com/tztgm1/…)  
**Attack type:** D (q-series / congruences) + E (Mathematica replay — blocked)  
**Gate:** `scripts/gates/pdn1.py` → `results/pdn1_gate_meta.json`

## Claim (quoted)

Generating function (1.1):

```text
Σ_{n≥0} PDN1(n) q^n = J_2² / J_1⁵ ,   J_k := (q^k; q^k)_∞
```

**Theorem 1.1** (any \(n\ge 0\), \(\alpha\ge 1\)):

```text
PDN1( 5^{2α} n + (23·5^{2α}+1)/24 ) ≡ 0 (mod 5^α)

PDN1( 5^{2α+1} n + (r·5^{2α}+1)/24 ) ≡ 0 (mod 5^{α+1})
  for r ∈ {71, 119}
```

**Theorem 1.2** (any \(n\ge 0\), \(\alpha\ge 1\)):

```text
PDN1( 7^{2α−1} n + (17·7^{2α−1}+1)/24 ) ≡ 0 (mod 7^α)

PDN1( 7^{2α} n + (23·7^{2α}+1)/24 ) ≡ 0 (mod 7^{α+1})
```

Load-bearing CAS step for the mod-5 induction: **Lemma 3.2 / (3.13)** fifth-order
modular equation in the Γ₀(10) functions \(u,t\) (σ-polynomials displayed in-paper).
Seventh-order analogue **(4.8)** for mod-7 lives in Appendix B / the mod-7 supplement.

## Gate contract

1. Exact integer series for \(J_2^2/J_1^5\); harness `PDN1(2)=18`.
2. Sample Theorem 1.1–1.2 progressions for small \(\alpha\) (includes AP base cases
   \(25n+24\), \(125n+74\), \(125n+124\), \(7n+5\), \(49n+47\)).
3. Verify (3.13) as a truncated q-series identity (plus the (3.6) \(t\)-relation).
4. Pin authors’ notebooks; do **not** fake a Mathematica/RISC replay.
5. **PASS** escalates; **BREAK** on any executable mismatch.

## Abort

If the GF or (3.13) σ-polynomials cannot be transcribed → BREAK underspecified.
