# Input pin — OpenAI ETH-disproof formalization (openai/math, SubexponentialSAT)

Pinned 2026-10-27. Source: Feed unit f1904cf3 (OpenAI
2026-10-26 announcement); opened at the user's "execute
now" 2026-10-27 03:54 EDT. Scope of the pick: **V-A, the
runner build and axiom audit of the 3,977-file solution
module at the repo pin; V-B, statement fidelity of the
exact-count-and-SAT theorem against the challenge
statement, with the twin-definition seam settled by a
challenge-env vs solution-env #print corpus** — the
accompanying natural-language manuscript is out of scope,
as are the sibling claims (local smoothing, Yang-Mills).
The verdict lock is not touched. No author contact.

## The claim

- OpenAI, 2026-10-26 announcement: a model-produced
  subexponential-time algorithm exactly counting satisfying
  assignments of bounded-width CNF and deciding SAT,
  formalized in Lean; the k = 3 decision content refutes
  the Exponential Time Hypothesis. Shepherds Impagliazzo,
  Paturi, Williams explicitly not certifying; OpenAI seeks
  no academic credit.

## The code

- Repo: github.com/openai/math @
  `7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a` (head ==
  origin head at run time).
- Challenge: `lean/ComparatorChallenges/SubexponentialSAT.lean`
  (+ `.json`): solution module
  `OAI.Algorithms.SubexponentialSAT.Main`, theorem
  `OAI.Algorithms.SubexponentialSAT.SqrtLogSpace.exact_count_and_sat`,
  permitted axioms = classical three.
- Solution module: `lean/OAI/Algorithms/SubexponentialSAT/`,
  3,977 `.lean` files, 710,320 lines, 42 MB; theorem proved
  in `SqrtLogSpace/Final.lean`; `LeanCompat.lean` (imported
  by 3,646 files) is just `import Mathlib`.
- Toolchain `leanprover/lean4:v4.34.1` (Lean 4.34.1,
  commit 5045d0056413266e57c625dcd7c365b10e377c52);
  Mathlib rev `d13f23b723b8a846827a245b89c10fc7d3f11612`;
  42 manifest packages (ETH closure is OAI + Mathlib only).
- Forge evidence zip sha256
  `a657b28a1e3e23bc695461f82235665c7a0ae676d11147cccbad872a22bd1a23`
  (49.8 KB, run page digest, re-verified locally).
- Forge run 40507873397 (laptop lane, dell-laptop),
  verdict=PASS; earlier runs #1 (probe bug, 4s) and #2
  (runner comms loss, 1h 43m) produced no verdict.
- Working copies and evidence: `~/workspace/eth-recon/`
  (`RECON-BRIEF.md`, `evidence-run-40507873397/`),
  `~/workspace/oai-claims-recon/PREP.md`.
