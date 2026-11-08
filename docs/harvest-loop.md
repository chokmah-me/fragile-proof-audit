# Harvest loop

Weekly pipeline: fresh-claim harvest in → recon analysis out → target pick.

## Stages

1. **Harvest.** Fresh claims land as `incoming/harvests/<YYYY-MM-DD>.md`
   (format: `incoming/harvests/README.md`). Produced by the weekly
   harvest scan, deep-research batches, or pasted in by hand.
2. **Recon (automatic).** The `harvest-loop` GitHub Action fires on push of a
   harvest file, weekly on Mondays (~09:17 ET), or manually. It runs
   `scripts/harvest-loop/recon.py`, which for each claim:
   - verifies the paper identifier against the arXiv API (title/author/date),
   - for arXiv-verified papers, runs a second-axis check against the
     OpenAlex API (lookup by arXiv DOI; title/author/year compared with the
     arXiv record) — agreement is recorded in the recon ledger, disagreement
     is flagged for classification (citation error vs index error or lag),
     and absence is recorded as no signal, never as non-existence,
   - verifies the code repo against the GitHub API (public, HEAD pin,
     Lean-file count, lakefile, `lean-toolchain` pin),
   - for claims with a Lean formalization, writes a **formalization coverage
     inventory** (file count, lakefile, toolchain pin, author-declared
     verification such as Palomar registration or comparator replay — recorded
     as *declarations*, never credited) plus a ready-to-run **LeanExplore
     probe query** for the post-pick Mathlib coverage check,
   - scores fragility from the harvest's declared signals plus computed
     adjustments (fixed rubric in `incoming/harvests/README.md`),
   - suggests attack lanes from the A–G taxonomy (heuristic; confirmed on pick).
3. **Output.** `docs/audits/harvest-<date>/recon.md` (verification ledger,
   ranked queue, per-claim cards), `ledger.json` (machine-readable checks),
   committed to main; a `harvest`-labeled GitHub issue carries the ranked
   table for the target pick. Examples: [`docs/audits/harvest-2026-09-24/`](audits/harvest-2026-09-24/),
   [`docs/audits/harvest-2026-09-28/`](audits/harvest-2026-09-28/).
4. **Target pick (human).** Reply on the issue. On pick: pin inputs
   (PDF + repo SHA under `incoming/`), write the audit note, then run gates.

### Lean-formalization recon (post-pick, manual or agent)

Clones and builds wait for the target pick — the loop above never does
either. Once a target with a Lean formalization is picked, run these two
autoformalization-tool recon steps before deep gates:

1. **Mathlib coverage probe (LeanExplore).** Take the probe query from the
   claim's recon card and semantic-search Mathlib:
   `leanexplore search "<query>" --package Mathlib` (remote API is public and
   keyless — LeanExplore retired API keys; or the website).
   If the formalized theorems, or their key lemmas, already exist in
   Mathlib, that reframes the novelty claim and can expose a
   `formal_subset_of_claim` gap. Feeds the statement-fidelity checklist below.
2. **Trace extraction (LeanDojo).** For the pinned repo, extract tactic
   traces, syntax trees, and proof states. Use them in the
   statement-fidelity checklist (M1: does the formal theorem say what the
   paper's theorem says?) and in the axiom audit (what do the proofs
   actually depend on?).

### Effectivity screen for QRH-instantiated claims (triage, adopted 2026-10-20)

Origin: check A6 of the Frei–Sofos–Widmer audit
(`docs/audits/frei-sofos-widmer.md`), generalized at the user's word
the same day. Applies to any harvest claim whose unconditionality is
instantiated by citing a zero-free region QRH(δ) (no zeros of the
relevant Dedekind zeta functions with Re s > 1 − δ; note the
parametrization: the region Re s > 31/32 is δ = 1/32) and whose proof
consumes that region through an effective Chebotarev or
prime-splitting step with a threshold of the standard shape
x ≥ c(δ)·(log Δ)^(a/δ)·(log log Δ)^(b/δ), while the consuming
argument needs primes at norm ≤ Δ^η.

Run `scripts/harvest-loop/qrh_effectivity_screen.py --delta <δ>
--eta <η>` (defaults a = 1, b = 2, c = 1; set a and b from the
claim's own corollary when they differ). It returns the crossover:
the discriminant digit count from which the threshold first drops
below Δ^η, classified EFFECTIVE (≤ 100 digits), LARGE-ONLY
(≤ 10,000 digits), or NIL (> 10,000 digits). c = 1 is a best case
most papers do not supply (FSW's c(δ) is pure existence), so every
crossover is a lower bound on the true one. `--fsw-grid` replays the
validation: the script reproduces the FSW audit's 16-cell grid
(395,225 at (ℓ,d) = (2,3) up to 2,757,773 at (5,6)) to within 0.5
log₁₀ units, and discriminates on controls at η = 1/8
(δ = 1/2 → 56 digits, δ = 1/12 → 451, δ = 1/32 → 1,359,
δ = 1/6000 → 395,225, δ = 10⁻⁶ → 86,912,155).

What the screen is and is not: it measures the **effective content
of the instantiation**, not the claim's truth; an asymptotic bound
can be true with an astronomically large implied constant, and the
exceptional-set absorption that keeps such corollaries true is
standard. A NIL or LARGE-ONLY flag is recorded on the claim's recon
card as an effectivity qualification (it caps what "unconditional"
can mean in practice, and it decided V-B's grade in the FSW audit);
it is not a verdict and never a kill by itself. If the claim's
consumption does not go through a threshold of this shape, the
screen does not apply; say so on the card rather than forcing the
fit.

### Statement-fidelity checklist (four modes)

Adopted 2026-10-08 from arXiv:2610.08144 (Bastounis–Circelli–Hansen,
"Navier-Stokes lost in translation"): Lean acceptance certifies the formal
proposition and the formal derivation supplied for it — not that the
proposition is the one the source text states, that the derivation follows
the source argument, or that the source argument is correct. A compiling
proof can coexist with a wrong NL proof, prove a different theorem by a
different method, or prove less than the NL text claims. Compilation is
therefore never the acceptance criterion for "the source proof is
correct"; no fixed finite procedure can certify faithful translation (their
SCI = ∞ result), so the checks below stay human-judgment, fail-closed.
The statement tests adopted 2026-11-08 supply machine evidence
to M1 without changing that: they test a statement's own
logic, never its faithfulness to the source, and the M1
judgment stays the auditor's.

Every audit note that evaluates a Lean formalization — ours or a third
party's — answers these four modes explicitly. Pure computational-replay
gates (types A–F) that re-derive the quantity from scratch have no
formalization under review; the note says so in one line.

- **M1 — Statement correspondence.** Does the formalized theorem state what
  the source's theorem states? Compare quantifiers, side conditions,
  derivative counts / integrability exponents, domains, norms,
  dependencies, and implicit existence conditions. Record any weakening,
  strengthening, or change — and whether downstream uses depend on the
  changed part. (Their Navier–Stokes case: m+4 → m+5 derivative loss and an
  added localized gradient term made the Lean estimate a different, weaker
  proposition.)
- **M2 — Argument correspondence.** Does the formal derivation follow the
  source's argument, or does it prove the formalized statement by a
  different route — or repair a broken one? Label it: *faithful
  formalization of the source proof* vs *independent proof of the
  formalized statement*. Both are legitimate; conflating them is not.
- **M3 — Credit honesty.** Does the claimed verification credit match what
  is actually verified? Disclose sorrys, axioms, divergences, and scope
  limits; no over-claiming. (This is the existing Type-G
  verification-credit scan, e.g. the NLA notes.)
- **M4 — Fine print** (Murray & van Oorschot, "BP: Formal Proofs, the Fine
  Print and Side Effects," IEEE SecDev 2018, DOI 10.1109/SecDev.2018.00009;
  adopted 2026-10-13, prospective only, no backfill). Inventory every
  load-bearing assumption not in the theorem statement: model/definitional
  choices, machine model, trusted base, exclusions. Dangling check: is the
  conjunction of those assumptions satisfiable by an instance of the source
  claim? Residual line per assumption: if it fails — survives / weakens
  to ___ / evaporates, and which downstream claims inherit it. Tag each
  proof-enabling change: source-faithful / convenience-only /
  risk-inducing.

### Non-vacuity vectors (Stellar BB6, adopted 2026-10-23)

Adopted verbatim at the user's word from the adversarial
verifier prompt in Appendix E of Dos Santos et al.,
arXiv:2610.22603v2 (the DeepMind Busy Beaver paper; source PDF
sha256 ed1954a91f6ff352e021d5c2c400b4f2c2c54a7ee5ddc1318924a04fc5dfec59;
transcription verified against the p. 24 page image). Scope:
harvest audits of Lean formalizations whose proofs rest on a
closed invariant / pattern system or on agent-rewritten
statements. Name mapping: macro-step rules = the target's
accelerated or transition rules; pattern set = its invariant
family; entry theorem = its canonical-start reachability
result. The audit note records each vector as PASS / FAIL /
N-A with the object named; N-A is a recorded answer, not a
skip. The four pipeline checks under §3 duplicate the Receipt
requirement below and are kept for fidelity; the Receipt
requirement governs.

> ### 2. Anti-Cheating & Non-Vacuity Auditing (Stellar BB6 Protocol)
> Every proof must pass all 5 verification gates:
>
> - Vector A (Satisfiable Hypotheses): Preconditions on macro-step rules must
>   be mutually satisfiable over Nat and logically consistent. Any premise
>   simplifying to False (omega/cases contra exploits) results in immediate
>   DISQUALIFICATION.
> - Vector B (Structural Non-Empty Invariants): The pattern set ps in
>   rules_closed / cryptid must be non-empty (ps != []) and evaluate to the
>   canonical configuration family (Config_*). Trivial 1-step unrolling or
>   universal catch-all patterns are DISQUALIFIED.
> - Vector C (Genuine Blank-Tape Reachability): The entry theorem
>   (init_reaches_*) must prove init [] executes a strictly positive number of
>   concrete machine steps (|-+ / execute) to reach the canonical Config_*
>   family. Zero-step bypasses (cfg_0 = init []) or disconnected dummy patterns
>   are DISQUALIFIED.
> - Vector D (Exhaustive Parameter Coverage): Macro-step rules must form a
>   total, exhaustive partition of N^k for all valid variable assignments in
>   ps. Proofs relying on Nat truncated subtraction underflow (a - b = 0 when
>   a < b) or leaving unhandled parameter gaps are DISQUALIFIED.
> - Vector E (Rule Proof Integrity): Every rule_* must be proved bottom-up
>   from the primitive transition function step with strictly positive progress
>   (|-+) and zero unproved axioms (no Lean.ofReduceBool, no foreign axioms).
>   Any subtraction within parameter bounds must have explicit inequality
>   proofs preventing underflow.
>
> ### 3. Verification Pipeline Checks
> 1. Kernel compilation: 0 errors, 0 warnings, 0 sorry.
> 2. Axiom audit (#print axioms): Only propext, Classical.choice, Quot.sound.
> 3. Comparator check: All declarations from problem.lean must match bit-for-bit.
> 4. Kernel replay: Full export via lean4export validated by independent checker.

Addition-gate lines: (1) replaces the improvised per-audit
vacuity checks each QUEUE-PREP re-derived from scratch; M1–M4
are unchanged, nothing is retired. (2) Scope as stated above.
(3) Review at the 2026-12-01 monthly hygiene run, or after its
first full application (expected: the Cryptids audit),
whichever is later. No automation rides with this adoption;
it is a document checklist.

### Statement tests (M1 add-on, adopted 2026-11-08)

M1 is a read. A read can be careful and still miss the two
failures that live inside a statement's own logic: hypotheses
only degenerate instances satisfy, and total functions whose
off-domain values silently shrink what the statement covers.
AutoIP (Clason et al., arXiv:2611.06962, Sec. 5) hit both in
settled literature: a textbook convergence theorem whose
hypothesis (order optimality for one nu and ALL rho > 0) admits
essentially only the zero operator, and a dimension lemma
weakened by Module.finrank being 0 on infinite-dimensional
spaces. The tests below turn the mechanical half of that check
into forge evidence. They supplement the M1 read; they do not
replace it, and they never grade the proof side.

Scope: the headline theorems of a Lean formalization audit (the
theorems the build and comparator target), plus any
artifact-defined predicate appearing in a headline signature
(one level in; that is where vacuity hid in the RiemannJensen
audit, in IsDedekindZetaContinuation). Every probe is recorded
per theorem as PASS / FAIL / N-A with the object named; N-A
means structural inapplicability only, and a probe that times
out is recorded PROBE-TIMEOUT, never N-A. Mandatory probes:
ST-1 for every headline theorem (the pure-existence N-A below
excepted), ST-2 whenever ST-1(a) is attempted, ST-5 for every
conditional headline theorem, and ST-3 / ST-4 whenever their
scope is nonempty. If the library build or the comparator
fails, probes do not run: their rows record NOT-RUN and the
verdict follows the machine tiers as usual. Probe files are
Lean files run in the forge (the AxiomAudit pattern), strictly
AFTER the library build and the comparator have succeeded, on
warm oleans, importing the built library; a probe never
recompiles the library. Probe obligations are discharged by
applying the pinned theorem (or a projection of its type),
never by re-typing its hypotheses into the probe file, so the
kernel itself checks that the obligation is about the pinned
statement. Probe lemmas join the run's axiom audit: a probe
proved with sorryAx or an added axiom is a failed probe, not a
passed one.

- **ST-1 Two-sided satisfiability.** (a) SATISFYING: exhibit a
  concrete instance of the theorem's binders and prove the
  hypotheses for it, by applying the pinned theorem or its
  hypothesis projection. (b) ESCAPING: exhibit an instance of
  the binders where at least one hypothesis fails. A signature
  predicate is probed the same way, as a hypothesis over its
  own arguments: exhibit an object satisfying it, or prove
  none exists, under the same labels. ST-1(a) has three
  outcomes, which are also its record values (WITNESSED
  records as PASS; VACUOUS-PROVED records as FAIL; UNWITNESSED
  records as itself, a finding):
  WITNESSED (a non-degenerate instance is exhibited, ST-2);
  UNWITNESSED (a bounded, recorded search found no witness;
  before recording it, check whether an existence proof for
  the hypotheses already exists in the artifact or Mathlib: a
  finding, not a cap, because failing to find a witness does
  not prove unsatisfiability); VACUOUS-PROVED (the audit
  proves the hypotheses imply False, or proves they admit
  only the degenerate cases under ST-2: the theorem as
  claimed is empty, and that theorem's verdict caps at
  PARTIAL with the proof as the receipt). AutoIP's catch was
  the VACUOUS-PROVED shape: not "no witness found" but an
  argument that only the zero operator survives. If no
  escaping instance is found either (NO-ESCAPE), the
  hypotheses may be content-free, recorded as a finding.
  Pure existence theorems, where exhibiting the witness is
  the theorem itself, are N-A with that reason recorded.
  Where a headline theorem carries both instance-level
  hypotheses and a proposition-level antecedent, ST-1 applies
  to the instance-level hypotheses; the antecedent is ST-5's
  object alone.

- **ST-2 Non-trivial witness.** The ST-1(a) witness must be
  non-degenerate relative to the claim. Non-degeneracy is
  pinned at pin time as an excluded list or an explicit
  predicate, not judged by eye afterward; the standing
  exclusions are the zero object, the trivial group or zero
  space, the empty structure, and a subsingleton or empty
  carrier where the claim's class is nontrivial. If the
  hypotheses provably imply degeneracy on the intended class
  (a formal proof, or a mathematical argument recorded in the
  note, as AutoIP's forcing argument that the hypothesis
  drives R to 0 and so T to 0), the finding is
  OVER-RESTRICTIVE HYPOTHESIS: the note states which
  instances the hypothesis actually admits, and any source
  assertion that the hypothesis is mild or general is
  recorded REFUTED, with the proof as the receipt. If only a
  documented search stands behind the suspicion, the finding
  caps at UNVERIFIED-NONDEGENERACY and the source assertion
  at UNSUPPORTED, never REFUTED.

- **ST-3 Hypothesis reference check.** First pass, no build
  cost: check whether each hypothesis of a headline theorem
  is referenced by its proof, using the unusedVariables
  linter or, equivalently, a dependency scan of the compiled
  proof term (two instruments for the same question; record
  which one ran). A hypothesis the proof never references is
  recorded as a finding: a reader of the claim is entitled to
  think it is needed. Where a hypothesis IS referenced but
  only through bulk tactics (simp, aesop, omega and their
  kin), a second pass may restate the theorem with that
  hypothesis dropped (or, where the formal version is
  stronger than the source's wording, weakened to the
  source's version), holding the dropped binder's position
  with a (h : True) dummy, and replay the original proof
  script. Second-pass outcomes: REPLAY-CLOSES (the script
  closes without the hypothesis: a finding) or REPLAY-BREAKS
  (the failing step is recorded verbatim: a finding). Either
  way the outcome is named referenced / not-referenced at the
  first pass: reference is syntactic, a referenced hypothesis
  can still be semantically redundant, and the probe claims
  nothing stronger. Cost overruns are PROBE-TIMEOUT, not N-A.

- **ST-4 Junk-value inventory and boundary probe.** For every
  total function with a documented off-domain value by
  convention (Module.finrank = 0 on infinite rank, Nat
  truncated subtraction, division by zero, partial operations
  totalized) appearing in a headline statement or in the
  artifact definitions that statement unfolds to (one to two
  levels in), record: the junk value, whether the statement's
  hypotheses rule the junk region out, and whether the source
  claim covers that region. Boundary probe: where a
  junk-region instance exists, exhibit it, restate the
  theorem on it, and record what the statement says there
  (nothing, a tautology, or real content). If the claim
  covers a region the formal statement silently excludes or
  trivializes through a junk value, the finding is WEAKENED
  STATEMENT, an M1 finding with the region named. The same
  treatment applies to artifact definitions built by
  totalization (Classical.epsilon / choose with an else
  default, if-exists-else): the definition's existence
  predicate is itself an ST-1 obligation. The offenders
  named in this section are the seed list; the list grows by
  findings, each addition named in the note that found it and
  appended to this section at the next hygiene review. The
  depth here (one to two levels into definitions) is deeper
  than ST-1's one level for predicates, because a predicate
  is probed as a hypothesis in its own right while a junk
  function hides inside the definitions a statement uses.
  (AutoIP Sec. 5.2: their satisfiability tests would not
  have caught the finrank case; this probe exists because
  that failure class is disjoint from ST-1.)

- **ST-5 Conditional antecedent status.** For a headline
  theorem of the form H -> C where H is itself a substantial
  proposition, record H's status at the pinned artifact. H
  grades PROVED only if (a) it sits inside the comparator's
  coverage at the pinned commit and passed there, or (b) it
  comes from the trusted base (the pinned Mathlib commit)
  with a clean #print axioms in the forge, or (c) the
  sibling claim that owns H has passed its own kernel tier at
  that exact commit. Anything else, including a theorem
  imported from a named pinned dependency whose oleans
  arrived by cache and were never kernel-rechecked in this
  audit, grades UNVERIFIED-IMPORTED-ANTECEDENT. (The D1 rule
  behind that grade, in one line: a leg fed by cached oleans
  is receipted only by the comparator, because a build does
  not kernel-recheck imported oleans.) (This formalizes the 2026-11-06
  CFSG handling: the corollary's antecedent is TauCeti's
  ClassificationStatement, proved in the cfsg package as
  CFSG.Certified.classification_finite_simple_groups, a
  separate registered claim.)

Grading summary: ST-1 VACUOUS-PROVED caps the affected
theorem at PARTIAL. A conditional headline theorem grades
above PARTIAL only if its antecedent is witnessed
non-degenerately under ST-1 + ST-2 (instance-level
hypotheses) or graded PROVED under ST-5 (proposition-level
hypotheses); otherwise it caps at PARTIAL. ST-1 UNWITNESSED,
ST-2, ST-3, ST-4 findings are recorded in the note's M1
section and move the verdict only when the affected
hypothesis or region is the claim's headline condition or
conclusion, per the loop's existing rules. A WEAKENED STATEMENT finding grades the affected
theorem PARTIAL, unless the excluded region is the claim's
central case, in which case the finding is recorded as a
statement-level BREAK for that theorem. A headline theorem
with a PROBE-TIMEOUT on a mandatory probe cannot grade clean
PASS. No probe result upgrades a verdict.

Addition-gate lines: (1) replaces the per-audit improvised
vacuity work outside the BB6 scope and generalizes BB6 Vector
A beyond closed invariant systems; the BB6 vectors stay in
force for their stated scope, M1–M4 are unchanged, nothing
else is retired. (2) Scope = headline theorems and their
signature predicates in Lean formalization audits, prospective
only, no backfill. (3) Review at the 2026-12-01 monthly
hygiene run, or after its first full application, whichever
is later; findings per probe are counted at the review, and a
probe with zero findings in its first three applications is a
retirement candidate there. The only automation is the forge
probe files the workflow already knows how to run; no new
standing machinery.

### Receipt requirement (adopted 2026-10-09)

"Trust, but replay" without the replay artifact is just trust. Every audit
note therefore carries a **Receipt** field pointing at machine evidence —
generated as a matter of course, not as an optional extra:

- **Lean formalization audits** end with an independent forge build and an
  axiom receipt: the pinned inputs (repo revision, toolchain, dependency
  pins), where it built (a machine separate from the author's), and the
  exact `#print axioms` output for the headline theorem. "It compiled on my
  machine" is not a receipt. (Pattern and catalog: `docs/family-receipts/`.)
- **Computational-replay gates (types A–F)** already produce their receipt in
  the gate script plus its output; the discipline is that the evidence hash
  is part of the verdict record every time, not just when convenient.
- A receipt that does not exist is reported as such — a missing receipt is a
  GAP in the note, never silently omitted.

### Companion prompts (adopted 2026-10-20)

Two Stunspot "Prompt of the Day" prompts are paired with this loop
(prospective only, no backfill; texts in the local Stunspot library,
`local-stunspot-potd`):

- **Grandmaster's Methods** (2025-08-16) runs at the recon step: reconstruct
  the author's actual working method from primary sources (the paper, the
  artifact, process evidence), weighted unvarnished-over-polished and
  high-stakes-over-promotional, with skeptic filters (survivorship,
  success-myth reconstruction, ghosted authorship) run continuously.
- **DEEPEN** (2025-10-10) runs as a pre-verdict challenge pass alongside the
  M1–M4 checklist: a reflect-and-challenge cascade over assumptions,
  theoretical basis, drawbacks, failure contexts, and alternatives, applied
  to the draft verdict before it is recorded.

## Boundaries

- The loop never clones code, never runs builds, never downloads artifacts.
  Running anything waits for the target pick.
- The loop never touches the verdict lock.
- Every audit note pins its agent harness (model + harness + version + run
  date) in the header block, the same way it pins the Lean toolchain —
  harness choice moves results more than model choice.
- The weekly scheduled run with no new harvest does a health re-check of
  the latest harvest's identifiers and reports only on drift (repo gone
  private, new HEAD, paper v2/withdrawn).

## Local testing

`python3 scripts/harvest-loop/recon.py [YYYY-MM-DD] [--health-check]`
(stdlib only; needs network for the arXiv/GitHub APIs).
