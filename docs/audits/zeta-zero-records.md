# Audit note — zeta-zero records in Lean 4 (arXiv:2610.08965, 2026-10-12)

**Claim artifact:** Kristian Muri Knausgård, *More than 83.9% of the zeros of
the Riemann zeta function are distinct and more than 67.35% are simple and on
the critical line* (arXiv:2610.08965, announced 2026-10-06). Six theorems in
Lean 4: ≥83.900% distinct zeros, ≥67.801% simple zeros, ≥67.354% simple zeros
on the critical line, plus two further bounds and six ceiling propositions.
The paper is explicit that it is "an experiment in AI-assisted mathematical
research" and discloses its full trust boundary (three computation axioms).
**Harvest item:** zeta-zero-2610-08965 (shortlist rank 1, 2026-10-12 run).
**Campaign objects:** `incoming/zeta-zero-2610-08965/` (paper source,
`PIN.md`, full repo clone).

**Repo pin:** https://github.com/kristianmk/839 @
`b280d51bef5ab32b3280b0955d040085ed522d59` (2026-10-09, "Add link").
Upstream library: anthropics/formal-math `zeta23/` @
`fbdc36bbf17d20af3fd0447c6d1a8a02773c9844`, Lean `v4.33.0-rc2`, Mathlib
`51e6992efd06126df61a496bebf8f49482a4e129` (all per the author's
`lean/README.md`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge`, `computational-claim-gate` · run date `2026-10-12`.

**Status:** CLOSED 2026-10-13 — verdict **PASS** (standalone verify/audit;
the 32-gate verdict lock is untouched). Closure evidence: the full WSL
replay recorded in the Receipt.

## M1 — statement correspondence: PASS

The six `Challenge*.lean` files state the theorems from Mathlib alone (with
`sorry` by design). The exact rational constants were verified against the
paper's claimed decimal bounds:

| Theorem | Formal constant | Value | Paper claim |
|---|---|---|---|
| `distinct_zeros_839` | 1645064/1960733 | 0.8390046… | > 0.839 |
| `simple_zeros_678` | 1329395/1960733 | 0.6780092… | > 0.678 |
| `simple_critical_zeros_673` | 1669159/2478195 | 0.6735382… | > 0.6735 |
| `average_simple_and_critical_8367` | 2073677/2478195 | 0.8367691… | > 0.8367 |
| `simple_or_critical_8891` | 3376433/3797325 | 0.8891609… | > 0.8891 |
| `simple_or_critical_8893` | 50652159/56956375 | 0.8893150… | > 0.8893 |

Every constant strictly exceeds the paper's headline bound. The counting
functions (`Ncount`, `Ndist`, `Nsimple`, `N0simple`, …) are defined in the
Challenge files from Mathlib's `riemannZeta` as the README describes. The
mechanical statement-fidelity check (`scripts/make_compare.py` +
`scripts/Compare*.lean`, which replaces each Challenge `sorry` with the
Solution theorem of the same name) was re-run on the WSL replay: all five
Compare scripts compiled, and every `Chal.*` axiom listing matches the
author's recorded listing exactly (see Receipt).

## M2 — argument correspondence: PASS (modulo the disclosed computations)

The proof architecture mirrors the paper exactly, and each file documents its
own trust role in its header:

- `Distinct839/Local/Checker.lean` (471 lines): the executable
  branch-and-bound checker. Imports nothing (core Lean only), all arithmetic
  in `Nat`, compiled to native code. Header states it implements "the same
  tests in the same order" as the reference verifiers.
- `Distinct839/Local/Soundness.lean`: `localInequality_of_check` — if the
  checker returns `true` on a sound table, the local inequality holds.
  Proved with the standard axioms only (kernel-checked; see below).
- `Distinct839/Kernel/Table.lean`: `kTabArray_sound` — the kernel table is a
  sound lower enclosure of `K²`, proved with the standard axioms only.
- `Distinct839/Local/FinalAll.lean`: `localInequality` is exactly
  `localInequality_of_check kTabArray kTabArray_size kTabArray_sound
  Local.check_passes` — the three kernel-checked premises plus the single
  computation axiom. The file header says so verbatim.

The same three-layer pattern (checker / soundness / table, then one
`native_decide` evaluation) is used for all three searches. No `sorry` in
any proof file (verified by scan; `sorry` occurs only in the five
`Challenge*.lean` statement files, by design). No manual `axiom`
declarations in the author's developments; the two `axiom` declarations in
the upstream library (`Zeta23/FromPNTPlus/Tactic/AdditiveCombination.lean`,
tactic test scaffolding: `qc : ℚ`, `hqc : qc = 2*qc`) are outside the
theorems' dependency closure — confirmed independently by the WSL axiom
re-run: neither appears in any listing (see Receipt).

## M3 — credit honesty: PASS

The paper and the repo disclose everything the audit looked for: the three
computation axioms are named in the abstract ("The proofs use three axioms
beyond those of Mathlib, one per inequality. Each records that a search
program returned true"); the `upstream_relax.patch` (14 files, relaxing two
window-machinery constants) is documented with an explicit statement of what
it can and cannot affect; the AI assistance (Claude, Codex) is credited in
the source files; the upstream `zeta23` library is pinned by commit with its
licence (Apache-2.0) noted.

## What was run

| Check | Result |
|---|---|
| Repo pin + `CHECKSUMS.sha256` | **all OK** except top-level `README.md` — the pinned commit `b280d51` ("Add link") adds one alphaxiv hyperlink to the README after the checksums were generated; no code or data touched |
| `sorry` / `admit` scan over all proof files | **zero** (only the five `Challenge*.lean` statement files, by design) |
| Manual `axiom` scan over the author's developments | **zero** |
| Six formal constants vs paper bounds | **all six strictly exceed** the claimed decimals (table above) |
| Axiom structure (source read) | exactly three `native_decide` axioms, with the exact statements the paper claims: `checkAll kTabArray = true` (×2), `checkAllPar kTabArray 32 96 = true` (×1) |
| C++ reference verifier rebuilt from source and re-run on certificate 1 | **PASS** — `PASS_COB_CONTINUUM`, 60,467,309 boxes / 30,233,655 accepted, byte-identical to the author's `cpp_verification.json` |
| Lean build: 205 library modules (everything not needing the search) | **stopped at 8708/8719** on the VM (reboot cut the logged run, no EXIT marker) — partial receipt, superseded by the WSL replay |
| Full build + three `native_decide` evaluations + axiom-audit re-run | **COMPLETED — success**, WSL run `38311097053` (2026-10-12 21:30 UTC → 2026-10-13 05:46 UTC): searches re-executed (3,740 s / 9,396 s / 11,569 s), developments + all three kernel spot checks built, axiom audit + Compare re-run; evidence artifact read in full (see Receipt) |

## Honest scope

- The three `native_decide` search evaluations (7 GB / 11 GB / 7 GB per the
  author's README) cannot run on the agent VM (7 GB total RAM), so they were
  re-executed on the WSL runner (32 GB): all three `RunAll` builds completed
  successfully. They remain the precise, disclosed trust assumption — "This
  trusts the Lean compiler, interpreter and runtime for these three
  computations" (paper §8). The replay re-executes them under that same
  assumption; it does not convert them into kernel checks. The independent
  C++ re-run corroborates the first search's outcome.
- The kernel-evaluated spot checks (`Local/SpotChecks.lean`, `decide
  +kernel`, 10–12 GB each) likewise exceed the VM; all three were built on
  the WSL run (112 s / 125 s / 70 s).
- The author's `axioms.txt` (2026-10-06) is no longer taken on trust: the
  independent re-run's listings are content-identical to it (see Receipt).
- Certificates 2 and 3 were not re-run through the C++ verifier (~9× the
  work of certificate 1 each). The Lean searches they correspond to were
  re-executed directly on the WSL run, which is what the theorems depend
  on; the independent C++ cross-check remains certificate-1-only. This is
  the audit's one residual gap — a cross-check gap, not a gap in the Lean
  evidence.
- The VM Lean partial build stopped at 8708/8719 and was not resumed: the
  WSL replay covers the full dependency closure, including every module
  the VM run did not reach.

## Receipt

Inputs: `incoming/zeta-zero-2610-08965/PIN.md` (repo SHA
`b280d51bef5ab32b3280b0955d040085ed522d59`, upstream
`fbdc36bbf17d20af3fd0447c6d1a8a02773c9844`) and `CHECKSUMS.sha256`. VM
partials (2026-10-12): the M1/M2/M3 source checks above; independent C++
certificate-1 re-run PASS — `~/workspace/zeta-verify-build/verify-cert1.log`
(`PASS_COB_CONTINUUM`, 60,467,309 boxes examined / 30,233,655 accepted,
matching the author's `certificate/cpp_verification.json` exactly); VM Lean
build log `~/workspace/zeta-verify-build/vm-build.log` (stopped at
8708/8719, no EXIT marker). WSL full replay: `zeta-zero-verify` run
`38311097053` (workflow @ `8f2fcab`), conclusion **success**; evidence
artifact `zeta-zero-verify-evidence` (14,429 bytes) downloaded and read in
full (copy under `~/workspace/zeta-verify-build/wsl-evidence/`): all three
`RunAll` logs end "Build completed successfully"; the solutions log
completes with only the by-design Challenge `sorry` warnings; all three
SpotChecks logs complete; `zeta-axioms.txt` together with
`zeta-compare.log` is content-identical to the author's `lean/axioms.txt` —
the recorded `zeta-axioms.diff` consists solely of the author's
hand-written header preamble, blank lines between sections, and the
workflow's split of the PrintAxioms and Compare halves into two files;
**zero axiom lines differ**, and neither upstream `qc`/`hqc` appears
anywhere. Not covered: C++ verifier re-runs of certificates 2 and 3; the
three `native_decide` evaluations are trusted computation by design
(author-disclosed), re-executed here but not kernel-checked.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone verify/audit verdict:
**PASS** — every checkable claim confirmed, no discrepancy found; the one
residual gap (C++ cross-check of certificates 2 and 3) is named in Honest
scope. Audit closed 2026-10-13.
