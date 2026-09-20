# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-20 — Phase 2(g) landed; **resume in a fresh session at 3(h)**  
**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  
**Habit:** commit each phase when it lands (do not leave a dirty tree for the next session)

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — Phase 3(h) Agoh–Giuga kit

**Genre:** claimed proofs that “\(n\) prime ⟺ Agoh/Giuga congruence”  
**Attack type:** finite oracle audit (reusable kit), then per-claim blueprint  
**First milestone:** verify the seven known Giuga numbers are Giuga and
**non-Carmichael** (Korselt fails) — the standing counterexample oracle  
**Blueprint to fill:** `docs/blueprint/agoh-giuga.md` (create on resume)  
**Gate:** `scripts/gates/giuga_oracle.py` → `results/giuga_oracle_gate_meta.json`

### Why this now

- 1(a) trained **G**; 1(b) trained **B**; 2(d) was extract **BREAK**.
- 2(e)–2(g) all **PASS**ed executable gates (escalate; do not force kills).
- Agoh–Giuga is the harvest’s reusable **genre kit**: each new claimed proof
  is a short audit once the oracle + Korselt/Giuga lemmas exist
  (`corpus/fragile-formalizable-proofs-report.md` §3.4).

### Day checklist (do in order)

1. **Oracle table (exact integers)**
   - Known Giuga composites (harvest spot-check list):  
     `30`, `858`, `1722`, `66198`, `2214408306`, `24423128562`
     (+ confirm the seventh from CARMA / ProofAtlas; pin citation).
   - For each \(g\): check Giuga criterion \(p \mid (g/p - 1)\) for all primes
     \(p \mid g\); check Korselt / Carmichael \((p-1) \mid (g-1)\) — expect
     **Giuga ∧ ¬Carmichael**.
   - Write quotes + table into `docs/blueprint/agoh-giuga.md`. No Lean yet.
2. **Numeric gate** — `scripts/gates/giuga_oracle.py`
   - Exact integer arithmetic only.
   - Emit `results/giuga_oracle_gate_meta.json` with per-\(g\) witnesses.
   - Register in `scripts/gates/check.py`.
3. **Lean only after a green gate**
   - Small `Giuga` / `Korselt` lemmas + the finite oracle table as `decide` /
     `native_decide`-free witnesses (prefer explicit proofs / `norm_num`).
   - Do **not** claim the Agoh–Giuga conjecture; kit is for auditing *claims*.
4. **Acceptance**
   - [ ] Blueprint with oracle table + criterion quotes
   - [ ] Gate ran; meta JSON written; all listed \(g\) Giuga ∧ ¬Carmichael
   - [ ] `pwsh ./scripts/verify.ps1` green
   - [ ] Audit note `docs/audits/agoh-giuga.md`
   - [ ] **Commit** the phase before leaving the session

**Abort:** if a “seventh” Giuga number cannot be sourced with a citable list →
gate the six verified ones, document the gap, do not invent a seventh.

### After the oracle (same phase or next)

Per new claimed proof: blueprint against the kit; instantiate failing lemma at
\(g=30\) or \(g=858\). Optional later: von Staudt–Clausen / Agoh–Bernoulli bridge.

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, `suman_eq48` PASS (verdict BREAK), `odd_zeta_1609` PASS
(verdict BREAK), `es_cover` PASS, `rr_qexpand` PASS (Ore capability-limited),
`pdn1` PASS (notebooks capability-limited), lake + forge VERIFIED.

**HEAD at this checkpoint:** `b64abae` (Phase 2(g)). Prior: `728c416` (2(e)+2(f)).

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
| Force kills on 2(e)–2(g) PASSes | Pass escalates; Ore/notebooks are capability-limited, not BREAKs |
| Joshi/IUT, Collatz, Goldbach “monitors” | No finite gate |
| Fake Mathematica / RISC / Magma replays | Prefer blocked notes over invented cofactors |

---

## Done (do not redo)

| Phase | Outcome | Evidence |
|---|---|---|
| **0** | Pin, harness, CI, forge | `README.md`, `results/lean_verify_meta.json` |
| **1(a)** γ | **G** — statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ | `docs/audits/gamma-aejonanonymous.md` |
| **1(b)** Suman ζ(5) | **B** — Eq. (48) at `n=1` has `a=2b`, `a=b` under `0 ≤ k ≤ d_1` | `docs/audits/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean` |
| **2(d)** odd-zeta 202601.1609 | **BREAK** — Lemma 3.2 is an LCM, not a sequence; `Λ_m` at ζ(5) unevaluable | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py` |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — Conjecture 1 covers hard-class primes `< 10^5`; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** — \(Z=P\) + Lemma 12; OreReduce (34) **capability-limited** | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **2(g)** PDN1 2503.00004 | **PASS** — GF + Thm 1.1/1.2 + (3.13); notebooks **capability-limited** | `docs/audits/pdn1.md`, `scripts/gates/pdn1.py`, `incoming/pdn1/` |
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

---

## Optional appendix (not a blocker) — compressed Kim

**Only if** you specifically want Type F on a known corpse.

- Source: arXiv:1105.0730 · Zudilin / OEIS A013663
- Stub: `docs/blueprint/kim-zeta5.md`
- Quote ε-inequality after eq. (3.3); gate `n_k ∈ {10,100,1000}`, `N=1`
- One-page audit. **No Tendsto** unless the table is surprising
- Does not gate 3(h)

---

## After 3(h)

| ID | Target | First milestone |
|---|---|---|
| 3(i) | Lamé 1847 | Atop flt-regular; `h₂₃ = 3` |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval exists |
| 2(d) pin | 202601.1609 PDF | Pin in `incoming/` if preprints.org returns 200 |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
6. **Commit as you go** — each phase lands with a git commit before the session ends.
