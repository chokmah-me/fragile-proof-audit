# Sec. 4. The evidentiary disciplines - draft (2026-09-23)

Sec. 3's attack types are only as honest as the gates that implement
them. A gate is a piece of software written by people who already
believe the target is fragile; every discipline below exists because
the campaign caught itself - or was caught - cutting a corner it had
sworn not to cut. Each is stated as a rule, with the failure mode it
guards and the incident that earned it.

## 4.1 Paper-first: pin and read the actual paper

No gate is built from a secondary summary. The procedure is mechanical:
fetch the version of record, record its SHA-256 and byte count, extract
the text, and read the argument before deciding what the load-bearing
step is. The dossier that supplied our targets (`corpus/`) finds
targets; it does not reliably describe the mathematics.

Three incidents in the campaign's first days are why the rule admits no exceptions. The
dossier described the Frankl union-closed target as an entropy-method
argument by "S. Schage" - the paper is a combinatorial
deletion-sequence argument by Roberto Demontis. It described the
Goldbach semi-continuous (S.C.E.) target at v2 with a "master
inequality (24)" - the live paper is v5, its dominant case resting on
admitted-unproven inequalities. It described the Legendre target at v2
with a "Theorem 2.18" - the live paper is v4, decisive step
Proposition 2.18. In each case a dossier-built gate would have tested
the wrong object - the Sarkozy failure mode, named for the campaign's
own early mistake of aiming a gate at a paraphrase rather than a
lemma. The dossier's paraphrase had Sarkozy's threshold as $|A| \ge cp$;
the conjecture as stated reads $|A| > (1/2-c)p$ - under the paraphrase the
claim fell to any small set and the BREAK was vacuous. The retrofit
caught it.

## 4.2 Discrimination control: a check that cannot fail is not evidence

A discrimination control is required where it bites: whenever the
verdict is an existence or non-existence claim resolved by search or
sampling. Such a verdict can be produced by a search that is too
narrow, too broad, or aimed at the wrong object, and none of those
failures announces itself - everything the campaign has learned from
controls came from this class. The control runs the gate in the
opposite direction on a matched input where the opposite verdict is
the known-correct answer: for a PASS, perturb the claim and confirm
the check rejects the near-miss; for a BREAK, supply a regime where
the refuted claim is true and confirm the gate declines. Matched and
single-variable - a control that varies two things at once reads like
evidence and is worse than none.

Where the verdict is an exact equality or divisibility between two
independently computed objects, a discrimination control is ceremony:
any discrepancy is caught by construction. What needs auditing there
instead is implementation equivalence (does the fast path reproduce
the exact oracle? see `pdn1`'s fast-path self-test) and depth (is the
sample large enough to carry information? `pdn1` at 81 points was not;
at 6,747 it is).

Every control outcome recorded in a receipt JSON is embedded in its
gate's own meta JSON, under the `controls` key - control name,
verdict, ok, receipt path, receipt SHA-256, and receipt timestamp --
by `scripts/gates/record_controls.py` on every aggregate run. A gate
whose meta carries `"controls": []` has no *separate* control receipt:
that is the honest record for the four exact-equality exemptions and
for the two inline controls (`gb_sce`, documented in its audit note;
`mah_3`, inside the gate).

The controls have caught real bugs, not hypothetical ones. The Baste
counterexample gate's control exposed a hardcoded `n = NUM_VERTICES`
that would have silently narrowed the search. The Goldbach S.C.E. gate
ran Dusart's inequality, the paper's own Teeter bounds, and its exact
model identities through the same gate - PASS on all three - while
the three unproven inequalities fired BREAK, and its partition counts
reproduced the known Goldbach totals (127, 810, 5402 at $10^4$/$10^5$/$10^6$).
The Mahler counting-lemma gate's wrong-$\theta$ control visibly breaks the
bound the right-$\theta$ setting confirms. And the discipline cuts the other
way too: when the Legendre target's residue turned out to be
asymptotic rather than a displayed inequality, the honest move was a
prose audit, not a forced numeric gate - a gate that cannot be
calibrated is not run.

## 4.3 Gate before prove: no formalization without a numeric gate

No Lean formalization begins until the claim it targets has survived a
numeric gate, and formalization targets carry a no-sorry,
kernel-checked standard. The gate decides *whether* the statement is
worth proving; the prover then decides whether the proof is correct.
Conflating the two - formalizing a statement nobody has checked - is
how effort gets spent on false lemmas.

The q-TSPP line follows this order: the milestone-1 Stembridge
shakedown (sorry-free, kernel-checked) preceded the milestone-2
diagonal identity, and milestone 3 is blocked on recovering the
recurrence coefficients from the authors rather than inventing them. The
discipline also sets the boundary of what formalization is *for* here:
it is not applied to BREAK verdicts at all - a refuted route needs no
formalization of its false lemma.

## 4.4 Fail-closed replay: hash-pinned inputs, any mismatch fails the lane

Replay lanes recompute from pinned inputs in shards; any checksum
mismatch, row disagreement, or unreproducible step fails the lane --
no "close enough," no partial passes. The Gomila $\Lambda$-bound finite lane verified
3,149,013/3,149,013 rows across 15 shards checksummed at the pinned
upstream commit; the Dini, barrier, and tail lanes each carry their own
sealed logs. Fail-closed is what makes a PASS verdict mean something: it is the
reason the Jacobian-2D computational PASS and the Mahler
counting-lemma gate PASS can be cited without hedging. (The Mahler
*claim* is a different matter - Sec. 6.2: the gate passed, the claim as a
whole is SKIP.)

## 4.5 Independent anchors and dual implementation: two layers, not one

A single implementation can be wrong in ways its own tests cannot see.
The campaign therefore uses two distinct layers. First, **brute-force
anchors**: tiny, obviously-correct computations at small parameters
that the real implementation must match. The Polya sieve's p=2 bug --
the 2-adic inverse does not exist for p=2, corrupting L(100000) from
-288 to -2074 - was caught by brute-force anchors before a second
implementation existed. Second, **dual implementation**: a second implementation, written
without reading the first, which must agree on every certificate --
91/91 chunks for Polya. The anchor
catches the bug class "wrong algorithm, confidently executed"; the
dual implementation catches the class "right algorithm, wrong code".
One layer is a precaution; two is evidence.

## 4.6 Durable job discipline: log to disk, mark the exit, verify by hand

Long-running jobs write their output to a durable log under the
workspace, append an explicit exit marker, and are verified by reading
the log - never by trusting a completion notification. This rule was
written after a background dependency-update job died silently and cost
an hour before anyone noticed the build directory was empty. Every
multi-hour sieve, Lean build, and replay lane in the campaign follows
it.

## 4.7 Where the method failed, and what caught it

The credibility backbone of this paper is not the disciplines but
the record of their violations (sources: `docs/WORKPLAN.md`
checkpoints).

- **Paper-first: seven provenance failures, one rule.** Before the
  rule existed, targets #1--#3 - `cohen_subadditivity`,
  `baste_domination`, `sarkozy_sum_product` - were gated from the
  corpus doc plus an abstract fetch, no PDF pinned; all three were
  retrofitted with the real PDFs on 2026-09-21, and the retrofit
  caught Sarkozy's misstated threshold (Sec. 4.1). The same day, four more
  provenance failures in one session: `tang_zhang_schatten` and
  `thakur_carlitz` (corpus text image-corrupted -> real PDF fetch),
  `chung_graham_spiro` (ghost entry - table row, no body section, no
  arXiv ID -> located by live web search), and NCI (the corpus claimed
  a "Verifiable Gate" the real paper, a first-moment existence proof,
  could not support -> SKIP). The rule now opens the protocol document
  (`docs/GATE-BEFORE-PROVE.md`), and every audit note since records
  its paper pin.
- **Ghost corpus entries.** Dossier table rows with no body section --
  claims about claims with nothing behind them. Corpus hygiene is now
  part of target intake.
- **Fabricated or garbled identifiers.** A "Reed/Zenodo $\gamma$" and a
  "Sun/Zenodo Catalan" entry turned out to reference nothing
  retrievable. Identifiers are now resolved to a fetchable artifact
  before a target is accepted. The rejected "Sun/Zenodo Catalan" entry
  is not the Sun preprint the catalog later gated: the live type-E
  BREAK target is Sun's arXiv:2609.04176v1, fetched from arXiv and
  pinned by SHA-256 - a different artifact from the unresolvable
  Zenodo handle.
- **The odd-zeta verdict correction (2026-09-20).** An early "$\Lambda_m$
  unevaluable" verdict was superseded by the Lemma 5.1 BREAK; both
  remain visible, the prior marked superseded, not deleted.
- **A harvested Lean snippet was itself buggy.** A third-party-LLM
  proof fragment proposed as the Suman gate carried the empty
  constraint $1 \le k \land k \le 0$. Harvested artifacts are inputs to be
  gated, never components to be trusted.
- **Harness bugs caught by controls and anchors**, summarized here
  because each one justifies a discipline above: the Pochhammer
  negative-index convention (type C), the hardcoded
  `n = NUM_VERTICES` (type F), the p=2 sieve inverse (Sec. 4.5).

None of these were caught by peer review, because none of them were
visible to peer review. They were caught by replaying things - which
is the entire argument of this paper.
