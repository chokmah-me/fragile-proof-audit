# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Pause:** Shabbat checkpoint cleared; Phase 1(b) landed 2026-09-19  
**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  

Full campaign plan (phases, per-target blocks, dependency graph, risk register) lives in the session plan file; this document is the **executable resume checklist**.

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI fragility = lead until gated.
3. A **pass** escalates (odd-zeta decay, ES cover) — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Jana–Karmakar is **off** the list. Negative-index Pochhammer is mandatory.

---

## Done

| Item | Evidence |
|---|---|
| Phase 0 skeleton + CI hooks | `README.md`, `.github/workflows/verify.yml` |
| Harness self-test (6/6) | `python scripts/gates/check.py` |
| Lake build + forge VERIFIED | `results/lean_verify_meta.json` |
| Phase 1(a) γ audit | `docs/audits/gamma-aejonanonymous.md` — break via statement non-fidelity |
| `AxiomAudit` scanner | `scripts/forge/axiom_audit.py` |
| Phase 1(b) Suman ζ(5) | blueprint quotes · `suman_eq48` BREAK · Lean BaseCase + criterion |

**γ outcome (short):** artifact proves `¬ is_rational_gamma` (homemade); does **not** prove `Irrational` of mathlib γ. Main file 0 sorry; comparator has 6. No historic escalate.

**Suman outcome (short):** Eq. (48) at `n=1` has solutions under Suman’s own range `0 ≤ k ≤ d_n` (`d_1=1`). Claude’s empty `1≤k≤0` snippet rejected. Note: `docs/audits/suman-zeta5.md`.

---

## Phase 1(b) Suman ζ(5) — done

**Sources:** arXiv:2407.07121v6 (claim) · arXiv:2411.16774 (Chen et al.)  
**Blueprint:** `docs/blueprint/suman-zeta5.md`

### Day checklist

1. **Extract before Lean**
   - [x] Quote Eq. (48) and the **actual** `k`-range / `d₁` from Suman (`0 ≤ k_i ≤ d_n`).
   - [x] Do **not** use Claude’s `1 ≤ k ≤ 0` snippet (`d₁ = 1` empty range).
   - [x] Quote Chen et al. Prop 3.1 (standard irrationality criterion).
2. **Numeric gate** — `scripts/gates/suman_eq48.py`
   - [x] Search integer solutions at `n = 1`; families `a = 2b`, `a = b`.
   - [x] Confirm ζ(5) ≈ 1.0369277551… ⇒ `a = b` ⇒ ζ(5) = 1 fails by ~0.037.
   - [x] Register in `scripts/gates/check.py`; write `results/suman_gate_meta.json`.
3. **Lean**
   - [x] `IrrationalityCriterion.lean` — Apéry-shaped criterion proved.
   - [x] `SumanZeta5/BaseCase.lean` — witnesses; negate “no solutions.”
   - [x] Do **not** claim ζ(5) is rational.
4. **Acceptance**
   - [x] Quoted k-range in blueprint
   - [x] Gate finds witnesses
   - [x] Lean sorry-free; `pwsh ./scripts/verify.ps1` green (forge VERIFIED)
   - [x] Private bug-report note under `docs/audits/`

---

## Resume here — Phase 1(c) Kim ζ(5)

**Source:** arXiv:1105.0730 · Zudilin / OEIS A013663  
**Blueprint:** `docs/blueprint/kim-zeta5.md`

1. Extract ε-inequality after eq. (3.3); define symbols.
2. Gate at `n_k ∈ {10,100,1000}`, `N = 1` → `scripts/gates/kim_eps.py`.
3. Lean: Tendsto kill or finite-threshold kill of the universal claim.
4. Shared dossier with Suman (“two generations, one genre”).

---

## Later (do not start before 1(b)–1(c) land)

| ID | Target | First milestone |
|---|---|---|
| 2(d) | Odd-zeta preprint 202601.1609 | Extract A_m, B_m; ‖Λ_m‖ for ζ(5), m≤50 |
| 2(e) | Erdős–Straus arXiv:2404.01508 | Sweep primes <10⁵ in hard classes mod 840 |
| 2(f) | RR 2608.05480 / 2608.15219 | q-expand in SymPy (no Sage) |
| 2(g) | PDN1 2503.00004 | Diff authors’ notebooks; 200+ q-terms |
| 3(h) | Agoh–Giuga kit | Giuga oracle numbers verified |
| 3(i) | Lamé 1847 | Atop flt-regular; h₂₃ = 3 |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval tooling exists |

**Out of scope:** re-attacking `catalan-sun-lean`; Jana–Karmakar; Joshi/IUT; Collatz/Goldbach monitors.

---

## Commands after resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
# clone γ mirror if needed (gitignored):
# git clone https://github.com/AEjonanonymous/Euler-Mascheroni.git incoming/Euler-Mascheroni
```

---

## Next concrete action

**Phase 1(c) step 1 — extract Kim ε-inequality after eq. (3.3) into `docs/blueprint/kim-zeta5.md`.**
