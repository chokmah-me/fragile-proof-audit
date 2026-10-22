# AGENTS.md — fragile-proof-audit

Replay audits of published mathematical claims. Gates refute routes, not theorems. 32 fail-closed gates pinned in `EXPECTED_VERDICT` (17 BREAK / 15 PASS).

## Commands

```powershell
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

That runs numeric gates (including the Pochhammer harness self-test), then `lake build` plus lean-proof-forge (no `sorry`, no `native_decide`, axioms ⊆ classical three).

Toolchain: Lean **4.32.2** / Mathlib **v4.32.2**.

## Work rules

- Fail-closed: no verdict without a receipt (hash-pinned inputs, reproduced run, checked artifact).
- The 32-gate verdict lock is read-only; do not edit verdicts. Drift in either direction fails CI (`scripts/gates/check.py`).
- Heavy Lean builds run on the user's self-hosted runners, never on a laptop VM; one heavy job per runner.
- Upstream filings use the three-fold template (report, second-look, self-contained reproduction).
- Gates refute lemma chains. Do not claim a theorem is false because a route BREAKS.

## Pointers

- `README.md` — phase status, DOI
- `docs/WORKPLAN.md` — resume
- `docs/GATE-BEFORE-PROVE.md` — order of work
- `docs/repo-layout.md` — layout
- `ZENODO.md` / `CITATION.cff` — cite / DOI map
