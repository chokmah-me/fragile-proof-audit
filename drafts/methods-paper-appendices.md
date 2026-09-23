# Appendices — draft (2026-09-23)

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
| `not_this_gate` | what the verdict does *not* cover (polarity rule, §3) |
| `timestamp` / `elapsed_s` | when and how long the gate ran |
| `ok` | whether the gate itself executed cleanly |

Gate-specific fields (counts tested/violated, margins, control
results) extend the schema; the fields above are mandatory.

The lock itself is `EXPECTED_VERDICT` in `scripts/gates/check.py`: a
map from gate id to `(meta-file, expected-verdict)`. The aggregate
run executes every gate, compares each recorded verdict against its
expectation, and reports `[ok]` or `[DRIFT]` per gate; any drift —
in either direction — fails the run. Adding a gate means adding its
entry in the same commit as the gate. Removing or re-pinning a
verdict requires the re-audit to be recorded first. Prose
dispositions (GAP, SKIP, UNKNOWN) and off-lock confirmations are not
in the map; they live in `docs/audits/` (§3).

## B. Gate harness conventions

- **Stdlib first.** Gates are dependency-free Python where possible
  (exact rational arithmetic via `fractions`, sieves by hand); where
  heavy numerics are needed the dependency is stated and pinned.
  A gate that cannot run on a fresh checkout is not a gate.
- **Deterministic.** Fixed seeds; no wall-clock dependence; no
  network access at run time. Inputs are hash-pinned files under
  `incoming/` or generated deterministically in the script.
- **Self-verifying inputs.** Hardcoded mathematical data (facet
  lists, group tables) carries its own consistency checks —
  supporting-plane verification, Euler characteristic, extremality —
  executed before the gate logic runs.
- **Controls are code, not commentary.** Every gate implements its
  discrimination control as a runnable function whose result is
  recorded in the meta JSON (e.g. `dusart_control_ok`,
  `wrong_theta_breaks_bound`).
- **Exit codes mean it.** Exit 0 with `verdict` set: the gate ran
  and decided. Any exception, missing input, or guard failure
  (e.g. paper hash mismatch) is an abort, never a verdict.
- **Timestamps refresh; verdicts don't.** The aggregate run rewrites
  `timestamp` fields across meta files; verdict fields change only
  by re-audit commit.

## C. Audit catalog (locked gates)

Gate → verdict → attack type(s), from `EXPECTED_VERDICT`
(`scripts/gates/check.py`). Types per the dossiers
(`corpus/Fragile-Route_Harvest_Dossier*.md`,
`corpus/lean4-attack-harvest.md`), the §4 worked examples, and the
audit notes (`es_cover` is D per its own note's "only Type-D-style
instance checking"; `giuga_oracle` is infrastructure, see note).

| Gate | Verdict | Type |
|---|---|---|
| suman_eq48 | BREAK | B |
| odd_zeta_1609 | BREAK | B |
| es_cover | PASS | D |
| rr_qexpand | PASS | D |
| pdn1 | PASS | D |
| giuga_oracle | PASS | infra¹ |
| lame_h23 | PASS | G |
| lame_ideal_neg23 | PASS | G |
| cohen_subadditivity | BREAK | F |
| baste_domination | BREAK | F |
| sarkozy_sum_product | BREAK | F |
| tang_zhang_schatten | BREAK | A |
| thakur_carlitz | BREAK | F |
| chung_graham_spiro | BREAK | F |
| salez_youssef_logsobolev | BREAK | G |
| tpc_area | BREAK | F |
| es5_eq35 | BREAK | A |
| cat_g | BREAK | E |
| krr_cl | BREAK | F |
| tpc_gn | BREAK | A |
| jac_2d | PASS | D+E |
| tait_tutte | BREAK | F |
| kempe_fritsch | BREAK | B/F |
| gb_sce | BREAK | A |
| mah_3 | PASS | A+G |
| **Total: 25 gates** | **17 BREAK / 8 PASS** | **machine-checked against `EXPECTED_VERDICT` in `scripts/gates/check.py`** |

Prose dispositions (not on the lock): FRK-UC (GAP, G),
LEG-NS (GAP, G), Erdős–Straus Thm-10 (GAP, G, repairable),
JAC-2D type-G (PASS, G), NCI (SKIP), quantum Hedetniemi
(UNKNOWN). Off-lock confirmations/canonizations: Gomila Λ-bound
(audit PASS), Pólya (BANKED).

¹ `giuga_oracle` is a standing verification oracle (known Giuga
composites checked against Korselt), not an attack on a route; it
carries no A–G letter.

## D. Glossary

**Attack type.** One of the mechanism classes A–G (§4): the kind of
route a proof takes to its conclusion.

**BANKED / canonization.** An off-lock infrastructure product: a
checkable record banked for the community (e.g., Pólya's smallest
counterexample), not a verdict about a route.

**BREAK.** Disposition: a specific lemma, as the paper states it, is
false, exhibited by a gate with a passing discrimination control.
Recorded as lemma · instance · false instance.

**Control (discrimination control).** A runnable check, part of the
gate, showing it produces the opposite verdict where the opposite is
correct. A gate that cannot be calibrated is not run.

**Corpus / dossier / harvest.** Target selection: the *harvest* is
the fragility-targeted search; the *dossier* is the document it
produces; the *corpus* is the dossier directory.

**Disposition.** An audit's final outcome — exactly one of BREAK,
GAP, PASS, SKIP, UNKNOWN — defined by what was done, not by how bad
the news is.

**Dual implementation.** A second, clean-room implementation of a
computation, written without reading the first, that must agree on
every certificate.

**Fail-closed.** Any checksum mismatch, row disagreement, or
unreproducible step fails the lane; no partial passes.

**GAP.** Disposition: the paper's argument does not establish its
conclusion, but no lemma statement was falsified. Found by prose
audit; carries its own evidentiary standard (§3).

**Gate.** The executable check: a script plus hash-pinned inputs plus
a machine-readable meta record. A gate records a *verdict*
(BREAK/PASS); an audit ends in a *disposition*.

**Gate-before-prove.** No Lean formalization begins until the claim
it targets has survived a numeric gate.

**Hostile prior.** The audit stance: a computational claim is
unconfirmed until an independent replay confirms it, regardless of
the prose around it.

**Lane.** A replay execution track — e.g., the Gomila audit's finite,
Dini, barrier, and tail lanes.

**Paper-first.** No gate from a secondary summary: pin the version
of record (SHA-256, byte count) and read the argument first.

**PASS.** Disposition: the gate confirmed what it was built to test —
a statement about the audit's reach, not a certificate of truth.
Carries the same weight as BREAK.

**Prose audit.** Manual proof-reading path: GAP analysis and
statement-fidelity checks, where no finite residue exists to gate.

**Residue.** The finitely checkable remainder of a claim — what a
gate actually tests.

**Route.** The specific chain of lemmas under test. Gates refute
routes, not theorems.

**SKIP.** Disposition: the target as stated admits no gate — the
verdict is about the audit ("we cannot test this"), not the paper.

**UNKNOWN.** The checkable parts check out, but the decisive step
cannot be replayed on the campaign's toolchain.

**Verdict / verdict lock.** A gate's recorded outcome, pinned in
`EXPECTED_VERDICT`; the lock runs in CI and any drift fails the
build.
