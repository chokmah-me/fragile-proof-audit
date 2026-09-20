# Blueprint — Phase 2(d): odd-zeta preprint 202601.1609

**Status:** extract complete — **BREAK (underspecified Λ_m)**  
**Claim:** Archan Chattopadhyay, *On the Irrationality of the Odd Zeta Values*,
Preprints.org 202601.1609.v1 (21 Jan 2026), doi:10.20944/preprints202601.1609.v1  
**Mirrors:** ResearchGate 10.13140/RG.2.2.11481.79203 (11 pages)  
**Sibling (not this target):** 202601.1390 (π-normalized odd zetas / `I_n`)  
**Attack type:** A (scalar decay) — *blocked at formula display*  
**Local PDF:** **not obtained** (preprints.org 403 / Akamai; RG HTML interstitial)

Provenance of quotes: indexed Preprints.org `download_pub` fulltext + ResearchGate OCR
of the same v1. That is enough to decide evaluability of `Λ_m`. It is **not** a
substitute for pinning a SHA/PDF in `incoming/`.

## Claim

For every `n ∈ ℕ`, `ζ(2n+1)` is irrational (Theorem 1.1), via integer linear forms

```text
Λ_m^{(q)} = A_m^{(q)} ζ(2n+1) − B_m^{(q)}
```

with `|Λ_m^{(q)}| → 0` as `m → ∞`, then a general irrationality criterion.

## Load-bearing lemma chain

1. Asymmetric beta kernel `W_m^{(q)}` + CDF `S_m^{(q)}` → integral identity linking
   `ζ(2n+1)` to weighted moments `L_m^{(q)}`.
2. Truncate Maclaurin / polylog `Li_{2n+1}` at `K`; clear denominators by an LCM
   `D_m^{(q)}` → integer forms `A_m`, `B_m`.
3. Kernel-tail + remainder decay (Stirling / `L^p`) vs denominator growth
   (Legendre + PNT) → `|Λ_m| → 0`.
4. Parameter inequality (24) on `g(α)` → exponential decay.
5. Criterion (Theorem 5.1) → irrationality.

**Break point for this campaign:** step 2 must produce an **evaluable** pair
`(A_m, B_m)` at `ζ(5)` (`n=2`) for some explicit `(m,q)`. It does not.

## Quoted `A_m`, `B_m`, `Λ_m` (Lemma 3.2)

Indexed Lemma 3.2 (*Integer linear form*):

```text
A_m^{(q)} := D_m^{(q)} ∈ ℤ                                          (11)

B_m^{(q)} := Ω_m^{(q)} D_m^{(q)} L_m^{(q)(≤K)} ∈ ℤ                  (12)

Λ_m^{(q)} := A_m^{(q)} ζ(2n+1) − B_m^{(q)}
          = Ω_m^{(q)} D_m^{(q)} L_m^{(q)(>K)}
```

So `A_m` is **not** a closed combinatorial sequence. It is a denominator-clearing
LCM `D_m^{(q)}`. `B_m` is that LCM times a truncated moment times a prefactor `Ω`.
The remainder form of `Λ_m` is the tail moment, not a number one can write down
from `(m,q,n)` alone.

Supporting sketch (§1.3): coefficients “are made integral by a suitable least
common multiple of denominators.” Truncation `K` is introduced as a parameter
(“Fix a truncation parameter `K`”), not as a closed function of `m`.

## Symbols required to evaluate `Λ_m` at ζ(5)

| Symbol | Role | Quoted closed form? |
|---|---|---|
| `W_m^{(q)}(x)` | asymmetric beta kernel on `[0,1]` | **No** — named, not displayed as an evaluable density |
| `S_m^{(q)}(x)` | CDF of `W` | **No** |
| `Ω_m^{(q)}` | prefactor in (11)–(12) | **No** (Beta/Gamma ratio is *not* written) |
| `F_{m,k}^{(q)}` | weights in `Σ F_{m,k}/k^{2n+1}` | **No** |
| `L_m^{(q)}` | weighted moments / truncated polylog integrals | **No** closed sum |
| `K` | truncation cutoff | parameter, not `K=K(m)` |
| `D_m^{(q)}` | LCM of “denominators up to …” | **No** explicit `lcm` range |
| `q` | kernel shape / Dirichlet-style parameter | `q ∈ ℕ`, no preferred value |

Without those, `Λ_m^{(q)}` for `ζ(5)` is not a Python object.

## Quoted `g(α)` (Lemma 5.1 / (24)) — this is *not* `Λ_m`

Decay is reduced to existence of `q ∈ ℕ`, `δ ∈ (0,1)`, `α > 0` with

```text
1 + q + λ α  <  min( γ^{(q)}(α),  −log δ )                     (24)
```

where

```text
γ^{(q)}(α) = −(1+q) log(1+q) − (1+α) log(1+α)
             + (1+q+α) log(1+q+α)

g(α) := 1 + q + λ α + (1+q) log(1+q) + (1+α) log(1+α)
        − (1+q+α) log(1+q+α)

g'(α) = λ − log((1+q+α)/(1+α))
g''(α) = q / ((1+α)(1+q+α)) > 0
```

Want `g(α) < 0`. Convexity ⇒ at most an interval `(α_1, α_2)`. The paper claims
this is nonempty once `λ < log(1+q)`, i.e. `q > e^λ − 1`, then pick `δ` small.

`λ := κ + 2` with `κ` from a Stirling/large-deviation estimate (not a displayed
number independent of the missing kernel). Harvest’s `α* = q/(e^λ−1)` is a nearby formula; the paper’s critical point from
`g'=0` is `e^λ = (1+q+α)/(1+α)`, hence

```text
α* = (1 + q − e^λ) / (e^λ − 1)
```

**Do not treat a sign check of `g` as evaluation of `Λ_m`.** Even if `g(α)<0` for
some floats, that does not produce integers `A_m, B_m`.

## Quoted criterion (Theorem 5.1)

```text
Let x ∈ ℝ. Suppose there exist infinitely many integers A_m ≠ 0 and B_m
such that  0 < |Λ_m| = |A_m x − B_m| ≤ ε_m ,          (25)
with ε_m → 0. Then x is irrational.
```

This is the classical packing already proved in
`FragileProofAudit.IrrationalityCriterion.irrational_of_integer_forms_tendsto_zero`.
The criterion is not the issue. The missing inputs are.

## Confirm / break / abort

| Outcome | Meaning |
|---|---|
| **BREAK (this extract)** | No evaluable `Λ_m` for `ζ(5)` at any `(m,q)` from the displayed lemmas. Harvest’s third outcome: “asymptotic claims asserted without displayed computation.” |
| Confirm (would escalate) | Explicit `A_m, B_m ∈ ℤ` and `0 < |Λ_m| → 0` beating denominator growth |
| Numeric decay fail | Only after a faithful closed form exists |

This BREAK refutes the **route** “displayed integer forms + decay,” not the
theorem `ζ(2n+1) ∉ ℚ`.

## What we will not do

- Invent a Chen-1999 beta kernel and call it the paper’s `W_m`.
- Fall back to Kim ζ(5) because the live claim did not yield a number.
- Write Lean for `A_m`/`B_m` until they are numbers.

## Fill checklist

- [x] Quote Lemma 3.2 (`A_m = D_m`, `B_m = Ω D L_{≤K}`)
- [x] Quote `g(α)` / (24)
- [x] Quote Theorem 5.1
- [x] Attempt `Λ_m` at ζ(5) — **cannot evaluate**
- [x] Gate meta `results/odd_zeta_gate_meta.json` (verdict BREAK)
- [ ] Pin official PDF in `incoming/` when a 200 OK exists
- [ ] Lean: none (gate-before-prove)
