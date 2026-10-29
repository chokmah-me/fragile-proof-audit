# Audit note — OpenAI ETH-disproof formalization (openai/math, SubexponentialSAT)

**Claim artifact:** OpenAI's 2026-10-26 announcement of three
model-produced results, of which this audit covers one: a Lean
formalization, in github.com/openai/math, of a subexponential-time
algorithm that exactly counts the satisfying assignments of any
bounded-width CNF and decides satisfiability. The formalized
theorem is `OAI.Algorithms.SubexponentialSAT.SqrtLogSpace.exact_count_and_sat`
(challenge module `ComparatorChallenges.SubexponentialSAT`,
solution module `OAI.Algorithms.SubexponentialSAT.Main`).
Headline: for each fixed k >= 2, one fixed primitive machine
counts and decides every width-<=k CNF in time
2^{o(n)} with polynomial visited space; the k = 3 decision
content is the refutation of the Exponential Time Hypothesis.
**Harvest item:** Feed unit f1904cf3 ("OpenAI hands ETH,
Kakeya, Yang-Mills proofs to reviewers", 2026-10-27 morning
edition); opened at the user's "execute now" 2026-10-27
03:54 EDT, after the after-midnight rule held the action for
morning confirmation.
**Campaign objects:** `incoming/openai-eth-disproof/PIN.md`.
**Pinned sources:** openai/math @
`7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a` (head == origin
head at run time); toolchain `leanprover/lean4:v4.34.1`
(Lean 4.34.1, commit 5045d0056413266e57c625dcd7c365b10e377c52);
Mathlib rev `d13f23b723b8a846827a245b89c10fc7d3f11612`; forge
evidence zip sha256
`a657b28a1e3e23bc695461f82235665c7a0ae676d11147cccbad872a22bd1a23`.
Evidence in `~/workspace/eth-recon/` (`RECON-BRIEF.md`,
`evidence-run-40507873397/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-27` · harness pin via
`scripts/harness_pin.py`. Recon was a direct statement read
and definition inventory (no Stunspot prompt ran on this
audit's recon); the pre-verdict deepening was the
twin-definition corpus check described below, which is the
audit's load-bearing question.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T16:32:42Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (build + axioms at the pin): PASS.** Forge run
  40507873397 on dell-laptop (laptop lane, after the desktop
  runner died mid-build in run #2), details below. The
  3,977-file solution module builds at Lean 4.34.1 + Mathlib
  d13f23b7, the challenge module builds, and the theorem
  depends on exactly the classical three axioms.
- **V-B (statement fidelity, M1): PASS at the contract layer.**
  The statement was read in full at recon and matches the
  claim: one machine per fixed k, exact counting, SAT decision
  on an answer tape, the 2^{o(n)} time bound with the
  square-root-log scale, polynomial visited space at every
  prefix. The twin-definition risk (below) is resolved by
  corpus equality, not by trust.
- **Scope (not a GAP in the audited claim):** the accompanying
  natural-language manuscript (dated 2026-10-25 in coverage)
  was not audited; this audit covers the Lean formalization
  and its statement only. The shepherds' independent review
  (Impagliazzo, Paturi, Williams) is a separate process and is
  not certified or pre-empted here.

## M1 — the twin-definition seam

The solution module carries its own copies of every
definition the statement names (SAT syntax and semantics,
BinaryArithmetic, Encoding, the Computation machine model,
SqrtLog.Statement scale and bound, SqrtLogSpace located
configurations) under the same fully-qualified names as the
challenge file, and imports nothing from
`ComparatorChallenges`. Printed theorem types would therefore
look identical even if a twin definition differed, so a
statement print alone cannot settle M1. The forge settles it
mechanically: two separate environments, one importing only
the challenge module and one importing only the solution
module, each printing all 36 statement components plus a
`#check` of the theorem. After whitespace normalization the
two corpora are byte-identical (13,637 chars each). Eyeball
checks at recon agreed (SAT definitions, runtimeScale,
runtimeBound all match the challenge text; the module's
other `runtimeBound` helpers live in different namespaces
and are not the statement's function).

## M2 — what the proof establishes

The Lean kernel checks the 3,977-file development ending in
`SqrtLogSpace/Final.lean`, which proves the stated theorem.
The audit verifies that a kernel-checked proof of exactly
this statement exists at the pin, with the classical-three
axiom footprint. It does not human-read the 710,320-line
development, and it does not re-derive the algorithm: the
Lean statement is the algorithm claim, and the statement's
own definitions govern what was proved.

## M3 — credit honesty

The claim is OpenAI's model output, released 2026-10-26 with
external shepherds who explicitly state their involvement
"should not be taken as certification of the claim", and
OpenAI seeks no academic credit. This note attributes the
claim to OpenAI's release and to nothing else. The sibling
claims from the same announcement (local smoothing, which
is public and auditable; Yang-Mills existence, for which no
public artifact exists) are not covered here.

## M4 — fine-print assumption inventory

- The machine model is the statement's own: a custom
  `PrimitiveMachine` over Mathlib's `Turing.Tape` and
  `TM0.Stmt`, with `Trace` counting `locatedStep` steps and
  `visitedSpace` summing visited cells per tape. Whether
  that model matches the standard complexity-theoretic
  notion of deterministic TM time and space is a
  definitional question the audit records; the verdict is
  that the Lean statement as written is proved, and the
  statement's definitions are the ones the corpus check
  pinned.
- The encoding is the statement's canonical `encodeCNF`.
  Clauses are Finsets of literals, so for fixed k the clause
  count (hence the input bit length) is polynomial in n;
  that is what makes the time bound subexponential in n
  rather than merely subexponential in the input size.
- The theorem quantifies per fixed k with existentially
  quantified machine and constants; the ETH refutation runs
  through k = 3, whose decision content is inside the
  statement (answer tape and halting state).
- The repo's own comparator tool (lean4export + landrun)
  was not run; the corpus check is the transparent
  equivalent for exactly the definitions the statement
  names, and it is the check this verdict rests on for M1.

## Receipt

- Forge: eth-forge run 40507873397, laptop lane on
  dell-laptop (machine DESKTOP-Q42R8VL), manually
  triggered 2026-10-27 08:57 EDT on fragile-proof-audit
  main@ebfd893, completed success 12:14 EDT, total
  3h 17m 2s. Run:
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40507873397
  Job:
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40507873397/job/122201753437
- Earlier runs: #1 (40471027485) failed in 4s at the Runner
  probe (df on the not-yet-created target dir; probe fixed
  and FM7 added to the pre-dispatch checker, main@7b2a139);
  #2 (40473059620) failed after 1h 43m when
  DESKTOP-7HDI2D1 lost communication mid-build (its WSL
  guest's ext4 later found unreadable; host disk cleared
  NTFS-clean). Neither run produced a verdict; the laptop
  lane switch (main@ebfd893) moved the audit to
  dell-laptop, where run #3 built from a fresh target dir.
- Build: solution module exit 0 in 11,485s; challenge
  module exit 0 in 33s; Mathlib cache exit 0, 8,937 oleans.
- Scans (comment-stripped): module 3,977 files, 0 sorry
  hits, 0 escape hits; challenge 1 file, exactly 1 sorry
  hit (the statement itself, by design), 0 escape hits.
  No `partial def`, `@[extern`, `implemented_by`,
  `unsafe`, or `native_decide` anywhere in the module.
- Corpus: challenge-env log == solution-env log after
  whitespace normalization, 13,637 chars each, both env
  exits 0.
- Axioms of `exact_count_and_sat` (from `#print axioms`,
  solution env): exactly `[propext, Classical.choice,
  Quot.sound]`; no sorryAx, no native_decide, no
  ofReduceBool. (The lake "local changes" warnings in the
  env logs are workspace-status noise from dependency
  checkouts and do not touch the axiom print.)
- Verdict step (fail-closed classifier, run page):
  verdict=PASS; module_files=3977 module_sorry=0
  module_escapes=0; challenge_sorry=1 (expected 1)
  challenge_escapes=0; corpus_equal=True
  corpus_chars=13637; axioms_found=Classical.choice,
  Quot.sound, propext; head == pin == origin head.
- Independent re-verification by the agent (2026-10-27):
  evidence zip sha256 matches the run-page digest;
  corpus logs re-compared equal (13,637 chars); axiom
  list re-read from the evidence log; scan counts,
  build exits, cache exit, toolchain, and Mathlib rev
  re-read from the evidence files. All agree with the
  verdict step.

Closing verdict: PASS.

## Addendum (2026-10-29) — ZKSF re-run, finite-size scope

Post-audit bearing assessment at the user's direction,
2026-10-29, of ZKSF Org, "The Exponential Time Hypothesis
Proof Checks, and Its Algorithm Is Brute Force on Every
Formula That Could Exist", Zenodo record 23732240, v1.0.0,
published 2026-10-28 (report, Dockerfiles, run logs with
hashes, and `cutoff_check.lean` in the record). The
assessment was double-checked with an adversarial
second-model pass (Argon, `google/gemini-4-argon`,
2026-10-29: UPHOLD WITH REPAIRS, adjudicated against the
record, not relayed). **Verdicts unchanged: V-A PASS,
V-B PASS. Original text above untouched; nothing in this
addendum corrects it, because nothing in it was false.**

Corroboration (bears on the M4 inventory, not the verdicts):

- Comparator (M4, fourth bullet): this audit recorded the
  repo's own comparator tool as not run and rested M1 on
  corpus equality. ZKSF has now run the published comparator
  configuration in an isolated (no-network) container at the
  same pin `7ef5c0cc`: run 1 (published configuration) ends
  "Lean default kernel accepts the solution" / "Your
  solution is okay!", exit 0. Inputs verified byte-identical:
  git blob hashes of the challenge file, configuration,
  lakefile, manifest and toolchain file at the pin; all 8,926
  compiled Mathlib and dependency files byte-identical to a
  fresh official cache download (0 different, 0 missing);
  no file outside the work volume changed. Caveat, theirs:
  the comparator's file-level layer (landrun) needs Linux
  7.2+ and ran best-effort on their 5.15 kernel, with the
  integrity checks above substituted for it.
- Second kernel: run 2 (nanoda, comparator's independently
  written kernel, switched on with its stock 16 MiB thread
  stack) aborted after 80s, exit 134, a stack overflow in a
  checking thread, which the comparator reports as "nanoda
  kernel rejected the solution". Run 3 changed exactly one
  constant (`STACK_SIZE` 16,777,216 to 1,073,741,824 in
  nanoda's source, per its build log): "nanoda kernel
  accepts the solution", Lean accepts, exit 0. The run-2
  output is a resource abort, not a rejection verdict.
- Statement and machine model (M4, first bullet): ZKSF
  audited the whole challenge file and find the formal
  statement faithful. Against this note's open definitional
  question, they read the machine affirmatively as a
  standard deterministic multi-tape Turing machine, one tape
  action per step, one fixed machine per k. Recorded as
  their reading; this note's cautious framing stands.

Finite-size scope (a consumption gap in M4, now filled).
Three distinct facts; they are not interchangeable:

- Bound crossover (statement level). The proved exponent is
  rho(n) = n (log2 log2 n)^2 / sqrt(log2 n); rho(n) < n iff
  (log2 x)^4 < x with x = log2 n, and that fails for every
  integer x from 5 to 65,536. So even with every hidden
  constant set to 1, the proved bound is no better than
  brute force's 2^n for any n up to 2^65,536. This is a fact
  about the proved upper bound, derivable from the
  statement's own bound definitions, not a measured runtime.
- Verified-program cutoff (proof body). The program's
  cutoff is `max 20 (max Nleaf Ns)`, with `Ns` any number
  past which `sparsifySchedule` stays at 2 or more
  (`NativeLargeEntry.lean`); no value is written anywhere.
  ZKSF's `cutoff_check.lean`, compiled against the proof's
  own definitions with exactly the classical three axioms
  (compile exit 0), proves `sparsifySchedule (2^521283) = 1`,
  `sparsifySchedule (2^521284) = 2`,
  `sparsifySchedule (2^639999) = 1`,
  `sparsifySchedule (2^640000) = 2`, and that every
  admissible `Ns` exceeds 2^639,999. The least admissible
  `Ns` (2^639,999 + 1) is a floor, not the program's actual
  cutoff; `Nleaf` may push it higher. Below the cutoff the
  program answers from a finite table fixed before the input
  (`FiniteFallback.lean`, noncomputable). It does not run
  exhaustive search.
- Manuscript algorithm (outside this audit's original
  scope; recorded here because it is how the result will be
  read). Proposition 6.4: "If s < 2, we use exhaustive
  search", with s = floor(sqrt(lambda) / nu^2),
  lambda = ceil(log2 n), nu = ceil(log2 lambda). By that
  rule the manuscript's algorithm is exhaustive search for
  every n <= 2^521,283 and again for
  2^524,288 < n <= 2^639,999, with its construction active
  in the window lambda in [521,284, 524,288] between.

Assessment: ZKSF's own framing is that nothing here
contradicts the result: ETH is a statement about growth
rates and a 2^{o(n)} algorithm refutes it however late the
speedup begins. This note's PASS certifies the asymptotic
statement as written and claimed nothing about finite-size
performance; what it did not do, until this addendum, is
state the magnitudes above, which are what a reader needs
to consume the headline correctly. The PASS is compatible
with the algorithm giving no speedup on any formula that
can be written down. The separate Anthropic ETH audit is a
different artifact and is unaffected.
