# Appendices - draft (2026-09-23)

## A. Verdict-log schema and lock mechanics

Every locked gate writes a machine-readable verdict record to
`results/<name>_gate_meta.json`. The schema, by example
(`results/gb_sce_gate_meta.json`):

| Field | Content |
|---|---|
| `target` / `source` | gate id; paper pinned as `arXiv:IDvN` |
| `local_pdf` / `pdf_sha256` | pinned paper artifact and its hash |
| `lemma` | the paper's claim under test, quoted or cited by location |
| `instance` | the parameters the gate instantiated |
| `false_instance` | the concrete witness (for BREAK) |
| `verdict` | `BREAK` or `PASS` |
| `not_this_gate` | what the verdict does *not* cover (polarity rule, Sec. 2) |
| `timestamp` / `elapsed_s` | when and how long the gate ran |
| `ok` | whether the gate itself executed cleanly |
| `controls` | control outcomes embedded in the gate's own meta: list of `control` / `verdict` / `ok` / receipt path / receipt SHA-256 / receipt timestamp; `[]` where no control receipt exists. `receipt_sha256` hashes the receipt file at embed time only. |

Gate-specific fields (counts tested/violated, margins, control
references) extend the schema. The lock's verdict check reads exactly
one field from each meta record: `verdict`, compared against
`EXPECTED_VERDICT`. `ok` - whether the gate executed cleanly - is
conventional rather than enforced: every current record carries it,
and the aggregate run reports per-gate `ok` from the process return
code, but the lock performs no schema validation over it. Field
naming varies per gate and the lock tolerates it: the
Kempe--Fritsch record, for example, uses `gate` where the table says
`target` and `local_pdf_sha256` where it says `pdf_sha256`, and omits
`instance`, `not_this_gate`, and `elapsed_s`. A record missing a
conventional field is a documentation gap, not a lock failure; the
fail-closed check is the verdict comparison in `check.py`.

The lock itself is `EXPECTED_VERDICT` in `scripts/gates/check.py`: a
map from gate id to `(meta-file, expected-verdict)`. The aggregate
run executes every gate, compares each recorded verdict against its
expectation, and reports `[ok]` or `[DRIFT]` per gate; any drift -
in either direction - fails the run. Adding a gate means adding its
entry in the same commit as the gate. Removing or re-pinning a
verdict requires the re-audit to be recorded first. Prose
dispositions (GAP, SKIP, UNKNOWN) and off-lock confirmations are not
in the map; they live in `docs/audits/` (Sec. 2).

## B. Gate harness conventions

- **Stdlib first.** Gates are dependency-free Python where possible
  (exact rational arithmetic via `fractions`, sieves by hand); where
  heavy numerics are needed the dependency is stated and pinned.
  A gate that cannot run on a fresh checkout is not a gate.
- **Deterministic.** Fixed seeds; no wall-clock dependence; no
  network access at run time. Inputs are hash-pinned files under
  `incoming/` or generated deterministically in the script.
- **Self-verifying inputs.** Hardcoded mathematical data (facet
  lists, group tables) carries its own consistency checks -
  supporting-plane verification, Euler characteristic, extremality -
  executed before the gate logic runs.
- **Controls are code, not commentary.** Each gate's discrimination
  control is a standalone runnable script under `scripts/controls/`,
  with its own receipt JSON under `results/` - and every control
  outcome recorded in a receipt is also embedded in its gate's own meta
  JSON, under the `controls` key (control name, verdict, ok, receipt
  path, receipt SHA-256, receipt timestamp). The embedding is done by
  `scripts/gates/record_controls.py`, which the aggregate
  (`scripts/gates/check.py`) calls after every gate run; gates with no
  control receipt carry `"controls": []`, an honest empty record rather
  than an omitted field. Two gates are the documented exception to
  "code, not commentary": they carry their control inline instead of as
  a script - `gb_sce` (matched control described in its audit note)
  and `mah_3` (wrong-$\theta$ control inside the gate) - and their
  metas record `"controls": []`, i.e. no *separate* receipt. Gates in the
  exact-equality class carry no discrimination control; Sec. 4.2 gives the
  exemption and its substitutes. Control failures are report-only: a
  receipt with `ok: false` is embedded as-is, printed loudly, and
  recorded in `gates_check_meta.json` as `controls_ok: false`, but it
  does not fail the aggregate or the verdict lock. Controls are re-run
  manually, outside the aggregate - `recorded_at` is the embed time,
  not the control-run time, so a receipt can predate its gate's last
  run. `receipt_sha256` binds the receipt file as of embed time; it
  binds neither the control script nor the gate code. Appendix C maps
  every gate to its control.
- **Exit codes mean it.** Exit 0 with `verdict` set: the gate ran
  and decided. Any exception, missing input, or guard failure
  (e.g. paper hash mismatch) is an abort, never a verdict.
- **Timestamps refresh; verdicts don't.** The aggregate run rewrites
  `timestamp` fields across meta files, and reserializes every gate
  meta (a meta is rewritten only when its embedded controls actually
  change, so repeat runs produce no diff churn); verdict fields change
  only by re-audit commit.

## C. Audit catalog (locked gates)

**Table C1.** Gate, target, stratum, verdict, claim-level
disposition, attack type, evidence category, and control, from
`EXPECTED_VERDICT`
(`scripts/gates/check.py`). Strata: hist = historical calibration,
live = live literature, fringe = low-stakes preprints, infra =
infrastructure. Evidence: proof-route refutation (a claimed proof's
route is broken), conjecture counterexample (a stated conjecture is
falsified), recomputation (a published refutation's witness is
recomputed from the pinned claim artifact), confirmation (the claim
survives), infrastructure. Controls are standalone scripts under
`scripts/controls/` with receipt JSONs under `results/` (App B);
"exact-equality" marks the Sec. 4.2 exemption.

| Gate | Target | Stratum | Verdict | Claim disposition | Attack | Evidence | Control |
|---|---|---|---|---|---|---|---|
| kempe_fritsch | Fritsch & Fritsch 1998 gadget | hist | BREAK | claim BREAK | B+F | recomputation | kempe_fritsch_break_control.py |
| tait_tutte | Tait 1884 / Tutte 1946 | hist | BREAK | claim BREAK | A | recomputation | tait_tutte_break_control.py |
| lame_h23 | Lame 1847 cyclotomic route | hist | PASS | claim BREAK (route) | G | proof-route refutation | not required (exact equality) |
| lame_ideal_neg23 | Lame 1847 ideal variant | hist | PASS | claim BREAK (route) | G | proof-route refutation | lame_ideal_control.py |
| cohen_subadditivity | Cohen Conjecture 66 | live | BREAK | claim BREAK | F | conjecture counterexample | cohen_break_control.py |
| baste_domination | Baste et al. 2019/2020 | live | BREAK | claim BREAK | F | conjecture counterexample | baste_break_control.py |
| sarkozy_sum_product | Sarkozy Conjecture 65 | live | BREAK | claim BREAK | F | conjecture counterexample | sarkozy_break_control.py |
| tang_zhang_schatten | Tang--Zhang | live | BREAK | claim BREAK | A | recomputation (Zeng--Liu--Ratnavelu) | tang_zhang_break_control.py |
| thakur_carlitz | Thakur 2015 | live | BREAK | claim BREAK | F | conjecture counterexample | thakur_break_control.py |
| chung_graham_spiro | Chung--Graham--Spiro 2020 | live | BREAK | claim BREAK | F | recomputation (Aliabadi) | chung_graham_break_control.py |
| salez_youssef_logsobolev | Salez--Youssef Conj. 1 | live | BREAK | claim BREAK | G | conjecture counterexample | salez_youssef_break_control.py |
| cat_g | Sun Catalan route | live | BREAK | claim BREAK | A | proof-route refutation | cat_g_break_control.py |
| es_cover | Lopez Erdos--Straus cover | live | PASS | claim PASS | D | confirmation | es_cover_control.py |
| rr_qexpand | Lau--Ono; Huang--Lau--Ono--Paule | live | PASS | claim PASS | D | confirmation | not required (exact equality) |
| pdn1 | Du--Yao | live | PASS | claim PASS | D | confirmation | not required (exact equality) |
| mah_3 | Mahler 3D counting lemma | live | PASS | claim SKIP | A+G | confirmation (gate) | inline wrong-$\theta$ control |
| suman_eq48 | Suman $\zeta(5)$ | fringe | BREAK | claim BREAK | B | proof-route refutation | `suman_break_control` |
| odd_zeta_1609 | odd-zeta claim (Chattopadhyay) | fringe | BREAK | claim BREAK | B | proof-route refutation | `odd_zeta_break_control` |
| es5_eq35 | Ghermoul ES eq. 35 | fringe | BREAK | claim BREAK | A | proof-route refutation | es5_eq35_break_control.py |
| tpc_area | twin-prime area method | fringe | BREAK | claim BREAK | F | proof-route refutation | tpc_area_break_control.py |
| tpc_gn | Chalise--Clark--Gnang Prop. 3.4 | fringe | BREAK | claim BREAK | A | proof-route refutation | tpc_gn_break_control.py |
| krr_cl | Gnang Lemma 25 | fringe | BREAK | claim BREAK | F | proof-route refutation | krr_cl_break_control.py |
| gb_sce | Zadehgol Mohammadi & Kolahdouz | fringe | BREAK | claim BREAK | A | proof-route refutation | audit-note matched control |
| jac_2d | Su 2D-Jacobian v43 | fringe | PASS | claim PASS | D+E | confirmation | jac_2d_break_control.py |
| giuga_oracle | standing Giuga oracle | infra | PASS | n/a | --[^1] | infrastructure | not required (exact equality) |
| **Total: 25 gates** | | **4 / 12 / 8 / 1** | **17 BREAK / 8 PASS** | | | **machine-checked against `EXPECTED_VERDICT`** | |

Off-lock dispositions (prose, not on the verdict lock): FRK-UC (GAP, G),
LEG-NS (GAP, G), Erdos--Straus Theorem 10 (GAP, G, repairable),
JAC-2D type-G (PASS, G), $\gamma$ formalization route (FAIL, off-lock:
the route targeted mathlib's `EulerMascheroniConstant` rather than the
paper's claim), Jana--Karmakar type-C (PASS, off-lock: WZ-certificate
audit of a published proof, not a fragile route), NCI (SKIP), quantum
Hedetniemi (UNKNOWN). Off-lock confirmations: Gomila $\Lambda$-bound
(execution-verified at pinned commit, Sec. 5.2), Polya (BANKED).

[^1]: `giuga_oracle` is a standing verification oracle (known Giuga
composites checked against Korselt), not an attack on a route; it
carries no A--G letter.

## D. Glossary

**Attack type.** One of the mechanism classes A--G (Sec. 3): the kind of
route a proof takes to its conclusion.

**BANKED / canonization.** An off-lock infrastructure product: a
checkable record banked for the community (e.g., Polya's smallest
counterexample), not a verdict about a route.

**BREAK.** Disposition: a specific lemma, as the paper states it, is
false, exhibited by a gate. Recorded as lemma, instance, false instance.

**Control (discrimination control).** A standalone runnable check
(Sec. 4.2) showing the gate produces the opposite verdict where the
opposite is correct; its outcome is recorded in a receipt JSON and
embedded in the gate's meta. Two gates carry their control inline
(`gb_sce`, `mah_3`); four exact-equality gates are exempt.

**Corpus / dossier / harvest.** Target selection: the *harvest* is
the fragility-targeted search; the *dossier* is the document it
produces; the *corpus* is the dossier directory.

**Disposition.** An audit's final outcome - exactly one of BREAK,
GAP, PASS, SKIP, UNKNOWN - defined by what was done, not by how bad
the news is.

**Dual implementation.** A second, clean-room implementation of a
computation, written without reading the first, that must agree on
every certificate.

**Fail-closed.** Any checksum mismatch, row disagreement, or
unreproducible step fails the lane; no partial passes.

**GAP.** Disposition: the paper's argument does not establish its
conclusion, but no lemma statement was falsified. Found by prose
audit; carries its own evidentiary standard (Sec. 2).

**Gate.** The executable check: a script plus hash-pinned inputs plus
a machine-readable meta record. A gate records a *verdict*
(BREAK/PASS); an audit ends in a *disposition*.

**Gate-before-prove.** No Lean formalization begins until the claim
it targets has survived a numeric gate.

**Hostile prior.** The audit stance: a computational claim is
unconfirmed until an independent replay confirms it, regardless of
the prose around it.

**Lane.** A replay execution track - e.g., the Gomila audit's finite,
Dini, barrier, and tail lanes.

**Paper-first.** No gate from a secondary summary: pin the version
of record (SHA-256, byte count) and read the argument first.

**PASS.** Disposition: the gate confirmed what it was built to test -
a statement about the audit's reach, not a certificate of truth.
Carries the same weight as BREAK.

**Prose audit.** Manual proof-reading path: GAP analysis and
statement-fidelity checks, where no finite residue exists to gate.

**Residue.** The finitely checkable remainder of a claim - what a
gate actually tests.

**Route.** The specific chain of lemmas under test. Gates refute
routes, not theorems.

**SKIP.** Disposition: the target as stated admits no gate - the
verdict is about the audit ("we cannot test this"), not the paper.

**UNKNOWN.** The checkable parts check out, but the decisive step
cannot be replayed on the campaign's toolchain.

**Verdict / verdict lock.** A gate's recorded outcome, pinned in
`EXPECTED_VERDICT`; the lock runs in CI and any drift fails the
build.

## E. Notation

**Table E1.** Symbols used in the manuscript.

| Symbol | Meaning |
|---|---|
| $B(n,k)$, $B(n,n)$ | TSPP orbit-counting generating function; the diagonal identity is $B(n,n) = 1$ |
| $C^{TZ}_{p,m}$ | Tang--Zhang conjectured Schatten-norm constant |
| $C_\sigma(N)$ | count of Sophie Germain cyclic integers in $[1,N]$ (Cohen) |
| $D_\ell$, $U_\ell$ | down-integer / up-integer $\ell$-step gap sets (Chung--Graham--Spiro) |
| $d_n$ | $\mathrm{lcm}(1,2,\dots,n)$ (Suman) |
| $G$ | Catalan's constant (Sun) |
| $h$, $h^{-}$, $h^{+}$ | class number and its minus/plus parts (Lame) |
| $L(n)$ | Liouville summatory function (Polya) |
| $t_0$, $y_0$ | Gomila parameter row: $\Lambda \le t_0 + y_0^2/2$ |
| $\Lambda$ | de Bruijn--Newman constant |
| $\Lambda_m$ | odd-zeta auxiliary sequence |
| $\zeta$ | Riemann zeta function |
| $\gamma$ | Euler--Mascheroni constant; $\gamma(G)$ domination number (Baste, context-dependent) |
| $\gamma_e(G)$ | edge domination number (Baste) |

## F. Execution environment

Gates run on stock Python 3 (standard library first: `fractions`,
hand-rolled sieves); where heavy numerics are needed the dependency is
stated and pinned in the gate's docstring. No network access at gate
run time; fixed seeds; inputs are SHA-256-pinned files under
`incoming/` or generated deterministically in the script. The Lean 4
formalization lines (q-TSPP milestones, Polya slice, Cohen ancillary)
use Lean toolchain 4.32.2 with pinned mathlib and dependency checkouts;
kernel-checked builds report jobs completed and error counts
(e.g., 8,656/8,656, zero errors). The verdict-lock aggregate
(`scripts/gates/check.py`) runs every gate and compares each recorded
verdict against `EXPECTED_VERDICT`; any drift fails the run.
