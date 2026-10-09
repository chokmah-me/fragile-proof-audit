# Independent axiom-audit receipt — family 237 (Honeycomb)

**Family:** 237 — Honeycomb (SAW free energy, challenge HoneycombFreeEnergy)
**Claim:** `OAI.HoneycombForce.logPartition_tendsto`
**Verdict:** PASS (fail-closed)

## Inputs (hash-pinned)

- **openai/math revision:** `adc7f12`
- **Vendored subtree:** `lean/OAI/Probability/Honeycomb` — **2 Lean files**
  (`OAI.Probability.Honeycomb.FreeEnergy`, `OAI.Probability.Honeycomb.TriangleVisits`), 2,007 lines, Mathlib-only imports
- **Toolchain:** `leanprover/lean4:v4.34.1`
- **mathlib pin:** `d13f23b723b8a846827a245b89c10fc7d3f11612`

## Run

- **Date:** 2026-10-07
- **Workflow:** `.github/workflows/oai-honeycomb-forge.yml` (the predecessor of the parameterized family forge)
- **Repo commit:** `chokmah-me/fragile-proof-audit` @ `e16a378` (main)
- **Run:** https://github.com/chokmah-me/fragile-proof-audit/actions/runs/37647725873
- **Runner:** GitHub-hosted (fresh, independent of the auditing VM)
- **Duration:** ~3m
- **Steps:** all green — sparse clone, scratch lake project (mathlib-only), full build, axiom audit, evidence

## Axiom result

Exact `#print axioms` output from the run:

```
import OAI.Probability.Honeycomb.FreeEnergy
#print axioms OAI.HoneycombForce.logPartition_tendsto
'OAI.HoneycombForce.logPartition_tendsto' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Allowed:** propext, Classical.choice, Quot.sound. **Found:** exactly those three. No `sorry`, no `admit`, no extra axioms.

## Verdict

**PASS** — the 2-file build completed green on an independent machine, and the headline theorem depends only on the three approved axioms. Scoped strictly to what ran: family 237 at the pinned revision above. No claim is made about any other family, revision, or theorem.
