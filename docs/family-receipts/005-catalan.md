# Independent axiom-audit receipt — family 005 (Catalan)

**Family:** 005 — Catalan (irrationality of Catalan's constant)
**Claim:** `OAI.InternalCatalan.catalan_irrational`
**Verdict:** PASS (fail-closed)

## Inputs (hash-pinned)

- **openai/math revision:** `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`
- **Vendored subtrees:** `OAI/NumberTheory/Catalan` (981 files) + `OAI/NumberTheory/ZetaFive` (7 files) = **988 OAI Lean files**, import-closure validated (every `import OAI.*` resolves to a vendored source)
- **Extra dependency:** PrimeNumberTheoremAnd, `https://github.com/AlexKontorovich/PrimeNumberTheoremAnd.git` @ `c39a751132c88b6e8080b74c74023fd95b3d8be0`, with patch `lean/patches/PrimeNumberTheoremAnd-lean4341.patch` (the "local changes" warning in the audit log is this applied patch — expected)
- **Build root:** `OAI.NumberTheory.Catalan.Main`
- **Toolchain:** `leanprover/lean4:v4.34.1`
- **mathlib pin:** `d13f23b723b8a846827a245b89c10fc7d3f11612`

## Run

- **Date:** 2026-10-09
- **Workflow:** `.github/workflows/oai-family-forge.yml` (parameterized one-dispatch forge)
- **Repo commit:** `chokmah-me/fragile-proof-audit` @ `7355ef4` (main)
- **Run:** https://github.com/chokmah-me/fragile-proof-audit/actions/runs/37963519628
- **Runner:** GitHub-hosted (fresh, independent of the auditing VM and the WSL runner)
- **Duration:** ~1h03m
- **Steps:** all 17 green — dependency pin, patch, cache, vendoring, import-closure check, full build, axiom audit, fail-closed verdict, evidence upload

## Axiom result

Exact `#print axioms` output from the run:

```
'import OAI.NumberTheory.Catalan.Main'
'#print axioms OAI.InternalCatalan.catalan_irrational'
'OAI.InternalCatalan.catalan_irrational' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Allowed:** propext, Classical.choice, Quot.sound. **Found:** exactly those three. No `sorry`, no `admit`, no `native_decide`, no extra axioms.

## Verdict

**PASS** — the full 988-file build completed green on an independent machine, and the headline theorem depends only on the three approved axioms. Scoped strictly to what ran: family 005 at the pinned revision above. No claim is made about any other family, revision, or theorem.
