# FragileProofAudit (private)

Private Lean 4 / mathlib campaign (Chokmah LLC) that audits mathematically
consequential but structurally fragile proofs. **Gates refute routes, not
theorems.**

Pinned from the CatalanSun reference campaign:

- Lean: `leanprover/lean4:v4.32.2`
- mathlib: `rev = "v4.32.2"`

## Discipline

1. Gates refute **lemma chains**, not open problems (ζ(5) is probably
   irrational; FLT is true). Notes name lemma · instance · false instance.
2. Audit the auditor: every failed gate ships with its harness. AI-sourced
   fragility claims are leads until a computation confirms them.
3. A **pass** is information: genuine decay or genuine covering → escalate,
   never force a refutation.
4. **Gate before prove** — see [`docs/GATE-BEFORE-PROVE.md`](docs/GATE-BEFORE-PROVE.md).

Jana–Karmakar (arXiv:2501.10109) is **off** the target list: its WZ pair
survived a 630-point exact audit. The first harness produced 66 false
mismatches by omitting `(a)_{-n} = (-1)^n/(1-a)_n` — that convention is
enforced in `scripts/harness/pochhammer.py`.

## Layout

| Path | Role |
|---|---|
| `FragileProofAudit/` | Lean modules (`AxiomAudit`, `IrrationalityCriterion`, …) |
| `scripts/harness/` | Exact arithmetic + rising-factorial conventions |
| `scripts/gates/` | Numeric gates (`check.py` is the CI entrypoint) |
| `scripts/forge/` | `lean-proof-forge` verify script |
| `docs/blueprint/` | Per-target blueprints |
| `corpus/` | Scout reports (graded trust; private) |
| `incoming/` | Read-only mirrors of third-party Lean artifacts |
| `results/` | Gate and forge receipts |

## Verify

```powershell
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Or separately:

```powershell
python scripts/gates/check.py
python scripts/forge/verify_lean_project.py --project . --target FragileProofAudit
```

## Phase status

| Phase | Status |
|---|---|
| 0 Readiness | **in progress** — repo skeleton, harness, CI hooks |
| 1(a) γ audit (`AEjonanonymous/Euler-Mascheroni`) | pending |
| 1(b) Suman ζ(5) | pending |
| 1(c) Kim ζ(5) | pending |
| 2–3 | see campaign plan |

Artifacts remain **private** until an explicit release decision.
