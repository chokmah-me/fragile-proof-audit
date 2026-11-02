# PIN — Morgan-Mullen conjecture, Lean formalization (arXiv:2610.36534)

Audit prep 2026-11-02 at the user's pick of the forge-prep
option (harvest 2026-11-02, CLAIM morgan-mullen-conjecture-lean,
recon fragility 2; Haiku 5.5 delegation plan,
~/workspace/haiku-harvest-delegation-2026-11-02/PLAN.md).
Hellwig, *Resolvent Components of Completely Normal Elements
and the Morgan-Mullen Conjecture*: every finite field
extension contains an element that is both primitive and
completely normal, plus Hachenberger's lower bound
(Corollary 8.8) and the PCN asymptotic corollaries (8.9),
formalized in Lean 4. PREP ONLY: this PIN and the forge
workflow are gate-checked and staged; nothing is dispatched
until the user says so. The verdict lock is not touched.

## Pins

- paper.pdf (arXiv:2610.36534): sha256 3b080fb1079b1971cbb1d56ac35cf4af0c5fa02e250ea1ac4826e6c2afe03bbe
- arXiv source tar.gz: sha256 35897c9c22dac23e614ea2d7f74ebd44f86ec11187d4b4d54aa114e26035fc68
- Repo: github.com/florian-hellwig/morgan-mullen @ 03fb9bd6c2605f7d4df111c154db14ed2f570b7b (recon HEAD,
  2026-10-28). Codeload tarball of that commit: sha256 245866896f1bba73970fc3ecea1ed4ca8da0d415765b89a135c6d910b3ed5e16.
  Release v1.0 archived at Zenodo 23661993.
- Inside the tree (sha256, verified at recon 2026-11-02):
  - lean-toolchain: d5edba4e4b8faad9c1baeadb265716d20d03be4d1a2647dc5e35b0c0325bea7b
    (content `leanprover/lean4:v4.34.1`)
  - lakefile.toml: f5a2366ca278c3aa1c94cb4ca6deb6b346481dd0ca2dd82dca26fde37699a19a
    (single require: mathlib rev v4.34.1, last and only; lean_lib MorganMullen, no roots/globs restriction)
  - lake-manifest.json: 797e133c7b78dbd75cee03f104f6278c66d6538166d63866d9c62270043947bb
    (mathlib d13f23b723b8a846827a245b89c10fc7d3f11612 (v4.34.1) + 7 satellites)
  - AXIOMS_AUDIT.txt (authors' reference output): 171d8b863279d3a31691afbe17c09cc7e514c4aefd386a87229a54f165537350
  - Audit.lean: 2cdd97d8073420625e8741db43023bbe11c64438bc1d9d819b18e26818365810
  - AuditDeep.lean: 374c1c1ff43cb39a9c27968a24aceec75b09018934c53f125bbe2680a08bc4ac
  - MorganMullen/Axioms.lean: a680011e6d0baafe1a8da09b81e3df8be0ac6b526003a934cf173b49326727fc

## Inventory at the pin (recon, counted from the tree)

43 .lean files: 40 under MorganMullen/ (16,952 lines) +
MorganMullen.lean (root, imports all 40) + Audit.lean +
AuditDeep.lean. This reconciles the harvest discrepancy:
the sweep's ~35 was a landing-page estimate, recon's API
count of 43 is exact against the tree. Toolchain Lean
v4.34.1 / Mathlib v4.34.1. Authors' stated build: 3,672
jobs, 0 errors, 0 warnings, `lake build --wfail` clean
(AXIOMS_AUDIT.txt) — to be reproduced on the forge, not
trusted. Recon scans of the tree: no `sorry` token, no
`admit` token anywhere in MorganMullen/, MorganMullen.lean,
Audit.lean, AuditDeep.lean; the only `axiom` declarations
in the project are the two in Axioms.lean below;
`native_decide` appears only in prose explaining why the
project uses `of_reduce_bool` instead.

## Permitted axiom set (the audit's fail-closed universe)

Exactly these 7, nothing else, and `sorryAx` never:

- Classical three: propext, Classical.choice, Quot.sound
- Computation outside the kernel: Lean.ofReduceBool,
  Lean.trustCompiler (25 Boolean checkers evaluated by
  compiled code; the native_decide axiom family standing
  exemption covers this pair's role)
- Declared literature axioms (MorganMullen/Axioms.lean,
  the ONLY project axioms):
  - MorganMullen.garefalakis_kapetanakis —
    Garefalakis-Kapetanakis (JPAA 223 (2019), Thm 1.3):
    the Morgan-Mullen property for n <= q. Its own proof
    uses a computer calculation (per the harvest note);
    the axiom is trusted as cited literature, not replayed.
  - MorganMullen.rosser_schoenfeld_psi —
    Rosser-Schoenfeld (Illinois J. Math. 6 (1962), Thm 12):
    psi(x) < 1.03883 x.

Expected exact sets per audited declaration (from the
authors' AXIOMS_AUDIT.txt, cross-checked line-for-line
against the authors' own CI classifier in
.github/workflows/lean_action_ci.yml at the pin; the forge
re-derives them from its own build):

- MorganMullen.morgan_mullen: all 7
- MorganMullen.hachenberger_lower_bound: 6 (no
  garefalakis_kapetanakis)
- MorganMullen.hachenberger_eq_iff: 6 (same)
- MorganMullen.pcn_sub_theta_cn_abs_le: classical 3 only
- MorganMullen.pcn_error_le_star: 6 (same as Hachenberger)
- MorganMullen.pcn_theta_cn: 6 (same)
- MorganMullen.pcn_ratio_tendsto_one: 6 (same)

Auditor superset (beyond the authors' Audit.lean):
#print axioms MorganMullen.weight_le_Wq (Theorem 7.8, the
Rosser-Schoenfeld consumer through which both corollaries
get their checkers) must be a subset of the permitted 7.
Plus the authors' AuditDeep.lean run as-is: it is itself
fail-closed (throws on any project constant with
@[implemented_by]/@[extern] used by a checker, and on any
project axiom beyond the two declared), and the forge
additionally requires its printed markers: 25 checkers of
the main theorem, both "OK: ... among the 25 checkers"
lines, and the "declares exactly the axioms" line.

## Claim seams recorded at recon

- Statement fidelity (M1, spot at recon, full read at
  audit): `HasMMProperty F E := exists w : E,
  IsPrimitiveElem w and IsCompletelyNormal F E w`
  (Basic.lean:45), and `theorem morgan_mullen (F E :
  Type*) [Field F] [Field E] [Finite E] [Algebra F E] :
  HasMMProperty F E` (Sec8Main.lean:836). The headline
  claim quantifies over all finite extensions; the
  formal statement matches that shape. The n <= q case is
  NOT proved in Lean: it enters as the
  garefalakis_kapetanakis axiom, exactly as the paper
  discloses. A PASS here is therefore a PASS on the
  formalization route with two named literature axioms and
  compiler-trusted checker evaluation in the trusted base,
  never a kernel-only proof of the raw conjecture.
- The 25 checkers are the trusted-computation seam:
  `checker = true` is established by compiled evaluation
  (ofReduceBool/trustCompiler), and the kernel-checked
  part is that `checker = true` implies the statement
  (the *Sound.lean files). AuditDeep bounds the blast
  radius (no project implemented_by/extern among checker
  dependencies; 104 core constants with such attributes
  are the trustCompiler base).
- verification_code/ (17 files, Python, with
  EXPECTED_OUTPUT.txt) is OUT of the forge's scope: it is
  the paper's own Python mirror of the computations, not
  the Lean checkers. A separate VM-masked replay against
  EXPECTED_OUTPUT.txt is a possible follow-on leg, not
  part of this forge and not a runner job (author code
  never runs on the runner boxes).

## Addendum 2026-11-02 (run #1 post-mortem, in brief)

Forge run #1 (41492466013) died in 6 s at the source-scan
step, on the harness, not the claim: the declared-axiom
count used a naive `grep "^axiom "` that also matches two
doc-prose lines inside /-! -/ blocks (Fin32Runs.lean:8 and
Sec7W28Runs.lean:7, both of the form "axiom
`Lean.ofReduceBool` (tactic ...)"), for a false count of
4 against the expected 2. The two real declarations are
unchanged and are exactly the pair above; the prose lines
discuss the ofReduceBool axiom, they declare nothing.
Fix: declaration pattern `^[[:space:]]*axiom [a-z_]`
(backtick prose excluded), count == 2, both hits inside
Axioms.lean, proven locally on the real tree (pass) and
on an injected-declaration copy (fail), with the full
scan step simulated against the pinned tree before
re-dispatch. Kernel-level backstop was already in the
design: AuditDeep.lean enumerates project axioms from
the environment and throws on any extra. Parent kind:
the gate-written-against-prep-assumptions family (the
2026-10-23 verdict-classifier lesson); the prep recon
grep output contained all 4 lines and was misread as 2.

## Forge design (morgan-mullen-forge.yml)

- Lane: HP, runs-on [self-hosted, desktop]
  (DESKTOP-7HDI2D1), one heavy job, timeout 330 min.
  Gate job on ubuntu-latest per the post-2026-10-27
  skeleton (docs/PRE-DISPATCH-CHECKS.md); forge needs gate.
- Clone at the pin (validated 40-hex in env), verify HEAD
  equals the pin and the seven in-tree sha256 above match,
  install elan, `lake exe cache get`, `lake build`
  (log scanned for sorry warnings), source sorry/admit
  scan, authors' Audit.lean + exact-set classifier,
  authors' AuditDeep.lean + marker checks, auditor
  superset print for weight_le_Wq + subset classifier.
- Verdict = every leg green; any mismatch fails closed.
  Evidence uploaded as an artifact. One-shot workflow:
  deleted after the audit closes.

Evidence in ~/workspace/morgan-mullen-recon/ (repo.tar.gz,
paper.pdf, source.tar.gz, extracted tree under src/).
