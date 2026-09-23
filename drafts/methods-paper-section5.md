# §5. The evidentiary disciplines — draft (2026-09-23)

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
