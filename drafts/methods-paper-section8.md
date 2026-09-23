# Sec. 7. Related work - draft (2026-09-23)

This paper claims a playbook and an audit log, not a new formalism.
Every piece it assembles exists in several literatures; what follows
is where each piece comes from and what this paper does
differently.

**The computational bound as a genre: Polymath15.** The closest
existing precedent for the *target* of a replay audit is
Polymath's de Bruijn--Newman project (arXiv:1904.12438; Res. Math.
Sci. 6 (2019)): a published, computer-assisted bound ($\Lambda \le 0.22$)
whose verification story is "the estimates are proved, the numerics
were run by the authors." Its
Table 1 is the archetypal replay-audit artifact: a conversion table
from "RH verified to height H" into a $\Lambda$ upper bound, i.e., a
published claim whose truth depends on someone else's computation.
The difference is posture: Polymath15 *produced* the computation; a
replay audit replays someone else's under a hostile prior.
Platt and Trudgian (arXiv:2004.09765; Bull. London Math. Soc. 53
(2021), 792--797) then demonstrated that computational claims compose: their verified RH height
(3,000,175,332,800) turns Polymath15's table into $\Lambda \le 0.2$ - the bound
is only as strong as someone else's replay of the underlying
computation. They also model the honest-boundary behavior Sec. 6
advocates: the next table entry would give $\Lambda < 0.19$, which their
height does not reach - "We have not pursued this."

**Verification institutions: mathlib review.** The strongest existing
institution for the thing this paper says is missing is Lean's
mathlib - except that it verifies a different object. Mathlib's PR
review is post-kernel human review: the kernel guarantees logical
correctness, and human reviewers check fitness (naming, generality,
placement, faithfulness to the intended statement). A replay audit is
the mirror image: for computational claims in published prose there
is no kernel, so the audit must supply *both* the correctness check
and the fitness check (is this the claim the paper actually makes?).
What this paper is not proposing is another formal library with a
review queue; the gap is that the computational half of published
proofs has no kernel and no review queue.

**Proof repair: the mechanized cousin of GAP.** Ringer et al.
("Proof Repair across Type Equivalences," PLDI 2021) study what
happens *after* a formal proof breaks: tools that repair proof terms
across type changes, with the kernel re-checking the repaired
artifact. That literature shows what "repairable" means when
verification is mechanized - and throws the informal case into
relief. This paper's GAPs are prose verdicts about informal arguments
with no kernel to confirm a repair, which is why they carry their own
evidentiary standard (verbatim quotation, independent re-reading,
explicit repairability judgment).

**Post-publication scrutiny that does not dispose.** PubPeer-style
commenting finds problems at scale: Ortega and Delgado-Quiros (EPI,
2023) report that of 17,244 PubPeer-commented articles, only 21.5%
of those deserving an editorial notice were ever corrected by the
journal. Scrutiny detects; it does not *dispose* - findings sit in
comment threads without verdicts. The disposition taxonomy (Sec. 2) is
the move from "someone commented" to "a gate fired and the lock
recorded it," with PASS carrying the same weight as BREAK so the
system cannot become a pure refutation machine.

**Adversarial scrutiny in security.** Institutionalized
adversarial scrutiny exists in industry practice. Competitive audit contests (Code4rena, Sherlock) run many
hostile strangers over a code snapshot with multi-stage judging,
deduplication, and fix review; professional cryptographic reviews
(e.g., NCC Group's) inspect source against a pinned commit and
publish findings with severity and exploitability. The judging and
fix-review stages are the analogue of this paper's controls and
verdict-lock discipline; the pinned-commit report header is the
model for the artifact pinning Sec. 1 demands of itself. The difference:
security audits judge code against a threat model, while replay
audits judge a proof against its own claims - and a BREAK must name
the lemma and exhibit the false instance, not merely assign a
severity.

**The replication movement.** Empirical science learned -
expensively - that published results often do not survive
replay, and built preregistration, replication studies, and
adversarial collaboration in response. Mathematics has largely
exempted itself on the grounds that proofs are self-verifying. They
are, where the proof *is* the reasoning. The verification gap (Sec. 1) is
the observation that, increasingly, part of the proof is a
computation - and computations are empirical claims about what a
machine did. This paper ports the replication movement's core
insight (trust the replay, not the report) to the part of mathematics
that is actually software.

**Machine-checked proofs and the verification filter.** Tao
("Machine-Assisted Proof," *Notices of the AMS* 72 (1), Jan. 2025)
states the principle that bounds this paper's claims: powerful but
unreliable tools are safe when their outputs can be independently
verified, suspect otherwise. A PASS from a replay audit is that filter applied to
someone else's computation; it is not an endorsement of the claim's
importance, just as a BREAK is not a contribution to the field.

What none of these currents supply, to our knowledge, is the
combination this paper documents: a fixed disposition taxonomy with a
CI-enforced verdict lock (Sec. 2), a mechanism-classified attack-type repertoire (Sec. 3), and a published log of the method's own failures
(Sec. 4.7). If that combination exists elsewhere, we would like to cite
it.
