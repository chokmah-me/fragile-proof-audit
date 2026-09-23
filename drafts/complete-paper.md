# Replay Audits of Published Mathematical Claims: Gates, Controls, and Dispositions

*Draft manuscript — companion methods paper to the fragile-proof-audit campaign. Exported 2026-09-23.*

## 1. Abstract

Published mathematics is trusted far more than it is independently
re-run. Peer review checks reasoning, not computation — and
increasingly, part of the proof *is* a computation. This paper
describes a short, intensive audit campaign (first commit 2026-09-18)
that replays published mathematical claims from scratch, under a
hostile posture: every computational claim must survive an
independent, well-resourced re-execution, and every instrument must
demonstrate it can produce the opposite verdict where the opposite is
correct.

The contribution is the playbook, not the verdicts. §3 defines a
five-disposition taxonomy (BREAK, GAP, PASS, SKIP, UNKNOWN) with a
CI-enforced verdict lock — currently 25 gates, 17 BREAK / 8 PASS —
that fails loudly on drift in either direction. §4 classifies the
attacks by mechanism (scalar gates, base-case kills, WZ-certificate
audits, finite q-expansions, CAS-transcript replays, counterexample
search, logical-gap exposure), each with a worked example. §5 states
the evidentiary disciplines that keep the attacks honest —
paper-first gating, discrimination controls, gate-before-prove,
fail-closed replay, independent anchors with dual implementation,
durable job discipline — together with the record of where those
disciplines were violated and what caught the violations. §6 gives
case studies (a refutation, a confirmation, a canonization, an
unfinished line); §7 states the limitations, including the ones no
discipline closes.

The repository — every gate, control, certificate, and audit note —
is released alongside this paper
(`https://github.com/chokmah-me/fragile-proof-audit`).
This draft corresponds to commit `f441d14`; the submitted
version will cite its exact commit SHA and an archival snapshot
(Zenodo/Software Heritage DOI). A paper whose thesis is *don't trust
prose, trust the re-run* must pin its artifact in the text.
The standing doctrine throughout:
gates refute routes, not theorems.


## 2. Introduction: the verification gap

Peer review checks reasoning, not computation. A referee reads the
argument, follows the lemmas, and judges whether the inferences hold.
What the referee almost never does is re-run the computation: the
thousand-line script, the supplementary data file, the certificate the
theorem's truth depends on. Those artifacts are trusted on the
strength of the prose around them — and prose is not a checksum.

The rot is ordinary, not scandalous. Authors move institutions and
their pages die; file formats age out; a dataset lives on a personal
site with no mirror. In this campaign's q-TSPP line, the authors'
certificate archive — 293 MB of computation the proof's key identity
depends on — survived only because the Wayback Machine had captured it;
the live site was gone. That archive then had to be re-read, re-hashed,
and re-run before a single lemma could be formalized. Nothing about
that process was adversarial. It was still most of the work.

The campaign described in this paper takes the next step: it treats
published computational claims as *hostile witnesses*. Not because
authors are dishonest — the overwhelming majority of the defects found
here are mistakes, not misconduct — but because trust is not a
verification method. Every claim in the audit catalog (`docs/audits/`)
was re-executed from scratch, from pinned inputs, by instruments built
to produce the opposite verdict where the opposite was correct. Where
the claim survived, that is recorded as a PASS with the same weight as
a BREAK: the method does not grade on a curve.

Two scoping admissions, made explicitly so they cannot be read as
hedges later. First, the timeline is short — the campaign's first
commit is 2026-09-18. The claim of this paper is the reproducibility
of the *method*, not the longevity of the results: every gate,
control, and certificate in the repository can be re-run by a reader,
and the verdict lock (§3) fails loudly if any of them drifts.
Second, the targets were selected for fragility by harvest dossiers,
not sampled at random. This paper makes no claim about the base rate
of defective proofs in the literature. It claims only that *these*
routes were tested, *this* is how, and *these* are the dispositions —
with the failures of the method itself recorded alongside (§5.7).

The rest of the paper is the playbook. §3 defines the disposition
taxonomy — the five verdicts and the rules that keep them from
drifting. §4 classifies the attacks by mechanism, with one worked
example per type. §5 states the evidentiary disciplines that keep the
attacks honest, including the record of where they were violated and
what caught the violations. §6 gives full case studies; §7 states the
limitations, including the ones no discipline closes.


## 3. The disposition taxonomy

Every audit in the campaign ends in exactly one disposition. The
taxonomy exists for one reason: verdicts drift. Without fixed
categories, a "the proof has a gap" quietly becomes "the theorem is
false" in retelling, a "we couldn't check this" becomes "it passed,"
and a refuted lemma becomes a refuted mathematician. Each disposition
below is defined by what was *done*, not by how bad the news is, and
each carries a scope rule about what it does and does not say.

The five dispositions: **BREAK**, **GAP**, **PASS**, **SKIP**,
**UNKNOWN**.

## BREAK — the route is refuted by a gated, controlled witness

A BREAK means: a specific lemma of the paper, stated as the paper
states it, is false — and the falsity is exhibited by a gate whose
instrument has demonstrated it can produce the opposite verdict where
the opposite is correct (§5.2). The record is always lemma · instance ·
false instance: the lemma as pinned, the parameters instantiated, and
the concrete counterexample. "Gates refute routes, not theorems"
(§4): ζ(5) is probably irrational, the four-color theorem is true, and
Goldbach's conjecture is untouched by the S.C.E. audit — what died in
each case is a specific chain of lemmas, and the audit note names them.

A BREAK is on the verdict lock (§3.6): the gate that produced it runs
in CI, and any drift in its verdict fails the build.

## GAP — the inference is broken, but the statement is not refuted

A GAP means: the paper's *argument* does not establish its conclusion,
but no lemma statement was falsified. The defect is found by proof
reading, not by computation — typically a quantifier error, an
undischarged hypothesis, or an invalid analytic inference — and the
residue is not finitely gateable, so there is no executable gate to
lock. The route as written is refuted; the theorem is untouched; and a
GAP is explicitly *not* a BREAK.

Three instances from the campaign: FRK-UC, where Theorem 5's proof
upgrades an existential conditional to an existential conjunction and
applies a definition outside its domain (`docs/audits/frankl-uc-gap.md`);
LEG-NS, where the contour-deformed integral is claimed analytic on an
open neighborhood it cannot reach (`docs/audits/leg-ns.md`); and the
Erdős–Straus Theorem-10 interval, where the exhibited parameters fail
but witnesses exist in the same construction family — a GAP can be
*repairable*, and the disposition records that, because "the route as
written fails" and "the route cannot be repaired" are different claims.

GAPs are not on the verdict lock: there is no gate to pin, only the
audit note and its verbatim quotations.

## PASS — the gate's claim is independently confirmed

A PASS means the instrument confirmed what it was built to test — and
nothing more. PASS escalates (a confirmed lemma can be built on);
it is never forced (a gate that cannot fail is not run, §5.2). The
Jacobian-2D campaign is the standing example: the coefficient
identities passed their computational gates *and* the proof text
passed its logical-gap audit, so the target stands as passed on both —
which means it is either correct or fails somewhere outside our
instruments' reach. A PASS is a statement about the audit's reach, not
a certificate of truth.

PASS verdicts are on the verdict lock exactly like BREAKs: a
confirmation that silently stops confirming is the same failure as a
refutation that silently stops refuting.

## SKIP — not auditable as stated

A SKIP means the target, as stated, admits no gate: nonconstructive
arguments, claims with no witness to exhibit, routes whose decisive
step cannot be instantiated at any parameters. SKIP is a verdict about
the audit, not the paper — it says "we cannot test this," not "this
is wrong." The campaign's standing example is the NCI target, skipped
because the alleged finite gate was absent from the paper as written.

## UNKNOWN — artifacts verified, kernel not re-checkable

An UNKNOWN means the checkable parts check out but the decisive
verification step cannot be re-run on our toolchain. The quantum
Hedetniemi audit verified the Python certificates and the source
catalog (PASS on those lanes) but the kernel step requires the
authors' Lean 4.19.0 environment, which we do not run — so the
disposition is UNKNOWN, not PASS. UNKNOWN is the honest alternative to
both inflating a partial check into a confirmation and discarding it.

## The polarity rule

A verdict attaches to the *gate's claim*, not to the paper's
conclusion. The Lamé 1847 audit is the canonical case: the locked
gates `lame_h23` and `lame_ideal_neg23` are **PASS** — the class number
h(ℚ(ζ₂₃)) = 3 is confirmed — and it is precisely that confirmed fact
that kills Lamé's route, which needed the class number to be 1. The
route verdict is BREAK; the gate verdicts are PASS; confusing the two
would invert the meaning of the evidence. Every audit note states both
polarities separately.

## The verdict lock

`scripts/gates/check.py` pins every gate's expected verdict in
`EXPECTED_VERDICT` — currently 25 gates (17 BREAK / 8 PASS). The lock
runs in CI; drift in either direction fails the build. It is not an
all-BREAK lock, and it was a mislabel to ever call it one: a PASS that
stops passing is as much a drift as a BREAK that stops breaking.
GAPs, SKIPs, and UNKNOWNs are not on the lock — they are prose
dispositions recorded in `docs/audits/`, not executable gates — and
neither are audit confirmations (Gomila) or canonizations (Pólya),
which are not verdicts about routes at all.

## Append-only history

The campaign's history is append-only: git plus dated WORKPLAN
checkpoints. When a verdict is corrected, the prior verdict is marked
superseded, not deleted. The odd-zeta audit's early "Λ_m unevaluable"
verdict was superseded by the Lemma 5.1 BREAK on 2026-09-20; both
remain visible, with the correction dated. Summary tables show the
current verdict with a "superseded" note. A taxonomy that rewrites its
past cannot be trusted about its present.


## 4. The attack types (A–G)

The campaign's gates are classified by *mechanism*, not by subject area. Each
type below names a route a proof can take to its conclusion, the instrument
built to test that route, and one worked example from the audit catalog
(`docs/audits/`, `docs/blueprint/`). The standing doctrine throughout:

> **Gates refute routes, not theorems.** ζ(5) is probably irrational; FLT is
> true; the four-color theorem is true. What dies is a specific lemma chain,
> recorded as lemma · instance · false instance.

A gate that cannot produce the opposite verdict where the opposite is correct
is not evidence (`docs/GATE-BEFORE-PROVE.md`); each type's construction notes
where the discrimination check bites. The taxonomy is append-only: a new
mechanism earns a new letter.

## A — Scalar gate

**Route attacked.** Claims whose decisive content is a numerical statement
about a specific constant — typically "best constant" conjectures, where the
entire proof stands or falls on one inequality.

**Gate construction.** Compute the constant, or an explicit witness violating
it, by two independent arithmetics (exact rational algebra and high-precision
floating point), with the violation margin far above any arithmetic noise
floor. The discrimination question here is not "does it fire on everything"
but "is the witness typical or extremal" — answered by sampling the
neighborhood.

**Worked example.** Tang–Zhang Schatten-norm constant
(`docs/audits/tang-zhang-schatten.md`; refutation artifact Zeng–Liu–Ratnavelu,
arXiv:2608.15558, Theorem 1.1). To be explicit about provenance: this BREAK is
an *independent confirmation* of Zeng–Liu–Ratnavelu's refutation, not a de novo
discovery — the campaign's gate re-derives the violation from scratch along two
independent computation paths rather than replaying their argument. The conjectured best constant
`C^TZ_{p,m} = √(x(x+m−1)) / (x^p + m − 1)^{1/p}` is exceeded by an explicit
rank-one pair at `p = 3/2`, `m = 2`:
`R = 1.03641365870489… > 207/200 > C^TZ_{3/2,2} = 1.03465395185143…`.
Path 1: exact rational Gram-matrix algebra
(`λ₁ = 13/8`, `λ₂ = 3/8`, `σ₁² = 1027/320`, `σ₂² = 3/320`);
Path 2: 60-digit mpmath construction. Agreement to `1e-40`; margins
`~1.4e-3` above and `~3.5e-4` below against a `1e-20` safety floor.
Control: 5,000 random rank-one pairs at the same `(p, m)` — only ~1% exceed
the conjectured constant and the witness sits near the true extremum, so the
gate is not reporting a violation any input would produce. **Verdict: BREAK.**

## B — Base-case kill

**Route attacked.** Induction or irrationality arguments whose load-bearing
step is a finiteness / non-existence claim at the base — the step the rest of
the proof assumes without exhibiting.

**Gate construction.** Instantiate the base case exactly, with all
constraints, and solve it. If solutions exist, the induction never starts and
nothing downstream matters.

**Worked example.** Suman ζ(5) (`docs/audits/suman-zeta5.md`). Eq. (48) is
claimed to have no integer solutions; it is the induction base for Theorem 1.
At `n = 1`, `d_1 = lcm(1) = 1`, constraints `0 ≤ k ≤ d_1` and `d_1 ∣ kb`:
solutions `(a,b,k) = (2,1,0)` (`a = 2b`) and `(1,1,1)` (`a = b`) exist.
Suman dismisses these because they "would force ζ(5) ∈ {1,2}" — but
solvability of Eq. (48) is independent of whether ζ(5) is an integer.
**Verdict: BREAK.**

## C — WZ-certificate audit

**Route attacked.** Claims resting on a Wilf–Zeilberger certificate pair — the
"a rational function proves the identity" genre, where the decisive object is
a machine-produced certificate the reader is expected to trust.

**Gate construction.** Independently re-verify the certificate pair by exact
evaluation on a dense grid. The known trap is Pochhammer conventions at
negative indices: `(a)_{-n} = (-1)^n/(1-a)_n` must be enforced, not assumed.

**Worked example.** Jana–Karmakar (arXiv:2501.10109). The claimed WZ pair
survived 630 + 630 exact telescoping checks (Lemmas 2.1 and 3.1) and 96
checks of the summed theorems, so the route stayed off the target list —
the audit produced a PASS, not a kill. The audit still earned its keep: the
first harness produced 66 false mismatches by omitting the `(a)_{-n}`
convention above; that convention is now enforced in
`scripts/harness/pochhammer.py`. A type-C gate that declines to fire is the
discipline working as designed: a pass escalates, never forced.

## D — Finite q-expansion

**Route attacked.** Partition congruences and modular-equation claims whose
decisive content is exact identities between q-series — checkable term by
term, but only to the depth actually computed.

**Gate construction.** Compute the generating function exactly to a fixed
depth, verify the congruence predictions on their arithmetic progressions and
the modular equation coefficient-by-coefficient. Depth is the open question
for D-gates: 81 points carried no information; 6,747 did
(`docs/GATE-BEFORE-PROVE.md`).

**Worked example.** PDN1 congruences, Du–Yao, arXiv:2503.00004
(`docs/audits/pdn1.md`). Exact series of `J_2^2/J_1^5` through `q^500`
(`PDN1(2) = 18`); Theorems 1.1–1.2 congruence predictions on stated APs mod
`5^α`, `7^α`; modular equation (3.13) with the paper's `σ_i` polynomials
through degree 80 — maximum absolute difference 0 across 6,747 divisibility
points. **Verdict: PASS (escalate)** on the type-D route; type G not
attempted. The authors' Mathematica supplements were cloned under
`incoming/pdn1/` for provenance.

## E — CAS-transcript replay

**Route attacked.** Computer-assisted proofs whose decisive steps live inside
a CAS session: guessed recurrences, Ore-algebra Gröbner bases, creative
telescoping certificates. The transcript *is* the proof, and it is usually
unpublished.

**Gate construction.** Re-run the transcript. When the tooling is not
available on the campaign stack, record blocked — do not invent operators.
("Same stance as 2(f) OreReduce: record blocked, do not invent operators,"
`docs/audits/pdn1.md`.)

**Worked example.** q-TSPP, the q=1 case of Koutschan's proof
(arXiv:0906.1018; `docs/blueprint/qtspp-q1.md`). The paper's §5.3 prints only
a factorization of the leading coefficient of the order-7 diagonal
recurrence, not the operator; the ∂-finite description (65 guessed
recurrences, 5 MB) was never published. The recovered q-case notebook
documents a 13 MB diagonal operator requiring 3 GB RAM and the
HolonomicFunctions package — unavailable. The campaign's answer is a
parametric Lean formalization of the closing argument (`DiagonalCertificate`;
`diagonal_identity_of_certificate` kernel-checked, sorry-free) modulo
coefficient recovery, plus author contact for the true coefficients. Type E
is the one attack type the campaign currently documents as tooling-limited:
the route exists before the infrastructure does.

## F — Counterexample search

**Route attacked.** Universal claims over finite combinatorial objects. The
classic BREAK engine: one witness ends the argument.

**Gate construction.** Exhibit the witness explicitly; close both sides —
the upper bound by construction, the lower bound by exact (branch-and-bound
or exhaustive) search. The control runs the same solver on graphs where the
answer is known both ways, proving it is not an always-fire detector.

**Worked example.** Baste domination (`docs/audits/baste-domination.md`).
Claim: every finite regular graph of positive degree satisfies
`γ(G) ≤ γ_e(G)`. False already at `Δ = 3`: a 50-vertex witness with
`γ(G) = 16 > 15 = γ_e(G)`; `γ_e(G) = 15` closed on both sides,
`γ(G) ≥ 16` by the campaign's own exact branch-and-bound dominating-set
solver. Control: the solver finds small dominating sets when they exist (K4
at budget 1; Petersen at budget 3) and correctly declines when they don't
(Petersen at budget 2) — and the control caught a real bug (`n =
NUM_VERTICES` hardcoded instead of `n = len(adj)`) the moment it tried a
non-target graph. **Verdict: BREAK.** (Same mechanism: Chung–Graham–Spiro;
Cohen subadditivity, witness `(31, 3928)` with 500 random pairs showing zero
violations elsewhere.)

## G — Logical-gap exposure

**Route attacked.** Proofs whose key step is a structural premise about an
algebraic object — no computation on the claim itself, just the exact lemma
the route needs, falsified at the precise failure point.

**Gate construction.** Isolate the premise; exhibit the smallest instance
where it fails; name the failure point. The blueprint header for G-audits
reads "Claim (route, not the theorem)."

**Worked example.** Lamé 1847 (`docs/blueprint/lame-1847.md`). The route
needs `ℤ[ζ_p]` to be a unique factorization domain for the prime at hand.
The first prime conductor with class number `> 1` is `p = 23`, where
`h(ℚ(ζ_23)) = 3` — and `h⁻_p = 1` for every prime `p < 23` (Maillet/OEIS
determinant formula; gate `scripts/gates/lame_h23.py`), so 23 is exactly the
point of failure. Kummer knew the factorization theory collapses as soon as
`h_p > 1`. FLT itself stands; the route dies at `p = 23`. **Verdict:** the
gates `lame_h23` and `lame_ideal_neg23` are locked **PASS**: they confirm the
fact `h(ℚ(ζ_23)) = 3`, and that confirmed fact refutes the route. A verdict
attaches to the gate's claim, not to the paper's conclusion (§3).


## 5. The evidentiary disciplines

§4's attack types are only as honest as the instruments that implement
them. A gate is a piece of software written by people who already
believe the target is fragile; every discipline below exists because
the campaign caught itself — or was caught — cutting a corner it had
sworn not to cut. They are stated as rules, each with the failure mode
it guards against and the campaign incident that earned it.

## 5.1 Paper-first: pin and read the actual paper

No gate is built from a secondary summary. The procedure is mechanical:
fetch the version of record, record its SHA-256 and byte count, extract
the text, and read the argument before deciding what the load-bearing
step is. The dossier that supplied our targets (`corpus/`) finds
targets; it does not reliably describe the mathematics.

Three incidents in one week earned this rule its absolute form. The
dossier described the Frankl union-closed target as an entropy-method
argument by "S. Schäge"; the actual paper is a combinatorial
deletion-sequence argument by Roberto Demontis
(`docs/audits/frankl-uc-gap.md`). It described the Goldbach
semi-continuous target at v2 with a "master inequality (24)"; the live
paper is v5, whose claim has shifted to a "relative proof" with the
dominant case resting on admitted-unproven inequalities
(`docs/audits/gb-sce.md`). It described the Legendre target at v2 with
a "Theorem 2.18"; the live paper is v4 and the decisive step is
Proposition 2.18 (`docs/audits/leg-ns.md`). In each case the gate that
would have been built from the dossier would have tested the wrong
object — the Sárközy failure mode, named for the campaign's own early
mistake of aiming a gate at a paraphrase rather than a lemma.

## 5.2 Discrimination control: a check that cannot fail is not evidence

Every gate must demonstrate the *opposite* verdict where the opposite
is correct, with matched single-variable controls. The control is part
of the gate's construction, not an afterthought, and it must be
discriminating: run the same instrument on a setting where Confirm (or
BREAK) is the known-correct answer, and require it to produce that
answer.

The controls have caught real bugs, not hypothetical ones. The Baste
counterexample gate's control exposed a hardcoded `n = NUM_VERTICES`
that would have silently narrowed the search. The Goldbach S.C.E. gate
ran Dusart's inequality, the paper's own Teeter bounds, and its exact
model identities through the same instrument — all Confirm — while the
three unproven inequalities fired BREAK, and its partition-count column
reproduced the known Goldbach counts (127, 810, 5402 at 10⁴/10⁵/10⁶),
so the instrument is calibrated, not trigger-happy. The Mahler
counting-lemma gate's wrong-θ control visibly breaks the bound the
right-θ setting confirms. And the discipline cuts the other way too:
when the Legendre target's residue turned out to be asymptotic and
analytic rather than a displayed inequality, the honest move was to
downgrade to a prose audit rather than force a numeric gate onto a
non-finite residue — a gate that cannot be calibrated is not run.

## 5.3 Gate before prove: no formalization without a numeric gate

No Lean formalization begins until the claim it targets has survived a
numeric gate, and formalization targets carry a no-sorry,
kernel-checked standard. The gate decides *whether* the statement is
worth proving; the prover then decides whether the proof is correct.
Conflating the two — formalizing a statement nobody has checked — is
how effort gets spent on false lemmas.

The q-TSPP line follows this order explicitly: the milestone-1
Stembridge shakedown (a sorry-free, kernel-checked recurrence-uniqueness
lemma) preceded the milestone-2 diagonal identity, which was built on
top of it, and milestone 3 is blocked on recovering the recurrence
coefficients from the authors rather than on inventing them. The
discipline also sets the boundary of what formalization is *for* here:
it is not applied to BREAK verdicts at all — a refuted route needs no
formalization of its false lemma.

## 5.4 Fail-closed replay: hash-pinned inputs, any mismatch fails the lane

Replay lanes recompute from pinned inputs in shards, and any
checksum mismatch, any row disagreement, any lane that cannot be
reproduced fails the lane — there is no "close enough" and no lane that
passes on partial evidence. The Gomila Λ-bound finite lane verified
3,149,013/3,149,013 rows across 15 shards checksummed at the pinned
upstream commit; the Dini, barrier, and tail lanes each carry their own
sealed logs. The Pólya canonization rests on 91 SHA-256-pinned chunk
certificates, each independently re-verifiable. Fail-closed is what
makes a PASS verdict mean something: it is the reason the Jacobian-2D
computational PASS and the Mahler counting-lemma PASS can be cited
without hedging.

## 5.5 Independent anchors and dual implementation: two layers, not one

A single implementation can be wrong in ways its own tests cannot see.
The campaign therefore uses two distinct layers. First, **brute-force
anchors**: tiny, obviously-correct computations at small parameters that
the real implementation must agree with. The Pólya sieve's p=2 bug —
the 2-adic inverse does not exist for p=2, giving L(100000) = −2074
instead of −288 — was caught by brute-force anchors before a second
implementation existed. Second, **clean-room dual implementation**: a
second implementation written without reading the first (or its
sources), which must agree on every certificate — 91/91 chunks for
Pólya. The anchor catches the bug class "wrong algorithm, confidently
executed"; the dual implementation catches the class "right algorithm,
wrong code". One layer is a precaution; two is evidence.

## 5.6 Durable job discipline: log to disk, mark the exit, verify by hand

Long-running jobs write their output to a durable log under the
workspace, append an explicit exit marker, and are verified by reading
the log — never by trusting a completion notification. This rule was
written after a background dependency-update job died silently and cost
an hour before anyone noticed the build directory was empty. Boring,
un glamorous, and load-bearing: every multi-hour sieve, Lean build,
and replay lane in the campaign follows it.

## 5.7 Where the method failed, and what caught it

The credibility backbone of this paper is not the disciplines but the
record of their violations. Sources: `docs/WORKPLAN.md` checkpoints.

- **Paper-first violated four times before it was retrofitted.**
  Targets #1–#3 were gated from abstract fetches, not papers. The rule
  now opens the protocol document (`docs/GATE-BEFORE-PROVE.md`), and
  every audit note since records its paper pin.
- **Ghost corpus entries.** Dossier table rows with no body section —
  claims about claims with nothing behind them. Corpus hygiene is now
  part of target intake.
- **Fabricated or garbled identifiers.** A "Reed/Zenodo γ" and a
  "Sun/Zenodo Catalan" entry turned out to reference nothing
  retrievable. Identifiers are now resolved to a fetchable artifact
  before a target is accepted.
- **The odd-zeta verdict correction (2026-09-20).** An early "Λ_m
  unevaluable" verdict was superseded by the Lemma 5.1 BREAK after
  re-examination; the correction is recorded with both verdicts
  visible and the prior one marked superseded, not deleted.
  History is append-only.
- **A harvested Lean snippet was itself buggy.** A third-party-LLM
  proof fragment proposed as the Suman gate carried the empty
  constraint `1 ≤ k ∧ k ≤ 0`. Harvested artifacts are inputs to be
  gated, never components to be trusted — including harvested proofs
  of the lemmas we attack.
- **Harness bugs caught by controls and anchors**, summarized here
  because each one justifies a discipline above: the Pochhammer
  negative-index convention (type C), the hardcoded
  `n = NUM_VERTICES` (type F), the p=2 sieve inverse (§5.5).

None of these were caught by peer review, because none of them were
visible to peer review. They were caught by re-running things. That is
the entire argument of this paper.


## 6. Case studies

Four studies, chosen to exercise every part of the playbook: a
refutation, a confirmation, a canonization, and an unfinished line.
Each is mapped to the §4 attack type and the §5 disciplines it leans
on. Full records live in `docs/audits/`; what follows is one page
each.

## 6.1 Kempe–Fritsch: the refutation case (BREAK)

In 1879 Alfred Kempe published a proof of the four-color theorem; in
1890 Heawood killed it with a single map. The decisive step was finite
and checkable — the claim that two simultaneous Kempe-chain
interchanges can always be performed without conflict at a degree-5
vertex — and the refutation was a witness, not a counter-argument
(`docs/audits/kempe-fritsch.md`). The campaign's gate replays that
witness mechanically: Heawood's map, run through the interchange
procedure, fails. The control is the procedure itself on maps where it
succeeds.

Kempe is in this paper as calibration, not as a trophy — the
mathematics was settled in the 1890s. Its lesson is the one the whole
campaign is built on: a proof can be accepted for a decade and still
die at one finite residue, and "the local case is clear" is a
fragility signature, not a proof. It also exercises the paper-first
discipline at its most literal: the gate pins the modern telling
(Gethner et al., *Involve* 2009) and Heawood's map, not anyone's
summary of them.

## 6.2 Gomila Λ-bound: the confirmation case (audit PASS)

Jude Gomila's claim — a de Bruijn–Newman constant bound Λ ≤
0.1787854, via a public candidate-audit repository — was replayed in
four lanes and passed in all four (`docs/blueprint/gomila-lambda.md`):
the finite lane verified 3,149,013/3,149,013 rows across 15 shards
checksummed at the pinned upstream commit; the Dini lane sealed 4/4
legs; the barrier lane closed 883/883 prisms under a 54-check parser;
the tail lane held 36/36 at both 256 and 512 bits. Every lane is
fail-closed (§5.4): any mismatch would have failed the lane, and the
sealed logs are re-verifiable.

The claim's lineage: Polymath15's Theorem 1.2 gave the method and the
then-best bound Λ ≤ 0.22; Platt–Trudgian (2020) pushed it to 0.2;
Gomila's 0.1787854 — exactly 129/800 + 87677/5,000,000 — is a claimed
further improvement instantiating Polymath15's machinery at an exact
rational parameter row. The audit's question was never whether the
lineage is respectable; it was whether this instantiation's ~3.15
million certificates check out. They do.

This case study exists to prove the campaign is not a
refutation machine. The same instruments, the same controls, the same
hostile posture — and the verdict is PASS, recorded with the same
weight as a BREAK. A methodology that cannot confirm is not an audit;
it is a demolition crew.

## 6.3 Pólya's conjecture: the canonization case (BANKED, off the lock)

Pólya's conjecture — that L(n) ≤ 0 for all n, where L is the
Liouville summatory function — was disproved in 1958, but no
*checkable* record of the smallest counterexample existed in one
place. The campaign banked one: the smallest n with L(n) = +1 is
906,150,257, recomputed by two independent sieves, with 91
SHA-256-pinned chunk certificates and a 370/370 verifier, plus a Lean
formalization of the finite slice through 100 (`docs/audits/polya.md`).

Pólya is the case study for §5.5. The p=2 sieve bug — the 2-adic
inverse does not exist, silently corrupting L(100000) from −288 to
−2074 — was caught by brute-force anchors *before* the second
implementation existed; the clean-room second sieve then agreed on
91/91 chunks. Neither layer alone would have been evidence; together
they are why the banked counterexample can be cited. It sits off the
verdict lock deliberately: canonization is infrastructure, not a
verdict about a route.

## 6.4 q-TSPP: the unfinished line (in progress)

The q-TSPP audit — formalizing Okada's determinant route to the
totally symmetric plane partition identities — is the campaign's
correct-proof infrastructure build, not a BREAK hunt. Milestone 1
closed with a sorry-free, kernel-checked recurrence-uniqueness lemma;
milestone 2 with a parametric order-7 diagonal certificate (8,656/8,656
jobs, zero errors). Milestone 3 is blocked on recovering the explicit
q=1 recurrence coefficients: the paper does not print them, the thesis
does not yield them, and the authors' site survives only on Wayback.
The author has been contacted; the line waits on his reply.

It belongs in this paper for one reason: it is what "gate before
prove" (§5.3) looks like as a multi-month project rather than a
slogan. The numeric gates came first, the formalization builds on
them, and the blocker — the unrecovered recurrence coefficients — is
stated plainly instead of being worked around. It stands as the
honest boundary of what the campaign could do alone.


## 7. Limitations

This section states what the playbook cannot do. Each limitation is
one the campaign actually hit, not a hypothetical.

## 7.1 Replay cannot catch specification errors on its own

A gate replays the computation the paper describes. If the paper
describes the *wrong computation* — proves a statement adjacent to
the one it claims — the gate passes and the error survives. The
campaign's first BREAK is the standing example
(`docs/audits/gamma-aejonanonymous.md`): the audited formalization
proved `¬ is_rational_gamma`, a statement about its own predicate,
not the irrationality of mathlib's γ. The computation was correct;
the specification was wrong. A separate *statement-fidelity* audit —
checking that the formal statement says what the paper claims it
says — is a partial remedy. It is not a closed gap: fidelity audits
are manual, unglamorous, and easy to skip, which is exactly why the
error class survives.

## 7.2 Nonconstructive arguments force SKIP

Where there is no witness to exhibit and no computation to replay,
there is no gate. Nonconstructive existence proofs, pure compactness
arguments with no extractable bound, and routes whose decisive step
cannot be instantiated at any parameters end in SKIP (§3) — honestly,
but unavoidably. The Mahler 3D audit is the boundary case: every
finitely checkable layer passed, the prose audit found no defect, and
the connectedness step that carries the conclusion has no finite
residue at all. The target sits on the watch list, which is the
correct output of the method and also its admission of reach.

## 7.3 The certificate cost curve is unsolved

GB-scale certificates against kernel checking remain an unsolved
tradeoff. The q-TSPP certificates are hundreds of megabytes; checking
them inside a proof assistant's kernel is not currently feasible, so
the campaign checks them outside the kernel and formalizes the
*shape* of the argument instead. That is a principled compromise, not
a solution: the trust migrates from the kernel to the external
checker, and the external checker is exactly the kind of software
this paper argues should be distrusted. Verified meta-level checkers
are the open problem; until they exist, large-certificate proofs get
a weaker standard of evidence, stated plainly.

## 7.4 Type E remains tooling-blocked

CAS-transcript replay — re-running a paper's "by symbolic
computation" steps independently — is the attack type the campaign is
worst equipped for. The tooling (verified computer algebra, Ore
algebras, q-Zeilberger infrastructure in the available provers) does
not exist at the needed level, and building it is a multi-year
project, not an audit step. Several targets carry "capability-limited"
notes for exactly this reason. The honest response is the one used in
this paper: mark the limitation, record what was checked by other
means, and do not pretend a partial replay is a full one.

## 7.5 Selection and window

Stated in §2 and repeated here because it belongs with the other
limitations: the targets were harvested for fragility, not sampled,
and the campaign window is weeks. Nothing in this paper estimates the
base rate of defective proofs. The method is reproducible; the
results are not a survey.


## 8. Related work

This paper's contribution is a playbook and its audit log, not a new
formalism. It stands in three existing currents, and differs from
each in one specific way.

**Proof assistants and formalization.** Large-scale formalization
projects have shown that deep mathematics can be checked by kernel —
the trend this campaign depends on for its "gate before prove"
discipline (§5.3). The difference is direction: formalization
typically starts from a proof believed correct and renders it
checkable. This campaign starts from a proof under suspicion and
tries to break it. The two meet at the boundary the q-TSPP line
currently occupies: formalization of a route whose correctness is
still being established.

**The scientific replication movement.** Empirical science learned —
expensively — that published results often do not survive
re-execution, and built preregistration, replication studies, and
adversarial collaboration in response. Mathematics has largely
exempted itself from that reckoning on the grounds that proofs are
self-verifying. They are, where the proof *is* the reasoning. The
verification gap (§2) is the observation that, increasingly, part of
the proof is a computation — and computations are empirical claims
about what a machine did. This paper ports the replication movement's
core insight (trust the re-run, not the report) to the part of
mathematics that is actually software.

**Prior proof-audit and verification projects.** Independent
verification of claimed results has a long history — from Heawood's
map against Kempe (§6.1) to modern computer-assisted proof checking
(Flyspeck, the four-color formalizations). What this campaign adds is
the *routine* form: small, fast, disposable gates aimed at the single
load-bearing step, run before anyone decides the claim deserves deep
attention. The audit catalog is the evidence that the routine form
catches real defects at low cost — most gates here ran in seconds to
hours, not months.

What none of the three currents supply, to our knowledge, is the
combination this paper documents: a fixed disposition taxonomy with a
CI-enforced verdict lock (§3), a mechanism-classified attack
repertoire (§4), and a published log of the method's own failures
(§5.7). If that combination exists elsewhere, we would like to cite
it.


## 9. Conclusion

The playbook is the product. Every pattern in §§3–5 — the five
dispositions and the rules that keep them from drifting, the
mechanism-classified attacks, the evidentiary disciplines and the log
of their violations — is reusable against the next claim, by anyone,
without our involvement. That is the test this paper sets for itself:
a reader who disagrees with every verdict in the audit catalog should
still be able to run every gate, check every control, and re-derive
every disposition from the pinned artifacts.

What the campaign found, in brief: most fragile-looking routes are
fragile. Seventeen of twenty-five locked gates refute the lemma they
target; three more routes fell to proof reading where no gate could
reach; two targets survived everything thrown at them and are recorded
as PASS with the same weight. The method's own failures — abstract
fetches gated as papers, ghost corpus entries, a corrected verdict,
harness bugs caught by controls — are part of the record, because a
methodology that hides its failures cannot be trusted about its
successes.

The open problems are stated in §7 and not repeated here, except the
one that matters most: the certificate cost curve. Until large
computational certificates can be checked inside a proof kernel at
reasonable cost, the strongest computer-assisted proofs will rest on
external checkers — software of exactly the kind this paper argues
should be distrusted. Closing that gap is the work that would make
this playbook obsolete. We would welcome it.


# Appendices — draft (2026-09-23)

## A. Verdict-log schema and lock mechanics

Every locked gate writes a machine-readable verdict record to
`results/<name>_gate_meta.json`. The schema, by example
(`results/gb_sce_gate_meta.json`):

| Field | Content |
|---|---|
| `target` / `source` | gate id; paper pinned as `arXiv:IDvN` |
| `local_pdf` / `pdf_sha256` | pinned paper artifact and its hash |
| `lemma` | the paper's claim under test, quoted or cited by location |
| `instance` | the parameters the gate instantiated |
| `false_instance` | the concrete witness (for BREAK) |
| `verdict` | `BREAK` or `PASS` |
| `not_this_gate` | what the verdict does *not* cover (polarity rule, §3) |
| `timestamp` / `elapsed_s` | when and how long the gate ran |
| `ok` | whether the gate itself executed cleanly |

Gate-specific fields (counts tested/violated, margins, control
results) extend the schema; the fields above are mandatory.

The lock itself is `EXPECTED_VERDICT` in `scripts/gates/check.py`: a
map from gate id to `(meta-file, expected-verdict)`. The aggregate
run executes every gate, compares each recorded verdict against its
expectation, and reports `[ok]` or `[DRIFT]` per gate; any drift —
in either direction — fails the run. Adding a gate means adding its
entry in the same commit as the gate. Removing or re-pinning a
verdict requires the re-audit to be recorded first. Prose
dispositions (GAP, SKIP, UNKNOWN) and off-lock confirmations are not
in the map; they live in `docs/audits/` (§3).

## B. Gate harness conventions

- **Stdlib first.** Gates are dependency-free Python where possible
  (exact rational arithmetic via `fractions`, sieves by hand); where
  heavy numerics are needed the dependency is stated and pinned.
  A gate that cannot run on a fresh checkout is not a gate.
- **Deterministic.** Fixed seeds; no wall-clock dependence; no
  network access at run time. Inputs are hash-pinned files under
  `incoming/` or generated deterministically in the script.
- **Self-verifying inputs.** Hardcoded mathematical data (facet
  lists, group tables) carries its own consistency checks —
  supporting-plane verification, Euler characteristic, extremality —
  executed before the gate logic runs.
- **Controls are code, not commentary.** Every gate implements its
  discrimination control as a runnable function whose result is
  recorded in the meta JSON (e.g. `dusart_control_ok`,
  `wrong_theta_breaks_bound`).
- **Exit codes mean it.** Exit 0 with `verdict` set: the gate ran
  and decided. Any exception, missing input, or guard failure
  (e.g. paper hash mismatch) is an abort, never a verdict.
- **Timestamps refresh; verdicts don't.** The aggregate run rewrites
  `timestamp` fields across meta files; verdict fields change only
  by re-audit commit.

## C. Audit catalog (locked gates)

Gate → verdict → attack type(s), from `EXPECTED_VERDICT`
(`scripts/gates/check.py`). Types per the dossiers
(`corpus/Fragile-Route_Harvest_Dossier*.md`,
`corpus/lean4-attack-harvest.md`), the §4 worked examples, and the
audit notes (`es_cover` is D per its own note's "only Type-D-style
instance checking"; `giuga_oracle` is infrastructure, see note).

| Gate | Verdict | Type |
|---|---|---|
| suman_eq48 | BREAK | B |
| odd_zeta_1609 | BREAK | B |
| es_cover | PASS | D |
| rr_qexpand | PASS | D |
| pdn1 | PASS | D |
| giuga_oracle | PASS | infra¹ |
| lame_h23 | PASS | G |
| lame_ideal_neg23 | PASS | G |
| cohen_subadditivity | BREAK | F |
| baste_domination | BREAK | F |
| sarkozy_sum_product | BREAK | F |
| tang_zhang_schatten | BREAK | A |
| thakur_carlitz | BREAK | F |
| chung_graham_spiro | BREAK | F |
| salez_youssef_logsobolev | BREAK | G |
| tpc_area | BREAK | F |
| es5_eq35 | BREAK | A |
| cat_g | BREAK | E |
| krr_cl | BREAK | F |
| tpc_gn | BREAK | A |
| jac_2d | PASS | D+E |
| tait_tutte | BREAK | F |
| kempe_fritsch | BREAK | B/F |
| gb_sce | BREAK | A |
| mah_3 | PASS | A+G |
| **Total: 25 gates** | **17 BREAK / 8 PASS** | **machine-checked against `EXPECTED_VERDICT` in `scripts/gates/check.py`** |

Prose dispositions (not on the lock): FRK-UC (GAP, G),
LEG-NS (GAP, G), Erdős–Straus Thm-10 (GAP, G, repairable),
JAC-2D type-G (PASS, G), NCI (SKIP), quantum Hedetniemi
(UNKNOWN). Off-lock confirmations/canonizations: Gomila Λ-bound
(audit PASS), Pólya (BANKED).

¹ `giuga_oracle` is a standing verification oracle (known Giuga
composites checked against Korselt), not an attack on a route; it
carries no A–G letter.

