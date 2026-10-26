# Audit note — Zhang, Jing, Zhao, Liu, Wang, Lean-QuantumAlg (arXiv:2610.30216v1, 2026-10-21)

**Claim artifact:** Lei Zhang, Mingrui Jing, Yusheng Zhao
(QudeLeap, Shanghai); Jiahong Liu, Xin Wang (HKUST
Guangzhou), *Lean-QuantumAlg* (arXiv:2610.30216v1, 22 pp),
and its code, github.com/QudeLeap/Lean-QuantumAlg @
`3d8829fe23d394173e2850e629b26e4f5cccf241`, Lean / Mathlib
v4.33.1, Apache-2.0. Headline: AI agents produce verified
quantum-algorithm formalizations of nine algorithms with
under 1% of lines needing human review.
**Harvest item:** the user's Feed, unit b5909076
(2026-10-25); recon and full audit opened at the user's tap
the same day, fidelity read first, runner build second.
**Campaign objects:** `incoming/lean-quantumalg/PIN.md`.
**Pinned sources:** paper PDF sha256 `1c4862d9…f2091`;
lake-manifest.json sha256 `888ee829…6b8b7` (matches the
forge evidence exactly). Working copies and per-check
evidence in `~/workspace/lean-quantumalg-recon/`
(`RECON-BRIEF.md`, `FIDELITY.md`, `FORGE-RUN-1-LOG.md`,
`FORGE-RUN-2-LOG.md`, `run3-evidence/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark
1.3` · run dates `2026-10-25` to `2026-10-26` · harness pin
via `scripts/harness_pin.py`. A Grandmaster's Methods pass
ran at recon; a DEEPEN pre-verdict pass (the `FIDELITY.md`
contract read) ran before the build verdict was finalized.
Two Argon second opinions were adjudicated against the
evidence, not relayed: the recon pass ($0.01937; its
abstract-qualification correction accepted, its arXiv-source
escape rejected on evidence) and the forge-design pass
($0.050646; five findings accepted and fixed, including an
axiom-classifier overwrite bug also present in the house
forge pattern).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-26T18:14:01Z): agent Muse (Meta), model Muse
Spark 1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (build + axioms at the pin): PASS.** Run
  40323638441, details below. All nine endpoint mains build
  and depend on exactly the classical three axioms.
- **V-B (statement fidelity, M1): PASS at the contract
  layer.** The `Solves` contract bites; success bounds are
  textbook-grade; scope restrictions are disclosed in the
  paper. Two soft spots and one opacity observation are
  recorded below; neither soft spot is hidden.
- **GAP (Table 1 reproducibility):** the measurement
  scripts behind Table 1 are in neither the public repo at
  the pin nor the arXiv source tarball. See M3.

## V-A evidence (forge run 3, 40323638441)

Workflow `quantumalg-forge` v2 at this repo's main
`a24fdc84810344fb3691e974c987015abc2ab49b` (byte-identical
to the reviewed candidate), lane [self-hosted, desktop]
(DESKTOP-7HDI2D1), dispatched 2026-10-26 08:34 EDT,
completed success 2026-10-26T17:55:07Z. All 16 steps green.

- Pins: target checked out at `3d8829fe…` and asserted;
  toolchain exactly `leanprover/lean4:v4.33.1`; installed
  Lean version gated.
- Cache: `CACHE_EXIT:0` on the first attempt;
  mathlib_oleans **8,322**, total_oleans 8,702. (The v2
  floor of 1,000 was set blind; the real count is 8,322.
  Calibrate future forge floors to it.)
- Scans (comment-stripped, `.lake` pruned): 4,373 files,
  0 sorry, 0 escapes (extern / implemented_by / unsafe /
  partial def / ofReduceBool / native_decide). The early
  artifact's scan.txt (uploaded before the build) is
  byte-identical to the final artifact's.
- Build: `BUILD_EXIT:0`, 7,709 jobs, build_seconds 10,816,
  "Build completed successfully".
- Axioms: `#print axioms` on all nine mains
  (DeutschJozsa, BernsteinVazirani, GroverSearch,
  QuantumPhaseEstimation, AmplitudeEstimation,
  OrderFinding ShorSourceJoint Canonical, FiniteCyclicDLP
  BinaryEndpoint, Factoring RSA2048, EllipticCurve
  P256LogicalResources) returns exactly
  [propext, Classical.choice, Quot.sound] for each.
  `AXIOM_AUDIT_EXIT:0`, `ENDPOINT_BUILD_EXIT:0`.
- Clocks: runner skew 5s (probe), 1s (pre-build), 6s
  (post-build). No clock event.
- Close-out, independent of the runner: both artifact
  zips downloaded and their sha256 verified against the
  run page (early `4c8dc2c7…83dd`, final `b2eb98f4…7e6`);
  the verdict classifier was extracted from the workflow
  file at `a24fdc8` and re-run locally on the downloaded
  evidence with the runner's verdict.txt removed. Exit 0,
  PASS, and the produced verdict.txt is byte-identical to
  the runner's.

Runs 1 and 2 produced no verdict on the target code and
are recorded so the run-3 PASS is not read as first-try:
run 1 (40251813868) lost its Mathlib cache fetch in
substance (masked by an `|| true`) and had its build
cancelled server-side; run 2 (40286503255) passed every
gate, then the runner lost communication with the server
at [4029/6270] of the build graph, the preserved build.log
clean and the step's exit file never written. Both are
infrastructure deaths; receipts in the recon workdir.

## M1 — statement fidelity: the contract read (V-B, from FIDELITY.md)

`Solves` is a 7-field structure (success, states, borrowed,
events, resident, auxiliary, time) over all admitted
inputs, bound to a single execution. It is not vacuous:
Grover's success bound is the exact sin² value by
equality; Deutsch-Jozsa and Bernstein-Vazirani are 1;
QPE is 4/π²; the DLP endpoint accepts exact words at 2/3;
RSA is 1 − batchFailure^totalRounds; P-256 runs 4,714
repetitions at 1/100 failure, matching code and paper
§C.4. BB6 non-vacuity vectors A–D pass at the contract
layer; vector E is the build leg and closes with V-A.

## M2 — argument fidelity

For a formalization target the argument leg is the kernel,
not a re-derivation: this audit does not redo the nine
algorithms' mathematics. It checks that the shipped
statements are the ones the sources require (M1, above)
and that every proof in the development was checked by
the Lean kernel at the pin, with no escape hatches and
no extra axioms (V-A). The paper's own Appendix D is a
vacuity memo naming the failure modes that would break
the argument (narrowed `valid`, `accepts := True`,
budget-from-candidate, gate relabeling); the contract
read tested for each of them by name.

## M4 — fine-print inventory (soft spots, opacity, scope)

Soft spots, both visible in the shipped problems, neither
a finding against soundness: (1) `initialization := True`
(load-free) in all nine problems; (2) `states = []` in the
five distributional problems (RSA and ECDLP carry a
singleton state requirement). RSA-2048's witness type is
a disclosed key class (paper §C.4: N = pq, distinct odd
1024-bit primes, gcd(p−1, q−1) < 2^181, at ≥ 0.99 of
keys); a reader of Table 1 alone would miss that scope.

Opacity observation (M1 follow-up, closed): `QuantumAlg/
Util/RSA/ShortLog/Reduction.lean` declares a private
structure `ShortLogPairRecoveryProgram` (line 4103) whose
`run_spec` field is a proof that the recovered trace
satisfies its spec, and a `private opaque` instance
(line 4114) with a concrete, kernel-checked value taken
from the real implementation (`shortLogPairRecovery
TraceImpl`, projections .1 and .2). The file sits inside
the RSA endpoint's import cone, and public recovery
lemmas in it legitimately consume the private spec lemma.
Disposition: the spec is a proved field of a checked
value, not an axiom or an assumption, and the endpoint's
axiom footprint is exactly the classical three, so
soundness is unaffected. The cost is auditability: pair
recovery correctness for the RSA path is proved against
a sealed implementation, and a reviewer must read the
implementation and its spec proof in that file as one
unit.

Scope limit of V-B: the per-Problem budget formulas were
not compared line-by-line against the source papers
[30]–[41]. The fidelity verdict covers the contract, the
success bounds, the acceptance relations, and the scope
disclosures.

## M3, the headline accounting

"Under 1% human review" holds only in Table 1's
Framework-trusted column: 0.09–0.72% per algorithm, 34–830
lines in absolute terms. Counting Core+Util as trusted
gives 0.43–2.05%; leaving the Framework untrusted gives
1.41–11.86% (about 3,058–5,148 lines). The abstract
carries the qualification ("once the shared framework
has been audited"); the unqualified form circulates only
in summaries of the paper, not in the paper.

## GAP, Table 1 measurement

Appendix B names two scripts, `StatementClosure.lean` and
`loc_footprint.py`. Neither is in the public repo at the
pin nor in the arXiv source tarball (main.tex + figures
only). Appendix B specifies the closure walk well enough
to reimplement, and the authors' own Limitations note the
LOC metric is gameable, so this is recorded as a
reproducibility GAP, not a defect in the formalization.
The V-A scans independently confirm the zero-sorry,
zero-escape facts the table's accounting presupposes.

## Receipt — full pins

Full sha256 pins curing the truncated pins used in the
prose above (house Receipt style: source named, bare hash
printed):

- Paper PDF (arXiv:2610.30216v1):
  1c4862d9a9f2ceee6e2547d4da027b2c6e362b81b8ceef5f018ae6d8600f2091
- arXiv e-print tarball:
  230845069789d5d55099b8548f557474e2723c07a6932485015ce60595a65760
- lake-manifest.json at the repo pin:
  888ee829542ff4f39d2da2734009167dd59756cbbcad3c1f45abaa5bb076b8b7
- Forge run 3 early evidence zip (run 40323638441):
  4c8dc2c771bb31bd6f2336eeadc228e3e108f827369597dac70979bf033883dd
- Forge run 3 final evidence zip (run 40323638441):
  b2eb98f4f86b9208e40c36ad7a3578b019e0868e110a148940523982ca7377e6
- Repo pin (commit): 3d8829fe23d394173e2850e629b26e4f5cccf241;
  forge workflow at this repo's main
  a24fdc84810344fb3691e974c987015abc2ab49b.

## Verdict lock

This note's verdicts: **V-A PASS · V-B PASS (contract
layer) · Table 1 GAP**. The 32-gate verdict lock
(17 BREAK / 15 PASS) is untouched.

**Verdict: PASS.** Both scoped verdicts stand as stated
above; the Table 1 reproducibility exception is recorded
in this section.
