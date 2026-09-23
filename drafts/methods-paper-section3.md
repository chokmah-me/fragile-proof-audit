# §3. The disposition taxonomy — draft (2026-09-23)

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
