# Sec. 5. Case studies - draft (2026-09-23)

The playbook is only as good as its hardest cases. Four studies, one
each for a refutation, a confirmation, a canonization, and an
unfinished line - each mapped to the Sec. 3 attack type and the Sec. 4
disciplines it leans on. Full records live in `docs/audits/`; what
follows is one page each.

## 5.1 Kempe--Fritsch: the refutation case (BREAK)

In 1879 Alfred Kempe published a proof of the four-color theorem; in
1890 Heawood found a map that broke it. The campaign's gate does not
replay Heawood's map. It replays the modern refutation of Kempe's
*algorithm*: the 9-vertex, 21-edge Fritsch graph (Fritsch & Fritsch
1998), transcribed from Gethner et al. Figure 3
(`docs/audits/kempe-fritsch.md`;
`results/kempe_fritsch_gate_meta.json`). The load-bearing lemma is
that Gadget $5_2$'s two successive Kempe-chain switches commute - that
the switch order cannot affect the outcome. On the pinned
pre-coloring, order A (chain(2,G,Y) then chain(3,G,B)) succeeds while
order B (chain(4,G,B) then chain(2,G,Y)) re-introduces G at vertex 8
and tangles vertex 1 irrevocably. The lemma is false, mechanically.

The discrimination control is a matched near-miss: the same
Configuration 2 color pattern on a bare 5-wheel, where the two Kempe
chains are isolated single vertices and both switch orders agree -
confirming the tangle comes from the Fritsch graph's long-range edges
(3--7, 4--7, 7--8), not from the machinery being order-sensitive. A
separate brute-force properness check after every switch, independent
of the gate's own, rules out a fabricated tangle.

Kempe is in this paper as calibration, not as a trophy - the
mathematics was settled in the 1890s, and Heawood's map is the
historical context, not the witness. Its lesson is the one the whole
campaign is built on: a proof can be accepted for a decade and still
die at one finite residue, and "the local case is clear" is a
fragility signature, not a proof. It exercises paper-first at its
most literal: the gate pins Gethner et al. (*Involve* 2009) - Fritsch &
Fritsch 1998 is background, not pinned, and not anyone's summary.

## 5.2 Gomila $\Lambda$-bound: the confirmation case (audit PASS)

Jude Gomila's $\Lambda$ $\le$ 0.1787854 claim was replayed in four lanes and
passed all four: 3,149,013/3,149,013 finite rows across 15 checksummed
shards; 4/4 Dini legs sealed; 883/883 barrier prisms closed; 36/36
tail checks at 256 and 512 bits (`docs/blueprint/gomila-lambda.md`). Every lane is
fail-closed (Sec. 4.4): any mismatch would have failed the lane, and the
sealed logs are re-verifiable.

Lineage: Polymath15's Theorem 1.2 gave the method and the then-best
bound $\Lambda \le 0.22$; Platt--Trudgian pushed it to 0.2; Gomila's 0.1787854 -
$t_0 + y_0^2/2$ with $t_0 = 129/800$ and $y_0^2 = 87677/2,500,000$, i.e.
893927/5,000,000 - instantiates Polymath15's machinery at an exact
rational parameter row. The audit's question was
whether this instantiation's ~3.15 million certificates check out.
They do.

This case study exists to show the campaign is not a refutation
machine - but it must be labeled for what it is. Every lane executed
the audit repository's own verifiers at the pinned commit
(`a74738d`), on freshly downloaded shards whose checksums were
verified first. That is independent *execution* of the author's
checker under a hostile prior, not an independent *reimplementation*
of the mathematics: no discrimination control is recorded, so the
verdict is execution-verified at the pinned commit, not
replay-confirmed. The one fully independent check in the case is the
Platt--Trudgian margin, recomputed from the primary source
(arXiv:2004.09765, Theorem 1): the RH verified height 3,000,175,332,800
minus half the candidate's required height (6,000,000,185,827 / 2 =
3,000,000,092,913.5) leaves 175,239,886.5 exactly. A methodology
that cannot confirm is not an audit - but a confirmation must say
what kind of confirmation it is.

## 5.3 Polya's conjecture: the canonization case (BANKED, off the lock)

Polya's conjecture ($L(n) \le 0$ for all n, L the Liouville summatory
function) was disproved by Haselgrove in 1958, but no *checkable*
record of the smallest counterexample existed in one place. The
campaign banked one: n = 906,150,257 - Tanaka's 1980 value,
recomputed by two independent sieves - with 91 SHA-256-pinned chunk
certificates, a 370/370 verifier, and a Lean formalization of the
finite slice through 100 (`docs/audits/polya.md`).

Polya is the case study for Sec. 4.5: the p=2 sieve bug was caught by
brute-force anchors before the dual implementation existed, which then
agreed on 91/91 chunks. Neither layer alone is evidence; together they
are why the banked counterexample can be cited. It sits off the
verdict lock deliberately: canonization is infrastructure, not a
verdict about a route.

## 5.4 q-TSPP: the unfinished line (in progress)

The q-TSPP audit - formalizing the totally symmetric plane partition
identities - is the campaign's correct-proof infrastructure build, not
a BREAK hunt. The lineage: Okada supplied the determinant reduction
to guessed normalized cofactors, and Koutschan's q=1 and q-case
algorithmic proofs and certificates are the formalization targets.
Milestone 1 - the q=1 Stembridge shakedown - closed with a sorry-free,
kernel-checked recurrence-uniqueness lemma; milestone 2 closed with a
parametric order-7 diagonal certificate (8,656/8,656 jobs, zero
errors). Milestone 3 is blocked on recovering the explicit q=1
recurrence coefficients: the paper does not print them, the thesis
does not yield them, and the author's site survives only on Wayback.
The author has been contacted; the line waits on his reply.

It belongs in this paper as "gate before prove" (Sec. 4.3) at a
projected 6--10-week scale (the blueprint's estimate, not a completed
line) - with a stated exception. No q-TSPP gate is on the verdict
lock, and no off-lock numeric gate preceded the Lean work: this line
formalizes a known-correct proof as infrastructure, so the
gate-before-prove rule - which exists to stop the campaign
formalizing a claim that might be false - has nothing to guard
against. The q=1 shakedown, kernel-checked against the known result,
is the empirical anchor in place of a gate. The blocker - the
unrecovered recurrence coefficients - is stated plainly instead of
being worked around. It is the honest boundary of what the campaign
could do alone.
