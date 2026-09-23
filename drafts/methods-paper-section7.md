# §7. Limitations — draft (2026-09-23)

This section states what the playbook cannot do. Each limitation is
one the campaign actually hit, not a hypothetical.

## 7.1 Replay cannot catch specification errors on its own

A gate replays the computation the paper describes. If the paper
describes the *wrong computation* — proves a statement adjacent to
the one it claims — the gate passes and the error survives. The
campaign's first BREAK is the standing example
(`docs/audits/gamma-aejonanonymous.md`): the audited formalization
proved `¬ is_rational_gamma`, a statement about its own predicate,
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
residue at all. The target sits on the watch list, which is the
correct output of the method and also its admission of reach.

## 7.3 The certificate cost curve is unsolved

GB-scale certificates against kernel checking remain an unsolved
tradeoff. The q-TSPP certificates are hundreds of megabytes; checking
them inside a proof assistant's kernel is not currently feasible, so
the campaign checks them outside the kernel and formalizes the
*shape* of the argument instead. That is a principled compromise, not
a solution: the trust migrates from the kernel to the external
checker, and the external checker is exactly the kind of software
this paper argues should be distrusted. Verified meta-level checkers
are the open problem; until they exist, large-certificate proofs get
a weaker standard of evidence, stated plainly.

## 7.4 Type E remains tooling-blocked

CAS-transcript replay — re-running a paper's "by symbolic
computation" steps independently — is the attack type the campaign is
worst equipped for. The tooling (verified computer algebra, Ore
algebras, q-Zeilberger infrastructure in the available provers) does
not exist at the needed level, and building it is a multi-year
project, not an audit step. Several targets carry "capability-limited"
notes for exactly this reason. The honest response is the one used in
this paper: mark the limitation, record what was checked by other
means, and do not pretend a partial replay is a full one.

## 7.5 Selection and window

Stated in §2 and repeated here because it belongs with the other
limitations: the targets were harvested for fragility, not sampled,
and the campaign window is weeks. Nothing in this paper estimates the
base rate of defective proofs. The method is reproducible; the
results are not a survey.
