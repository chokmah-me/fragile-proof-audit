# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-20 — Phase 2(f) PASS (Ore capability-limited); resume at 2(g)  
**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — Phase 2(g) PDN1

**Source:** arXiv:2503.00004  
**First milestone:** Diff authors’ notebooks / replay declared computations  
**Attack type:** E (CAS transcript) / computational claim gate  

Do not reopen 2(e)/2(f) as kills — both **PASS**ed their executable gates
(2(f) OreReduce remains capability-limited, not a BREAK).

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, `suman_eq48` PASS (BREAK), `odd_zeta_1609` PASS (BREAK),
`es_cover` PASS, `rr_qexpand` PASS (Ore capability-limited), lake + forge VERIFIED.

---

## Do not reopen

| Item | Why |
|---|---|
| Invent a Chen beta kernel for 202601.1609 | Gate of a formula the paper did not write |
| Treat `g(α)<0` as `‖Λ_m‖→0` | Different object |
| Fall back to Kim because odd-zeta failed | 2(d) BREAK is a valid outcome |
| Full Kim Tendsto Lean | Compressed appendix only |
| Claude’s Suman snippet `1 ≤ k ≤ 0` | Empty range; real range is `0 ≤ k ≤ d_n` |
| Jana–Karmakar | Audited clean (630+96); Pochhammer negative-index is mandatory |
| `catalan-sun-lean` | Own reference campaign; reuse pin, do not re-attack |
| Joshi/IUT, Collatz, Goldbach “monitors” | No finite gate |

---

## Done (do not redo)

| Phase | Outcome | Evidence |
|---|---|---|
| **0** | Pin, harness, CI, forge | `README.md`, `results/lean_verify_meta.json` |
| **1(a)** γ | **G** — statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ | `docs/audits/gamma-aejonanonymous.md` |
| **1(b)** Suman ζ(5) | **B** — Eq. (48) at `n=1` has `a=2b`, `a=b` under `0 ≤ k ≤ d_1` | `docs/audits/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean` |
| **2(d)** odd-zeta 202601.1609 | **BREAK** — Lemma 3.2 is an LCM, not a sequence; `Λ_m` at ζ(5) unevaluable | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py` |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — Conjecture 1 covers all hard-class primes `< 10^5`; odd-`k` fold side-check OK; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py`, `incoming/erdos-straus-2404.01508.pdf` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** on Type-D \(Z=P\) q-expand + Lemma 12; OreReduce (34) **capability-limited** (no RISC) | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

Last checkpoint before 2(e)/2(f) landings: `a73e6a7` (WORKPLAN resume pin).

---

## Optional appendix (not a blocker) — compressed Kim

**Only if** you specifically want F trained on a known corpse before a live covering.

- Source: arXiv:1105.0730 · Zudilin / OEIS A013663
- Stub: `docs/blueprint/kim-zeta5.md`
- Quote ε-inequality after eq. (3.3); gate `n_k ∈ {10,100,1000}`, `N=1`
- One-page audit. **No Tendsto** unless the table is surprising
- Does not gate 2(e)

---

## After 2(e)

| ID | Target | First milestone |
|---|---|---|
| 2(d) pin | 202601.1609 PDF | Pin in `incoming/` if preprints.org returns 200 |
| 2(f) | RR 2608.05480 / 2608.15219 | q-expand in SymPy (no Sage) |
| 2(g) | PDN1 2503.00004 | Diff authors’ notebooks |
| 3(h) | Agoh–Giuga kit | Giuga oracle numbers verified |
| 3(i) | Lamé 1847 | Atop flt-regular; `h₂₃ = 3` |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval exists |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
