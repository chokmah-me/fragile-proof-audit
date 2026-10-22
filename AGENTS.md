# AGENTS.md — fragile-proof-audit

## What this is
Trust, but Replay: replay audits of published mathematical claims — 32 fail-closed gates (17 BREAK / 15 PASS), Lean 4 + mathlib, Python harnesses

## Layout (top level)
- `CITATION.cff`
- `FragileProofAudit.lean`
- `FragileProofAudit`
- `LICENSE`
- `README.md`
- `ZENODO.md`
- `corpus`
- `docs`
- `drafts`
- `incoming`

## Work rules
- Fail-closed verification: no verdict without a receipt (hash-pinned inputs, reproduced run, checked artifact).
- The 32-gate verdict lock (17 BREAK / 15 PASS) is read-only; do not edit verdicts.
- Heavy Lean builds run on the user's self-hosted runners, never on a laptop VM; one heavy job per runner.
- Upstream filings use the three-fold template (report, second-look, self-contained reproduction).

## Canonical docs
- `README.md` — purpose, usage, and status.
- `CITATION.cff` — how to cite the associated paper/record.
- `LICENSE` — terms of use.
