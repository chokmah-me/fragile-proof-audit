# Family receipts — independent axiom audits of openai/math Lean families

## What is this, in plain English?

OpenAI published hundreds of "machine-checked" math proofs, but nobody ever
independently re-ran them — a proof that doesn't build on anyone else's machine
isn't much of a proof. This pipeline rebuilds each one from scratch on an
independent computer and issues a receipt: yes, it built, and here are the exact
foundational assumptions it depends on. It's reproducibility, but for proofs.

Each receipt records an independent machine build of one openai/math family's
Lean formalization on a machine separate from the auditing VM, with the exact
`#print axioms` output for the family's headline theorem. Verdicts are
fail-closed PASS/FAIL, scoped strictly to the pinned revision that ran.

| Family | Claim | Verdict | Axioms | Run | Receipt |
|---|---|---|---|---|---|
| 005 — Catalan | `OAI.InternalCatalan.catalan_irrational` (irrationality of Catalan's constant) | PASS | propext, Classical.choice, Quot.sound | [37963519628](https://github.com/chokmah-me/fragile-proof-audit/actions/runs/37963519628) (2026-10-09, `oai-family-forge.yml` @ `7355ef4`, 988 files) | [005-catalan.md](005-catalan.md) |
| 237 — Honeycomb | `OAI.HoneycombForce.logPartition_tendsto` | PASS | propext, Classical.choice, Quot.sound | [37647725873](https://github.com/chokmah-me/fragile-proof-audit/actions/runs/37647725873) (2026-10-07, `oai-honeycomb-forge` @ `e16a378`, openai/math `adc7f12`, 2 files) | [237-honeycomb.md](237-honeycomb.md) |

## Method

- The family forge (`.github/workflows/oai-family-forge.yml`) vendors the family's
  Lean sources from a pinned openai/math revision onto a fresh GitHub-hosted
  runner, validates the import closure, builds the full tree, runs
  `#print axioms` on the headline theorem, and renders a fail-closed verdict.
- One dispatch per family; inputs are the family id, subdirectories, extra
  dependencies, and the headline theorem.
- No receipt is posted to any catalog or forum without a separate instruction.
