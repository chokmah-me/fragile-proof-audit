# Repository layout

| Path | Role |
|---|---|
| `FragileProofAudit/` | Lean modules (`AxiomAudit`, `IrrationalityCriterion`, …) |
| `scripts/harness/` | Exact arithmetic + rising-factorial conventions |
| `scripts/gates/` | Locked numeric gates (`check.py` = CI). `borsuk63.py` in this folder is an **instrument**, not a lock row |
| `scripts/controls/` | Discrimination instruments; never in `check.py` |
| `scripts/forge/` | `axiom_audit.py` + lean-proof-forge verify |
| `docs/WORKPLAN.md` | **Resume checklist** (start here) |
| `docs/blueprint/` | Per-target blueprints ([index](blueprint/INDEX.md)) |
| `docs/audits/` | Bug-report style write-ups ([index](audits/INDEX.md)); `harvest-<date>/` holds recon cards + `ledger.json` from the harvest loop; `receipt-hashes.json` pins script/output sha256 for the gate notes |
| `docs/family-receipts/` | Independent axiom-audit receipts for openai/math Lean families ([catalog](family-receipts/README.md)) |
| `drafts/` | Methods-paper source (`complete-paper.md` + section drafts); released PDF under [`ZENODO.md`](../ZENODO.md) |
| `polya/` | Pólya counterexample canonization workspace (`src/`, `certs/`, `build.sh`) |
| `.github/workflows/` | CI: `verify` (per-push), `con-leche` (external kernel), `deep-replay` (weekly Euler replay), `full-build` (reboot-free full `lake build`), `harvest-loop` (weekly recon) |
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
