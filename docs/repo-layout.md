# Repository layout

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

## Corpus trust

| File | Trust |
|---|---|
| `corpus/fragile-formalizable-proofs-report.md` | Master harvest / ranking |
| `corpus/harvest-addendum-analysis.md` | **Authoritative** on identifiers & fragility truth |
| `corpus/lean4-attack-harvest.md` | Adopt 7-type taxonomy; Pith verdicts = leads |
| `corpus/historical-collapses-gemini-export.md` | Lead. Track C pins (Borsuk-63, quantum Hedetniemi); not the resume |
