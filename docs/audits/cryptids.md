# Audit note — Cryptids (DeepMind Busy Beaver formalizations)

**Claim artifact:** Dos Santos, Veeriah, Havrilla, Bolt, Zuzic,
Singh, Zahavy (Google DeepMind; Dos Santos also Cambridge), *At
the Limits of Computability: Steps Towards Autonomous AI Discovery
on the Busy Beaver Frontier*, arXiv:2610.22603, v1 15 Oct 2026, v2
19 Oct 2026 (local PDF sha256
`ed1954a91f6ff352e021d5c2c400b4f2c2c54a7ee5ddc1318924a04fc5dfec59`;
no supplementary file on arXiv — App. A prints the rule systems,
App. C the candidate list, App. D compression algorithms, App. E
the pipeline prompts incl. the Stellar BB6 protocol).
**Harvest item:** Cryptids (queue 3rd at recon; head after
h5i-app-bench closed; recon 2026-10-23, verdict YES strong target;
Grandmaster's Methods at recon).
**Campaign objects:** `incoming/cryptids/PIN.md`; working notes
`~/workspace/cryptids-recon/` (RECON.md, GM-RECON.md,
QUEUE-PREP.md, M1-VA.md, M1-VB.md, M1-VC.md, M3-M4.md,
`forge-evidence/`).
**Repo pin:** `google-deepmind/cryptids` @
`664cd03904a870e9a8796476dbf9dbc13a72a37b` (2026-10-22).
**Toolchain pins:** Lean `v4.35.0-rc4` (`lean-toolchain`); deps
mathlib v4.35.0-rc4 @ `1f414401`, verso v4.35.0-rc4 @ `01a09f32`
(from `lake-manifest.json` at the pin).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`, audit
date `2026-10-23`. Machine legs: a one-shot forge workflow
`cryptids-forge` (fresh clone at the pin, toolchain asserted,
environment probe, `lake exe cache get`, `lake build Cryptids
Challenge` then `lake build BusyBeaver BusyBeaverChallenge` with
`LEAN_NUM_THREADS=1` as upstream CI, `verify.py`, comment-stripped
solution-code scans, `lake comparator` over all 12 configs, and
`#print axioms` over the 321 unique load-bearing theorems with
per-config permitted-axiom enforcement), dispatched on the
`[self-hosted, desktop]` lane. An adversarial pre-dispatch pass
covered the workflow file (YAML parse, `bash -n` per step,
`py_compile` per embedded block, scanner tested on 3 cases, axiom
generator checked to emit exactly 321 `#print axioms` lines,
verdict parser unit-tested on 5 synthetic cases). **Harness pin**
(`scripts/harness_pin.py`, 2026-10-23T15:37:06Z): agent Muse
(Meta), model `Muse Spark 1.3`; skills dir `~/workspace/skills`
(mtime 2026-10-09T20:02:43Z) with `lean-proof-forge`
(forge-workflow design), `computational-claim-gate`, and
`testforge` among 11 skills.

**Scope of this audit:** M1 statement fidelity (App. A diff for
the 11 seeded machines; 12-machine V-B sample with the Stellar
BB6 non-vacuity vectors A–E — **first application of the vectors
adopted 2026-10-23 in `docs/harvest-loop.md`**; all 22 V-C
headline statements against `formalization.yaml`), M2 argument
fidelity (forge builds, comparator, axiom prints), M3 credit
honesty, M4 fine-print inventory. Three verdicts kept separate:
V-A the paper's Table 1 claims, V-B the repo Busy Beaver library,
V-C the conjecture machines. No author contact (standing policy).
The 32-gate verdict lock is untouched.

**Status:** CLOSED 2026-10-23 — verdict **PASS**, with
qualifications (see M1–M4). DEEPEN ran as the pre-verdict pass
(see below); nothing in it moved the verdict.

## M2 — receipt (independent verification)

Forge run `39960565475` (one-shot workflow `cryptids-forge`,
FPA main@`765b752`, `[self-hosted, desktop]` lane, dispatch gate
PASS 2026-10-23T13:21:20Z), concluded **success**. Evidence
artifact `cryptids-forge-evidence` (33,469 bytes; local copy
`~/workspace/cryptids-recon/forge-evidence/`): **the zip's
sha256 matches GitHub's listed artifact digest exactly**
(`24eadb25509446b60fc5f6a7857572f9cb90cd4e3a61e7c4124de0a56c729bbb`).

Independently re-derived from the artifact (not from the
workflow's own verdict step):

- Both cold builds exit 0 (`Cryptids Challenge`, then
  `BusyBeaver BusyBeaverChallenge`).
- `verify.py` exit 0: all first-principles checks passed
  (baseline machines 25/432/744/393/120 states; candidates
  goldbach_21, zf_380, riemann_104, riemann_95 with state
  counts, hashes, and simulation cross-checks).
- Comment-stripped solution-code scans: 0 hits on
  `sorry`/`admit`/`native_decide`/`bv_decide`/`axiom`
  declarations/`Lean.ofReduceBool`.
- All 12 comparator configs exit 0 ("Your solution is okay!" in
  each leg log): `constructive`, `all`, `busy_beaver`,
  `goldbach_21`, `goldbach_semantics`, `riemann_104`,
  `riemann_120`, `riemann_95`, `riemann_semantics`, `zf_380`,
  `zf_393`, `zf_semantics`.
- `#print axioms` over the union of the two load-bearing
  configs: **321 unique theorems** (299 `BusyBeaver.*` + 22
  `ConjectureMachines.*`, exactly the census counts), names
  matching `check-names.txt` one-for-one, **0 `sorryAx`**, every
  record within `{propext, Classical.choice, Quot.sound}`, and
  the 10 `constructive`-config theorems within `{propext,
  Quot.sound}` (the 10 recovered from the constructive leg's
  own export list).

Three evidence-hygiene notes, for a later reader:

- The `declaration uses 'sorry'` warnings in the comparator
  leg logs are the repo's own root `Challenge.lean` — the
  challenge skeleton with the statements as `:= by sorry`
  placeholders, which the comparator replays the `Cryptids`
  proofs against. Expected by the design, not solution code.
- `comparator-classnumber.log` and `comparator-zerogap.log` in
  the artifact predate the run (2026-10-22, prep-time probe
  residue, not among the 12 configs); they are not part of the
  verdict.
- Comparator is a Lean **core** command as of v4.35.0 (the
  standalone `leanprover/comparator` repo is merged into core);
  the leg uses the upstream CI's bubblewrap setup.

**M2 verdict: PASS.** 321/321 axiom records clean, 12/12
comparator legs accept, no sorry anywhere in solution code.

## M1 — statement fidelity

Working notes: `~/workspace/cryptids-recon/M1-VA.md` (1,082
lines), `M1-VB.md` (495), `M1-VC.md` (305).

**V-A (paper).** Table 1 = exactly **26 machines** (11 Full +
1 Acceleration + 14 Proof). App. A prints rule systems **only
for the 11 novel machines**; the 15 rediscoveries have no
printed seed (App. B/Table 3 classifies them against community
rules without printing either). Diff on the 11, clause by
clause: **8 identical, 2 added rule/extends** (A.1 adds an
unprinted high-level contraction triple; A.4 adds auxiliary
family P, printed map preserved verbatim as
`highLevelNext`), **1 other** (A.11 auxiliary families
restricted to a in {0,1}, exactly the reachable values), **0
added bounds (weakens), 0 changed coefficients (breaks)**.
Every printed bound (A.2 `c≥1`, A.3 domain, A.8 `b≥6`, A.11
`d in {3,6}`) is the paper's own, reappearing as the `ps`
guard and/or the State encoding. **Two of the 26 have no repo
module at the pin:** the BB(2,5) Acceleration machine (no
BB(2,5) library exists in the repo at all) and the Ligocki
Proof machine `1RB---_0RC0RD_…` — Table 1's Lean-verified claim
for those two is unevidenced by the repo at 664cd039
(recorded as an M4 fine-print weaken, not a refutation: a
coverage gap in the artifact, not a false proof). 24/24
remaining modules load their machine by the exact Table 1
name via `load_rle_machine%`.

**V-B (repo library).** 12-machine sample (3 paper-novel, 3
rediscovery, 3 post-paper novel incl. high-level, 2
certificate-based, Antihydra =
`M_1RB1RA_0LC1LE_1LD1LC_1LA0LB_1LF1RE_HHH0RA`). **12/12
machine-identity MATCH** three-way (filename vs BB6 README RLE
vs in-module `load_rle_machine%` string, independent Python
RLE decoder). **60/60 vector cells PASS**, with three flags:

- **F1 — Vector C, FAIL on the letter, spirit analysis
  attached (parent's call at verdict time):** paper-novel A.1
  (`M_1RB1LD_1RC0RA_1LA1RE_0LA0LB_0RB1RF_HHH1RD`) has entry
  theorem `ReachesStar.refl` — **zero steps** (module line
  1166) — because its pattern family is anchored at the blank
  tape (`encode start = cfg_A 0 0 0 0 = init []`, lines
  1134–1145). Vector C ("Genuine Blank-Tape Reachability")
  disqualifies zero-step bypasses (`cfg_0 = init []`). The
  vector hunts unreachable/dummy families vacuously proving
  non-termination; that failure mode is absent here — the
  family is trivially reachable — and the authors disclose the
  0-step anchor in the BB6 README ("Starting from C(0, 0, 0)
  (the blank tape, 0 steps)"). The letter is tripped; the
  spirit is satisfied; the machine is not a cheater. This is
  recorded as a letter-grade FAIL on that machine's Vector C
  cell with the analysis attached, not waived.
- **F2:** post-paper novel
  `M_1RB1LC_1RC0RF_1RD0LB_1RE0LD_1LFHHH_0RA1LA`'s "high-level
  acceleration" is a definitional alias of its base triple
  (`HighLevelState := State`, etc., lines 3030–3045) —
  true but degenerate; 1 of 21 modules; an M3 credit item.
- **F3:** the BB6 README Wiki column disagrees with Table 1
  twice (A.7 carries a Wiki link but is a paper new
  discovery; A.11 the inverse); machine-by-machine
  identification rests on Table 1, the Wiki column is
  cross-check only.

Census: exactly **21** BB6 modules carry
`is_valid_highLevel_acceleration` = 11 paper-novel + 10
post-paper, matching the HEAD commit's "21 novel" claim.
`Defs.lean`: no trivial satisfiability (empty `ps`
unsatisfiable, :173–186; `step_none` :203–220 demands real
halting reachability; `IsHalt` quantifies over `init []` only,
:105–110; the pattern language has no wildcard).
`Bridge.lean`: `load_rle_rows%`/`load_rle_machine%` share the
single `parseRleBlock` (:31–55); `isHalt_toBB_iff_halts`
(:243–256) is a genuine two-direction proof. `Cert.lean`:
soundness theorems read (`checkTrans_sound`:1599,
`checkHaltTrans_sound`:1619, `checkHub_sound`:1633,
`checkInit_sound`:1653); exactly 2 modules import `Cert` (both
sampled). Recorded limit: those two cert modules' exact
base-entry step counts were not independently recomputed
(entry positivity was proved by configuration distinctness
instead).

**V-C (conjecture machines).** **22/22 headline theorems
faithful** to `formalization.yaml`'s alignment table,
statement-by-statement vs `Challenge.lean`.
`RiemannHypothesis` is **Mathlib's own**
(`Mathlib/NumberTheory/LSeries/RiemannZeta.lean`:185–186 at
mathlib rev `1f414401`); the repo never redefines it.
`GoldbachConjecture` is **repo-defined — no Mathlib
counterpart exists** (0 token occurrences in the pinned
Mathlib tree); it is the standard statement over
`Nat.Prime`, with the bridges proved
(`isPrime_iff_prime`, `Semantics/Goldbach.lean`:44–46;
`goldbachConjecture_iff_all_stages`:49–59).
`MatiyasevichRiemannCounterexample ↔ ¬RH` is **proved, not
asserted** (`Semantics/Riemann/Analytic.lean`:676–679).
WadeZF vs ZF: 19 constructors each, 16 identical, **exactly 3
differ: B6a** (`hzy: z ≠ y` replaced by `hy: y ≠ 0` —
neither implies the other), **B8a** (`b8a_zero`), **B8c**
(`b8c_zero`); the repo's "20-clause" prose counts 20 RPN
dispatch slots, a counting artifact. Row 13 (`zf_432`) is
faithful *because* the yaml claims `WadeZFInconsistent`.
Riemann120's headline is unconditional (the RH-conditioned
bound is discharged inside the proof,
`Semantics/Riemann120.lean`:35–42). Provenance: PROVENANCE.md
pins **no upstream repo/commit for riemann_120** (unlike
zf_393's `9c5c2e82`); the recorded upstream is
arXiv:2609.30306 itself. **Three-way SHA-256 agreement at
`b4b0f07607fc92dae6940f6e6c2d184fec3c13bbfc8cd00a0253321be6009db5`**
(PROVENANCE.md:11, verify.py:133–135, in-repo
`baselines/sources/riemann_120_shunia.tm`, and an independent
byte-for-byte re-derivation from the arXiv e-print's 240-line
appendix table, rhtm.tex:2889–3128; caveat: arXiv serves the
current version — the recorded hash is the durable pin).

**M1 verdict: PASS on all three,** with the 24/26 Table 1
coverage weaken and the Vector C letter-grade recorded above.

## M3 — credit and disclosure (abridged)

Full notes in `~/workspace/cryptids-recon/M3-M4.md`.

- **Authorship split:** disclosed one click down.
  `BusyBeaver/README.md`:14 names all 7 paper authors + the
  pipeline; `Cryptids/README.md`:3 names Faldor & Firsching
  "using Gemini Argon"; the root README names neither group.
  `formalization.yaml` covers only the Cryptids-side project.
- **Model names:** four names across surfaces — "Gemini 3.1
  Pro" (paper §4.1), "Gemini 3.8 Flash" (Table 1 footnote),
  "Gemini 4 Argon" (LinkedIn), "Gemini Argon" (yaml +
  Cryptids side); which model produced the post-paper BB
  additions is unstated in the repo.
- **Novelty counts:** 11 (paper) / 21 (HEAD commit, census-
  consistent) / "20 new + 33 verified" (LinkedIn,
  unreconciled).
- **B6a divergence:** exemplary disclosure — the repo
  formalizes both the compiled and the intended system and
  says so in the yaml fidelity block and the semantics docs.

## M4 — fine-print assumption inventory

From `~/workspace/cryptids-recon/M3-M4.md` (14 items; nothing
evaporates):

1. **Trusted base** (kernel, comparator, RLE-loader
   elaborator, Cert.lean soundness, Mathlib definitions).
   SURVIVES as scoped.
2. **Problem Setter freedom (§3.5):** granted and, on the
   seeded set, not abused. SURVIVES.
3. **Blank-tape-only scope:** all equivalences about
   `init []`; nothing claims more. SURVIVES.
4. **Empirical stages are pipeline filters, not proof
   inputs.** SURVIVES.
5. **verify.py differential evidence** carries table-identity
   weight only; riemann_120 provenance re-derived three ways.
   SURVIVES.
6. **"Cryptid" label pending community acceptance** —
   stated by the authors; the equivalences stand regardless.
   SURVIVES.
7. **BB(3,3) holdout-list inheritance.** WEAKENS to: all 6 on
   the community's list as the repo cites it at the pin.
8. **Port seam** (paper ran 4.28.1; the repo is a later port;
   the 4.28.1 artifacts are not public). WEAKENS the V-A
   receipt to the public port at the pin.
9. **Two Table 1 machines unevidenced at the pin** (V-A).
   WEAKENS the coverage claim to 24/26.
10. **GoldbachConjecture is repo-defined** (standard
    statement, bridges proved). SURVIVES with the naming
    caveat.
11. **Constructive ZF equivalences** are fenced by the
    authors themselves (stronger logic than PA/ZF).
    SURVIVES.
12. **Vector C zero-step entry (A.1)** — recorded in M1-F1
    above. WEAKENS that machine's Vector C cell to the
    letter-grade FAIL; the acceleration itself is
    substantive.
13. **Degenerate high-level triple (1 of 21).** WEAKENS the
    high-level surface for that module only; its base
    acceleration is genuine.
14. **`decide` volume** (1,802 uses in solution code):
    kernel-checked build cost, not a soundness input; the
    comparator re-check is the receipt. SURVIVES.

## DEEPEN — pre-verdict pass (Stunspot pairing, 2026-10-23)

Run against the proposed verdict before it was written. The
questions it answered meaningfully:

- *What is overlooked?* The comparator leg's `sorry`
  warnings are the challenge skeleton, not solution code
  (checked in the repo at the pin). The scan's scope is
  solution code only, by design; the note now says so.
- *Which challenge is load-bearing?* The two unevidenced
  Table 1 machines (V-A). Disposition: they weaken the paper's
  coverage claim to 24/26; they do not touch any proved
  theorem.
- *Is the F1 call the right one?* Vector C's letter is
  tripped by A.1's 0-step entry; the hunted failure mode is
  absent and the anchor is author-disclosed. Alternatives
  considered: (a) waive as PASS-with-disclosure — rejected,
  because the letter's wording is explicit and the vectors
  were adopted verbatim; (b) fail V-B — rejected, one
  machine's entry style is not the library's proof standing.
  The parent's call stands: letter-grade FAIL on the cell,
  spirit analysis attached, library verdict PASS with the
  qualification.
- *Context where this does not work as effectively:* the
  BB(3,3) census and the 4.28.1 port are inherited, not
  re-derived — fenced in M4 items 7–8.
- *Risks:* misreading the comparator receipt as re-verifying
  the paper's 4.28.1 run (it verifies the port); the note's
  port-seam item fences this.

Nothing in the pass moved the verdict or added a finding.

## Verdict lock

Untouched (17 BREAK / 15 PASS). This audit is a replay/verify
engagement, not a gate in the 32-gate series.

**Verdict: PASS** — V-A (paper) with the 24/26 coverage
weaken, V-B (repo library) with the Vector C letter-grade on
A.1 recorded, V-C (conjecture machines) clean — all with the
M1–M4 qualifications above.
