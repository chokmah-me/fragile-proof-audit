# Audit note — Anthropic / Claude ETH formalization (anthropics/formal-math, eth/)

**Claim artifact:** Anthropic's 2026-10-27 release of a Lean
formalization, in github.com/anthropics/formal-math (project
folder `eth/`), of a subexponential-time 3-SAT algorithm from
the paper *A 2^o(n) Time Algorithm for 3-SAT* (Hexagon
2610.00577, paper dated 2026-10-26, author "Claude"). The
formalized theorems are `MainResults.ethIsFalse` (the
Exponential Time Hypothesis is false: `¬ (0 < s 3)`) and
`MainResults.mainTheorem` (one FinTM2 machine and one constant
C counting the satisfying assignments of every k-CNF in the
stated ranges within
2^{C·min{km/√(log m), k²n·log log n/√(log n)}} steps).
Headline: a deterministic algorithm decides 3-SAT in 2^o(n)
time and counts satisfying assignments (#3-SAT) in
2^O(n log log n / √(log n)), refuting ETH; purely asymptotic
(beats brute force only past 10^108 variables, per the claim).
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
anthropic-claude-3sat-subexponential-eth, recon fragility 3,
issue #12); picked at the user's tap 2026-10-27 for the cheap
build and the direct A/B against the OpenAI ETH audit (CLOSED
PASS 2026-10-27).
**Campaign objects:** `incoming/anthropic-eth/PIN.md`.
**Pinned sources:** anthropics/formal-math @
`16a5ce41304fcdaea4e0be7c132e1c361dc26da5` (head == origin
head at run time); toolchain `leanprover/lean4:v4.33.1`
(Lean 4.33.1, commit 819816b2e0a3bf405af45ae5c7af2491d8f5bee6);
Mathlib rev `0df444a360eaa60ab8c11dca51a86af692955474`;
forge evidence zip sha256
`3bfe1e87b39238a448c52e079b316c3dd973dc4b332a98f980fd3dcb9fcbf6a4`.
Evidence in `~/workspace/anthropic-eth-recon/`
(`RECON-BRIEF.md`, `DEEPEN.md`,
`evidence-run-40558969722/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-27` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: a direct read of what the
statement architecture actually does); the pre-verdict
deepening was a DEEPEN challenge pass (below), run after
independent re-verification of the evidence.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T19:35:10Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (build + axioms at the pin): PASS.** Forge run
  40558969722 on DESKTOP-7HDI2D1 (desktop lane), details
  below. The 1,052-file `eth/` project builds at Lean 4.33.1
  + Mathlib 0df444a3, and both theorems depend on exactly
  the classical three axioms.
- **V-B (statement fidelity, M1): PASS.** The statements
  were read in full at recon. Challenge and Solution share
  one statement file by construction (no twin-definition
  seam, contrast the OpenAI audit), and the three-environment
  corpus is the mechanical receipt that both environments
  print the same definitions and theorem types.
- **Scope (not a GAP in the audited claim):** the
  accompanying natural-language paper was not audited; this
  audit covers the Lean formalization and its statement,
  plus the paper's Appendix E declared-differences
  inventory, which is recorded in M4. The repo's own
  Comparator/nanoda check was not run (its tool builds,
  go/cargo, are absent on the runner; the probe records
  tool_go=no, tool_cargo=no); the corpus + axiom audit
  checks the same two properties the comparator checks
  (theorem-type identity, axiom footprint) directly, but
  it is not an independent kernel replay: verification
  trusts the standard Lean 4.33.1 kernel via `lake build`,
  without nanoda's external re-checking of exported proof
  terms or landrun sandboxing, as in the OpenAI ETH audit.

## M1 — one shared statement file

`MainResults.lean` (182 lines, definitions only, imports
Mathlib alone) defines all 21 statement components (Lit,
CNF, IsKCNF, slot, Satisfiable, encClauses, DecidesKSat,
InTime, s, ETH, ETHIsFalse, AllOccur, numSat, binary,
encInput, lg, expM, expN, timeMin, CountsWithin,
MainTheorem). `Challenge.lean` imports MainResults alone and
restates both theorems with sorry. `Solution.lean` imports
MainResults plus the proof libraries and proves both
theorems at the same types, so the kernel itself checks the
proofs against the shared proposition types; there are no
twin definitions to drift. The forge still settles it
mechanically: three environments (A importing Challenge, B
importing Solution, C importing MainResults alone) print all
21 definitions, with a `#check` of both theorems in A and B
only (the theorems do not exist in C). After whitespace
normalization the corpora agree exactly (receipt below).
The load-bearing definitions, verbatim in substance:
`encClauses k φ` is `List.replicate n true ++ false ::`
the clauses' slot numbers written as bit strings
(`slot`: 0 for an empty position, 2i+1 for ¬xᵢ, 2i+2 for
xᵢ, each in `Nat.log2 (2n)+1` bits); `encInput k φ` is
`List.replicate k true ++ false :: encClauses k φ`;
`s k` is the infimum over δ of `InTime k δ` (a machine
deciding k-SAT within ⌊c·2^{δn}⌋ steps), `ETH` is
`0 < s 3`, and `ETHIsFalse` is its negation. Both
encodings are fixed syntactic transcriptions with no
computational content, read at recon; the step counter
that the theorems bound counts machine steps on these
encodings, so no work is hidden in the encoding layer.

## M2 — what the proof establishes

The Lean kernel checks the 1,052-file, 152,420-line
development ending in the two theorems of `Solution.lean`.
The audit verifies that a kernel-checked proof of exactly
this statement exists at the pin, with the classical-three
axiom footprint. It does not human-read the development and
does not re-derive the algorithm. Route label, from the
paper's Appendix E: the proof follows the printed route of
Corollary 11, with cost counted internally in operations of
a query machine and rendered later as a padding-string
budget; the authors' own strictest AI reviewers count it
"a different proof of the same statement, along the printed
route". The Lean statement is the algorithm claim, and the
statement's own definitions govern what was proved.

## M3 — credit honesty

The claim is Anthropic's release. Per the paper, the core
algorithm was found on October 16, 2026 by an internal
Claude research model with 14M output tokens and no human
input, and the Lean formalization was written by AI models;
Appendix E adds that it was reviewed by other instances of
the same models and that "no person is known to have
checked it". This note attributes the claim to Anthropic's
release and to nothing else, and credits none of the
authors' unrun-by-us declarations (full from-scratch build,
leanchecker replay, Comparator acceptance) beyond what the
forge receipt itself shows. The OpenAI ETH-disproof claim
(audited CLOSED PASS 2026-10-27) is a distinct claim by a
distinct claimant of the same theorem; both labs date the
discovery to October 16, 2026. Independence is not
auditable from the artifacts and is recorded, not
adjudicated.

## M4 — fine-print assumption inventory

Declared differences between the paper's printed statement
and the formalized one (paper Appendix E, the authors' own
inventory):

- The Lean names the O(·) constant explicitly (one C,
  chosen before k; its value is not given) and makes the
  ranges k ≥ 1, m ≥ 2, n ≥ 4 explicit for all instances,
  where the printed Main Theorem's O(·) speaks only of
  large enough m, n.
- Time model: the paper counts word-RAM operations; the
  Lean counts FinTM2 steps (Mathlib's `Turing.FinTM2`, one
  step = run to the next goto/halt, bounded stack work for
  a fixed machine), input reading included. The two
  bridging steps (formula → input word in polynomial time;
  FinTM2 simulated on a word RAM at bounded ops per step)
  are NOT part of the Lean proof, by the authors' own
  statement; the polynomial-below-the-bound part IS proved
  in Lean. The audit does not certify the bridge.
- Clauses: the paper's are nonempty sets; the Lean's are
  lists (a clause may be empty, may repeat a literal, order
  matters); formulas are lists with no clause repeated.
- The machine model is Mathlib's, not a claimant-built one
  (contrast the OpenAI audit's custom PrimitiveMachine);
  the definitional questions sit in Mathlib's FinTM2 and
  in the bridging steps above, both recorded here.
- The repo's own comparator tool (lean4export + nanoda +
  landrun) was not run; see the scope line above.
  comparator.json pins permitted_axioms to the classical
  three, which is exactly the footprint the axiom audit
  found.

## DEEPEN — pre-verdict pass

Run 2026-10-27 (full text in `~/workspace/anthropic-eth-recon/
DEEPEN.md`), after independent re-verification and before
this note was written. Alternatives considered: V-B PARTIAL
for not running the repo's Comparator/nanoda CI (rejected:
same scope line as the OpenAI audit, and the two properties
the comparator checks, theorem-type identity and the axiom
footprint, are checked directly here); one combined verdict
(rejected at the pick); treating the Appendix E bridging
steps as a GAP in the claim (rejected: they are outside the
formalized statement and author-declared; grading them would
grade the paper, which is outside the formal verification
scope of this audit). The pass
also confirmed the verdict file's 195 s "clock skew" is the
elapsed time between the probe and post-cache clock reads,
not a clock error (probe: NTP synchronized), and that it
does not gate the verdict. Nothing in the pass moved a
verdict or added a finding.

## Receipt

- Forge: anthropic-eth-forge run 40558969722, desktop lane
  on DESKTOP-7HDI2D1 (probe: 8 vCPU, 27 GiB, NTP
  synchronized), manually triggered 2026-10-27 14:19 EDT
  on fragile-proof-audit main@ba04248, completed success
  15:06:44 EDT, run duration 46m 48s. Run:
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40558969722
  Job:
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40558969722/job/122382535086
- Build: `lake build` (all default targets) exit 0 in
  2,306 s, 9,768 jobs, "Build completed successfully"; the
  only sorry warnings are Challenge.lean:12 and :16, the
  two challenge statements by design. Mathlib cache exit
  0, 8,702 oleans.
- Scans (comment-stripped): total 1,052 files, 2 sorry
  hits, 0 escape hits; module 1,051 files, 0 sorry, 0
  escapes; challenge 1 file, exactly 2 sorry hits (the two
  statements, by design), 0 escapes. No `native_decide`,
  `@[extern`, `implemented_by`, `ofReduceBool`,
  `partial def`, or `unsafe` anywhere in the project.
- File hashes at the pin (in-run sha256) match the PIN on
  all five key files: MainResults.lean 47f78a95…,
  Challenge.lean 63f54eda…, Solution.lean 27d30479…,
  comparator.json 757e5537…, paper.pdf 7af518b0….
- Corpus: challenge-env log == solution-env log after the
  classifier's whitespace-stripped normalization, 2,471
  chars each; both minus the two theorem `#check` lines ==
  the statements-only log, 2,379 chars; all three env
  exits 0.
- Axioms (the repo's own `scripts/PrintAxioms.lean`,
  solution env): `MainResults.ethIsFalse` and
  `MainResults.mainTheorem` each depend on exactly
  [propext, Classical.choice, Quot.sound]; no sorryAx, no
  native_decide, no ofReduceBool. The script itself is
  two genuine `#print axioms` commands and nothing else
  (full text inspected post-verdict, 2026-10-27, sha256
  `2cee91aad13365865fbf239db74c3a05588d6721717d94720674bb260cfe2406`);
  its output is kernel-generated, and its own header
  disclaims any trust-check role.
- Verdict step (fail-closed classifier, evidence file
  08-verdict.txt): verdict=PASS; total_files=1052
  total_sorry=2 total_escapes=0; module_sorry=0
  module_escapes=0; challenge_sorry=2 (expected 2)
  challenge_escapes=0; corpus_equal=True
  corpus_chars=2471; axioms for both theorems =
  Classical.choice, Quot.sound, propext;
  head == pin == origin head.
- Independent re-verification by the agent (2026-10-27):
  evidence zip sha256 matches the run-page digest; the
  three corpus logs re-compared equal under the
  classifier's own normalization, with both theorem checks
  present in the challenge and solution corpora and absent
  from the statements corpus; axiom sets re-read from the
  evidence log; scan counts, build exit and seconds, cache
  exit, toolchain, Mathlib rev, and the five file hashes
  re-read from the evidence files. All agree with the
  verdict step.

## Post-verdict stress test (2026-10-27)

At the user's word, an independent model (Gemini 4 Argon
via OpenRouter, contract-breaker brief, this note as its
only fact pack) attacked the verdict on four axes; bottom
line UPHOLD WITH REPAIRS. Adjudication by the auditor:
the attack on the claimant-authored axiom reporter fails
on the facts once the script is inspected (receipt above,
amended), and the attack that the in-Lean encodings might
smuggle computation fails on the definitions (M1,
amended). Two wording repairs stand and are applied
above: the corpus + axiom audit is no longer called an
"equivalent" of Comparator/nanoda (scope section), and
the DEEPEN quote no longer says the paper was "not
opened" (it was outside the formal verification scope).
One completeness repair stands: the load-bearing
definitions are now quoted in M1, since the corpus
receipt alone proves identity, not fidelity. No attack
moved the verdict. Run record:
`~/workspace/argon-verdict-stress-2026-10-27/` (payload,
response, adjudication inputs).

Closing verdict: PASS. The 32-gate verdict lock is
untouched (17 BREAK / 15 PASS).

**Verdict: PASS**
