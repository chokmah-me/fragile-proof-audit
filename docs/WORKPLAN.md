# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-20 — Phase 3(i)#a Gauss-sum embed `gauss23² = −23` in
`ℚ(ζ₂₃)` VERIFIED; Phase 3(i)+++++ concrete ideal `(2, θ)` with
`absNorm = 2` non-principal VERIFIED; Phase 3(i)++++ `IsDedekindDomain OKNeg23`
VERIFIED; Phase 2(d) odd-zeta 202601.1609 RE-BROKEN at Lemma 5.1;
**resume at OKNeg23 ↪ 𝓞(ζ₂₃) / cyclotomic Ideal / proved h⁺, or per-claim Agoh–Giuga**
(2(d) write-up declined — gate stays as internal audit record)

**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  
**Habit:** commit each phase when it lands (do not leave a dirty tree for the next session)

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — after Phase 3(i)#a Gauss-sum embed

**3(i) Lamé 1847:** **DONE through 3(i)#a** —
gate \(h^-_{23}=3\); Lean Premise/QuadraticWitness/Maillet Bareiss;
quadratic ideal gate + `no_norm_two_equation`;
`IdealPrincipal` + **`IsDedekindDomain OKNeg23`** + concrete
`P2 = (2, θ)` with `absNorm P2 = 2` and `¬ IsPrincipal P2`;
**`CyclotomicEmbed`**: `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ`.
Evidence: `FragileProofAudit/Lame/`,
`scripts/gates/lame_h23.py`, `scripts/gates/lame_ideal_neg23.py`,
`docs/audits/lame-1847.md`.

**3(h) Agoh–Giuga kit:** **DONE** — Python oracle PASS + Lean `Criteria`/`Oracle`
(`oracle_seven`).

**Next options:**

1. **`OKNeg23 ↪ 𝓞(ℚ(ζ₂₃))` / cyclotomic Ideal** — use `gauss23` to build the
   algebra / ring-of-integers map, then non-principal ideal in `𝓞`; or prove
   \(h^+_{23}=1\).
2. **Per-claim Agoh–Giuga audit** — blueprint a concrete claimed proof against
   the kit; instantiate failing lemma at \(g=30\) or \(g=858\).
3. Optional: von Staudt–Clausen / Agoh–Bernoulli bridge (same kit, not blocking).

**Blocked:** flt-regular as a lake dependency — upstream toolchain is
`leanprover/lean4:v4.34.*` while this campaign pins `v4.32.2` (match
`catalan-sun-lean`). Do not bump the pin casually.

Do **not** claim the Agoh–Giuga conjecture. Do **not** confuse Kummer-regular
(\(23\nmid h\)) with UFD (\(h=1\)). Do **not** claim Lean proved
`classNumber (CyclotomicField 23 ℚ) = 3` — Bareiss owns \(h^-\); \(h^+\) stays cited.

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, prior gates as before, `giuga_oracle` PASS, `lame_h23`
PASS, `lame_ideal_neg23` PASS, lake + forge VERIFIED (includes
`Lame.IdealWitness` + `Lame.IdealPrincipal` + `Lame.DedekindField` +
`Lame.IdealNormTwo` + `Lame.CyclotomicEmbed`).

**3(i) landing:** gate `76521e6`; Premise/QuadraticWitness `9ae01da`; Maillet
Bareiss `7a8da40`; IdealWitness `9e7d8f2`; IdealPrincipal `4444ea9`;
Dedekind `c36aa9a`; IdealNormTwo `bc2bd06`; CyclotomicEmbed follows.

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
| **2(d)** odd-zeta 202601.1609 | **BREAK (corrected 2026-09-20)** — Lemma 5.1 never supplies admissible `(q,α,δ)`: `g(α*)>0` for every `q>e^λ−1` at `λ=2n+3`, `n=1..5`, sampled 300 orders of magnitude; superseded prior "`Λ_m` unevaluable" claim (that was false, PDF now pinned) | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py`, `incoming/odd-zeta-202601/` (gitignored, sha256 in gate meta) |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — Conjecture 1 covers hard-class primes `< 10^5`; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** — \(Z=P\) + Lemma 12; OreReduce (34) **capability-limited** | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **2(g)** PDN1 2503.00004 | **PASS** — GF + Thm 1.1/1.2 + (3.13); notebooks **capability-limited** | `docs/audits/pdn1.md`, `scripts/gates/pdn1.py`, `incoming/pdn1/` |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `GiugaOnFactors`/`KorseltOnFactors`/`oracle_seven` | `docs/audits/agoh-giuga.md`, `scripts/gates/giuga_oracle.py`, `FragileProofAudit/AgohGiuga/` |
| **3(i)** Lamé 1847 | **PASS** — through 3(i)#a: Bareiss + ideal + Dedekind + concrete `(2,θ)` + Gauss-sum `√−23` in `ℚ(ζ₂₃)` | `docs/audits/lame-1847.md`, `FragileProofAudit/Lame/` |
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

## After 3(i)++++ IsDedekindDomain OKNeg23

| ID | Target | First milestone |
|---|---|---|
| 3(i)++++ | Dedekind instance | **DONE** — `IsDedekindDomain OKNeg23` via integral closure |
| 3(i)+++++ | Concrete ideal | **DONE** — `P2 = (2, θ)`, `absNorm = 2`, `¬ IsPrincipal` |
| 3(i)#a | Gauss-sum embed | **DONE** — `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ` |
| 3(i)# | Cyclotomic Ideal / classNumber | `OKNeg23 ↪ 𝓞(ℚ(ζ₂₃))`, `Ideal.IsPrincipal`, or proved `h^+` |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval exists |
| 2(d) done | 202601.1609 PDF | **Pinned** (user-supplied download); Lemma 5.1 gate BREAK landed and closed — no write-up planned |
| 3(h)+ | Per-claim Agoh–Giuga | Concrete claimed proof vs kit at \(g=30\) / \(858\) |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
6. **Commit as you go** — each phase lands with a git commit before the session ends.
