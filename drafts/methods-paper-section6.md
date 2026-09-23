# §6. Case studies — draft (2026-09-23)

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
procedure, fails; the control is the procedure on maps where it
succeeds.

Kempe is in this paper as calibration, not as a trophy — the
mathematics was settled in the 1890s. Its lesson is the one the whole
campaign is built on: a proof can be accepted for a decade and still
die at one finite residue, and "the local case is clear" is a
fragility signature, not a proof. It exercises paper-first at its
most literal: the gate pins the modern telling (Gethner et al.,
*Involve* 2009) and Heawood's map, not anyone's summary of them.

## 6.2 Gomila Λ-bound: the confirmation case (audit PASS)

Jude Gomila's Λ ≤ 0.1787854 claim was replayed in four lanes and
passed all four: 3,149,013/3,149,013 finite rows across 15 checksummed
shards; 4/4 Dini legs sealed; 883/883 barrier prisms closed; 36/36
tail checks at 256 and 512 bits (`docs/blueprint/gomila-lambda.md`). Every lane is
fail-closed (§5.4): any mismatch would have failed the lane, and the
sealed logs are re-verifiable.

Lineage: Polymath15's Theorem 1.2 gave the method and the then-best
bound Λ ≤ 0.22; Platt–Trudgian pushed it to 0.2; Gomila's 0.1787854 —
exactly 129/800 + 87677/5,000,000 — instantiates Polymath15's
machinery at an exact rational parameter row. The audit's question was
whether this instantiation's ~3.15 million certificates check out.
They do.

This case study exists to show the campaign is not a refutation
machine. The same gates, the same controls, the same hostile prior —
and the verdict is PASS, recorded with the same weight as a BREAK. A
methodology that cannot confirm is not an audit.

## 6.3 Pólya's conjecture: the canonization case (BANKED, off the lock)

Pólya's conjecture (L(n) ≤ 0 for all n, L the Liouville summatory
function) was disproved in 1958, but no *checkable* record of the
smallest counterexample existed in one place. The campaign banked one:
n = 906,150,257, recomputed by two independent sieves, 91
SHA-256-pinned chunk certificates, a 370/370 verifier, and a Lean
formalization of the finite slice through 100 (`docs/audits/polya.md`).

Pólya is the case study for §5.5: the p=2 sieve bug was caught by
brute-force anchors before the dual implementation existed, which then
agreed on 91/91 chunks. Neither layer alone is evidence; together they
are why the banked counterexample can be cited. It sits off the
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

It belongs in this paper as "gate before prove" (§5.3) at multi-month
scale: the numeric gates came first, the formalization builds on
them, and the blocker — the unrecovered recurrence coefficients — is
stated plainly instead of being worked around. It is the honest
boundary of what the campaign could do alone.
