# Sec. 1. Introduction: the verification gap - draft (2026-09-23)

Peer review checks reasoning, not computation. A referee reads the
argument, follows the lemmas, and judges whether the inferences hold.
What the referee almost never does is replay the computation: the
thousand-line script, the supplementary data file, the certificate the
theorem's truth depends on. Those artifacts are trusted on the
strength of the prose around them - and prose is not a checksum.

The rot is ordinary, not scandalous. Authors move institutions and
their pages die; file formats age out; a dataset lives on a personal
site with no mirror. In the q-TSPP line, the authors' 293 MB certificate archive survived
only on the Wayback Machine; the live site was gone. It had to be
re-read, re-hashed, and replayed before a single lemma could be
formalized. Nothing about that was adversarial. It was still most of
the work.

The campaign described in this paper takes the next step: it treats
published computational claims under a *hostile prior*. Not because
authors are dishonest - the overwhelming majority of the defects found
here are mistakes, not misconduct - but because trust is not a
verification method. Every locked gate was replayed from pinned
inputs by a script built to produce the opposite verdict where the
opposite was correct; GAP, SKIP, and UNKNOWN dispositions have no
executable gate by definition (section 2). Where the claim survived,
that is recorded as a PASS with the same weight as a BREAK: the method
does not grade on a curve.

Two scoping admissions, then a word on the labor. First, the timeline is short - the campaign's first
commit is 2026-09-18. The claim of this paper is the reproducibility
of the *method*, not the longevity of the results: every gate,
control, and certificate in the repository can be replayed by a reader,
and the verdict lock (Sec. 2) fails loudly if any of them drifts.
Second, the targets were selected for fragility by harvest dossiers,
not sampled at random. This paper makes no claim about the base rate
of defective proofs in the literature. It claims only that *these*
routes were tested, *this* is how, and *these* are the dispositions --
with the failures of the method itself recorded alongside (Sec. 4.7).

Third, the labor. The throughput above - 25 gates, four replay lanes,
a 91-chunk canonization, a two-milestone Lean formalization, and eight
prose audits in six calendar days (2026-09-18 to 2026-09-23) - was
produced by AI agents working
under human direction: they wrote the gates, ran the computations,
drafted the audit notes, and assembled this paper; the human set the
targets, reviewed the verdicts, and owns every disposition. Target
curation used the same division of labor: the human wrote
deep-research prompts and ran them on the Kimi 3 and Grok 3.1
deep-research tools to assemble the candidate harvest list, then
shortlisted it by hand. Nothing else predates the repository's
2026-09-18 root commit. This is stated plainly because it is load-bearing,
not confessional. An agent pipeline fails in characteristic ways (Sec. 4.6--Sec. 4.7), and
Sec. 4's disciplines are in large part the scar tissue from those
failures. The verification-of-verification question,
*who audited the auditors*, is answered the same way this paper
answers everything else: by the artifact. Every gate is a script a
reader can run; every verdict is pinned in a lock that fails loudly on
drift; every failure of the method is published beside its successes.
Trust the replay, not the resume - including ours.

That review was a full replay, not a skim. The author directed
a clean replay of the twenty-five-gate verdict lock (executed by an AI
agent at the author's direction) - 25/25 `[ok]`, zero drift - then
re-read every audit note and every prose disposition, checking each
verdict against the underlying evidence rather than the recorded pin,
and spot-checked gate sources against their meta receipts. The replay
caught two missing Python dependencies in the review environment
(`pypdf`, `networkx`); three gates aborted fail-closed on their
PDF-identity controls until the dependencies were installed, then
went green. Approximately two hours of review found no verdict
discrepancies. The
replay log is pinned in the repository.

The rest of the paper is the playbook. Sec. 2 defines the disposition
taxonomy, Sec. 3 the attack types by mechanism with one worked example
each, Sec. 4 the evidentiary disciplines and the record of their
violations, Sec. 5 the case studies, Sec. 6 the limitations.
