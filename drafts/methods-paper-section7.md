# §7. Limitations — draft (2026-09-23)

This section states what the playbook cannot do. Each limitation is
one the campaign actually hit, not a hypothetical.

## 7.1 Replay cannot catch specification errors on its own

A gate replays the computation the paper describes. If the paper
describes the *wrong computation* — proves a statement adjacent to
the one it claims — the gate passes and the error survives. The
campaign's first BREAK is the example
(`docs/audits/gamma-aejonanonymous.md`): the audited formalization
proved `¬ is_rational_gamma` — a statement about its own predicate,
not the irrationality of mathlib's γ. The computation was correct;
the specification was wrong. A separate *statement-fidelity* audit —
checking that the formal statement says what the paper claims it
says — is a partial remedy. It is not a closed gap: fidelity audits
are manual, unglamorous, and easy to skip, which is exactly why the
error class survives.

## 7.2 Nonconstructive arguments force SKIP

Where there is no witness to exhibit and no computation to replay,
there is no gate. Nonconstructive existence proofs, pure compactness
arguments with no extractable bound, and routes whose decisive step
cannot be instantiated at any parameters end in SKIP (§3) — honestly,
but unavoidably. The Mahler 3D audit is the boundary case: every
finitely checkable layer passed, the prose audit found no defect, and
the connectedness step that carries the conclusion has no finite
residue at all. The gate verdict stays PASS — it correctly reports
what the counting lemma gate checked — but the claim as a whole is
SKIP: the decisive step cannot be instantiated at any parameters, so
there is nothing to promote. The target is set aside — the correct
output of the method, and its admission of reach.

## 7.3 The certificate cost curve is unsolved

GB-scale certificates against kernel checking remain an unsolved
tradeoff. The q-TSPP certificates are hundreds of megabytes —
uncheckable inside a proof kernel — so the campaign checks them
outside the kernel and formalizes the *shape* of the argument instead.
That is a principled compromise, not a solution: trust migrates to the
external checker, exactly the kind of software this paper argues
should be distrusted. Verified meta-level checkers are the open
problem; until they exist, large-certificate proofs get a weaker
standard, stated plainly.

## 7.4 Type E remains tooling-blocked

Type E — replaying a paper's "by symbolic computation" steps — is
the attack type the campaign is worst equipped for. The tooling
(verified computer algebra, Ore algebras, q-Zeilberger infrastructure)
does not exist at the needed level; building it is a multi-year
project, not an audit step. The honest response: mark the limitation,
record what was checked by other means, and do not pretend a partial
replay is a full one.

## 7.5 Selection and window

The targets were harvested for fragility, not sampled, and the
campaign window is weeks (§2). Nothing in this paper estimates the
base rate of defective proofs. The method is reproducible; the
results are not a survey. The q-TSPP certificate-rot episode (§2,
§6.4) is reported as a single instance; whether disappearing
certificate archives are typical is a question for a larger sample,
not a claim of this paper.

## 7.6 No pre-publication author notification

The campaign does not notify authors before publishing a verdict,
and does not intend to adopt notification as a regular policy. The
reason is throughput, not hostility: at twenty-five gates in five days,
individualized pre-publication correspondence is infeasible, and a
notification rule honored selectively would be worse than none. The
substitute is the public record itself. Every BREAK names the lemma,
exhibits the false instance, and pins the inputs; every audit note is
a document an author can answer point by point, and the repository is
the correction channel — a verdict met with a correct
counter-argument is superseded in the open, under the append-only
rule (§3). What the campaign does not do is litigate verdicts
privately before publishing them. (The q-TSPP author was contacted,
but to request missing coefficients for a formalization built on the
authors' work, not to disclose a finding.)
