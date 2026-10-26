# Audit note — Quantum circuits discovered with LLMs (Gu, Kemeny, Yelin, Lukin)

**Claim artifact:** Andi Gu, Alek H. Kemeny, Susanne F. Yelin,
Mikhail D. Lukin, *Discovering state-of-the-art quantum circuits
with large language models*, arXiv:2610.22367v1, submitted
2026-10-15, 46 pages, 10 figures, 6 tables; Supplementary
Information inside the paper. Headline: an evaluator-guided LLM
search (OpenEvolve, Claude Mythos 5 proposer, hand-written task
specifications) discovers circuits beating the state of the art
on both Toffoli and qubit counts in 7 of 8 tasks (largest gain
39x TQ-cost, fixed-point Gaussian), and a new reversible
divsteps architecture for prime-field modular inversion in the
8th. The claim audited is the discovered circuits' certified
costs and correctness, plus the three claims in the paper that
cite the repo as `gu2026lean`; the LLM search itself was not
re-run (see M4).
**Repo pin:** https://github.com/andigu/uncompute @
64b5a13aa249f1360846657392e6c66817b26d0f (2026-10-16, 2 commits),
Apache-2.0, first author's account. Toolchains pinned in-repo:
lean/divsteps on Lean 4.32.2 + Mathlib v4.32.2, lean/dqi on
Lean 4.33.1 + Mathlib v4.33.1; 43 .lean files total. Local
verified tree ~/workspace/quantum-circuits-recon/repo;
execution copy repo-run/ (the verified tree stayed pristine).
**Harvest item:** Emergent Mind harvest 2026-10-20 (fragility 1,
ranked #4 in its batch); code-availability probe and target pick
at the user's word 2026-10-25. **Campaign objects:**
`incoming/quantum-circuits-llm/PIN.md`; working notes
`~/workspace/quantum-circuits-recon/` (PROBE.md, EVIDENCE.md,
DEEPEN.md).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`,
audit dates `2026-10-25` to `2026-10-26`. All machine legs ran
on this VM (evaluator replay, both Lean builds, the certificate
replica); no forge workflow was needed.

**Harness pin** (`scripts/harness_pin.py`): agent Muse (Meta), model
`Muse Spark 1.3`; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

**Scope of this audit:** three legs. (1) Evaluator replay of all
8 tasks (discovered + baseline circuits, 24 results.jsonl
entries) against the repo's `results.jsonl` and the paper's
Table I. (2) Evaluator-fidelity read: grader and reference
independence, test-draw construction, failure budgets; the
evaluator is the claim's trusted base. (3) The Lean leg: build
and axiom-audit `lean/divsteps` and `lean/dqi`, and M1-check
their statements against the three paper claims citing
`gu2026lean`. Plus M1-M3 checks of the paper text itself. The
verdict lock is not touched. No author contact.

## M1 — statement fidelity

Two of the three `gu2026lean` claims match their formalizations
exactly. Claim B: the appendix proposition (p = 2^256-2^32-977,
every 0 <= w < p reaches g=0 within 590 active steps) is the
Lean `zWalk590` statement, word for word in substance. Claim C:
the decoding rule (eq:divstep-decoding-rule, appendix
app:divstep-recovery) is restated by the Recovery.lean theorems,
and the file's own comment says the public theorems restate the
appendix results exactly; the audit's read agrees.

Claim A carries the audit's one M1 finding (DEEPEN D5). The
paper displays, once (main.tex line 1370, eq:dqi-budget-bound,
citing `gu2026lean`): |<f>impl - <f>| <= 4*eps*<f>. The
formalized theorem `Dqi.dqi_end_to_end` has three terms:
(|lambda|+m)*4*mu + 4*sqrt(mu)*sigma_dec + 2*sqrt(mu_cl)*(...).
Term 1 maps exactly onto the displayed bound (|lambda|+m =
2<f> when lambda >= 0; mu := eps). Terms 2 and 3, the
profile-residual term in sigma_dec and the clean-relocation
term in mu_cl (with the collision count itself a hypothesis,
hcoll), are nowhere stated or numerically bounded in the
paper for either DQI instance. The repo README argues the
structure in prose (order mu, residual tracked, relocation
separate) without instance numbers. So the displayed bound is
the leading term of the proved bound under two unstated
conditions. The Lean theorem is exact as a conditional
statement and its hypotheses are honestly listed; the paper's
downstream arithmetic all recomputes exactly (eps <= 2.434e-3
at 97.5%; 5.6e-3 and 7.0e-3; advantage fractions 7.4% and
4.9%), and replay shows the discovered decoders' failures are
exclusively wrong-sign (30/100k hermitian, 7/100k RS), with no
relocations observed. Qualification, not refutation.

Evaluator counts: every Table I row the audit replayed matched
the recorded counts (see Receipt), including gaussian
1583/139 vs 23784/362 (the 39x headline) and RS-DQI 442397/1837
vs 5125070/1938 (12x).

## M2 — argument (the trusted bridge)

The bridge here is the evaluator: certified counts mean what
the paper says they mean only if the judge is independent of
the judged. The audit read the protocol and graders in full
or in part and tested the independence four ways. (a) Each
grader rebuilds its instance data from first principles at
import and asserts equality with contract.json sha256
provenance anchors; the gaussian and hermitian graders carry
known-answer vectors pinned outside the code (mpmath at 50 dps;
five syndrome/phase KATs). (b) Each task ships a second,
stdlib-only classical reference (reference.py) implementing
the same spec independently of the evaluator. (c) The test
draw is a deterministic function of the circuit's own op-stream
hash, SHAKE256(domain || "/tests/" || h_ops), with per-shot XOF
seeds, so no per-circuit test selection is possible inside the
protocol. (d) Two independent executors, the normative Python
compact reader and the C kernel, produce byte-identical full
reports on 6/6 small entries, and pipe mode rebuilds the
certified op streams from the shipped circuit.py files for
gaussian and coulomb, hash-exact.

Residual trust, recorded: the op-stream cost model (what
counts as a Toffoli, Clifford weights) is the kickmix model of
Babbush et al. 2026 (arXiv:2603.28846), applied identically to
baselines and discovered circuits. The audit verifies the
comparison inside that model, which is the comparison the
paper makes; the model's fidelity to hardware is a cited
external claim, not this paper's.

## M3 — credit honesty

Clean, with one presentation blemish. Baselines are
reconstructions and are labelled as such: every baseline
folder carries an Attribution section, each baseline's source
is cited in the paper's tables (Khattar 2025, Haner 2018,
Babbush 2018, Sakata 1995, Osorio 2025, Luo 2026), and Table
I's caption declares the baseline free parameters were chosen
to minimize the baseline's TQ cost, the opposite of
strawmanning. The hermitian "baseline" is flagged in the paper
itself as a naive reversible implementation with no prior
literature compilation, and no gain is claimed for it (G shown
as ---). The kickmix cost model is credited to Babbush et al.;
the search stack (OpenEvolve, Claude Mythos 5, hand-written
specifications) is disclosed in Methods. The blemish: the paper
carries no code-availability statement and no code link in the
arXiv record; the repo is reachable only through the
bibliography entry `gu2026lean`. A reader of the paper alone
is not told that the evaluator and all artifacts are public.
(Adjacent record, not this paper's fault: the third-party
tatra-labs/kickmix-arena README states the original evaluator
"was not released"; the pinned repo was pushed 2026-10-16 and
contradicts that.)

## M4 — fine-print assumption inventory

- Failure budgets are fixed a priori in the graders and
  disclosed in the paper's Extended Data Table (<= 1e-3 DQI,
  <= 2e-4 modinv). Observed usage in replay sits well inside:
  hermitian discovered 30/100 (all wrong-sign), RS discovered
  7/100 (all wrong-sign), modinv headline 4/20; the five
  STRICT tasks recorded zero failed shots across all replay,
  chemistry at 18.4M shots included. Budgets exist where the
  algorithm is itself probabilistic (decoder failure mass,
  long divstep walks); the claim-A bound prices that mass.
- The divsteps step bound rests on a native_decide certificate:
  the 3 step-bound theorems carry the per-proposition axiom
  example590_par._native.native_decide.ax_1_1 on top of the
  standard three. This is disclosed in the Main.lean header and
  the repo README, and the paper's appendix attributes the
  bound to Wuille's analysis. The audit cross-checked the
  certificate with the repo's own plain-Python replica of
  Wuille's Coq certificate (see Receipt): an independent
  implementation of the same decidable check. A trust-base fact
  stated here, not a defect.
- `Dqi.dqi_end_to_end` is conditional: hypotheses include the
  collision bound (hcoll) as an assumption, bent constancy,
  a normalized profile, and oracle agreement off the failure
  set F. All are listed in the theorem; none is discharged for
  the paper's instances inside the formalization.
- The circuit schedules 533 steps and tests termination from
  step 499; the walk-termination failure (~1e-5) and the
  history-cap failure (2.4e-6) are charged to the Unified(20)
  evaluator budget (main.tex line 597 figure caption).
- The Extended Data Table's criterion column uses "Exact" for
  zero per-shot tolerance while chemistry samples 2x10^7 shots
  over a 2^32 domain. The test counts print beside the
  criterion, so the line carries what a reader needs; recorded
  as a minor wording qualification (DEEPEN D6).
- The LLM search was not re-run. The audit verifies artifacts,
  which stand regardless of how they were produced (DEEPEN D7).

## DEEPEN — pre-verdict pass

D1 (replay with the authors' evaluator proves only
self-consistency): substantially answered, M2 (a)-(d); residual
is the shared kickmix cost model, recorded. D2 (weak baseline
reconstructions manufacture the gain): mitigated; the verified
claim is "beats these cited state-of-the-art constructions as
reconstructed", which is the claim the tables make. D3 (failure
budgets let failing circuits pass): answered; budgets a priori,
disclosed, usage well inside, STRICT tasks at zero. D4
(native_decide is trust in the compiler): true, disclosed, and
independently cross-checked by the replica run. D5 (the
headline DQI inequality is not the proved statement):
sustained as the audit's one M1 qualification. D6 ("exact"
overstates coverage): wording note only. D7 (LLM provenance
unverifiable): out of scope by the pick's terms; no verified
claim depends on it. D8 (two unreplayed entries would make a
PASS an overclaim): procedural at draft time; closed at close
(both entries completed 2026-10-26, below), so the count
verdict covers all 24 entries.

## Receipt

- Pins: paper PDF sha256
  3607f457c3349db74e10b131abadef23a4a2dea0fefa0cf6ac6d0ed9f37fdfd9;
  e-print tarball sha256
  ec714a639c886a1f8ef78d14a255adfdac24a5405b2cf563978b64ce591ec989;
  main.tex sha256
  3520c73870f884c769ca160bebee43bfdc0c5e4d691642126ed023999d5cc475;
  repo andigu/uncompute @
  64b5a13aa249f1360846657392e6c66817b26d0f, verified stronger
  than a checkout: all 302 file blobs in the GitHub API
  recursive tree at the pin recomputed locally as git blob
  SHA-1, full match, no missing, no extras.
- Hash check: 24/24 results.jsonl entries, decompressed stream
  SHA-256 equals the recorded h_ops.
- Kernel replay (UNCOMPUTE_KERNEL=1): 24/24 entries reproduce
  verdict, toffoli, qubits, tq_cost and h_ops exactly
  (evidence/replay-kernel.jsonl plus the two closeout runs).
  22 entries completed 2026-10-25. The last two ran solo on
  2026-10-26: luo-eea, five-field match (OK, 69529757, 838,
  58265936366, h_ops
  a770ca2474778735f05e54f7b113a5be2833c1f2daf238d89a1e6004cc9c7e17);
  sakata-fengrao at --jobs 1 after
  two 2-worker runs died by OOM (shard worker killed, evaluator
  failed closed, exit 2) and one jobs-1 run was killed by a VM
  reboot at 19 minutes, five-field match (OK, 104263342,
  194053, 20232614305126, h_ops
  de6ce2fd65fc80624c8975ae2092484147c9a5eaff7aaa51bc47dce06844ddf7).
  All evaluator runs with
  TMPDIR on disk (the 512MB /tmp tmpfs ENOSPC'd the first
  sakata attempt).
- Cross-lane checks: Python lane equals kernel lane, full
  reports, on coulomb x2, gaussian x2, hhl x2; pipe mode
  reproduces the certified h_ops exactly for the gaussian and
  coulomb discovered circuits.
- Lean divsteps (4.32.2): cache fetch EXIT 0; Certificate
  module 5268s solo (native_decide evaluation of certEmptyPar
  Mstar 590); full lake build EXIT 0, 1518 jobs. Axiom audit
  (21 #print axioms lines in Main.lean): 17 theorems on exactly
  [propext, Classical.choice, Quot.sound]; the 3 step-bound
  theorems add example590_par._native.native_decide.ax_1_1.
  No sorryAx.
- Certificate replica: repo-run/lean/divsteps/calibration/
  replica.py --full, 2026-10-26, calibration fixtures pass,
  example590: empty=True [1320.6s], ALL REQUESTED CHECKS
  PASSED, exit 0 (evidence/replica-full.log).
- Lean dqi (4.33.1): lake build EXIT 0, 3293 jobs. Audit
  AxiomCheck (repo-run/lean/dqi/AxiomCheck.lean): Dqi.
  dqi_end_to_end and DqiWitness.witness_end_to_end each depend
  on [propext, Classical.choice, Quot.sound] only. No
  native_decide, no sorryAx. Source scan for sorry/admit
  across both Lean projects: clean outside comments.
- Working evidence: ~/workspace/quantum-circuits-recon/
  (EVIDENCE.md, DEEPEN.md, evidence/). Environment notes: this
  VM reboots roughly hourly; all long jobs ran logged and
  resumable, relaunched only from the main agent turn.

## Verdict lock

Untouched (17 BREAK / 15 PASS).

**Verdict: PASS.** All 24 evaluator entries reproduce exactly
under the authors' own evaluator, with the judge's independence
established by rebuild-from-first-principles graders, pinned
known-answer vectors, an independent stdlib reference, a
hash-determined test draw, and two executors in byte-identical
agreement; both Lean projects build at their pins with axiom
footprints exactly as disclosed (standard three everywhere,
plus the one disclosed native_decide certificate axiom on the
3 step-bound theorems), and that certificate is independently
reproduced by the Python replica of Wuille's check.
Qualifications: the M1 finding on eq:dqi-budget-bound (the
paper displays term 1 of the formalized 3-term bound; the
sigma_dec and mu_cl terms are unstated and unbounded in the
paper), and the minor "Exact" wording note in the Extended
Data Table. Neither moves any certified count.
