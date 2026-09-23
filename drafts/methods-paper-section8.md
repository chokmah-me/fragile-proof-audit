# §8. Related work — draft (2026-09-23)

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
