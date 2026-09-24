# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Erratum (2026-09-23):** earlier entries call the lock the "BREAK lock". It is a *verdict* lock: `EXPECTED_VERDICT` pins both verdicts — 24 gates (17 BREAK / 7 PASS) before the MAH-3 gate landed. The label is corrected in place throughout; dated counts (21/21, 23/23, …) are left as recorded at the time.

**Checkpoint:** 2026-09-24 (latest) — **Reboot hardening: checkpoint/resume for long replays + CI split.** The VM reboots ~every 2h and kills running jobs silently, so long replays are now resumable. New `scripts/harness/resume.py`: crash-safe JSONL checkpoint journal (fsync per unit; header pins the source commit *and* the checker's SHA-256 — a stale journal from an edited checker or moved source is rotated aside, never silently applied). Only *passing* units are journaled, so a checkpoint can never turn a would-be failure into a pass (fail-closed). Wired into the ab_fluid Euler gate (5,249 piece checks): `kill -9` mid-run, then re-run resumes and still lands PASS 5,249/5,249. Unit ids are occurrence-indexed (`uNNNNN::chunk::piece`) so the replay is bit-identical to the uncheckpointed gate — a first version keyed by piece name silently skipped 2,646 duplicate occurrences the original checks twice; the piece-count check caught it before commit. Journals live in `results/.checkpoints/` (gitignored, not audit evidence). `scripts/gates/check.py` gains `--only/--skip/--list-gates` for reboot recovery; the verdict-lock check still covers every gate's committed meta even on a subset run. CI split: per-push `verify.yml` runs the fast gate suite (`--skip ab_fluid`) plus the Lean build, with pip/elan caches, job timeouts, and concurrency cancel; new `deep-replay.yml` (weekly + manual dispatch) clones the pinned Euler source and runs the checkpointed ab_fluid gate. Verdict lock untouched (31 gates: 17 BREAK / 14 PASS).

**Checkpoint:** 2026-09-24 (latest) — **NLA-NR03 audited: Type-E PASS, Type-G GAP (catalog verification credit).** First harvest target picked (user: "easiest win", excluding openai-nse/ab-fluid). Holden's 127-term exact rational factorization of C7 (rank₊(C7) ≤ 127 < 128): paper + certificate pinned (`incoming/nla-nr03-holden.pdf`, 345,135 bytes, SHA-256 `249a1c630d2442be22456cc7eaf12f02c80439c00ea08508663cb0742563db02`; `incoming/nla-nr03-factors_n7.json`, 207,141 bytes, SHA-256 `fa515775f9c77e5dfe85109125d3f730c4b36684894730096247cd67fcc60bb9`, byte-identical to the git blob at sgstepaniants/OpenProblemsInNLA@`f664d07`). Type-E gate `scripts/gates/nla_nr03.py`: all 16,384 entries verify exactly (integer + `Fraction` paths, 0 bad), rebuilt-target 5,103/11,281 zero/positive split matches the paper, exactly 127 atoms; discrimination control `scripts/controls/nla_nr03_control.py` = NO FALSE POSITIVE (single-entry W/V/denominator perturbations each rejected via the product check; unperturbed passes). Type-G: catalog `RESOLVED.md` (@`0689db0`) claims "**Lean verified — 2026-09-13**" with "canonical Linux Comparator/default-kernel verification ... passed", but the tree page at the exact linked commit (`f664d07`) says "**source-only candidate: it has not yet passed** the authoritative Linux LeanCert/default-kernel/Comparator harness ... **It does not add to the Lean-verified count**", and the paper itself says "**No Lean verification was performed**." The GAP is in the catalog's credit, not the proof route — gates refute routes, not theorems. Audit note `docs/audits/nla-nr03.md`; blueprint `docs/blueprint/nla-nr03.md`; metas `results/nla_nr03_gate_meta.json`, `results/nla_nr03_typeg_meta.json`, `results/nla_nr03_control_meta.json`. **Verdict lock extended 25 → 26** (`nla_nr03` PASS); all 25 pre-existing rows untouched.

**Checkpoint:** 2026-09-24 (latest) — **Harvest loop live.** Weekly pipeline wired end to end: the `weekly-harvest-scan` cron now writes each harvest to `incoming/harvests/<date>.md` and pushes; the `harvest-loop` GitHub Action (push/weekly/manual) runs `scripts/harvest-loop/recon.py`, which verifies identifiers via the arXiv/GitHub APIs, scores fragility on the fixed rubric, suggests A–G attack lanes, and commits `docs/audits/harvest-<date>/` (recon cards + `ledger.json`) plus a `harvest`-labeled issue with the ranked queue. Boundaries: no clones, no builds, no downloads; verdict lock untouched. Pilot: first harvest (7 claims) recon'd, issue #1 open. Format spec `incoming/harvests/README.md`; loop doc `docs/harvest-loop.md`.

**Checkpoint:** 2026-09-23 (latest) — **MAH-3: SKIP** (gate PASS, claim set aside). Chen–Li–Xi–Xu 3D Mahler claim (arXiv:2605.09334v3, pinned) survives everything thrown at it: gate 5a (Lemma 5.1, exact rational arithmetic) PASS on 7/7 polytopes with discriminating wrong-θ control; gate 5b stress probes of Prop 6.4's dependencies PASS (Lemma 6.3 shadow-flow decrease reproduced, Lemma 6.2 holds); full prose audit of §4, Lemma 5.3, Prop 6.4, §7 found no defect. Per the dossier's standing rule, Prop 6.4's connectedness is irreducibly topological with no finite gate → claim set aside (SKIP), not promoted to PASS. Audit note `docs/audits/mah-3.md`; gates `scripts/gates/mah_3.py`, `scripts/analysis/mah_3_stress_5b.py`. Verdict lock untouched — now 25 gates (17 BREAK / 8 PASS).

**Infra fix (same day):** installed pypdf 6.19.0 on the VM — 3 pre-existing gates (cat_g, krr_cl, tpc_gn) were DRIFT/ABORTing on their pdf-identity guard for lack of it. Aggregate `check.py` now 25/25 ok, zero drift.

**Checkpoint:** 2026-09-23 (prior) — **JAC-2D Type-G audit: PASS.** Su's 2D-Jacobian claim (arXiv:1603.01867v43, 55 pp, SHA pinned; hash matches the D/E gate pin) survives the logical-gap pass too: the decisive inferences (Prop 2.15 o(h) estimate, Lemma 2.8 induction, Thm 1.3 properness, Prop 3.12 perturbation engine, EVT assembly) were re-derived by hand and found sound — no quantifier upgrades, no undischarged premises. Six harmless slips documented (scalar factor, o-vs-O, an omitted nonnegative term, stale section intro) — none proof-breaking. Audit note `docs/audits/jac-2d-typeg.md`; meta `results/jac_2d_typeg_meta.json`. Scope: prose/logical pass, not formal verification. This target now stands as PASS on both computational and logical audits — it either is correct or fails somewhere outside our reach. Verdict lock untouched.

**Checkpoint:** 2026-09-23 (latest) — **JAC-2D Type-G audit: PASS.** Su's 2D-Jacobian claim (arXiv:1603.01867v43, 55 pp, SHA pinned; hash matches the D/E gate pin) survives the logical-gap pass too: the decisive inferences (Prop 2.15 o(h) estimate, Lemma 2.8 induction, Thm 1.3 properness, Prop 3.12 perturbation engine, EVT assembly) were re-derived by hand and found sound — no quantifier upgrades, no undischarged premises. Six harmless slips documented (scalar factor, o-vs-O, an omitted nonnegative term, stale section intro) — none proof-breaking. Audit note `docs/audits/jac-2d-typeg.md`; meta `results/jac_2d_typeg_meta.json`. Scope: prose/logical pass, not formal verification. This target now stands as PASS on both computational and logical audits — it either is correct or fails somewhere outside our reach. 24/24 verdict lock untouched.

**Checkpoint:** 2026-09-23 (prior) — **LEG-NS proof GAP (type G): Legendre-via-Newman-sums route refuted at v4.** Pinned arXiv:2307.08725v4 (May 2026; dossier's v2 intel stale — decisive step is now Prop. 2.18). No finite gate applies: load-bearing claims are asymptotic/analytic, so this downgraded to a prose audit per the dossier's own warning. Defect A (decisive): the contour-deformed Mellin integral converges on closed {Re≥0} but diverges for Re<0 (probe: 5.6e−13 / 4.7e−06 / 3.96e+01 at t=160 across the axis), so the paper's "analytic in an open neighborhood" inference is a non sequitur — and Newman's theorem needs that neighborhood. Defect B: arithmetic error p.17 (3 − e^{−s}/s − 1/s ≠ (e^{−s}−1)/s). Audit note `docs/audits/leg-ns.md`; illustration probe `scripts/analysis/leg_ns_contour_probe.py`. Disposition: proof GAP, route refuted, theorem untouched — explicitly NOT a BREAK. 24/24 verdict lock untouched.

**Checkpoint:** 2026-09-23 (prior) — **GB-SCE BREAK (route): Goldbach semi-continuous model route refuted.** Paper pinned at arXiv:1909.13230**v5** (May 2026; dossier's v2 intel stale — claim shifted to a "relative proof" with the dominant 75th structure resting on admitted-unproven inequalities). Gate `scripts/gates/gb_sce.py`: inequality (i) false for every even E by sign (RHS<0 vs b_E≥0 — analytic, not just numeric), (ii) false ∀ E≥4 as stated (5 small-E counterexamples, first E=398), (iii) violated 925/1004, systematically at large E (margin −2.46M at E=10⁸). Controls (Dusart, Teeter (18)/(19), identities (11)–(13), Example 2.6) all Confirm — instrument discriminates. Audit note `docs/audits/gb-sce.md`; results `results/gb_sce_gate_meta.json`. Goldbach's conjecture itself untouched. **verdict lock extended 23/23 → 24/24.**

**Checkpoint:** 2026-09-23 (prior) — **FRK-UC proof GAP (type G): Demontis's claimed proof of Frankl's union-closed conjecture has a broken decisive inference.** Recon (`corpus/recon-frankl-uc.md`) pinned arXiv:2405.03731v1 (8 pp, v1 only, never withdrawn; dossier wrong on author and method — Demontis, combinatorial, not "S. Schäge"/entropy). Theorem 4's proof proceeds on an undischarged "if we could choose Y" and an unearned induction invocation; Theorem 5's proof upgrades `∃i[A→B]` to `∃i[A(Y₀)∧B]` (quantifier confusion) with `Y₀ ⊂ D` violating Def 9's `Y ⊂ F` (type error). NOT-GATEABLE as finite search: control probe `scripts/analysis/frankl_uc_thm5_probe.py` — 61/61 (n=3), 2480/2480 (n=4), 300k sampled (n=5), zero violations of Theorem 5. Audit note `docs/audits/frankl-uc-gap.md`. Disposition: proof GAP, route refuted, theorem untouched — explicitly NOT a BREAK. 23/23 verdict lock untouched.

**Checkpoint:** 2026-09-23 (prior) — **Erdős–Straus Thm-10 interval gap fully characterized: real, structural, repairable.** Follow-up to the main-chat gate (`docs/audits/erdos-straus-gate.md`): reproduced the k=718 failure independently, then `scripts/analysis/erdos_straus_salvage.py` exhaustively searched the paper's d-range for n=4,6,8 — the exhibited (u,v)=(n,n−1) works only at the single endpoint d=n/2 (n=6: k=718 fails; n=8: k=40318 fails), but every failing k is salvageable within the same construction family (uniform d=1,u=1, v|k+1 with v≡2 mod 3; exact-Fraction identity verified). Conclusion stands; proof as written does not establish it. Logical gap (route, not theorem); Conjecture 1 PASS and ES untouched. 23/23 verdict lock untouched.

**Checkpoint:** 2026-09-23 (prior) — **q-TSPP milestone 2 CLOSED (parametric).** Recovery of the explicit q=1 order-7 diagonal recurrence was exhausted across all public sources in the requested order: (1) arXiv source package e-print/0906.1018 (54,137 bytes, SHA-256 pinned — TeX + 4 EPS figures, no ancillary files); (2) Koutschan's RISC 2009 PhD thesis (949,327 bytes, SHA-256 pinned — Ch. 7 §7.3 repeats the paper verbatim, no operator coefficients); (3) Wayback CDX of `risc.jku.at/people/ckoutsch/*` and `koutschan.de/publ/Koutschan09/*` (only q-case `qtspp/` captures; no q=1 supplementary page/file found in the searched captures). The coefficients are not printed anywhere checked, so identity (3.2) B(n,n)=1 is formalized parametrically: `FragileProofAudit/QTSPP/DiagonalIdentity.lean` introduces a `DiagonalCertificate` structure (order-7 coefficients `p` + right-factor witness `q` with the `L = Q·(S_n−1)` Ore relations unfolded) and fully proves `diagonal_identity_of_certificate` (telescoping ⇒ constant-1 satisfies `L` ⇒ `d = 1` via milestone-1 `recurrence_unique`). Kernel-checked, sorry-free: `lake build` EXIT 0, 8,656/8,656 jobs, zero errors. Coefficient recovery stays open as milestone-3 work. 23/23 verdict lock untouched.

**Checkpoint:** 2026-09-23 (prior) — **q-TSPP q=1 Stembridge shakedown landed.** Koutschan's algorithmic proof of Stembridge's TSPP theorem (arXiv:0906.1018) staged as the q=1 case: Okada determinant reduction stated as `stembridgeDetIdentity` (Prop), product formula and matrix entry defined, abstract closing lemma `recurrence_unique` proved sorry-free (variable-coefficient linear recurrence uniqueness — the engine behind identity (3.2)), blueprint `docs/blueprint/qtspp-q1.md` with certificate landscape (65 recurrences → 5 Gröbner-basis polynomials; q=1 norm ~5MB/order-10, orthogonality ~200MB/~700MB). **Not a BREAK — correct-proof infrastructure; 23/23 verdict lock untouched.** Build verification blocked by transient VM storage stalls (Lean olean loading); code manually verified.

**Checkpoint:** 2026-09-23 (prior) — **Pólya v1 BANKED.** Canonization of Tanaka's smallest counterexample L(906,150,257)=+1 is complete and banked: clean-room segmented λ-sieve (C, integer-only) + 91 SHA-256-pinned chunk certificates covering [2,906150257] + independent verifier (370/370 checks PASS) + second independent implementation (Python/numba prime-power flip sieve, C source never read — 91/91 chunk agreement, anchors exact) + full blueprint + Lean checked-sieve slice kernel-verified through n=100 (`polya_holds_to_100`, axioms only [propext, Classical.choice, Quot.sound], independently re-verified this session). **Not a BREAK — canonization artifact; 23/23 verdict lock untouched.** q-TSPP recon also landed (certificates recovered via Wayback; formalization scope mapped) — that's the natural next target, not started.

**Checkpoint:** 2026-09-22/23 (prior) — **Pólya v1 kickoff landed overnight.** Clean-room segmented λ-sieve (`polya/src/liouville_sieve.c`, integer-only; p=2 stripped via ctz, odd p via p⁻¹ mod 2⁶⁴) reproduces all published anchors exactly: L(10⁹)=−25216, first crossing 906150257, max 829 at 906316571. 91 chunk certificates (10M chunks) cover [2,906150257], SHA-256-pinned in `polya/certs/manifest.json`; independent verifier `polya/src/verify_certs.py` **PASS (370 checks)**: L(n)≤0 for 2≤n<906150257, L(906150257)=+1. Note: initial sieve build had a real bug (2-adic inverse doesn't exist for p=2 — factors of 2 never divided out); caught by the brute-force anchors, fixed, re-validated. Deferred to fresh eyes: second independent implementation, full blueprint write-up, Lean slice. Not a BREAK — canonization artifact; 23/23 verdict lock untouched.

**Next session:** q-TSPP milestone 3 — coefficient recovery for the q=1 order-7 diagonal recurrence (explicit coefficients unrecoverable from arXiv source, thesis, Wayback; milestone 2 closed parametrically). Then identity (3) pilot.

Prior checkpoint: **Gomila Λ-bound tail replay VERIFIED PASS — all four audit lanes now closed.** Fresh clone of the audit repo at pinned commit `a74738d`, read-only scope: 5/5 sealed tail certificate SHA-256 checksums match (`tail_1787854_160/256`, `tail_arb_256/512`, `p11_triangle_tail_cells_independent`); `verifiers/verify_tail_arb.c` (FLINT 3.0.1) **36/36 checks PASS at 256 bits and 36/36 at 512 bits** (exit 0, decisive contraction D<1, N≥3840000, M=153814); `verifiers/verify_tail_arb_logs.py` **PASS** on sealed logs (D<1, flow>error, margin >1.7352093733e-4); independent Python interval tail verifiers **ALL PASS at 160 and 256 bits**. Finite lane (3,149,013/3,149,013 rows), Dini y-transfer (4/4 legs), barrier (54/54, 883/883 prisms, Prop 4.10 at 256+512 bits) all previously PASS — the Triangle weld B=893927/5000000 is now fully replayed on this audit's evidence, finite and tail lanes overlapping on the complete window N=3840000. **Not a BREAK — an audit confirmation**; not on the 23/23 verdict lock. Evidence: `docs/blueprint/gomila-lambda.md` (tail section added).


Prior checkpoint, same day (earlier): **Gomila Λ-bound barrier replay VERIFIED PASS.** Fresh clone of the audit repo at pinned commit `a74738d`, read-only scope (no producer rebuild): 5/5 sealed barrier certificate SHA-256 checksums match the repo's `SHA256SUMS` pins (`barrier_target_closed.log` + macOS/FLINT-3.6.0 twin, storedsum taylor-tail/provenance/uniform-error logs); `verifiers/verify_barrier_binding.py` (Python 3.12.3 + mpmath 1.2.1) **ALL PASS, exit 0 — 54/54 checks, 883/883 prisms parsed**, conclusion: H_t zero-free on the complete closed slab [X,X+1]×[0.1809,1]×[0,0.16125]; `verifiers/verify_prop410_arb.c` compiled against FLINT 3.0.1 and run at both precisions — **31/31 checks PASS at 256 bits and 31/31 at 512 bits** (exact candidate identity t₀+y₀²/2=893927/5000000, all domain/error-budget gates, no stored certificate read). Gates (i)+(ii)+(iii) of the Triangle weld now closed on this audit's evidence. **Not a BREAK — an audit confirmation**; not on the 23/23 verdict lock. Remaining: tail-lemma replay (contraction D<0.999721). Evidence: `docs/blueprint/gomila-lambda.md` (barrier section added).

Prior checkpoint, same day (earlier): **Gomila Λ-bound full finite replay VERIFIED PASS (3,149,013/3,149,013 rows).** Ran the audit repo's own fail-closed verifier (`verifiers/verify_finite_and_binding.py`, Python 3.12.3 + mpmath 1.2.1, 220-bit interval arithmetic, exit code 0) on a fresh download of all 15 sealed shards at pinned audit-repo commit `a74738d`: 15/15 shard SHA-256 checksums match the repo's `SHA256SUMS` pins; leg p235711 ({2,3,5,7,11}) — 4 files, 12 runs, N=690988..728999, 38,012 rows, min floor 0.000000791366 @690988, UNCERT=0; leg p2357 ({2,3,5,7}) — 1 file, 1 run, N=729000..818999, 90,000 rows, min 0.000315112459 @729000, UNCERT=0; leg p235 ({2,3,5}) — 1 file, 1 run, N=819000..1027999, 209,000 rows, min 0.000305788807 @819000, UNCERT=0; leg p23 ({2,3}) — 9 files, 9 runs, N=1028000..3840000, 2,812,001 rows, min 0.000309285478 @1028000, UNCERT=0; global 3,149,013 rows, N=690988..3840000, gaps=0, overlaps=0, UNCERT=0; error budget 12/12 gates, eAB≤2.057023688667e-12, eC0≤2.33492848188649183e-7, Emax≤2.33494905212337849e-7 (within the claimed 2.33495e-7); normalizer/corr monotonicity 6/6 gates, Xi_ub=−1.363112154757640042<0; binding floor = 7.91366e-7 − 2.33494905212337849e-7 = 5.57871094787e-7 > 0. Dini y-transfer also verified PASS 2026-09-22 (9/9 log checksums match; sealed Dini logs 4/4 legs at 180+256 bits, worst ratio 0.99999860767275095 < 1; stored-log checks all PASS incl. tail 93/93); Platt–Trudgian margin independently confirmed: 3,000,175,332,800 − 6,000,000,185,827/2 = 175,239,886.5 exactly (primary source: arXiv:2004.09765 Thm 1). RESULT PASS: full finite Triangle weld B=893927/5000000 rows=3149013. **Not a BREAK — an audit confirmation**; not on the 23/23 verdict lock. README + this workplan synced. Evidence: `docs/blueprint/gomila-lambda.md`.

Prior checkpoint, same day (earlier): **Kempe–Fritsch gated + controlled,
verdict BREAK.** Continued down the same harvest report's ranked list after
Tait–Tutte (prior checkpoint): harvest rank 6, Kempe's 1879 four-color
algorithm, refuted by Fritsch & Fritsch's (1998) 9-vertex counterexample.
Unlike Tait–Tutte, this target's decisive content (the exact graph, the
exact pre-coloring, the exact two Kempe-chain-switch sequences) exists only
as a rendered diagram inside the primary source
(Gethner, Kallichanda, Mentis et al., *Involve* 2:3 (2009), Theorem 4,
Figure 3) — two WebFetch attempts on the PDF returned corrupted binary
content, so the body text was extracted with `pdfplumber` instead (clean),
and Figure 3 itself (still an image) was rendered to a 300 DPI PNG and read
directly via multiple zoomed crops, not reconstructed from memory or a
qualitative Wikipedia description (which was tried first and found
insufficient — this session explicitly declined to fabricate a plausible-
looking coloring instead, per user steer). The resulting 9-vertex, 21-edge
graph's degree sequence (three degree-4, six degree-5 vertices) matches the
Fritsch graph's independently documented invariants exactly, cross-checking
the transcription before trusting it. `scripts/gates/kempe_fritsch.py`
implements the paper's own Definitions 1-2 (Kempe chain = maximal two-color
connected component; Kempe chain switch = swap those two colors on it) as
plain BFS, replays both switch orders from the transcribed pre-coloring, and
reproduces the paper's own chain components and outcome exactly: order A
(`(2,G,Y)` then `(3,G,B)`) leaves vertex 1 colorable; order B (`(4,G,B)`
then `(2,G,Y)`) reintroduces `G` at vertex 8, tangling vertex 1 — Gadget 5₂
does not commute. Discrimination control
(`scripts/controls/kempe_fritsch_break_control.py`) independently re-checks
properness after every switch, and confirms via a matched near-miss (a bare
5-wheel graph with the same color pattern but no long-range chords, where
both Kempe chains are trivially isolated single vertices) that the same
unmodified machinery correctly finds no tangle when the graph's extra edges
aren't present: **NO FALSE POSITIVE**. Registered in `check.py`'s
`EXPECTED_VERDICT`; **verdict lock now 23/23**; Lean forge still VERIFIED.
Evidence: `docs/blueprint/kempe-fritsch.md`, `docs/audits/kempe-fritsch.md`.
Remaining unexploited candidates from the same report: Gomila's Λ-bound
(rank 8, verify/audit not refutation, needs replaying ~3M certificates),
Pólya's counterexample (rank 9, needs a sieve to ~906M, real engineering
risk), q-TSPP (rank 10, correct-proof infrastructure, 6-10 weeks) — none
attempted this session.

Prior checkpoint, same day (earlier): **Tait–Tutte gated + controlled,
verdict BREAK.** Reopened `corpus/fragile-formalizable-proofs-report.md`'s
harvest table per this session's own resume note ("next session should
open... for unexploited targets"): ranks 1–5 (odd-zeta, Erdős–Straus,
Agoh–Giuga, Suman, Lamé) were already covered by existing gates; the
historical-collapses export had nothing new (all dispositioned or Track C
pins). Rank 6 (Kempe 4CT) needs planarity + Kempe-chain machinery beyond this
session's budget; rank 7 (**Tait's 1884 conjecture / Tutte's 1946
counterexample**) is a clean finite decidable proposition. Built
`scripts/gates/tait_tutte.py`: the 46-vertex, 69-edge Tutte graph (adjacency
from `networkx.tutte_graph()`'s reference construction, itself cited to
Wikipedia, reproduced inline for diffability) is confirmed 3-connected,
planar, and cubic by `networkx`'s connectivity/planarity routines, then a
from-scratch DFS backtracking search (not any library Hamiltonian-cycle
routine) confirms exhaustively that no Hamiltonian cycle exists
(38,698,468 calls, ~22s) — refuting Tait's conjecture that every
3-connected planar cubic graph is Hamiltonian. Discrimination control
(`scripts/controls/tait_tutte_break_control.py`) reuses the same search
unmodified against the cube graph and truncated tetrahedron (both
Hamiltonian, confirming the search finds cycles when present) and the
Petersen graph (cubic, 3-connected, non-Hamiltonian, but **not planar** —
confirms the gate's planarity hypothesis check is load-bearing, not
decorative): **NO FALSE POSITIVE**. This is a from-scratch build, not a
Track C replay of an external verifier (compare `lame_h23`), so it is
registered in `scripts/gates/check.py`'s `EXPECTED_VERDICT`; **verdict lock
now 22/22**. `networkx==3.6.1` added to `requirements.txt` (first non-
mpmath/SymPy dependency this campaign has needed). No Lean scaffold — the
corpus report's own effort estimate for a planar-graph + Kempe-chain-style
formalization is 2–4 weeks, beyond this session. Evidence:
`docs/blueprint/tait-tutte.md`, `docs/audits/tait-tutte.md`. Remaining
unexploited candidates from the same report, in order: Kempe 4CT (rank 6,
needs planarity + Kempe-chain machinery), Gomila Λ-bound (rank 8, a
verify/audit not a refutation), Pólya counterexample (rank 9, canonize a
certificate), q-TSPP (rank 10, correct-proof infrastructure build) — none
attempted this session.

Prior checkpoint, same day (earlier): **Cohen's Lean scaffold attempted,
blocked on `Nat.totient` decide cost, reverted.** Built the scaffold this
file's prior checkpoint flagged as "the natural next Lean session":
`cyclic`/`SGcyclic`/`Csigma` matching Ibarra's own described formalization,
same `Nat.count_add` window-splitting trick (so `C_σ(3928)` cancels
algebraically and is never evaluated — the only numeric fact needed is
`window(31 members, up to 3959) > Csigma(31)`, i.e. `11 > 10`, one
`decide`). A standalone `lake env lean` check of that one declaration
succeeded in ~2 minutes. Wired into `FragileProofAudit.lean` and run
through the full `lake build` + axiom-audit pipeline, it **timed out past
3600s twice on the operator's own real hardware** (confirmed not a sandbox
artifact) — `Nat.totient` has no `native_decide`-free fast-eval path in
mathlib, and kernel-reducing it at the ~63 values this witness needs (up
to `2·3959+1 = 7919`) is far more expensive under the full pipeline than
the isolated check suggested. Searched for a cheaper witness first
(Python, `m, n ≤ 4000`): only two violations exist in that range — `(31,
3928)` and `(32, 3927)` — both need the same expensive window, so there is
no smaller substitute. Reverted (`FragileProofAudit.lean` import and
`FragileProofAudit/Cohen/` deleted) rather than invest unbounded time in a
from-scratch kernel-cheap totient. Evidence and the full account:
`docs/audits/cohen-subadditivity.md`. **Do not retry the
decide-over-`Nat.totient` approach at this scale** without first building
and timing a fast trial-division Decidable instance standalone. The
Python gate's BREAK verdict is unaffected (verdict lock still 21/21); this
just stays "confirmed tractable in principle, not built."

Prior checkpoint, same day (earlier): **Sárközy sum-product Lean scaffold
landed, ported not built.** Asked which of the 17 scaffold-free gates was
*actually* tractable, not "likely" — checked two. Cohen: wrote a throwaway
probe (`isCyclic`/`Csigma` on `Nat.Coprime`/`Nat.totient`/`Nat.count`), ran
it through `lake env lean` against this project's real mathlib v4.32.2;
`DecidablePred` synthesized with no manual wiring, `by decide` proved
`Csigma 31 = 10` and (with `maxRecDepth 4000`) `Csigma 200 = 45` — confirmed
tractable, not yet built (probe deleted, not committed). Sárközy: the
pinned PDF's four ✓✓-marked results are already formalized by the author
(Tang) at a public GitHub URL cited in the paper's own references, built
with Aristotle + human review. Fetched it, verified it's real (717 lines,
theorem names match the paper exactly), and **ported it verbatim** into
`FragileProofAudit/Sarkozy/UPNT65.lean`. Compiled against this campaign's
pin (v4.32.2, newer than their v4.28.0) with **zero errors** on the first
attempt — one deprecation warning fixed (`push_neg`→`push Not`), one
`private lemma` had its modifier dropped because this campaign's
`axiom_audit.py` cannot resolve Lean 4's private-name mangling by
fully-qualified name (everything else needed no changes). `verify.ps1`:
**verdict lock 21/21, Lean forge VERIFIED, 184 declarations, axiom-clean**
(`propext`/`Classical.choice`/`Quot.sound` only, no `sorry`, no
`native_decide`). This proves Sárközy's Conjecture 65/1.1 false **in full
generality** (quantified over all `c>0`, `p₀`), not just the finite prime
list `scripts/gates/sarkozy_sum_product.py` spot-checks — a third,
independent confirmation alongside the Python gate's two computational
paths. Evidence: `docs/audits/sarkozy-sum-product.md`. Cohen's scaffold
(same tractability tier, not yet built — needs Ibarra's `Nat.count_add`
window-splitting trick to reach `Csigma(3959)` without a `native_decide`)
is the natural next Lean session.

Prior checkpoint, same day (earlier): **KRR-CL "bigger enumerator"
built and found vacuous, not a gate.** Dossier II's own "Next options" list
scored the exhaustive composition-lemma inequality check
(`score(f^2) <= score(f)`, n=5..9) higher (R=9) than the already-landed
Q^[1]-congruence BREAK. Built it (`scripts/controls/krr_cl_composition_scan.py`)
and ran it: 5 902 trees (n=5..8), zero counterexamples, `score` saturates at
the ceiling `n` on every instance because the graceful tree conjecture is
independently known computationally far past what `(n-1)!` brute force can
reach — the inequality reads `n<=n` regardless of the lemma's correctness.
This is structural, not a depth limit: no reachable n makes it decisive.
Governing discipline #7 caught it before registration; it is an instrument
in `scripts/controls/`, not `scripts/gates/check.py` (**lock stays 21/21**).
Corrected inline in `corpus/Fragile-Route_Harvest_Dossier_II.md` and
`docs/audits/krr-cl.md`. Conclusion: the narrower point-witness BREAK
already locked was the right target, not a fallback from a bigger check the
campaign failed to build. TPC-GN's analogous edge-disjointness enumerator
(Hit 4) was **not** attempted this session, given this pattern — a fresh
session should read Hit 4's actual packing-composition machinery before
assuming it inherits the same vacuity trap, rather than assuming either way.

Prior checkpoint, same day (earlier): **JAC-2D gated, verdict PASS
(escalate)**. Yucai Su, arXiv:1603.01867v43 (43 versions, 2016-2024,
"FINAL"), claimed proof of the 2D Jacobian conjecture. Dossier II's
"Earliest pin" was Remark 2.7 + the coefficient-comparison chain to Lemma
2.8 (eq. 2.41). Read the real paper first, per this campaign's standing
discipline: the dossier's framing of Remark 2.7 as "deferring a key
identity to 'a symbolic computation'" does not hold up — the pinned PDF
gives an inline hand proof (a weight-counting argument) right after that
phrase, not a deferral. Replayed the actual identities instead: Remark 2.7
parts (i)/(ii) on generic tight-degree symbolic coefficients, and eq.
(2.41)'s four clauses on two from-scratch, unconditionally invertible
Keller pairs (\(m{=}4,n{=}2\) via \(F=(y^2{+}x)^2{+}y\), \(G=y^2{+}x\); and
\(m{=}6,n{=}3\) one level up). All checks hold exactly, including the exact
linear coefficient \(c_{(-m+1)/m}=-J_0/m\cdot x\) on both instances. Control
(`scripts/controls/jac_2d_break_control.py`) perturbs \(F\) by one monomial
to break the constant-Jacobian hypothesis and shows three of the four
clauses then fail on the same machinery — **DISCRIMINATES**, not a
tautology. Gate: `scripts/gates/jac_2d.py`. Local PDF pinned
(`incoming/jac2d-su-1603.01867v43.pdf`, sha256
`65634fc...ec4224`, 55 pages). Registered in `scripts/gates/check.py`;
**verdict lock now 21/21**; no Lean scaffold (mathlib has no Keller-map
coverage). Evidence: `docs/blueprint/jac-2d.md`, `docs/audits/jac-2d.md`.
Per Governing discipline #3, a PASS here escalates — it does **not** clear
the paper's 55 pages; the dossier's own Fr=8 fragility score (43 versions,
still unaccepted) stands regardless. This was Dossier II's last
ranked-table candidate flagged for this session (see prior checkpoint
below); next session should return to `corpus/fragile-formalizable-proofs-report.md`
/ `corpus/historical-collapses-gemini-export.md` for unexploited targets, or
pivot to Resume (A)/(B) below.

Prior checkpoint, same day (earlier): **TPC-GN locked BREAK** on the evaluation
display in Proposition 3.4, not on Lemma 3.10 and not on the
Gyárfás–Lehel conjecture. Parikshit Chalise, Antwan Clark, and Edinah K.
Gnang, arXiv:2410.13840v2. The live record's v3 (1 Sep 2026) withdraws the
paper because of an error in Lemma 3.10 and cites arXiv:2202.03178v2; that
notice is not the witness, and the KRR-CL congruence does not transfer.
On the augmented stars \(g=((0,1,2),(0,0,2),(0,0,0))\), both
\(\sigma_A=((0,1,2),(1,0,2),(2,0,1))\) and
\(\sigma_B=((0,1,2),(2,0,1),(1,0,2))\) are complete labelings. The display
gives one polynomial in \(y\), up to sign. The coefficient of \(y^3\) is
\(-3072\) at \(\sigma_A\) and \(6144\) at \(\sigma_B\). Both Vandermonde
factors equal \(-8\), and \(\prod_k(k!)^3=8\). Lock is 20. Control:
`scripts/controls/tpc_gn_break_control.py`. No Lean file. Next harvest row:
**JAC-2D** (arXiv:1603.01867v43), pinned and read on its own.

Prior same day: **KRR-CL locked BREAK** on the \(Q^{[1]}\)
congruence in the proof of Lemma 25, not on the inequality in the lemma
statement and not on the Kotzig–Ringel–Rosa conjecture. Edinah K. Gnang,
arXiv:2202.03178v3. The witness is the normalized path \(f=(0,0,1,2)\),
diameter 3, partial iterate \(g=(0,0,1,1)\). At \(\sigma=(0,3,1,2)\) the
printed sum is 128 and \((x_1-x_2)^6\) is 64. Two members of \(\Phi(g)\)
share the pair \((\sigma(1),\sigma(2))=(3,1)\). The \(P_g\) formula on the
same page holds, and both scores equal 4. Lock is 19. Control:
`scripts/controls/krr_cl_break_control.py`. No Lean file. Next harvest row:
**TPC-GN** (Gnang arXiv:2410.13840), pinned and read on its own; this
congruence does not transfer by citation.

Prior same day: **CAT-G locked BREAK** on the sentence between
(2.3) and (2.4), not on `K(-3/2)` and not on the tail recurrence. Zhi-Wei Sun,
arXiv:2609.04176v1, is a different manuscript from Zenodo 22830611 (Bilar's
§9 note, `catalan-sun-lean`). `Pi_i` starts at `h = 1`, so the `k = 0`
denominator `(2i+1)^2` is not cancelled. At `B = 2`, `S = 1`, `j = 1`,
`a = 0` the order-4 difference is `3596288/99225`. The next display writes
`T_{i+1}` where (2.3) has `T_i`, and `T_0 > 8/9 > T_1`. `D(-3/2) = 0`, so
(2.16) is not the witness; (2.13) fails later at the same off-by-one.
(1.4) holds and is not the verdict. Lock is 18. Control:
`scripts/controls/cat_g_break_control.py` (Apéry's ζ(3) weight of degree
`4n` has difference 0 at order `4n+1`). Next harvest row: **KRR-CL**
(Gnang arXiv:2202.03178).

Prior same day: **ES-5 locked BREAK** on the printed line, not on
the whole cover. Ghermoul arXiv:2508.07367v1, equation (35): the `u ≡ 2 (mod 7)`
case copies equation (34)'s denominators onto `q = 12(7x+2)`. At `x = 0` that
says `5/121 = 5/61`. The `p4` formula at `y = 1` is a true identity for the
same `q`, and `q ≡ 0 (mod 252)` stays the author's Conjecture 2 (not gated).
`es_cover` (`2404.01508`) was not retouched. Lock is 17. Control:
`scripts/controls/es5_eq35_break_control.py`.

Prior same day: **TPC-AREA locked BREAK** (Agama
arXiv:1707.03265v4, Theorem 2.3). The dossier witness `1_{3|n}` has shift-1
correlation `0` and sits outside the hypothesis; the locked witness is `f=1`
on `{1,2}∪3ℕ`, correlation identically `2`, and `Q(30)=66>60`. No fixed
`C(1)` works. `f≡1` keeps `C=1`. Lock is 16. Control:
`scripts/controls/tpc_area_break_control.py`. Next harvest row: **ES-5**
(arXiv:2508.07367), abort if the paper already concedes an uncovered class.

Same day, earlier: **COL-FP closed VACUOUS** (Kawasaki arXiv:2502.20642v2).
The dossier's `3/2` expansion is real and is not a lemma of v2. Theorem 3.1's
weighted sum is `<= 0` on `{1,...,256}²`. Remark 3.1 already drops Theorems
2.2 and 2.3; recomputed at `λ ≡ 1`, `(x,y)=(1,3)`, the live branch of 2.3(5)
has ratio `3/2`. No lock row. Instrument: `scripts/gates/col_fp.py`.

Prior checkpoint: 2026-09-21 (late) — **Track D re-audit. All 15 verdicts stand;
one conjecture statement was wrong and is fixed.**

Cold re-read of the whole Track D batch. Findings, in order of what they cost:

1. **`sarkozy_sum_product` had the conjecture itself wrong.** The corpus doc
   stated the threshold as `|A| ≥ c·p`; Sárközy's Conjecture 65, as quoted in
   Tang's Conjecture 1.1, reads `|A| > (½ − c)p`. Under the corpus doc's
   version the claim falls to any small set and the BREAK was vacuous. The
   control did not catch it because the control checked the gate against the
   *same* corpus paraphrase — an echo, not an instrument. Both fixed; the gate
   now also implements Tang's real construction (Section 2: the graph
   `u~v ⟺ u+v=1 ∨ uv=1`, components `{0,1}`, `{2,½,−1}`, the roots of
   `X²−X+1`, and `(p−5−δ)/6` six-cycles), verified across 29 primes up to
   2003. It refutes every `c > 0.00025` by explicit witness. **The verdict is
   unchanged and now actually supported.**
2. **The "read the real paper" lesson was never retrofitted.** Targets #1–#3
   (Cohen, Baste, Sárközy) had no PDF pinned — gated from the corpus doc plus
   an abstract fetch, the exact provenance that failed four times later in the
   same session. All three PDFs are now pinned and read. **Cohen and Baste
   verify exactly**: Cohen's definitions and `C_σ(3959)=697 > 696` match
   character for character, and Baste's twenty clauses *and* its dominating set
   `D₀ = {0,2,5,7,8,13,15,30,31,32,33,35,37,42,46,48}` match the paper verbatim
   — the gate's independently-found witness is the paper's own.
3. **Three controls were checking strings against themselves.** `cohen` and
   `baste` "verified transcription" by substring-matching prose the campaign
   had written down. Replaced with real matched checks: Cohen now runs the
   gate's own predicate against Ibarra's stated values (including Cohen's
   tabulated `C_σ(598)=120` and the eleven window members), Baste compares the
   gate's clause list and `D₀` against an independent second transcription.
4. **Two gates reintroduced the check-that-cannot-fail defect** the campaign
   fixed in `es_cover`: `sarkozy`'s `density_below_half` (its own comment said
   it could not fail) and `thakur`'s literal `degree_is_5 = True`. Both removed
   from the `ok` conjunction; Thakur's degree is now read off `POLY_P`, making
   it a genuine transcription check.
5. **Controls left almost no evidence.** Eight of ten wrote no receipt at all.
   All now write `results/<control>_meta.json` via
   `scripts/controls/receipt.py`; `salez_youssef`'s two-check control grew the
   two missing categories. Controls remain instruments — never in `check.py`.
6. **NCI's SKIP had no artifact**; it now has `results/nci_skip_meta.json` so a
   later session cannot silently re-open it.
7. Docs resynced: README had **no Track D row at all**, and the control runbook
   here listed 3 of 11 receipts.
8. **The local Lean axiom audit had been silently dead, and the committed
   VERIFIED receipt did not come from the documented command.** Running
   `verify.ps1` in the repo root produced `CAPABILITY_LIMITED`: all 150
   declarations "unresolved". Cause — a stale agent worktree at
   `.claude/worktrees/agent-af80866ecd1aa0e9f/` holds a full copy of the Lean
   sources, `.claude` was not in the forge's `SKIP_DIRS`, so `find_sources`
   emitted module names like `.claude.worktrees.<id>.FragileProofAudit`. The
   generated audit file's first `import` is then a syntax error, the whole file
   fails to parse, and every declaration comes back unaudited. The committed
   `results/lean_verify_meta.json` recorded `VERIFIED` because that run had
   `"project"` pointing *inside* the worktree, where the walk was clean. CI
   stayed green throughout because a fresh checkout has no `.claude/` at all —
   so nothing anywhere pointed at the gap. Fixed: `.claude` (and the usual
   editor/vendor directories) added to `SKIP_DIRS`, plus a guard that names an
   illegal module path instead of reporting mysteriously unresolved
   declarations. `verify.ps1` from the repo root now reports **VERIFIED, 150
   declarations, axioms ⊆ {propext, Classical.choice, Quot.sound}**.
   The stale worktree is gitignored and was left in place; it is not a
   registered `git worktree` any more.

**Follow-up landed same day (2026-09-22):** the corpus doc is annotated inline
(a header banner plus AUDIT NOTEs on the Sárközy, NCI and ranking-table
sections) and downgraded in `corpus/README.md` — its identifiers and ranking
were good, its descriptions of the mathematics were not, and it is now
exhausted. All eight Track D targets have bug-report briefs under
`docs/audits/`, closing the gap where nineteen blueprints had only ten briefs.
The stale agent worktree is deleted (all 92 of its files verified already in
the git object store first; its `.lake` symlink into the main build was removed
before the directory, so nothing could follow it). One more meta/source drift
fixed: `chung_graham_spiro`'s `false_instance` said the scan reached
`N=20 000` while `DEPTH_N = 50 000`; the string is now interpolated so it
cannot drift again.

Two leads this turned up, both worth a session: Ibarra's Cohen paper is
**verified in Lean 4 over mathlib** (`Nat.Coprime n (Nat.totient n)`,
axiom-clean, no `native_decide`) and Tang's Sárközy paper marks Proposition 2.1
and Theorem 2.2 as **formalized in Lean 4**. The standing claim that no Track D
target has a tractable Lean scaffold is wrong for at least these two.

Prior checkpoint: Track D#8 **`salez_youssef_logsobolev` gated +
controlled, verdict BREAK**. Per this session's own standing lesson (NCI's
corpus entry claimed a gate that turned out fabricated), fetched and read
the real paper first (Münch, Leipzig University, arXiv:2504.08055,
`incoming/salez-youssef-munch-2504.08055.pdf`, live-checked via WebFetch
before download) — this time the corpus doc's description held up: Münch
refutes the Salez-Youssef conjecture (`α_LSI ≥ c·K/log(d)` under an Ollivier
curvature lower bound `K`, for a universal `c`) with an explicit birth-death
chain family on `{1,...,3n}` with exact rational transition rates,
`κ ≥ 1/(4n²)` everywhere, and a capacitary upper bound on `α_LSI` that decays
like `1/(n³ log n)` — one power of `n` faster than `K/log d ~ 1/(n² log n)`,
so no fixed `c` survives `n → ∞`. Gate (`scripts/gates/salez_youssef_logsobolev.py`)
reproduces this exactly: `fractions.Fraction` transition probabilities,
`mpmath` 80-digit stationary distribution and capacity (magnitudes down to
`~1e-10937` at `n=3000`, far outside float64), exact-rational confirmation
that the curvature bound is met with **equality** at every `n` tested, and
confirmation that the ratio `R(n)/[K/log d]` is strictly decreasing across
seven `n` values spanning three orders of magnitude, dropping below `0.01` at
`n=3000` — the actual asymptotic mechanism, not a single snapshot.
Discrimination control (`scripts/controls/salez_youssef_break_control.py`)
verdict **NO FALSE POSITIVE**: ten transcription spot-checks against the
pinned PDF's Section 2 formulas all match, and — using the paper's own named
"this case satisfies the conjecture" example (constant curvature + log-concave
invariant measure) — the same ratio diagnostic correctly shows the ratio
*growing* (not vanishing) as `n` grows, confirming the machinery discriminates
rather than always finding a "violation." Registered in `scripts/gates/check.py`;
**verdict lock now 15/15**; no Lean scaffold (mathlib has no Ollivier
curvature / isocapacitary / log-Sobolev coverage — the corpus doc's own
ranking table already correctly flagged this as low tractability). Evidence:
`docs/blueprint/salez-youssef-logsobolev.md`. This closes out the corpus
doc's ranking table (all 8 rows now dispositioned: 6 BREAK, 1 SKIPPED/no
finite gate, this one BREAK) — **Track D has no further corpus-doc-ranked
candidates**; next session should check `corpus/fragile-formalizable-proofs-report.md`
and `corpus/historical-collapses-gemini-export.md` for unexploited targets,
or return to the Lamé/cyclotomic Lean thread (**Resume (A)** below).

Prior Track D checkpoint (2026-09-21): Track D#7 **NCI Conjecture
(arXiv:2608.27416) SKIPPED, no finite gate** (not a BREAK/PASS — a scope
decision). Went to gate the corpus doc's next-ranked target (NCI has a full
"Target Identifier" block, unlike Chung-Graham's ghost entry, so it looked
trustworthy). Fetched and read the real paper (Wilhelm, TU Ilmenau,
`incoming/nci-wilhelm-2608.27416.pdf`, live-checked via WebFetch first) and
found the corpus doc's claimed "Verifiable Gate / Counterexample: Python
script validating the non-existence of admissible sets..." does not exist in
the source — **fabricated**, not merely corrupted-by-image-transcription
like the prior three targets. The actual refutation (Theorem 8.1 / Corollary
8.2) is a first-moment (probabilistic-existence) argument: Lemma 7.2 proves
*some* marking `m` on `F_p²` (`p ≥ 10^5`) makes the lattice `P_{p,m}` admit
no winning dot-algebra tree, via a union-bound expectation `E_p < 1`, but
**exhibits no marking** — confirmed by the paper's own §9 Open Problems item
1, which states verbatim that even a small-`p` explicit counterexample is
unsolved. The only numerically checkable content in the paper (the
double-counting identities in `(7.1)`) is true of every finite point set
unconditionally — testing it would be exactly the check-that-cannot-fail
ceremony Governing discipline #7 forbids. No script to write that would
*reproduce* the paper's witness, because it has none. Filed under **Do not
reopen** alongside Joshi/IUT, Collatz, Goldbach "monitors" — no finite gate.
Evidence: `docs/blueprint/nci-conjecture.md`.

Prior Track D checkpoint (2026-09-21): Track D#6 **`chung_graham_spiro` gated +
controlled, verdict BREAK**. Cross-checked the "Chung-Graham Gap-Set" row
against the corpus doc's own Section headers first, per the resume-note flag
— found it is a **ghost entry**: Sections 1-3 cover exactly seven other
targets, each with a full "Target Identifier" block and a Works Cited
number; Chung-Graham has neither, appearing only in the final ranking table
with no arXiv ID, no claimed theorem, no citation, and an incomplete name
(the real conjecture is Chung-Graham-**Spiro**, J. Number Theory 210
(2020)). Located the actual refutation by live web search:
Mohsen Aliabadi (2026), arXiv:2609.04473, `9 ∈ U_4 \ D_4` at `l=4`
(`incoming/chung-graham-spiro-2609.04473.pdf`). Gate reproduces the witness
by two independent paths: a direct translation of the paper's own `(a,b,t)`
representation algorithm (Path A, validated by exact transcription match
against two independently-sized literal lists printed in the PDF, `D∩[2,17]`
and the full 54-element `D∩[2,113]`), and a from-scratch simulation of the
original slow-Fibonacci-walk definition (Path B, agrees with Path A on all
192 unambiguous integers checked in `[2,220]`; 27 excluded as genuine ties
this campaign's naive brute force can't resolve without the original 2020
paper's tie-breaking rule — reported openly, not hidden). Caught and fixed a
category-error bug during development (conflating "is 9 itself an
up-integer" with "is 9 a gap value in `U_4`" — different questions).
Discrimination control (`scripts/controls/chung_graham_break_control.py`)
verdict **NO FALSE POSITIVE**: the same machinery correctly reproduces the
paper's own *true* claims at `l=1,2`, and correctly finds no discrepancy at
the paper's own flagged-open `l=3` case. Registered in
`scripts/gates/check.py`; **verdict lock now 14/14**; no Lean scaffold yet.
Evidence: `docs/blueprint/chung-graham-spiro.md`.

Prior Track D checkpoint (2026-09-21): Track D#5 **`thakur_carlitz` gated + controlled,
verdict BREAK**. Thakur's 2015 conjecture (every Carlitz-Wieferich prime of
`F_q[T]` in odd characteristic has degree divisible by the characteristic
`p`) refuted at an explicit degree-5 prime over `F_{19^3}`
(`incoming/thakur-carlitz-2607.15305.pdf`, arXiv:2607.15305, D. Niedbala
Giraudin) — **another corpus-doc narrative unusable** (the explicit quintic
and field data were behind untranscribed inline images), so the gate was
built by fetching and reading the actual paper. A from-scratch pure-Python
finite-field engine (`scripts/harness/finite_field.py` — no
`galois`/Sage/PARI on this laptop) builds `F_{19^3}[T]/(P)`, confirms `P`
irreducible via the standard distinct-degree test, and confirms the
c-Wieferich condition `M_5(theta)=0` via two independently coded formulas
(the paper's nested form and the raw alternating-sum definition) that agree.
Discrimination control (`scripts/controls/thakur_break_control.py`) verdict
**NO FALSE POSITIVE**: the same engine correctly identifies two known
c-Wieferich primes at different `(degree, characteristic)` pairs
(`T^5+4T+1`/F_5, Bamunoba-Bergström's `T^6+T^4+T^3+T^2+2T+2`/F_3) as positive
controls, and reports 0 hits among 10 random irreducible quintics over F_19
as negative controls. Registered in `scripts/gates/check.py`; **verdict lock
now 13/13**; no Lean scaffold yet (likely blocked on mathlib Carlitz-module
coverage). Evidence: `docs/blueprint/thakur-carlitz.md`.

Prior Track D checkpoint (2026-09-21): Track D#4 **`tang_zhang_schatten` gated +
controlled, verdict BREAK**. The Tang-Zhang Schatten-norm conjecture
(a single formula `C^TZ_{p,m}` claimed sharp for all finite `p>1`) refuted
at `p=3/2, m=2` via a real PDF pin (`incoming/tang-zhang-2608.15558.pdf`,
arXiv:2608.15558) — **this target's corpus-doc narrative was unusable**
(numeric constants lost behind untranscribed inline-image placeholders),
so the gate was built by fetching and reading the actual paper instead.
Two independent computation paths (exact-`Fraction` Gram-matrix algebra,
and mpmath 60-digit direct matrix construction) agree to `1e-40` and both
reproduce the paper's exact witness `R ≈ 1.0364136587048904 > 207/200 >
C^TZ_{3/2,2} ≈ 1.0346539518514341`. Discrimination control
(`scripts/controls/tang_zhang_break_control.py`) verdict **NO FALSE
POSITIVE**: 5 000 random rank-one pairs at the same `(p,m)` show only
~1% exceed the conjectured constant (witness is near the true extremum,
not typical), and the same formula independently reduces to Tang-Zhang's
own *proven* `p=2` closed form for several `m`. Registered in
`scripts/gates/check.py`; **verdict lock now 12/12**; no Lean scaffold
yet (likely blocked on mathlib Schatten-norm coverage). Evidence:
`docs/blueprint/tang-zhang-schatten.md`.

Prior Track D checkpoint (2026-09-21): Track D#3 **`sarkozy_sum_product`
gated + controlled, verdict BREAK**. Sarkozy's mod-`p` sum-product
conjecture (`|A| >= c*p` implies `1 in A+A union A*A`) refuted
independently: exhaustive search over `Z/pZ` for `p in
{5,7,11,13,17,19}` (CI, `--deep` adds `23`) finds an explicit
size-`(p-1)/2` witness avoiding `1` in both sumset and productset for
**every** tested prime, without transcribing Tang's (arXiv:2603.29992)
actual construction — the corpus doc's own description of it is
internally inconsistent. Discrimination control
(`scripts/controls/sarkozy_break_control.py`) verdict **NO FALSE
POSITIVE**, with one honest caveat: item-4 independent corroboration
(plain quadratic residues as an unrelated witness family) came back
negative at every tested prime. Evidence:
`docs/blueprint/sarkozy-sum-product.md`.

Prior checkpoint (2026-09-20): Phase 3(i)#+b **`Gal(ℚ(ζ₂₃)/ℚ)` cyclic of order
22, VERIFIED** (`CyclotomicGalois.lean`, axiom-clean, 150 declarations). The
attempt to go further and pin the decomposition-group cardinality (`Nat.card
(stabilizer G P) = 11` via `Ideal.card_stabilizer_eq`) hit a genuine mathlib
instance-diamond wall — see **Blocked** below; not forced through. Phase
3(i)#+a **norm pin VERIFIED**: any prime of `𝓞(ℚ(ζ₂₃))` above `2` has `absNorm
= 2^11`, not `2` (`CyclotomicPrimeTwo.lean`). Phase 3(i)# `OKNeg23 ↪
𝓞(ℚ(ζ₂₃))` VERIFIED (ring embedding, injective, via `embedToRingOfIntegers`);
Phase 3(i)#a Gauss-sum embed `gauss23² = −23` in `ℚ(ζ₂₃)` VERIFIED; Phase
3(i)+++++ concrete ideal `(2, θ)` with `absNorm = 2` non-principal VERIFIED;
Phase 3(i)++++ `IsDedekindDomain OKNeg23` VERIFIED; Phase 2(d) odd-zeta
202601.1609 RE-BROKEN at Lemma 5.1; **audit-integrity pass landed 2026-09-20**
— verdict lock + discrimination controls; **all eight verdicts of the day unchanged**,
but what several of them *mean* changed (see **Track B**). **Track B item 1
landed same day** — `lame_ideal_neg23` discrimination control built, NO FALSE
POSITIVE. **Track D opened 2026-09-21** — ingested
`corpus/live-fragile-proofs-2024-2026.md` (7 arXiv-verified candidate
targets from an AI deep-research export; distinct from the Gemini export,
all 7 IDs live-checked). Two targets gated + controlled same day:
`cohen_subadditivity` (BREAK) and `baste_domination` (BREAK, closed both
bounds independently including an exact branch-and-bound search this
campaign wrote for γ(G)≥16). A third, `sarkozy_sum_product`, landed
2026-09-21 (BREAK). A fourth, `tang_zhang_schatten`, also landed
2026-09-21 (BREAK, first Track D target to need a real PDF fetch since the
corpus doc's own text was unusable for it). A fifth, `thakur_carlitz`,
landed 2026-09-21 (BREAK, second Track D target needing a real PDF fetch —
same image-corruption failure mode as Tang-Zhang). A sixth,
`chung_graham_spiro`, also landed 2026-09-21 (BREAK) — worst provenance
failure yet: the corpus doc has no body section for this target at all (a
table-only ghost entry, no arXiv ID, incomplete name), so the refutation was
located by live web search instead of any corpus-doc lead. A seventh
candidate, NCI, was SKIPPED (no finite gate) the same day — its corpus entry
looked complete but claimed a "Verifiable Gate" fabricated relative to the
real paper, which is a pure first-moment existence proof with no witness
(see `docs/blueprint/nci-conjecture.md`). An eighth, `salez_youssef_logsobolev`,
landed 2026-09-21 (BREAK) — this one's corpus description held up against the
real paper. All seven landed BREAKs registered in `scripts/gates/check.py`;
none has a Lean scaffold yet (mathlib coverage gaps: cyclic-number/graph
theory targets are tractable in principle but not attempted; Ollivier
curvature/log-Sobolev has no mathlib coverage at all).

**Resume at any of:** *(A)* the decomposition-group identification needed to
finish the pushed-forward non-principal ideal in `𝓞(ℚ(ζ₂₃))` — `Gal(ℚ(ζ₂₃)/ℚ)`
is now pinned cyclic of order 22, but `Ideal.card_stabilizer_eq` is blocked on
an `Algebra ℤ Cyclotomic23` / `Algebra ℚ Cyclotomic23` instance diamond (see
**Blocked**), or proved h⁺, or per-claim Agoh–Giuga — *(B)* the 2(d) write-up
decision (Track B item 2) — *(C)* Track D: Cohen, Baste, Sárközy, Tang-Zhang, Thakur, Chung-Graham-Spiro,
and Salez-Youssef are now all gated + controlled (BREAK ×7); NCI is SKIPPED
(no finite gate — its "Target Identifier" block existed, unlike Chung-Graham's,
but its "Verifiable Gate" claim turned out to be fabricated, not just
image-corrupted). The corpus doc's own 8-row ranking table is now fully
dispositioned — no further candidates there. Next Track D session should
open `corpus/fragile-formalizable-proofs-report.md` and
`corpus/historical-collapses-gemini-export.md` for unexploited targets (apply
the same "fetch and read the real paper before trusting any gate claim"
discipline learned this session), or pivot back to *(A)*.
`docs/blueprint/cohen-subadditivity.md`, `docs/blueprint/baste-domination.md`,
`docs/blueprint/sarkozy-sum-product.md`, `docs/blueprint/tang-zhang-schatten.md`,
`docs/blueprint/thakur-carlitz.md`, `docs/blueprint/chung-graham-spiro.md`,
`docs/blueprint/nci-conjecture.md`, and `docs/blueprint/salez-youssef-logsobolev.md`
are the templates to follow — the middle four also demonstrate the fallback
when the corpus doc's own text is corrupted, entirely missing, or (NCI)
fabricated for a target: fetch and read the real paper instead (see their
**Local PDF pinned** lines; chung-graham-spiro's documents cross-checking the
corpus doc's Section headers before trusting a table row; nci-conjecture's
documents recognizing a claimed gate that doesn't exist in the source at
all, as opposed to merely being image-corrupted).

(2(d) write-up was declined — **worth revisiting**: after the false-positive
control it is the campaign's only sendable artifact. See Track B item 2.)

**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  
**Habit:** commit each phase when it lands (do not leave a dirty tree for the next session)

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — after Phase 3(i)#a Gauss-sum embed

**3(i) Lamé 1847:** **DONE through 3(i)#** —
gate \(h^-_{23}=3\); Lean Premise/QuadraticWitness/Maillet Bareiss;
quadratic ideal gate + `no_norm_two_equation`;
`IdealPrincipal` + **`IsDedekindDomain OKNeg23`** + concrete
`P2 = (2, θ)` with `absNorm P2 = 2` and `¬ IsPrincipal P2`;
**`CyclotomicEmbed`**: `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ`;
**`CyclotomicIdeal`**: `embedToRingOfIntegers : OKNeg23 →+* 𝓞 (CyclotomicField
23 ℚ)`, injective — `OKNeg23 ↪ 𝓞(ℚ(ζ₂₃))` as a ring embedding (θ ↦
`(1+gauss23)/2`, same minimal polynomial `X²−X+6`; integrality transported
via `Module.Finite ℤ OKNeg23` / `map_isIntegral_int`).
Evidence: `FragileProofAudit/Lame/`,
`scripts/gates/lame_h23.py`, `scripts/gates/lame_ideal_neg23.py`,
`docs/audits/lame-1847.md`.

**3(h) Agoh–Giuga kit:** **DONE** — Python oracle PASS + Lean `Criteria`/`Oracle`
(`oracle_seven`).

**3(i)#+a Norm pin (2026-09-20):** **DONE** — before attempting the pushforward,
pinned what the target norm has to be. `ord₂ mod 23 = 11` (`2^11 = 2048 ≡ 1`),
so mathlib's `IsCyclotomicExtension.Rat.inertiaDeg_eq_of_not_dvd` +
`Ideal.absNorm_eq_pow_inertiaDeg'` give: **any** prime of `𝓞(ℚ(ζ₂₃))` lying
over `(2)` has absolute norm `2^11 = 2048`, never `2`. Confirms in Lean the
suspicion already in this file: `Ideal.map embedToRingOfIntegers P2` cannot
land on a norm-2 ideal. Axiom-clean (`propext`/`Classical.choice`/
`Quot.sound` only). Evidence: `FragileProofAudit/Lame/CyclotomicPrimeTwo.lean`.

**3(i)#+b Cyclic Galois group (2026-09-20):** **DONE** —
`Gal(ℚ(ζ₂₃)/ℚ)` is cyclic of order 22. `Cyclotomic23/ℚ` is Galois
(`IsCyclotomicExtension.isGalois`); `cyclotomic 23 ℚ` is irreducible
(`Polynomial.cyclotomic.irreducible_rat`), giving
`IsCyclotomicExtension.autEquivPow : Gal(Cyclotomic23/ℚ) ≃* (ZMod 23)ˣ`;
`(ZMod 23)ˣ` is cyclic (`ZMod.isCyclic_units_prime`, 23 prime), and cyclicity
transports along the `MulEquiv` (`isCyclic_of_surjective`); order 22 via
`Nat.card (ZMod 23)ˣ = (23).totient = 22`. Axiom-clean, 150 declarations.
Evidence: `FragileProofAudit/Lame/CyclotomicGalois.lean`.

**Next options:**

1. **Pushed-forward non-principal ideal in `𝓞(ℚ(ζ₂₃))`** — now that
   `embedToRingOfIntegers` exists, the target norm is pinned at `2^11`, and
   `Gal(ℚ(ζ₂₃)/ℚ)` is confirmed cyclic of order 22, the remaining gap is
   identification, not arithmetic: show `Ideal.map embedToRingOfIntegers P2`
   is *prime* (not just contained in one) and equals *the* prime above `(2)`
   fixed by `L23`. **Attempted 2026-09-20 and blocked** — see below. Informal
   argument stands: the decomposition group of a prime above 2 has order
   `ef = 11·1 = 11`, the unique order-11 subgroup of the cyclic group of
   order 22, whose fixed field is exactly `L23`; formalizing this needs a
   decomposition-group / fixed-field correspondence connecting `OKNeg23`'s
   coordinate presentation to the actual subfield fixed by that subgroup; or
   sidestep norms entirely and prove \(h^+_{23}=1\) directly.
2. **Per-claim Agoh–Giuga audit** — blueprint a concrete claimed proof against
   the kit; instantiate failing lemma at \(g=30\) or \(g=858\).
3. Optional: von Staudt–Clausen / Agoh–Bernoulli bridge (same kit, not blocking).

**Blocked (2026-09-20):** the decomposition-group cardinality step
(`Ideal.card_stabilizer_eq` from `Mathlib.NumberTheory.RamificationInertia.Galois`,
which would give `Nat.card (MulAction.stabilizer Gal(ℚ(ζ₂₃)/ℚ) P) = 11` for
`P` a prime over `(2)`) hit a genuine mathlib instance diamond, not a missing
lemma: `IsGaloisGroup.of_isFractionRing Gal(Cyclotomic23/ℚ) ℤ (𝓞 Cyclotomic23)
ℚ Cyclotomic23` needs `[IsScalarTower ℤ ℚ Cyclotomic23]`, which *is* available
standalone (`AddCommGroup.intIsScalarTower`, fully generic), but fails to
synthesize once `Algebra ℤ Cyclotomic23` has already been pinned to
`CyclotomicField.instAlgebra` (mathlib's `deriving instance Algebra A,
IsScalarTower A K for CyclotomicField n K` mechanism) while `Algebra ℚ
Cyclotomic23` gets independently pinned to `DivisionRing.toRatAlgebra` —
`trace.Meta.synthInstance` confirms the failure is exactly at
`IsScalarTower ℤ ℚ Cyclotomic23` after those two choices are locked in.
Forcing `Algebra ℚ Cyclotomic23 := CyclotomicField.algebra 23 ℚ` via `haveI`
did **not** fix it (still fails — the ambient ambiguity between the two
`Algebra ℚ` instances seems to be the actual cause, not merely which one is
picked). This is not a missing-lemma gap of the kind flagged in advance (the
group-theory "unique order-11 subgroup of a cyclic group of order 22" lemma
was never reached — the block is earlier, at the ring-theoretic instance
wiring for `IsGaloisGroup`). Not forced through; no file committed with a
`sorry`. A future session should either (a) hunt for the right
`letI`/`Algebra.compHom`-based override that makes all three of `Algebra ℤ
Cyclotomic23`, `Algebra ℚ Cyclotomic23`, `IsScalarTower ℤ ℚ Cyclotomic23`
mutually defeq-consistent for instance synthesis, or (b) sidestep
`Ideal.card_stabilizer_eq` entirely and go for `h^+_{23}=1` directly.

flt-regular as a lake dependency is separately blocked — upstream toolchain is
`leanprover/lean4:v4.34.*` while this campaign pins `v4.32.2` (match
`catalan-sun-lean`). Do not bump the pin casually.

Do **not** claim the Agoh–Giuga conjecture. Do **not** confuse Kummer-regular
(\(23\nmid h\)) with UFD (\(h=1\)). Do **not** claim Lean proved
`classNumber (CyclotomicField 23 ℚ) = 3` — Bareiss owns \(h^-\); \(h^+\) stays cited.

---

## Track B — audit integrity (the non-Lean thread)

**Landed 2026-09-20** — commits `f399b26`, `3f8a78f`, `73782e0`, `5752140`.

- **Verdict lock** (`scripts/gates/check.py`) — every gate pinned in
  `EXPECTED_VERDICT`; drift in *either* direction fails the run. Gates still
  exit 0 on a BREAK by design (a BREAK is a finding, not a build failure); the
  lock is what notices a flip. Changing a pin is a deliberate act and belongs
  in the same commit as the re-audit.
- **Discrimination control is now doctrine** — `docs/GATE-BEFORE-PROVE.md`
  protocol step 3, with a register of which gates require one.
- **`scripts/controls/`** — instruments, not gates: no campaign verdict, never
  registered in `check.py`.
- Forced UTF-8 on gate subprocess IO and runner stdio. `lame_h23` and
  `lame_ideal_neg23` had been exiting 1 under a cp1252 console *after* writing a
  correct PASS, making `verify.ps1` red for pure code-page reasons.

**Net result: no verdict changed.** All three PASSes and both BREAKs stand.

### What the audit altered

| target | change |
|---|---|
| **2(g) PDN1** | Real defect, in the *gate*. α=2 rested on 1 and 2 integers and α=3 was untested — **81 data points total**. Added a mod-arithmetic path (sparse Euler/Jacobi + Kronecker substitution) self-tested against the exact dense oracle. CI now **6 747** points reaching α=3 in ~7 s; `--deep` gives **33 746** with α=3 on all four families. All hold. |
| **2(e) ES** | PASS *reinterpreted*. Matched control: coverage carries **no** information — every perturbed congruence covers *more* primes than the real one — but `egyptian3` separates **100 % / exactly 0 %**. The gate certifies **Theorems 4 and 7** (the implication), not Conjecture 1 (the existential). The paper never claimed to prove ESC; its abstract conjectures the covering. |
| **2(f)** RR | `nmax` circularity tested directly: raising it by 3 never moves `Z`, and the largest *contributing* ‖n‖ is 4–6 against a cutoff of 11–14. Degree push — (3,8) 12→**22** (past Frobenius 13), (3,7) 15→26, (3,5) 24→34 — all MATCH. |
| **1(b) Suman** | False-positive control clear. The search has no discriminating power on its own; the verdict rests entirely on the `k = 0` endpoint, verified verbatim in the PDF, reinforced by (49) being stated with **no** mention of ζ(5), and matched to Chen et al. |
| **2(d)** odd-zeta | False-positive control clear, and **upgraded**: the BREAK is an **infimum**, not a sample. For λ ≥ 0.5 the minimum over the whole domain is at the boundary, `g = 1+q = e^λ` exactly (148.413 = e⁵ … 442414 = e¹³). The instrument is shown to discriminate — it *finds* admissible `q` for λ < 0.458. |
| **`es_cover` odd-k** | Had gated the verdict on five branches that are tautologies in `k`. Now gates the failable scope invariant (every hard residue ≡ 1 mod 8); failure is `ABORT_SCOPE`, not `BREAK`. |

### Resume here (Track B), in order

1. ~~`lame_ideal_neg23` discrimination control~~ — **DONE 2026-09-20**,
   `scripts/controls/lame_ideal_control.py`. Confirms the search finds real
   solutions (`32 → (±3, ±1)`, `24 → (±1, ±1)`, `4 → (±2, 0)`); reproduces
   `norm_equation_solutions` against a brute force at 10x `b_bound` for seven
   targets (no truncation); shows the parity filter accepts at target=32 (not
   just vacuously true at target=8). Verdict: NO FALSE POSITIVE. Not
   registered in `check.py` — instrument, not a gate, per doctrine.

2. **2(d) write-up decision — revisit.** After the false-positive control this
   is the campaign's **only sendable artifact**: a 2026 preprint with no
   published refutation, a BREAK that is now an infimum result, survivor of both
   a retraction cycle and a control. Contrast 1(b) — Chen et al.
   (arXiv:2411.16774v3) already published that objection, so it is internal
   calibration, not an output.

3. **ES corpus question — open.** Does the 100 %/0 % separation belong in
   `corpus/` as a *positive* finding about Lopez's Theorems 4 and 7, rather than
   filed as a non-event because nothing died? Partial evidence gathered:
   Theorem 4 is an **iff** with a real constructive proof (`4duv = p+u+v` ⟹
   `u = (p+v)/(4dv−1)`, natural iff `4dv−1 | p+v`), *not* a one-line identity —
   which makes the framing more defensible than assumed. **Theorem 7 not yet
   read.** Note the campaign has no slot for "verified, no defect found"
   outputs, so `corpus/` is selection-biased toward kills.

4. **Type G on the PASSes.** ES is **vacuous** — the paper claims no proof, so
   there is no argument to find a gap in. Real remaining targets: PDN1's
   induction and RR's Ore step. All three notes now say `Type G not attempted`.
   Scope before starting; a pass escalates, never force a kill.

5. **Operator-only deep runs** (not CI): `python scripts/gates/pdn1.py --deep`
   (~105 s, 33 746 points, α=3 everywhere); RR `(3,8)` beyond `N=22` (23 s at
   22, cost grows fast).

---

## Track C — historical Type F pins (not resume)

**Landed 2026-09-20** from the Gemini “historical collapses” export
(`corpus/historical-collapses-gemini-export.md`, trust: lead). These do
**not** change the resume line above and are **not** in `EXPECTED_VERDICT`.

| Pin | Clone SHA | What was run | Lock |
|---|---|---|---|
| Quantum Hedetniemi arXiv:2609.20690 | `95c0ac05e9b7ea50b827ec491661eed2ed0147b4` | author Python certificates PASS; `axiom_audit.py` 382 files, no `sorry`/`axiom`; kernel `UNKNOWN` (their Lean 4.19.0) | off |
| Borsuk-63 Grinsztajn | `cdcdbeac2e692b8641218c70ce9f414522e125e5` | `scripts/gates/borsuk63.py` wraps author `verify_borsuk63.py` | off |

Do **not** promote either into the verdict lock. Do **not** bump the
campaign Lean pin to 4.19.0 to compile Zeiss. Operator commands:

```powershell
python scripts/gates/borsuk63.py
python incoming/quantum-hedetniemi/numerics/check_base_graph.py
python scripts/forge/axiom_audit.py incoming/quantum-hedetniemi --json-out results/hedetniemi_q_audit_meta.json
```

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, prior gates as before, `giuga_oracle` PASS, `lame_h23`
PASS, `lame_ideal_neg23` PASS, `cohen_subadditivity` BREAK,
`baste_domination` BREAK, `sarkozy_sum_product` BREAK,
`tang_zhang_schatten` BREAK, `thakur_carlitz` BREAK, `chung_graham_spiro`
BREAK, `salez_youssef_logsobolev` BREAK, `tpc_area` BREAK, `es5_eq35` BREAK,
`cat_g` BREAK, `krr_cl` BREAK, `tpc_gn` BREAK, `jac_2d` PASS,
`tait_tutte` BREAK, `kempe_fritsch` BREAK, `gb_sce` BREAK,
**verdict lock 24/24 ok**, lake + forge VERIFIED
(includes `Lame.IdealWitness` + `Lame.IdealPrincipal` + `Lame.DedekindField` +
`Lame.IdealNormTwo` + `Lame.CyclotomicEmbed` + `Lame.CyclotomicIdeal` +
`Lame.CyclotomicPrimeTwo` + `Lame.CyclotomicGalois` + `Sarkozy.UPNT65`;
axiom-clean, 184 declarations).

Controls are **not** run by `verify.ps1` — they are operator instruments:

```powershell
python scripts/controls/es_cover_control.py 10000      # ~3 s
python scripts/controls/break_control.py               # ~7 s  (suman + odd_zeta)
python scripts/controls/lame_ideal_control.py          # <1 s
python scripts/controls/cohen_break_control.py         # ~20 s
python scripts/controls/baste_break_control.py         # ~2 s
python scripts/controls/sarkozy_break_control.py       # ~6 s
python scripts/controls/tang_zhang_break_control.py    # ~3 s
python scripts/controls/thakur_break_control.py        # ~25 s
python scripts/controls/chung_graham_spiro_break_control.py  # ~5 s
python scripts/controls/salez_youssef_break_control.py # ~30 s
python scripts/controls/jac_2d_break_control.py        # ~10 s
python scripts/controls/tait_tutte_break_control.py    # <1 s
python scripts/controls/kempe_fritsch_break_control.py # <1 s
python scripts/gates/borsuk63.py                       # Track C; not on the verdict lock
```

All exit 0. Each writes `results/<control>_meta.json` (thirteen receipts from
twelve scripts — `break_control.py` covers two targets and writes one receipt
each). A receipt is **not** a lock row: nothing fails CI when one changes, and
controls are still never registered in `check.py`.

Every control that has a pinned PDF checks it. `break_control` needs the pinned
PDFs under `incoming/`; without them its transcription and corroboration checks
report `unavailable` rather than passing silently.

**3(i) landing:** gate `76521e6`; Premise/QuadraticWitness `9ae01da`; Maillet
Bareiss `7a8da40`; IdealWitness `9e7d8f2`; IdealPrincipal `4444ea9`;
Dedekind `c36aa9a`; IdealNormTwo `bc2bd06`; CyclotomicEmbed follows.

---

## Do not reopen

| Item | Why |
|---|---|
| Invent a Chen beta kernel for 202601.1609 | Gate of a formula the paper did not write |
| Treat `g(α)<0` as `‖Λ_m‖→0` | Different object |
| Fall back to Kim because odd-zeta failed | 2(d) BREAK is a valid outcome |
| Full Kim Tendsto Lean | Compressed appendix only |
| Claude’s Suman snippet `1 ≤ k ≤ 0` | Empty range; real range is `0 ≤ k ≤ d_n` |
| Jana–Karmakar | Audited clean (630+96); Pochhammer negative-index is mandatory |
| `catalan-sun-lean` | Own reference campaign; reuse pin, do not re-attack |
| Force kills on 2(e)–2(g) PASSes | Pass escalates; Ore/notebooks are capability-limited, not BREAKs |
| Joshi/IUT, Collatz, Goldbach “monitors” | No finite gate |
| Kawasaki COL-FP contraction (2502.20642v2) | Dossier object is not the printed lemma. v2 Remark 3.1 already withholds Theorems 2.2 and 2.3. Reopen only if a later version claims a Banach contraction of `T`, or a `λ` for which 2.2 or 2.3 applies. See `docs/audits/kawasaki-collatz.md` |
| NCI Conjecture (arXiv:2608.27416) | No finite gate — refutation is a first-moment existence argument with no exhibited witness, confirmed unsolved by the author's own §9 Open Problems; corpus doc's "Verifiable Gate" claim is fabricated, see `docs/blueprint/nci-conjecture.md` |
| Fake Mathematica / RISC / Magma replays | Prefer blocked notes over invented cofactors |
| Unmatched negative controls | The first ES control varied the congruence **and** the search breadth at once; its “weakly discriminating” answer had to be withdrawn. Prove search equivalence before concluding |
| Suman base case as a “false positive” | The paper does derive `a=2b`/`a=b` itself, but (49) is stated with **no** ζ(5), so the base case owes an *algebraic* claim. Chen et al. concur. Settled 2026-09-20 |
| Re-promoting `es_cover`’s odd-k identity branches | Tautologies in `k`; documentation only, never a verdict |
| Discrimination controls on `rr_qexpand` / `pdn1` / `giuga_oracle` / `lame_h23` | Ceremony — exact equality or divisibility; see the register in `GATE-BEFORE-PROVE.md` |

---

## Done (do not redo)

| Phase | Outcome | Evidence |
|---|---|---|
| **0** | Pin, harness, CI, forge | `README.md`, `results/lean_verify_meta.json` |
| **1(a)** γ | **G** — statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ | `docs/audits/gamma-aejonanonymous.md` |
| **1(b)** Suman ζ(5) | **B** — Eq. (48) at `n=1` has `a=2b`, `a=b` under `0 ≤ k ≤ d_1` | `docs/audits/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean` |
| **2(d)** odd-zeta 202601.1609 | **BREAK (corrected 2026-09-20)** — Lemma 5.1 never supplies admissible `(q,α,δ)`: `g(α*)>0` for every `q>e^λ−1` at `λ=2n+3`, `n=1..5`, sampled 300 orders of magnitude; superseded prior "`Λ_m` unevaluable" claim (that was false, PDF now pinned) | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py`, `incoming/odd-zeta-202601/` (gitignored, sha256 in gate meta) |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — certifies **Theorems 4/7**, not Conjecture 1: matched control shows coverage carries no information, `egyptian3` separates 100 %/0 %; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** — \(Z=P\) + Lemma 12; OreReduce (34) **capability-limited** | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **2(g)** PDN1 2503.00004 | **PASS** — GF + Thm 1.1/1.2 + (3.13) through **α=3**, 6 747 points in CI / 33 746 at `--deep` (was 81); notebooks **capability-limited** | `docs/audits/pdn1.md`, `scripts/gates/pdn1.py`, `incoming/pdn1/` |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `GiugaOnFactors`/`KorseltOnFactors`/`oracle_seven` | `docs/audits/agoh-giuga.md`, `scripts/gates/giuga_oracle.py`, `FragileProofAudit/AgohGiuga/` |
| **3(i)** Lamé 1847 | **PASS** — through 3(i)#a: Bareiss + ideal + Dedekind + concrete `(2,θ)` + Gauss-sum `√−23` in `ℚ(ζ₂₃)` | `docs/audits/lame-1847.md`, `FragileProofAudit/Lame/` |
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

**Audited 2026-09-20** — every row above re-tested for false negatives (the
PASSes) or false positives (the BREAKs). **No verdict changed.** See **Track B**
for what the audit altered about their meaning and support.

---

## Optional appendix (not a blocker) — compressed Kim

**Only if** you specifically want Type F on a known corpse.

- Source: arXiv:1105.0730 · Zudilin / OEIS A013663
- Stub: `docs/blueprint/kim-zeta5.md`
- Quote ε-inequality after eq. (3.3); gate `n_k ∈ {10,100,1000}`, `N=1`
- One-page audit. **No Tendsto** unless the table is surprising
- Does not gate 3(h)

---

## After 3(i)++++ IsDedekindDomain OKNeg23

| ID | Target | First milestone |
|---|---|---|
| 3(i)++++ | Dedekind instance | **DONE** — `IsDedekindDomain OKNeg23` via integral closure |
| 3(i)+++++ | Concrete ideal | **DONE** — `P2 = (2, θ)`, `absNorm = 2`, `¬ IsPrincipal` |
| 3(i)#a | Gauss-sum embed | **DONE** — `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ` |
| 3(i)# | Cyclotomic embedding | **DONE** — `embedToRingOfIntegers : OKNeg23 →+* 𝓞(ℚ(ζ₂₃))`, injective |
| 3(i)#+a | Norm pin for primes above 2 | **DONE** — any prime over `(2)` in `𝓞(ℚ(ζ₂₃))` has `absNorm = 2^11`, via `ord₂ mod 23 = 11` |
| 3(i)#+b | `Gal(ℚ(ζ₂₃)/ℚ)` cyclic order 22 | **DONE** — via `autEquivPow ≃* (ZMod 23)ˣ` + `ZMod.isCyclic_units_prime` |
| 3(i)#+ | Pushed-forward ideal / classNumber | **BLOCKED 2026-09-20** on an `Algebra ℤ`/`Algebra ℚ` instance diamond for `Cyclotomic23` inside `Ideal.card_stabilizer_eq` (see **Blocked**, above); needs `Ideal.map embedToRingOfIntegers P2` prime + decomposition-group identification with the norm-`2^11` prime, `¬ Ideal.IsPrincipal`, or proved `h^+` |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval exists |
| 2(d) done | 202601.1609 PDF | **Pinned**; Lemma 5.1 BREAK landed, false-positive control clear, now an **infimum** result — write-up **decision to revisit** (Track B item 2) |
| 3(h)+ | Per-claim Agoh–Giuga | Concrete claimed proof vs kit at \(g=30\) / \(858\) |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
6. **Commit as you go** — each phase lands with a git commit before the session ends.
7. **A check that cannot fail is not evidence.** Run the discrimination control
   where `docs/GATE-BEFORE-PROVE.md` requires one, and never gate a verdict on a
   tautology. Pin every verdict in `EXPECTED_VERDICT`.
