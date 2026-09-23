# §2. Introduction: the verification gap — draft (2026-09-23)

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

Third, the labor. The throughput above — 25 gates, four replay lanes,
a 91-chunk canonization, a two-milestone Lean formalization, and a
dozen prose audits in five days — was not produced by hand. It was
produced by AI agents working under human direction: agents wrote the
gates, ran the computations, drafted the audit notes, and assembled
this paper; the human set the targets, reviewed the verdicts, and owns
every disposition. This is stated plainly because it is load-bearing,
not confessional. An agent pipeline fails in characteristic ways — it
gates from an abstract instead of the paper (four times before the
rule was retrofitted, §5.7), it writes dossier rows about claims with
nothing behind them (ghost corpus entries), it fabricates identifiers
("Reed/Zenodo γ"), it lets a background job die silently and reports
nothing (§5.6) — and §5's disciplines are, in large part, the scar
tissue from those failures. The verification-of-verification question,
*who audited the auditors*, is answered the same way this paper
answers everything else: by the artifact. Every gate is a script a
reader can run; every verdict is pinned in a lock that fails loudly on
drift; every failure of the method is published beside its successes.
Trust the re-run, not the résumé — including ours.

The rest of the paper is the playbook. §3 defines the disposition
taxonomy — the five verdicts and the rules that keep them from
drifting. §4 classifies the attacks by mechanism, with one worked
example per type. §5 states the evidentiary disciplines that keep the
attacks honest, including the record of where they were violated and
what caught the violations. §6 gives full case studies; §7 states the
limitations, including the ones no discipline closes.
