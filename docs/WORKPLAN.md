# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-20 — resume in a fresh session here  
**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — Phase 2(e) Erdős–Straus covering

**Source:** arXiv:2404.01508 (*A Complete Congruence System for the Erdős–Straus Conjecture*)  
**Blueprint to fill:** `docs/blueprint/es-covering.md` (create on resume)  
**Attack type:** F (counterexample search) on a **live** covering claim  
**Gate:** `scripts/gates/es_cover.py` → `results/es_cover_gate_meta.json`

### Why this, not Kim, not more odd-zeta

- 1(a) already trained **G** (statement non-fidelity).
- 1(b) already trained **B** (base-case kill).
- 2(d) already showed odd-zeta `Λ_m` is **not evaluable** — there is no `m`-sweep.
- Kim’s `n_k` table would train **F** on a 2011 corpse (cheap appendix, not a blocker).
- Erdős–Straus trains **F** on a live covering lemma: one uncovered prime in a hard
  class mod 840 kills the route. A pass **escalates**.

### Day checklist (do in order)

1. **Extract before Python**
   - Download arXiv:2404.01508 into `incoming/`.
   - Quote the claimed covering families and the hard residues
     `{1, 121, 169, 289, 361, 529}` mod 840.
   - Write `docs/blueprint/es-covering.md` with those quotes. No Lean yet.
2. **Numeric gate** — `scripts/gates/es_cover.py`
   - Exact `Fraction` / integer arithmetic only.
   - First pass: primes `< 10^4` in the six hard classes (widen to `< 10^5` if clean).
   - Log first uncovered prime **or** first parameter that violates the paper’s
     divisibility (e.g. the “automatic” odd-`k` fold).
   - Register in `scripts/gates/check.py`; write `results/es_cover_gate_meta.json`.
3. **Lean only after a green (or BREAK) gate**
   - If BREAK: a witness prime + `not_covered` lemma; do **not** claim ESC is false.
   - If PASS: stop and escalate — do not force a kill.
4. **Acceptance**
   - [ ] Quoted families in blueprint
   - [ ] Gate ran; meta JSON written
   - [ ] `pwsh ./scripts/verify.ps1` green
   - [ ] Note under `docs/audits/es-covering.md` (lemma · instance · false instance,
         or “survived this sweep”)

**Abort:** if the paper’s families cannot be transcribed into an executable checker
→ same treatment as 2(d): **BREAK underspecified**, do not invent identities.

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, `suman_eq48` PASS (verdict BREAK), `odd_zeta_1609` PASS
(verdict BREAK, `Λ_m` unevaluable), lake + forge VERIFIED.

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
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

Last pushed commit at checkpoint: `278b801` (2(d) extract BREAK).

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
