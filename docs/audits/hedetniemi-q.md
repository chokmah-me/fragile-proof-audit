# Audit note — quantum Hedetniemi (Zeiss arXiv:2609.20690)

**Date:** 2026-09-20  
**Artifact:** GitHub `JuliusAZeiss/Lean-Verification-and-More-Quantum-Hedetniemi-conjecture`  
**Commit:** `95c0ac05e9b7ea50b827ec491661eed2ed0147b4`  
**PDF:** `incoming/hedetniemi-2609.20690.pdf` sha256
`1b307f781029ab9d6f263857528a7a770b35a968037b387b838a1770e6cad316`  
**Author toolchain:** `leanprover/lean4:v4.19.0` · mathlib
`c44e0c8ee63ca166450922a373c7409c5d26b00b`  
**Campaign pin (contrast):** `v4.32.2`  
**Scanner:** `scripts/forge/axiom_audit.py` → `results/hedetniemi_q_audit_meta.json`

## Verdict (route, not theorem)

This is a **claimed disproof of a false conjecture**, already equipped with
Lean and exact-integer certificates. The campaign audit is statement
fidelity + replay of the author’s finite checks. It does **not** add a
campaign BREAK/PASS to the eight-gate lock.

Quantum Hedetniemi remains a theorem-of-the-paper claim until an independent
kernel check of *their* lake project is recorded. Source scan and Python
certificates are consistent with the paper as advertised.

## Finite certificates (executed 2026-09-20, stdlib only)

| Command | Result |
|---|---|
| `python numerics/check_base_graph.py` | ALL CHECKS PASSED (Lemma 8, eq. (13), \(c=1538\), \(\|V(G)\|=524288\), \(\|V(H)\|=1576451\), \(k\ge 1639\)) |
| `python numerics/check_appendix_certificate.py` | ALL CHECKS PASSED (Appendix A \(M_0\succeq 0\) via diagonal dominance) |
| `python numerics/compare_lean_data.py` | ALL CHECKS PASSED (Lean integer literals = JSON) |
| `python data/verify_regular.py` | `INTEGER_CHECKS_PASSED` (6 rejection tests) |
| `python data/verify.py` | `EXACT FINITE CERTIFICATE VERIFIED` (tamper tests listed in stdout) |
| `python lean/check.py --check-sources` | `SOURCES_CHECKED: 371 sources, exact import closure` |

## Source forge

`axiom_audit.py` on the clone: **382** `.lean` files (baseline `lean/` plus
`lean_extension/`). Hit counts for `sorry` / `admit` / `axiom` /
`native_decide` / `opaque` / `constant`: **none**. `import Mathlib` present.

Headline declarations exist where `THEOREM_MAP.md` says they do, including
`regular_quantum_counterexample` and `regular_cstar_counterexample` in
`lean_extension/Hedetniemi/Expository/RegularCounterexample.lean`.

This is a **source catalog**, not a kernel check. Operator follow-up in
*their* tree (Lean 4.19.0 already installed this session; mathlib cache
fetched, 6641 files): `python lean/check.py`. `lake build Hedetniemi` fails
because there is no `Hedetniemi.lean` root file — the author’s checker
compiles the 371-source import closure itself. Kernel status remains
**UNKNOWN** until that checker is run.

## Statement fidelity

| Check | Result |
|---|---|
| Paper claims Lean 4 projective formulation | Yes (abstract + §1) |
| Clone contains `ProjectiveColoring` / `QuantumColorable` / `CStarColorable` | Yes (`lean/Hedetniemi/Model.lean`) |
| Main example orders match Python | Yes: 524288 / 1576451 / 1538 / 1539 |
| Campaign pin used | **No** — 4.19.0 vs 4.32.2 |

## Discrimination

`data/verify.py` already ships tamper/rejection tests (wrong generator,
corrupted Gram factor, missing strict separation, …). No extra campaign
control in this pass.

## Do not claim

- That FragileProofAudit proved the quantum Hedetniemi conjecture false.
- That their Lean is kernel-checked under `v4.32.2`.
- That the Gemini MD’s 45 s homomorphism search was run.
