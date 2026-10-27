# Input pin — Anthropic / Claude ETH formalization (anthropics/formal-math, eth/)

Pinned 2026-10-27. Source: fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
anthropic-claude-3sat-subexponential-eth, recon fragility 3,
issue #12); picked at the user's tap 2026-10-27 for the cheap
build and the direct A/B against the OpenAI ETH audit (CLOSED
PASS 2026-10-27). Scope of the pick: **V-A, the runner build
and axiom audit of the 1,052-file `eth/` Lake project at the
repo pin; V-B, statement fidelity of the two theorems
(MainResults.ethIsFalse, MainResults.mainTheorem) against the
shared statement file, settled by a three-environment #print
corpus (MainResults env vs Challenge env vs Solution env)** —
the accompanying natural-language paper is out of scope except
its Appendix E declared-differences inventory, which is
recorded. The repo's own Comparator/nanoda check is not run
(needs go/cargo tool builds on the runner); the corpus + axiom
audit is the transparent equivalent for statement identity, as
in the OpenAI ETH audit. The verdict lock is not touched. No
author contact.

## The claim

- Anthropic, 2026-10-27 release: a deterministic algorithm
  decides 3-SAT in 2^o(n) time and counts satisfying assignments
  (#3-SAT) in 2^O(n log log n / sqrt(log n)), refuting the
  Exponential Time Hypothesis; purely asymptotic (beats brute
  force only past 10^108 variables). Paper provenance: the core
  algorithm was found on October 16 by an internal Claude
  research model with 14M output tokens and no human input;
  the Lean formalization was written by AI models. Distinct
  claimant from OpenAI's ETH disproof (audited PASS
  2026-10-27); both labs date the discovery to Oct 16 —
  independence is recorded, not adjudicated.

## The code

- Repo: github.com/anthropics/formal-math @
  `16a5ce41304fcdaea4e0be7c132e1c361dc26da5`. Project folder
  `eth/`: 1,052 `.lean` files, 152,420 lines.
- Statement file `eth/MainResults.lean` sha256
  `47f78a9550d95b37d8718dd1ee16ae824da893a5e17c319f737e6d0a5ed24944`
  (definitions only, imports Mathlib alone);
  `eth/Challenge.lean` sha256
  `63f54edafad0b4d1a4184c6279dc2fea4d8b3a6ef39fa04ab7fa72e86bfbb39e`
  (both theorems restated with sorry);
  `eth/Solution.lean` sha256
  `27d304798a6ec294db7fdeee301227b70d72044cb31c85615901a8d728b0b98f`
  (both theorems proved at the same types);
  `eth/comparator.json` sha256
  `757e5537ccf47d1946521b0b5fb91a230cdcfd8933dc9ab047710709c15ffa7e`
  (permitted axioms = classical three, nanoda enabled);
  `eth/paper.pdf` sha256
  `7af518b09342c967ea371c74b8989806684c5d02aabe5763ca08554aff5025a0`
  (49 pp, author "Claude"; also Hexagon 2610.00577).
- Toolchain `leanprover/lean4:v4.33.1`; Mathlib rev
  `0df444a360eaa60ab8c11dca51a86af692955474` (v4.33.1), pinned
  in both lakefile.toml and lake-manifest.json.
- Local recon scan at the pin (comment-stripped): 1,052 files,
  exactly 2 sorry hits (both in Challenge.lean, the statements
  by design), 0 escape hits (no native_decide, @[extern,
  implemented_by, ofReduceBool, partial def, unsafe).
- Working copies and recon: `~/workspace/anthropic-eth-recon/`
  (`RECON-BRIEF.md`, extracted source under `src/eth/`).
- Forge evidence zip sha256
  `3bfe1e87b39238a448c52e079b316c3dd973dc4b332a98f980fd3dcb9fcbf6a4`
  (23,176 bytes, run-page digest, re-verified locally).
- Forge run 40558969722 (desktop lane, DESKTOP-7HDI2D1),
  verdict=PASS; audit CLOSED PASS 2026-10-27, note at
  `docs/audits/anthropic-eth.md`; evidence in
  `~/workspace/anthropic-eth-recon/evidence-run-40558969722/`,
  DEEPEN pass in `~/workspace/anthropic-eth-recon/DEEPEN.md`.
