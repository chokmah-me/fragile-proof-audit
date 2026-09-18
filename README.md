# FragileProofAudit

**Private** Lean 4 / mathlib campaign (Chokmah LLC) that audits mathematically
consequential but structurally fragile proofs.

> **Gates refute routes, not theorems.**  
> ζ(5) is probably irrational; FLT is true. What we kill is a lemma chain:
> *lemma · instance · false instance.*

| | |
|---|---|
| **Pin** | Lean `v4.32.2` · mathlib `v4.32.2` (same as [`catalan-sun-lean`](https://github.com/chokmah-me/catalan-sun-lean)) |
| **Stack** | Laptop · Python `mpmath` / `Fraction` / SymPy · no Sage / Magma / cluster |
| **Resume** | After Shabbat → **Phase 1(b) Suman ζ(5)** — see [`docs/WORKPLAN.md`](docs/WORKPLAN.md) |

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

**Not an external kill:** Sun Catalan / Zenodo 22830611 is this shop’s own
`catalan-sun-lean` reference campaign — reuse its pin and gate style; do not
re-attack it.

---

## Layout

| Path | Role |
|---|---|
| `FragileProofAudit/` | Lean modules (`AxiomAudit`, `IrrationalityCriterion`, …) |
| `scripts/harness/` | Exact arithmetic + rising-factorial conventions |
| `scripts/gates/` | Numeric gates (`check.py` = CI entrypoint) |
| `scripts/forge/` | `axiom_audit.py` + lean-proof-forge verify |
| `docs/WORKPLAN.md` | **Resume checklist** (start here after Shabbat) |
| `docs/blueprint/` | Per-target blueprints |
| `docs/audits/` | Bug-report style write-ups |
| `corpus/` | Scout reports (graded trust) |
| `incoming/` | Third-party Lean mirrors (gitignored; pin SHA in `results/`) |
| `results/` | Gate and forge receipts |

### Corpus trust

| File | Trust |
|---|---|
| `corpus/fragile-formalizable-proofs-report.md` | Master harvest / ranking |
| `corpus/harvest-addendum-analysis.md` | **Authoritative** on identifiers & fragility truth |
| `corpus/lean4-attack-harvest.md` | Adopt 7-type taxonomy; Pith verdicts = leads |

---

## Phase status

| Phase | Status |
|---|---|
| **0** Readiness | **done** — pin, harness 6/6, forge VERIFIED, CI |
| **1(a)** γ audit (`AEjonanonymous/Euler-Mascheroni`) | **done** — break: statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ. Brief: [`docs/audits/gamma-aejonanonymous.md`](docs/audits/gamma-aejonanonymous.md) |
| **1(b)** Suman ζ(5) | **next** — derive k-range from paper; `IrrationalityCriterion` + base-case witnesses |
| **1(c)** Kim ζ(5) | pending — ε-inequality + Tendsto / threshold kill |
| **2** Gates at scale | odd-zeta decay · Erdős–Straus cover · RR q-expand · PDN1 |
| **3** Infrastructure | Agoh–Giuga kit · Lamé pinpoint · Sun batch `2603.29973` |

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
decision. Third-party mirrors under `incoming/` retain their upstream licenses;
we do not republish them in this repo (directories are gitignored; commit SHAs
are recorded under `results/`).
