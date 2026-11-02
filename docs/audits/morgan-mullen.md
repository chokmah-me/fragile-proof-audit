# Audit note — Morgan-Mullen conjecture, Lean formalization (Hellwig, arXiv:2610.36534)

**Claim artifact:** Florian Hellwig, *Resolvent Components of
Completely Normal Elements and the Morgan-Mullen Conjecture*,
arXiv:2610.36534. Claim: every finite field extension contains an
element that is both primitive and completely normal (the
Morgan-Mullen conjecture), plus Hachenberger's lower bound
(Corollary 8.8) and the PCN asymptotic corollaries (8.9),
formalized in Lean 4. Release v1.0 archived at Zenodo 23661993.
**Campaign objects:** `incoming/morgan-mullen/PIN.md` (pins,
permitted axiom universe, expected exact axiom sets, claim seams,
run #1 post-mortem addendum).
**Repo pin:** https://github.com/florian-hellwig/morgan-mullen @
`03fb9bd6c2605f7d4df111c154db14ed2f570b7b`. Toolchain and Mathlib
both v4.34.1 (mathlib rev
`d13f23b723b8a846827a245b89c10fc7d3f11612`). 43 Lean files.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
harness: one-shot forge workflow `morgan-mullen-forge.yml`
(gate job + forge job on the HP self-hosted runner), pre-dispatch
gate per `docs/PRE-DISPATCH-CHECKS.md`; run dates `2026-11-02`.

**Status:** CLOSED 2026-11-02 — verdict **PASS** (standalone
verify/audit; the 32-gate verdict lock is untouched). Scope of the
PASS, stated once and binding on every summary of this note: the
formalization route reproduces exactly as pinned, with two named
literature axioms and compiler-trusted checker evaluation in the
trusted base (M4). This is not a kernel-only proof of the raw
conjecture, and the note does not claim one.

## Forge record

- Run #1 (41492466013, main@508510e) died in 6 s at the
  source-scan step on the auditor's harness, not the claim: a
  naive `grep "^axiom "` counted two doc-prose lines as
  declarations. Post-mortem and fix in the PIN addendum; fix
  landed main@f353f41 and was proven both directions against the
  pinned tree before re-dispatch.
- Run #2 (41493317158, main@f353f41) completed **SUCCESS** in
  26m58s (2026-11-02T17:40:06Z to 18:07:04Z). Gate job success;
  forge job success on DESKTOP-7HDI2D1, all 13 steps success.
  Build leg 17:44:55Z to 17:54:51Z.
- Evidence artifact `morgan-mullen-forge-evidence` (id
  13167570685, 4,110 bytes, expires 2027-01-31) downloaded
  2026-11-02; zip sha256
  `edf075d03f361d6b710e4c7dda60e22441a7d0dd1aed1c1c0d9ad805ef7de541`
  matches the GitHub API digest exactly. Every file in it
  (verdict.txt, pins.txt, expected.sha256, declared-axioms.txt,
  build.log, audit.log, auditdeep.log, audit-extra.log) was
  checked line by line against the PIN before this note was
  written. verdict.txt reads `FORGE-VERDICT: PASS`.

## M1 — statement correspondence: PASS

- pins.txt: HEAD equals the pin; all seven in-tree sha256
  (lean-toolchain, lakefile.toml, lake-manifest.json,
  AXIOMS_AUDIT.txt, Audit.lean, AuditDeep.lean,
  MorganMullen/Axioms.lean) OK; 43 Lean files, as counted at
  recon.
- The headline theorem's printed signature in audit.log is
  `MorganMullen.morgan_mullen : ∀ (F E : Type*) [Field F]
  [Field E] [Finite E] [Algebra F E], HasMMProperty F E`, with
  `HasMMProperty F E := ∃ w : E, IsPrimitiveElem w ∧
  IsCompletelyNormal F E w` (Basic.lean:45, read at recon). The
  formal statement quantifies over all finite extensions and
  matches the paper's claim shape.
- The Hachenberger pair and the three PCN corollaries print
  with the statements the paper numbers as Corollary 8.8 and
  8.9 (signatures in audit.log).

## M2 — execution correspondence: PASS

- The build reproduces in our hands on the HP runner:
  `Build completed successfully (3672 jobs)`, the authors'
  stated job count exactly, no sorry in the build log, source
  scans clean (no `sorry`, no `admit`, declared axioms exactly
  the two in Axioms.lean: garefalakis_kapetanakis at line 28,
  rosser_schoenfeld_psi at line 32).
- The authors' Audit.lean, run as-is against our build,
  reproduces the expected exact axiom set for every audited
  declaration, matching the PIN table (derived from the
  authors' AXIOMS_AUDIT.txt and their own CI classifier):
  - `morgan_mullen`: all 7 permitted axioms (classical three +
    Lean.ofReduceBool + Lean.trustCompiler + both declared
    literature axioms)
  - `hachenberger_lower_bound`, `hachenberger_eq_iff`,
    `pcn_error_le_star`, `pcn_theta_cn`,
    `pcn_ratio_tendsto_one`: 6 each (no
    garefalakis_kapetanakis)
  - `pcn_sub_theta_cn_abs_le`: classical three only
  - `sorryAx` appears in no set.
- Auditor superset beyond the authors' audit:
  `MorganMullen.weight_le_Wq` (Theorem 7.8, the
  Rosser-Schoenfeld consumer) depends on 6 axioms, a subset of
  the permitted 7 (audit-extra.log).
- The authors' AuditDeep.lean, run as-is (it is itself
  fail-closed), reports: 67,982 constants reachable from
  morgan_mullen; exactly 25 checkers evaluated by
  Lean.ofReduceBool, all named; 7,224 constants the checkers
  depend on, 228 of them project constants; 104 core constants
  with @[implemented_by]/@[extern] (the trustCompiler base);
  and both required OK lines: no project constant used by a
  checker carries @[implemented_by]/@[extern], and the project
  declares exactly the two named axioms. The 6 checkers of
  Corollary 8.8 and the checkers of Corollary 8.9 are all
  among the 25; `pcn_sub_theta_cn_abs_le` uses 0 checkers,
  consistent with its classical-three-only axiom set.

## M3 — credit honesty: PASS

- The authors' stated build (3,672 jobs, clean) and their
  published axiom audit reproduce exactly; nothing in the
  repo overstates what the formalization does.
- The one case the Lean development does not prove, n <= q,
  enters as the declared axiom garefalakis_kapetanakis and is
  disclosed as such in the paper and in Axioms.lean. The
  checker evaluation seam (ofReduceBool/trustCompiler) is
  likewise documented in the project, including prose
  explaining why `native_decide` is not used.

## M4 — fine-print assumption inventory

Trusted base of this PASS, complete list:

- The classical three (propext, Classical.choice, Quot.sound).
- Two declared literature axioms, trusted as cited, not
  replayed: Garefalakis-Kapetanakis (JPAA 223 (2019), Thm 1.3;
  its own proof rests on a computer calculation in the cited
  literature) and Rosser-Schoenfeld (Illinois J. Math. 6
  (1962), Thm 12), psi(x) < 1.03883 x.
- Compiler-trusted checker evaluation: Lean.ofReduceBool +
  Lean.trustCompiler for the 25 Boolean checkers. The
  kernel-checked part is that `checker = true` implies the
  statement (the *Sound.lean files); AuditDeep bounds the
  blast radius (no project implemented_by/extern among
  checker dependencies; the 104 core constants with such
  attributes are the trustCompiler base).
- Out of scope, not checked: `verification_code/` (17 Python
  files with EXPECTED_OUTPUT.txt), the paper's own Python
  mirror of the computations. A VM-masked replay against
  EXPECTED_OUTPUT.txt is a possible follow-on leg; it is not
  part of this verdict.
