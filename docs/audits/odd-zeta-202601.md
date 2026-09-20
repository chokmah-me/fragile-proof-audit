# Audit note — odd-zeta preprint 202601.1609 (Phase 2(d) extract)

**Claim artifact:** Archan Chattopadhyay, *On the Irrationality of the Odd Zeta Values*,
Preprints.org 202601.1609.v1 (doi:10.20944/preprints202601.1609.v1).  
**Campaign objects:** `docs/blueprint/odd-zeta-202601.md`,
`scripts/gates/odd_zeta_1609.py`, `results/odd_zeta_gate_meta.json`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | There exist explicit integer forms `Λ_m^{(q)} = A_m^{(q)} ζ(2n+1) − B_m^{(q)}` whose size tends to 0 |
| **Instance** | `ζ(5)` (`n=2`), any explicit `(m,q)` — campaign asked for `m=1,q=1` |
| **False instance** | Lemma 3.2 defines `A_m := D_m` (an LCM) and `B_m := Ω D L_{≤K}`; `W_m`, `Ω_m`, `F_{m,k}`, `K`, `D_m` have no closed evaluable form. `Λ_m` is not a number |

This is harvest outcome three: *asymptotic claims asserted without displayed computation.*
It is a **route** kill (displayed-forms + decay), not a claim that odd zetas are rational.

## What was gated

- Attempted `Λ_m` at ζ(5): **not evaluable**.
- Side check only: the paper’s `g(α)` *can* be negative for some `(q,λ,α)` with
  `λ < log(1+q)`. That is **not** `Λ_m`.

## PDF pin

Official PDF 403 from preprints.org (Akamai). Quotes from indexed `download_pub`
fulltext + ResearchGate OCR of the 11-page v1. Re-pin when a 200 OK exists;
the evaluability BREAK does not depend on a local file.

## Lean

None. Gate-before-prove. `IrrationalityCriterion` already covers Theorem 5.1.

## Not done, on purpose

Did not invent a Chen-1999 beta kernel. Did not fall back to Kim ζ(5).
