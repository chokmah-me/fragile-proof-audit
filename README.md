# FragileProofAudit

**Private** Lean 4 / mathlib campaign (Chokmah LLC) that audits mathematically
consequential but structurally fragile proofs.

> **Gates refute routes, not theorems.**  
> ζ(5) is probably irrational; FLT is true. What we kill is a lemma chain:
> *lemma · instance · false instance.*

| | |
|---|---|
| **Pin** | Lean `v4.32.2` · mathlib `v4.32.2` (same as [`catalan-sun-lean`](https://github.com/chokmah-me/catalan-sun-lean)) |
| **Stack** | Laptop · Python `mpmath` / `Fraction` / SymPy / `networkx` (graph gates only) · no Sage / Magma / cluster |
| **Resume** | Fresh session → cyclotomic **decomposition group / h⁺** (Gal order 22 pinned; instance diamond blocks the next Lean step), Cohen's Lean scaffold (infrastructure confirmed tractable, not yet built), per-claim Agoh–Giuga, the 2(d) write-up, or open `corpus/fragile-formalizable-proofs-report.md` / `corpus/historical-collapses-gemini-export.md` for unexploited targets — [`docs/WORKPLAN.md`](docs/WORKPLAN.md) |
| **Lock** | 21 gates pinned in `EXPECTED_VERDICT` (`scripts/gates/check.py`); drift in either direction fails CI |

---

## Quick start

```powershell
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

That runs (1) numeric gates including the Pochhammer harness self-test, then
(2) `lake build` + lean-proof-forge (no `sorry`, no `native_decide`, axioms ⊆
classical three).

---

## Discipline

1. **Routes, not theorems** — public/private notes name the dead chain only.
2. **Audit the auditor** — every failed gate ships with its harness; AI-sourced
   fragility claims (including “Pith”) are leads until a gate confirms them.
3. **A pass escalates** — genuine decay or covering is a breakthrough outcome;
   never force a refutation.
4. **Gate before prove** — [`docs/GATE-BEFORE-PROVE.md`](docs/GATE-BEFORE-PROVE.md).

**Off the target list:** Jana–Karmakar (arXiv:2501.10109) — WZ pair survived
630+96 exact checks. The first harness produced 66 false mismatches by omitting
`(a)_{-n} = (-1)^n/(1-a)_n`; that convention is enforced in
`scripts/harness/pochhammer.py`.

**Not an external kill:** Zenodo 22830611 is this shop’s own
`catalan-sun-lean` note on Sun’s §9 — reuse its pin and gate style; do not
re-attack that manuscript. Sun’s preprint itself, arXiv:2609.04176v1, is the
separate CAT-G row.

---

## External kernel check (con-leche)

Beyond `lake build`, every push also runs
[con-leche](https://github.com/leanprover/con-leche) — an independent Lean
kernel that re-checks an NDJSON export of the built library, catching bugs
that exist only in Lean's own kernel and rejecting leftover `sorry`s or
non-standard axioms. Same pins and pipeline as `catalan-sun-lean`. Details:
[`docs/con-leche.md`](docs/con-leche.md).

---

## Layout

| Path | Role |
|---|---|
| `FragileProofAudit/` | Lean modules (`AxiomAudit`, `IrrationalityCriterion`, …) |
| `scripts/harness/` | Exact arithmetic + rising-factorial conventions |
| `scripts/gates/` | Locked numeric gates (`check.py` = CI). `borsuk63.py` in this folder is an **instrument**, not a lock row |
| `scripts/controls/` | Discrimination instruments; never in `check.py` |
| `scripts/forge/` | `axiom_audit.py` + lean-proof-forge verify |
| `docs/WORKPLAN.md` | **Resume checklist** (start here) |
| `docs/blueprint/` | Per-target blueprints |
| `docs/audits/` | Bug-report style write-ups |
| `corpus/` | Scout reports (graded trust) |
| `incoming/` | Pinned source PDFs (tracked) + third-party Lean mirrors (gitignored; pin SHA in `results/`) |
| `results/` | Gate and forge receipts |

### Corpus trust

| File | Trust |
|---|---|
| `corpus/fragile-formalizable-proofs-report.md` | Master harvest / ranking |
| `corpus/harvest-addendum-analysis.md` | **Authoritative** on identifiers & fragility truth |
| `corpus/lean4-attack-harvest.md` | Adopt 7-type taxonomy; Pith verdicts = leads |
| `corpus/historical-collapses-gemini-export.md` | Lead. Track C pins (Borsuk-63, quantum Hedetniemi); not the resume |

---

## Phase status

| Phase | Status |
|---|---|
| **0** Readiness | **done** — pin, harness 6/6, forge VERIFIED, CI |
| **1(a)** γ audit (`AEjonanonymous/Euler-Mascheroni`) | **done** — break: statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ. Brief: [`docs/audits/gamma-aejonanonymous.md`](docs/audits/gamma-aejonanonymous.md) |
| **1(b)** Suman ζ(5) | **done** — Eq. (48) base-case kill; gate + Lean witnesses; brief [`docs/audits/suman-zeta5.md`](docs/audits/suman-zeta5.md) |
| **1(c)** Kim ζ(5) | compressed appendix — not a blocker |
| **2(d)** Odd-zeta 202601.1609 | **BREAK (corrected 2026-09-20)** — PDF pinned; Lemma 5.1 never supplies admissible `(q,α,δ)` at the paper's own `λ=2n+3`, `n=1..5`. Superseded prior "`Λ_m` unevaluable" claim. [`docs/audits/odd-zeta-202601.md`](docs/audits/odd-zeta-202601.md) |
| **2(e)** Erdős–Straus | **PASS (escalate)** — Conjecture 1 covers all hard-class primes `< 10^5`; no Lean kill. [`docs/audits/es-covering.md`](docs/audits/es-covering.md) |
| **2(f)** RR / HJO | **PASS** — \(Z=P\) q-expand + Lemma 12; OreReduce capability-limited. [`docs/audits/rr-qexpand.md`](docs/audits/rr-qexpand.md) |
| **2(g)** PDN1 | **PASS** — GF + Thm 1.1/1.2 + (3.13); notebooks capability-limited. [`docs/audits/pdn1.md`](docs/audits/pdn1.md) |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `oracle_seven`. [`docs/audits/agoh-giuga.md`](docs/audits/agoh-giuga.md) |
| **3(i)** Lamé 1847 | **PASS** — through 3(i)#+b: `Gal(ℚ(ζ₂₃)/ℚ)` cyclic of order 22. Next Lean step (decomposition-group cardinality) blocked on a mathlib instance diamond; or prove \(h^+\). [`docs/audits/lame-1847.md`](docs/audits/lame-1847.md) |
| **Track D** Live fragile proofs 2024–26 | **7 BREAKs, all gated + controlled** (2026-09-21): [Cohen subadditivity](docs/audits/cohen-subadditivity.md) · [Baste–Fürst–Henning domination](docs/audits/baste-domination.md) · [Sárközy sum-product](docs/audits/sarkozy-sum-product.md) · [Tang–Zhang Schatten norm](docs/audits/tang-zhang-schatten.md) · [Thakur Carlitz–Wieferich](docs/audits/thakur-carlitz.md) · [Chung–Graham–Spiro gap sets](docs/audits/chung-graham-spiro.md) · [Salez–Youssef log-Sobolev](docs/audits/salez-youssef-logsobolev.md). [NCI **SKIPPED**](docs/audits/nci-conjecture.md) — no finite gate. Corpus ranking table fully dispositioned. **Sárközy has a Lean scaffold** (`FragileProofAudit/Sarkozy/UPNT65.lean`, ported from Tang's own public formalization, VERIFIED axiom-clean) — the only Track D target formalized so far; Cohen's is confirmed tractable but not yet built. |
| **3** Infrastructure | Agoh–Giuga kit · Lamé pinpoint · Sun batch `2603.29973` |
| **Dossier II** Harvest sweep (2026-09-22) | **5 BREAKs + 1 PASS, all gated + controlled**: [TPC-AREA](docs/audits/tpc-area.md) (Agama Thm 2.3) · [ES-5](docs/audits/es5-eq35.md) (Ghermoul eq. 35) · [CAT-G](docs/audits/cat-g.md) (Sun, between (2.3)/(2.4)) · [KRR-CL](docs/audits/krr-cl.md) (Gnang \(Q^{[1]}\) congruence) · [TPC-GN](docs/audits/tpc-gn.md) (Gnang Prop. 3.4 display) · [JAC-2D](docs/audits/jac-2d.md) (Su's 2D Jacobian conjecture claim — Remark 2.7 / Lemma 2.8 skeleton **survives** replay; PASS, escalate, not a clearance). Source: `corpus/Fragile-Route_Harvest_Dossier_II.md`. |
| **Track C** | Operator pins, **not resume, not on the verdict lock.** Borsuk-63 author verifier PASS; quantum Hedetniemi (arXiv:2609.20690) Python certificates + source catalog PASS, kernel UNKNOWN (their Lean 4.19.0). [`docs/audits/borsuk-63.md`](docs/audits/borsuk-63.md) · [`docs/audits/hedetniemi-q.md`](docs/audits/hedetniemi-q.md) |
| **Tait–Tutte** (2026-09-22) | **BREAK**, gated + controlled — Tier 2 historical pinpoint, `corpus/fragile-formalizable-proofs-report.md` §4.3 (harvest rank 7, first unexploited target in that report once ranks 1–5 were confirmed already covered by existing gates). The Tutte graph (46v/69e, cubic, 3-connected, planar) has no Hamiltonian cycle, refuting Tait's 1884 conjecture. On the verdict lock (22nd entry) — a genuine from-scratch build, not a Track C replay. [`docs/audits/tait-tutte.md`](docs/audits/tait-tutte.md) |

Detail and day-level steps: [`docs/WORKPLAN.md`](docs/WORKPLAN.md).

---

## Attack taxonomy (adopted)

| Type | Name |
|---|---|
| A | Scalar-gate |
| B | Base-case kill |
| C | WZ-certificate audit |
| D | Finite q-expansion |
| E | CAS-transcript replay |
| F | Counterexample search |
| G | Logical-gap exposure |

---

## License / visibility

Private Chokmah LLC artifact. No public deposit until an explicit release
decision. Third-party material under `incoming/` retains its upstream license.
Lean mirrors are **not** republished here (their directories are gitignored;
commit SHAs are recorded under `results/`). Source **PDFs are tracked** — they
are the pinned provenance every gate is checked against, and a gate whose paper
is not in the repo cannot be re-audited. Any public release must revisit
whether those PDFs ship.
