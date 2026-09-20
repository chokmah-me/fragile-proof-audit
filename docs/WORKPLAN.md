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
| Phase 2(d) odd-zeta 202601.1609 | extract BREAK: `Λ_m` not evaluable (`docs/audits/odd-zeta-202601.md`) |

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

## Phase 2(d) odd-zeta 202601.1609 — extract BREAK

**Source:** Preprints.org 202601.1609.v1 · doi:10.20944/preprints202601.1609.v1  
**Blueprint:** `docs/blueprint/odd-zeta-202601.md`  
**Note:** `docs/audits/odd-zeta-202601.md`

Quoted Lemma 3.2: `A_m := D_m` (LCM), `B_m := Ω D L_{≤K}`. Kernel `W_m`, `Ω`,
`F_{m,k}`, `K`, `D_m` are unnamed as closed forms. **`Λ_m` at ζ(5) is not
evaluable** — harvest third outcome, not a Kim detour.

`g(α)` is quoted and is a different object; do not treat `g<0` as `|Λ_m|→0`.

---

## Compressed later — Phase 1(c) Kim ζ(5) (not a blocker)

**Source:** arXiv:1105.0730 · Zudilin / OEIS A013663  
**Blueprint:** `docs/blueprint/kim-zeta5.md`

Numeric ε-table only (`n_k ∈ {10,100,1000}`, `N=1`); no Tendsto unless surprising.
Does not gate 2(e)+.

---

## Later (1(b) landed; 2(d) extract BREAK recorded)

| ID | Target | First milestone |
|---|---|---|
| 2(d) | Odd-zeta preprint 202601.1609 | **BREAK** — `Λ_m` not evaluable; pin PDF if 200 OK |
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

**Phase 2(e) — Erdős–Straus covering (arXiv:2404.01508): transcribe claimed families and sweep primes in hard classes mod 840.** Kim remains a compressed appendix, not the resume pointer. Pin 202601.1609 PDF if a 200 OK appears.
