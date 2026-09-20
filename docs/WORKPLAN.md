# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-20 — Phase 3(i)#a Gauss-sum embed `gauss23² = −23` in
`ℚ(ζ₂₃)` VERIFIED; Phase 3(i)+++++ concrete ideal `(2, θ)` with
`absNorm = 2` non-principal VERIFIED; Phase 3(i)++++ `IsDedekindDomain OKNeg23`
VERIFIED; Phase 2(d) odd-zeta 202601.1609 RE-BROKEN at Lemma 5.1;
**audit-integrity pass landed 2026-09-20** — verdict lock + discrimination
controls; **all eight verdicts unchanged**, but what several of them *mean*
changed (see **Track B**).

**Resume at either:** *(A)* `OKNeg23 ↪ 𝓞(ζ₂₃)` / cyclotomic Ideal / proved
h⁺, or per-claim Agoh–Giuga — *(B)* the `lame_ideal_neg23` control, then the
2(d) write-up decision.

(2(d) write-up was declined — **worth revisiting**: after the false-positive
control it is the campaign's only sendable artifact. See Track B item 2.)

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

## Track B — audit integrity (the non-Lean thread)

**Landed 2026-09-20** — commits `f399b26`, `3f8a78f`, `73782e0`, `5752140`.

- **Verdict lock** (`scripts/gates/check.py`) — all eight gates pinned in
  `EXPECTED_VERDICT`; drift in *either* direction fails the run. Gates still
  exit 0 on a BREAK by design (a BREAK is a finding, not a build failure); the
  lock is what notices a flip. Changing a pin is a deliberate act and belongs
  in the same commit as the re-audit.
- **Discrimination control is now doctrine** — `docs/GATE-BEFORE-PROVE.md`
  protocol step 3, with a register of which gates require one.
- **`scripts/controls/`** — instruments, not gates: no campaign verdict, never
  registered in `check.py`.
- Forced UTF-8 on gate subprocess IO and runner stdio. `lame_h23` and
  `lame_ideal_neg23` had been exiting 1 under a cp1252 console *after* writing a
  correct PASS, making `verify.ps1` red for pure code-page reasons.

**Net result: no verdict changed.** All three PASSes and both BREAKs stand.

### What the audit altered

| target | change |
|---|---|
| **2(g) PDN1** | Real defect, in the *gate*. α=2 rested on 1 and 2 integers and α=3 was untested — **81 data points total**. Added a mod-arithmetic path (sparse Euler/Jacobi + Kronecker substitution) self-tested against the exact dense oracle. CI now **6 747** points reaching α=3 in ~7 s; `--deep` gives **33 746** with α=3 on all four families. All hold. |
| **2(e) ES** | PASS *reinterpreted*. Matched control: coverage carries **no** information — every perturbed congruence covers *more* primes than the real one — but `egyptian3` separates **100 % / exactly 0 %**. The gate certifies **Theorems 4 and 7** (the implication), not Conjecture 1 (the existential). The paper never claimed to prove ESC; its abstract conjectures the covering. |
| **2(f) RR** | `nmax` circularity tested directly: raising it by 3 never moves `Z`, and the largest *contributing* ‖n‖ is 4–6 against a cutoff of 11–14. Degree push — (3,8) 12→**22** (past Frobenius 13), (3,7) 15→26, (3,5) 24→34 — all MATCH. |
| **1(b) Suman** | False-positive control clear. The search has no discriminating power on its own; the verdict rests entirely on the `k = 0` endpoint, verified verbatim in the PDF, reinforced by (49) being stated with **no** mention of ζ(5), and matched to Chen et al. |
| **2(d) odd-zeta** | False-positive control clear, and **upgraded**: the BREAK is an **infimum**, not a sample. For λ ≥ 0.5 the minimum over the whole domain is at the boundary, `g = 1+q = e^λ` exactly (148.413 = e⁵ … 442414 = e¹³). The instrument is shown to discriminate — it *finds* admissible `q` for λ < 0.458. |
| **`es_cover` odd-k** | Had gated the verdict on five branches that are tautologies in `k`. Now gates the failable scope invariant (every hard residue ≡ 1 mod 8); failure is `ABORT_SCOPE`, not `BREAK`. |

### Resume here (Track B), in order

1. **`lame_ideal_neg23` discrimination control** — the one gap the doctrine
   marks *required* but unbuilt. "No α with |N(α)| = 2" is a non-existence
   result from a bounded search (`norm_equation_solutions`, `b ∈ {−1,0,1}`),
   the shape that has misled this campaign twice. The control must confirm the
   search **does** return solutions where they exist (`32 → (±3, ±1)`,
   `24 → (±1, ±1)`) and that `b_bound = isqrt(target//23) + 1` is not
   truncating the domain. ~30 lines; pattern in `scripts/controls/break_control.py`.

2. **2(d) write-up decision — revisit.** After the false-positive control this
   is the campaign's **only sendable artifact**: a 2026 preprint with no
   published refutation, a BREAK that is now an infimum result, survivor of both
   a retraction cycle and a control. Contrast 1(b) — Chen et al.
   (arXiv:2411.16774v3) already published that objection, so it is internal
   calibration, not an output.

3. **ES corpus question — open.** Does the 100 %/0 % separation belong in
   `corpus/` as a *positive* finding about Lopez's Theorems 4 and 7, rather than
   filed as a non-event because nothing died? Partial evidence gathered:
   Theorem 4 is an **iff** with a real constructive proof (`4duv = p+u+v` ⟹
   `u = (p+v)/(4dv−1)`, natural iff `4dv−1 | p+v`), *not* a one-line identity —
   which makes the framing more defensible than assumed. **Theorem 7 not yet
   read.** Note the campaign has no slot for "verified, no defect found"
   outputs, so `corpus/` is selection-biased toward kills.

4. **Type G on the PASSes.** ES is **vacuous** — the paper claims no proof, so
   there is no argument to find a gap in. Real remaining targets: PDN1's
   induction and RR's Ore step. All three notes now say `Type G not attempted`.
   Scope before starting; a pass escalates, never force a kill.

5. **Operator-only deep runs** (not CI): `python scripts/gates/pdn1.py --deep`
   (~105 s, 33 746 points, α=3 everywhere); RR `(3,8)` beyond `N=22` (23 s at
   22, cost grows fast).

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, prior gates as before, `giuga_oracle` PASS, `lame_h23`
PASS, `lame_ideal_neg23` PASS, **verdict lock 8/8 ok**, lake + forge VERIFIED
(includes `Lame.IdealWitness` + `Lame.IdealPrincipal` + `Lame.DedekindField` +
`Lame.IdealNormTwo` + `Lame.CyclotomicEmbed`).

Controls are **not** run by `verify.ps1` — they are operator instruments:

```powershell
python scripts/controls/es_cover_control.py 10000   # ~3 s
python scripts/controls/break_control.py            # ~7 s
```

Both exit 0. `break_control` needs the pinned PDFs under `incoming/`
(gitignored); without them its transcription and corroboration checks report
`unavailable` rather than passing silently.

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
| Unmatched negative controls | The first ES control varied the congruence **and** the search breadth at once; its “weakly discriminating” answer had to be withdrawn. Prove search equivalence before concluding |
| Suman base case as a “false positive” | The paper does derive `a=2b`/`a=b` itself, but (49) is stated with **no** ζ(5), so the base case owes an *algebraic* claim. Chen et al. concur. Settled 2026-09-20 |
| Re-promoting `es_cover`’s odd-k identity branches | Tautologies in `k`; documentation only, never a verdict |
| Discrimination controls on `rr_qexpand` / `pdn1` / `giuga_oracle` / `lame_h23` | Ceremony — exact equality or divisibility; see the register in `GATE-BEFORE-PROVE.md` |

---

## Done (do not redo)

| Phase | Outcome | Evidence |
|---|---|---|
| **0** | Pin, harness, CI, forge | `README.md`, `results/lean_verify_meta.json` |
| **1(a)** γ | **G** — statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ | `docs/audits/gamma-aejonanonymous.md` |
| **1(b)** Suman ζ(5) | **B** — Eq. (48) at `n=1` has `a=2b`, `a=b` under `0 ≤ k ≤ d_1` | `docs/audits/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean` |
| **2(d)** odd-zeta 202601.1609 | **BREAK (corrected 2026-09-20)** — Lemma 5.1 never supplies admissible `(q,α,δ)`: `g(α*)>0` for every `q>e^λ−1` at `λ=2n+3`, `n=1..5`, sampled 300 orders of magnitude; superseded prior "`Λ_m` unevaluable" claim (that was false, PDF now pinned) | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py`, `incoming/odd-zeta-202601/` (gitignored, sha256 in gate meta) |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — certifies **Theorems 4/7**, not Conjecture 1: matched control shows coverage carries no information, `egyptian3` separates 100 %/0 %; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** — \(Z=P\) + Lemma 12; OreReduce (34) **capability-limited** | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **2(g)** PDN1 2503.00004 | **PASS** — GF + Thm 1.1/1.2 + (3.13) through **α=3**, 6 747 points in CI / 33 746 at `--deep` (was 81); notebooks **capability-limited** | `docs/audits/pdn1.md`, `scripts/gates/pdn1.py`, `incoming/pdn1/` |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `GiugaOnFactors`/`KorseltOnFactors`/`oracle_seven` | `docs/audits/agoh-giuga.md`, `scripts/gates/giuga_oracle.py`, `FragileProofAudit/AgohGiuga/` |
| **3(i)** Lamé 1847 | **PASS** — through 3(i)#a: Bareiss + ideal + Dedekind + concrete `(2,θ)` + Gauss-sum `√−23` in `ℚ(ζ₂₃)` | `docs/audits/lame-1847.md`, `FragileProofAudit/Lame/` |
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

**Audited 2026-09-20** — every row above re-tested for false negatives (the
PASSes) or false positives (the BREAKs). **No verdict changed.** See **Track B**
for what the audit altered about their meaning and support.

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
| 2(d) done | 202601.1609 PDF | **Pinned**; Lemma 5.1 BREAK landed, false-positive control clear, now an **infimum** result — write-up **decision to revisit** (Track B item 2) |
| 3(h)+ | Per-claim Agoh–Giuga | Concrete claimed proof vs kit at \(g=30\) / \(858\) |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
6. **Commit as you go** — each phase lands with a git commit before the session ends.
7. **A check that cannot fail is not evidence.** Run the discrimination control
   where `docs/GATE-BEFORE-PROVE.md` requires one, and never gate a verdict on a
   tautology. Pin every verdict in `EXPECTED_VERDICT`.
