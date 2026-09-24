# Weekly harvests

Raw weekly harvest files live here. Each file is the *input* to the harvest
loop (`.github/workflows/harvest-loop.yml`), which analyzes it using the
fragile-proof-audit recon regime and writes dated recon output to
`docs/audits/harvest-<date>/`.

## File format

One file per week: `<YYYY-MM-DD>.md`. UTF-8, plain ASCII preferred.

```markdown
# Harvest 2026-09-24
window: 2026-09-10..2026-09-24
source: user deep-research batch

## CLAIM euler-forced-blowup
title: Forced 3D Euler blowup (Alpöge–Buckmaster)
claim: Smooth forcing drives finite-time blowup for 3D Euler, 2D Boussinesq, and IPM.
paper: arXiv:2609.12345
code: https://github.com/someorg/fluid_lean
code_note: three Lean 4 projects with interval-arithmetic certificates
inputs_note: full Lean sources + pinned toolchain public; third-party rebuilt all three
signals: ai_generated, released_under_pressure, build_skips_main_file
```

- `## CLAIM <id>` starts a claim block; `id` is kebab-case, unique in the file.
- `paper`: an `arXiv:<id>` identifier (preferred) or a full URL.
- `code`: full URL of the public code/data repo, or `none`.
- `signals`: comma-separated fixed vocabulary (see below). Free-text
  fragility notes go in `code_note`/`inputs_note`; scoring uses `signals`.

## Signal vocabulary (fixed; the analyzer scores these)

| Signal | Points | Meaning |
|---|---|---|
| `ai_generated` | +2 | claim/code heavily AI-generated |
| `released_under_pressure` | +1 | rushed release stated or evident |
| `anonymous_or_unaffiliated` | +1 | author anonymous or unaffiliated |
| `single_author` | +1 | single author, no co-signers |
| `ai_only_review` | +1 | only informal AI review behind it |
| `disclosed_llm_help` | +1 | author discloses LLM assistance |
| `formal_subset_of_claim` | +2 | formalization covers less than the headline claim |
| `credit_dispute` | +1 | authorship/credit dispute around the work |
| `build_skips_main_file` | +2 | build passes without compiling the main artifact |
| `third_party_rebuild` | −2 | independent third party rebuilt it |
| `pinned_toolchain` | −1 | toolchain/commit pinned by the authors |
| `public_ci_green` | −1 | public CI green at a pinned commit |

Computed adjustments (analyzer-added, not in the file): code repo
unreachable → inputs BLOCKED; Lean files present but no `lean-toolchain`
pin → +1; paper identifier does not resolve → +1.

Higher score = more fragile = higher in the recon queue. The score is a
triage signal, not a verdict. The verdict lock is never touched by the loop.
