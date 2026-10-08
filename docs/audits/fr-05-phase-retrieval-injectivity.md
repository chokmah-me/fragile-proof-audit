# Audit note — FR-05 phase-retrieval injectivity, Lean formalization (2026-09-29)

**Claim artifact:** Zhangsong Li, *Resolution of Vinzant's Conjecture on
Phase Retrieval Injectivity* (13 September 2026), the FR-05 entry of
`ajt60gaibb/OpenProblemsInNLA`: for iid standard complex-Gaussian frames
with `N = 4d − 5` measurements, all-signals phase-retrieval injectivity
satisfies `p_d ≤ C/d` (`d ≥ 2`), hence `p_d → 0`.
**Harvest item:** `fr-05-phase-retrieval-injectivity`.
**Campaign objects:** `results/fr_05_phase_retrieval_gate_meta.json`;
working copies at `~/workspace/phase-retrieval-audit/`
(tarball of the repo at the pinned commit, not committed).

**Repo pin:** https://github.com/ajt60gaibb/OpenProblemsInNLA @
`80c0e3e638b2f26dcb3a00353651fc3d2215dd65` (fetched 2026-09-29 via
GitHub API tarball, ~482.7 MB; the extracted tree carries no local git
history). Published problem IDs are permanent and were not renumbered.

**Dependency pins (all verified in place):** Lean
`leanprover/lean4:v4.33.1` (via elan), mathlib
`0df444a360eaa60ab8c11dca51a86af692955474`, plus 8 further packages at
`lake-manifest.json` revisions. `lake update` EXIT 0; 8,689 cached files
decompressed.

**Agent provenance (reconstructed):** Muse (Meta) · model `Muse Spark 1.3` · run date `2026-09-29` · added before the harness-pinning policy (2026-10-08); the verdict rests on pinned artifacts, independent of the agent transcript.

## Verdict: PASS (verify/audit)

## What was run

| Check | Result |
|---|---|
| Full `lake build` (Lean 4.33.1, pinned deps) | **BUILD_EXIT 0**, 3,344 jobs, zero warnings/errors |
| Fresh axiom audit: independent `lake env lean` run of `#print axioms` on the three exported theorems | all ⊆ {`propext`, `Classical.choice`, `Quot.sound`} |
| Build-log axiom sweep: all 17 `#print axioms` reports in `Solution.lean` | all exactly the standard triple, zero `sorryAx` |
| Placeholder scan: `sorry` over `NLA/FR05/` and `Solution.lean` | **none found**; the 4 intentional `sorry`s in `Challenge.lean` are outside `Solution`'s import closure (nothing in `NLA/` or `Solution.lean` imports it) |
| Teeth: `audit/axiom_audit.py` on `audit/fixture_corrupt.lean` (theorem depending on a custom axiom) | **correctly rejected**, EXIT 1, "non-standard axioms ['myEvilAxiom']" |
| Source hash | `sources/injectivity_phase_retrieval.pdf` SHA-256 `d1be40e7…97254` matches `SOURCE_FREEZE.md` |
| Statement inspection | `N = 4M − 5`; iid standard complex Gaussian entries (real/imag coordinates `N(0,1/2)`); injectivity modulo global phase; all-signals predicate — matches the manuscript and Lean boundary |

**Exported theorems** (`NLA.FR05`, `Solution.lean`):
`phaseRetrieval_probability_le_planted_add_sqrt`,
`phaseRetrieval_injective_probability_le_inv` (`∃ C, 0 < C ∧ ∀ d ≥ 2,
p_d ≤ C / d`),
`phaseRetrieval_injective_probability_tendsto_zero` (`p_d → 0` at
`4d − 5` measurements).

## Honest scope

- This audit rebuilt the formalization from the pinned tarball on this VM;
  it does **not** re-derive the paper's hand proof — the Lean kernel
  checked the formalized proof, and the audit verified the statements say
  what the paper claims. An independent formal statement review was not
  obtained.
- The audit covers `Solution.lean` and its `NLA.FR05` import closure;
  `Challenge.lean` (4 intentional `sorry`s) is a separate lib target and
  is not part of the claim artifact.
- Several build modules take 15–45 minutes each
  (`LikelihoodComparison` 2,795 s); the full build survived multiple VM
  reboots by resuming from cached oleans.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). This is a standalone verify/audit
PASS, recorded the same way as the other harvest targets — target 8 of 9.
