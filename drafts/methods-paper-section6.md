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
them, and the blocker is stated plainly instead of being worked
around. If the coefficients arrive before submission, this note
becomes a fifth case study; if not, it stands as the honest boundary
of what the campaign could do alone.
