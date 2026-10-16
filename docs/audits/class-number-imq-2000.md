# Audit note — imaginary quadratic fields of class number ≤ 2000 (arXiv:2610.21511, 2026-10-15)

**Claim artifact:** Iwao Kimura, *Imaginary quadratic fields of class
number at most 2000* (arXiv:2610.21511v1, announced 2026-10-15), and its
companion Lean 4 formalization in `iwaokimura/cln-imq-2k` (`lean/`),
which formalizes two theorems: the explicit zero gap
(`B4Chi8.lean`: `zero_gap_all`, `zero_gap_large`, `re_LFunction_pos`)
and the class-number bounds
(`B4ClassNumber.lean`: `classNumber_gt_{100,200,500,1000,2000}`).
**Harvest item:** `class-number-imaginary-quadratic-2000` (weekly scan
2026-10-16, issue #6, recon rank 1, fragility 2, signals
`disclosed_llm_help`; single author).
**Campaign objects:** `incoming/class-number-imaginary-quadratic-2000/PIN.md`.
**Repo pin:** `iwaokimura/cln-imq-2k` @
`7133a32cfce5f541c98dc4d65c98c9704747c406` (one README-line commit after
recon's `e451afc`; diff verified +1/−1, no claim-bearing content moved).
**Pinned sources:** paper e-print
`~/workspace/class-number-audit/tex/main.tex` (arXiv:2610.21511v1;
PDF sha256 `1d23022a…a8ae8a`, tarball `d78b7eba…418387` per PIN);
repo clone at the pin above.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run date
`2026-10-16`. An adversarial enumeration of 14 paths that could carry
or kill the claim was written before this note
(`~/workspace/class-number-audit/brief-paths.md`); every path gets a
named check and a result below.

**Scope of this audit:** M1 statement correspondence, M2 argument
correspondence (structural, from the TeX + the Lean sources), M3 credit
honesty, M4 fine-print inventory. No Lean build, no forge run in this
phase — see Receipt.

## The claim and its three parts

The headline (paper thm:main, §1): exactly 16,453,493 imaginary
quadratic fields with class number ≤ 2000; largest |d_K| =
1,062,350,083, at h = 1978. The paper decomposes this into three
parts of different status (intro, after thm:gap): (A) thm:gap and
thm:lean, proved in Lean; (B) prop:sieve, a computation whose
correctness argument (lem:minima, lem:certified) is proved in the
paper but whose program is not formally verified; (C) the
Mosunov–Jacobson class-number tables below 6·2^28, a computation by
others, spot-checked and partly recomputed. `thm:main` itself is not
a Lean theorem — it is assembled in the paper's *Proof of thm:main*
(§6) from these parts. M1 therefore covers thm:gap and thm:lean; the
assembly logic is checked by hand below.

## M1 — Statement correspondence: PASS

| # | Formal claim | Paper statement | Match |
|---|---|---|---|
| 1 | `B4.Chi8.zero_gap_all` (B4Chi8.lean:198): `5811/10000000 ≤ (1−β)·log q`, q ≥ 3, all hypotheses of the paper | thm:gap, first bound (`main.tex`, thm:gap): `(1−β)log q ≥ 5811·10⁻⁷` | exact; `5811/10000000 = 5811·10⁻⁷`. The abstract's `5.8·10⁻⁴` is the rounded constant — the Lean proves the sharper printed value |
| 2 | `B4.Chi8.zero_gap_large` (B4Chi8.lean:227): `log q ≥ 350131/10000 → 1193/200000 ≤ (1−β)·log q` | thm:gap, second bound: `log q ≥ 350131/10000 → (1−β)log q ≥ 1193/200000` | exact, same rationals |
| 3 | `B4.Chi8.re_LFunction_pos` (B4Chi8.lean:156): `0 < (LFunction χ σ).re`, χ ≠ 1 on conductor 8, σ > 0 | lem:chi8 (paper §2): `L(σ,χ) > 0` for `0 < σ < 1`, q = 8 | exact; the Lean quantifies `σ > 0` (weaker hypothesis, stronger theorem) |
| 4 | `B4.ClassNumber.classNumber_gt_N` (B4ClassNumber.lean:232–261), N = 100/200/500/1000/2000: `T_N ≤ log |discr K| → N < classNumber K`, T_N = 286787/10000, 150729/5000, 160029/5000, 334757/10000, 350131/10000 | thm:lean: `N ∈ {100,200,500,1000,2000}`, `log |d_K| ≥ T_N → h_K > N`; Table TN: 28.6787, 30.1458, 32.0058, 33.4757, 35.0131 | exact; `286787/10000 = 28.6787`, `150729/5000 = 30.1458`, `160029/5000 = 32.0058`, `334757/10000 = 33.4757`, `350131/10000 = 35.0131` |

### The encoding points (where M1 usually fails)

- **"Imaginary quadratic field"** is `[Field K] [NumberField K]
  [IsTotallyComplex K] (hK : finrank ℚ K = 2)`. A number field with
  `[K:ℚ] = 2` that is totally complex is exactly an imaginary
  quadratic field — this is an *exact encoding*, not a weakening:
  `finrank = 2` already forces `K ≠ ℚ`, and totally complex rules out
  the real quadratic case.
- **The `q ≠ 8` hypothesis.** The internal predicate
  `B4.GapFrom c l0` (B4Chain.lean:27) carries `q ≠ 8`, matching the
  paper's structure (thm:gap's proof opens with lem:chi8, then
  assumes `q ≠ 8`). The user-facing theorems (`zero_gap_all`,
  `zero_gap_for_h2000`, `zero_gap_large`, GapFromAll at
  B4Chi8.lean:198–236) remove it via `gapFromAll_of_gapFrom`
  (B4Chi8.lean:215) together with `LFunction_ne_zero` (B4Chi8.lean:190),
  the Lean lem:chi8. Removal path explicit, faithful.
- **The large-gap constant.** `zero_gap_for_h2000 :
  GapFromAll (1193/200000) (350131/10000)` (B4Chi8.lean:223) is built
  from `B4.Cert.zero_gap_for_h2000` (`:= chain_148`,
  B4Certificates.lean:3176) — the same two literals. No drift
  between the certificate chain and the public theorem.
- **The class-number formula.** `classNumber_ge`
  (B4ClassNumber.lean:168): `√|D|·(Lchi 1).re ≤ π·classNumber K`,
  from `classNumber_formula` (`2π h = w·√d·L(1,χ)`) and
  `w ≥ 2` (`NumberField.Units.even_torsionOrder`) — exactly the
  paper's `eq:cnf` (`2π h(-d) = w_K √d L(1,χ)`, hence
  `π h(-d) ≥ √d L(1,χ_{-d})`). `classNumber_gt_of`
  (B4ClassNumber.lean:190) proves `q > e³ > 8` internally, so the
  q = 8 exclusion never leaks into the user-facing theorems.
- **Challenge vs solution.** The Comparator challenges
  (`lean/Challenge/B4ClassNumber.lean`, `lean/Challenge/B4ZeroGap.lean`)
  state the eight theorems with `sorry` and Mathlib-only imports.
  Diff against the solutions: only `open`-resolved name spellings
  differ (`NumberField.IsTotallyComplex` vs `IsTotallyComplex`,
  `Module.finrank` vs `finrank`) — Comparator's statement export
  matched them, and the negative controls reject a one-digit
  constant change on both sides (see M3). No weakening or
  strengthening found.

## M2 — Argument correspondence: qualified (faithful with one documented departure)

Label: *faithful formalization of the paper's proof, with one
alternate-route step.* The paper's own §7 (sec:lean, "In
particular…") states this: "It is not an independent proof of [SZ]:
it follows the argument of [SZ] except for the interpolation step,
and its core, (4.4)–(4.6), is the upstream formalization of that
argument, with the interpolation step proved by a multiplicity
estimate."

- **Upstream dependency boundary.** The B4 proof imports from the
  upstream OpenAI formalization (vendored at
  `lean/vendor/openai-math/`, OAI commit
  `301488868beec11bfd897168433b0a64f5258559`) exactly two modules:
  `OAI.NumberTheory.SiegelZeros.EntireFunctions.GammaBound`
  (B4Analytic.lean:14) and
  `OAI.NumberTheory.SiegelZeros.EntireFunctions.RealZeroUniformMasterBound`
  (B4ZeroGap.lean:14). What is *taken* from the latter is the
  intermediate determinant-data lemma
  `source_character_global_greedy_determinant_master_bounds`
  (the eqs. (4.1)/(4.3) + pivot bounds S₁, S₂ of the paper) —
  name-grep over all `B4*.lean` finds no use of the upstream FINAL
  theorem `uniform_master_bound` / `normalized_master_bound` /
  `FinalComparison` (the only occurrence of those names in B4 is the
  B4ZeroGap.lean docstring). The paper's "We do not use its final
  theorem, which gives Theorem 1 of [SZ] with an unspecified
  constant" (sec:lean, "The upstream proof") holds in the import
  closure as checked.
- **The interpolation departure.** SZ Lemma 3 (the lattice-polytope
  supporting-face + Lagrange interpolation, general degrees) is not
  formalized. What is formalized is the needed *conclusion* (SZ
  Cor. 4 for their box): the rows R_α with the stated α-bounds span,
  proved via the dual statement — a nonzero polynomial supported on
  `{0,…,B−1}⁴` cannot vanish at (1,1,1,1) to all these orders along
  the three invariant derivations — by a multiplicity estimate
  (`uniform_rectangular_multiplicity` in the dependency closure;
  paper sec:lean, "Where the formalization departs from [SZ]").
  The conclusion feeds only the pivot bounds (4.6)
  (`global_source_rectangle_pivot_bounds`); nonvanishing of Δ
  itself is proved without it (Vandermonde on the M distinct ϑ_n).
  So: same source argument everywhere except one step, where a
  different proof of the same conclusion is supplied. This is
  source-faithful formalization with a documented route change, not
  an independent proof — and the paper says exactly this.
- **Other libraries.** Mathlib, PrimeNumberTheoremAnd, TauCeti,
  AINTLIB, LeanCert, LeanArchitect enter the dependency closure as
  described in the paper's "Other libraries" paragraph (TauCeti
  provides the Kronecker character and prime splitting used for
  ζ_K(s) = ζ(s)L(s,χ_D) via AINTLIB Euler products). Vendored
  sources match their committed SHA-256s
  (`sha256sum --quiet -c SHA256SUMS` in `lean/vendor/`: clean); the
  upstream byte-compare script (`vendor/check.sh`) needs network and
  was not re-run here — its claims are declarations (see Receipt).
## M3 — Credit honesty: PASS on disclosure, with the receipts recorded as GAPs below

- **AI contributions.** The paper's §8 (sec:ai) states: the OpenAI model
  produced [SZ] and its Lean formalization (taken unmodified at
  `lean/vendor/openai-math/`); Claude Opus 5.5 (via Claude Code)
  did (a) the explicit argument + L(1,χ) bound, (b) the Lean files,
  numerical certificates, kernel replay, Comparator setup, (c) the
  sieve program, the `computations/` scripts, the checks and
  comparisons, (d) most section text from the author's outline.
  The repo README (lines 25–31) says the same: Lean code, sieve
  program and scripts written with Claude; the SZ preprint and its
  formalization from an OpenAI model. The harvest signals
  `disclosed_llm_help` + `single_author` match. No over-claim in
  either direction.
- **What is not formalized is stated.** Paper intro: prop:sieve is
  "a computation whose correctness argument (lem:minima,
  lem:certified) is proved in the paper but whose program is not
  formally verified"; the MJ tables are "an unconditional
  computation by others". The label `[computation]` on prop:sieve
  is fail-open-by-design and honest.
- **Comparator.** The paper (sec:lean, checks (c)) discloses its own
  caveat: "Comparator reused build products compiled earlier,
  outside the sandbox, in the same workspace; Comparator's guarantee
  against a deliberately adversarial proof assumes a clean build,
  but the kernel checks above are unaffected." Both negative
  controls are in the log (`lean/comparator/B4Comparator.txt`:
  zero-gap run: `5811→5812` in the challenge →
  "uncaught exception: Challenge and solution theorem statement do
  not match: 'B4.Chi8.zero_gap_all'"; class-number run:
  `T_1000 = 334757/10000 → 33` →
  "...do not match: 'B4.ClassNumber.classNumber_gt_1000'"). The log
  is author-generated — a declaration, not a receipt (see Receipt).
- **Kernel replay and build logs.** `lean/B4Build.txt` (build log +
  `#print axioms` on the B4 declarations) and `lean/B4Replay.txt`
  (`lake env lean --run B4Replay.lean`: dependency closure of the
  eight user-facing theorems = 123,010 constants, "replayed, type
  unchanged", only propext/Classical.choice/Quot.sound, exit 0)
  are author logs. They record exactly what the receipt rule asks
  for; until reproduced on a machine separate from the author's
  they are declarations.
- **External agreement checks.** Sec:results comparisons (h ≤ 1000
  vs Cremona–Sutherland 2024; odd h ≤ 1999 vs HJKMP) are credited
  by the paper only as far as they go: "In these ranges the
  GRH-conditional data … are therefore complete unconditionally" —
  they validate the extraction, not the MJ tables themselves
  (paper says so in §4). Credited exactly that far.
- **The lists.** The paper prints the uncompressed SHA-256s of the
  two list files; the PIN's data gate (run at pin, this VM)
  confirms both: `imq_h2000.txt` = 16,453,493 lines,
  `07100ea3…5c86f9f24c0`; `imq_h1000.txt` = 4,115,897 lines,
  `075a201c…fc46d8b0c45`; d strictly increasing; every h ∈ [1,2000];
  max line `1062350083 1978`; the h1000 file is exactly the h≤1000
  subset. That validates the shipped lists against the paper's
  printed commitments — it does not validate the sieve, the tables,
  or the Lean proofs.

## M4 — Fine-print inventory (Murray & van Oorschot; load-bearing items)

For each: what it is, the tag, the residual if it fails, and which
downstream claims inherit it. Tags: source-faithful /
convenience-only / risk-inducing.

1. **MJ tables correctness where not recomputed** (tables, d <
   6·2^28). Risk-inducing (external, by others). If it fails:
   *evaporates* — the exact count is wrong. Inherits: thm:main's
   "exactly 16,453,493" and "largest |d| = 1,062,350,083".
   Standing checks: extraction completeness (paper §4(a): entry
   count = independent fundamental-discriminant count, a
   deletion test; (b)-(d) PARI/GP spot checks, overlap with
   Watkins/OEIS/LMFDB); raw `.gz` files are not in the repo
   (`computations/mj_data.sha256` records only hashes — declared,
   not present).
2. **qsieve.c correctness** (prop:sieve, 6·2^28 ≤ d ≤ 1.65·10^15).
   Risk-inducing (C, never formally verified). If it fails:
   *evaporates* for that range — a field with h ≤ 2000 could hide
   there, killing thm:main. Residual: the soundness argument
   (lem:minima proved in the paper; lem:certified cases (i)–(iv))
   reduces to faithfulness of the code, which I read: Phase 1/2 =
   cases (i)/(ii) (bit-parallel class mask on periodic χ(p)
   patterns, with `-M` division-free scalar version and `-V`
   three-way cross-check), Phase 2b `bound_certify` = case (iii)
   (`w * (2k²+1) > N` ⟺ (2t²+1)W₀ > N), `exact_certify` = case (iv)
   (exact count, primes ≤ min(X, 2·10⁶)); uncertified d go to
   residual files + `postproc.gp` (never used — shipped logs show
   residual 0 everywhere). TESTING.md records a real
   soundness-relevant bug found and fixed (`compsym[NSMALL][16]`
   overflow corrupting small-prime symbols; fix: `[32]`).
   `qsieve/qsieve.c` sha256 `b053152d…9c6217ea9` at pin. The two
   runs' logs (`qsieve/logs/gap2000`, `main2000`): 188 workers
   each, all "finished: units X/X (100.00%)", residual total 0,
   bound-check failures 0. Full re-run is out of scope (author:
   188 processes on a 96-core Threadripper; VM has 2 cores) — see
   Receipt.
3. **AVX-512 bit-vector path.** The bit-parallel class mask runs
   in AVX-512 (or AVX2) registers for W ≤ 16 words (qsieve.c
   header). Tag: convenience-only for trust (the algorithm is
   identical to the scalar version, cross-checked by `-V` and
   `-M`; TESTING.md test V: 0 mismatches on 666,511 random d).
   Spot re-run feasibility on this VM: CPU has AVX-512
   (avx512_bf16/bitalg/vbmi2/vnni/vp2intersect), gcc present — a
   small direct-mode segment is feasible, not attempted in this
   phase.
4. **PARI/GP in the loop.** Used in tables checks (b),(c),(d)
   (random class-number spot checks via `qfbclassno`; documented
   correct only below 2·10¹⁰ in the repo) and to *generate*
   `computations/lean_grid.gp` / `lean_h_cert.gp` outputs.
   Tag: convenience-only — the generated LeanCert files are
   checked by the Lean kernel (see 5), so the generator's
   correctness is out of the trust path; the spot checks are
   sampling evidence only. Residual: PARI bug below 2·10¹⁰ →
   spot checks only, *weakens* (a), not the count.
5. **LeanCert `trust := kernel`.** Every `leancert` in the two
   generated certificate files uses kernel mode: 315 occurrences
   in `lean/B4Certificates.lean`, 50 in
   `lean/B4ClassCert.lean`, zero with any other trust mode
   (grep-checked at the pin). Paper sec:lean declares the mode
   and that the generator "plays no role in their correctness" —
   matches the files. Tag: source-faithful.
6. **GMP literal arithmetic in both kernels.** Paper-declared
   ("What the formal proof covers": both kernels include
   arithmetic on natural-number literals (GMP)). Not
   independently verified in this phase — nanoda is not on disk;
   the declaration is credited as a declaration. Mitigating:
   two independent kernels (Lean + nanoda via lean4export) agree.
7. **nanoda as second kernel.** Paper-declared via lean4export;
   the Comparator log shows "nanoda kernel accepts the
   solution" (author-run). Not independently reproduced here.
8. **Comparator clean-build caveat.** Paper-disclosed (M3 above).
   Tag: risk-inducing for the adversarial-proof guarantee only;
   mitigated by the kernel replay of the 123,010-constant closure
   from an empty environment — not independently reproduced here.
9. **TauCeti patch (3 lemma-call adaptations).**
   `lean/vendor/patches/TauCeti-pinned-mathlib.patch`, read in
   full at the pin: 3 files, 4 proof-internal renames
   (`MulEquiv.toMonoidHom_trans → coe_monoidHom_trans` ×2,
   `IsConcreteLE.not_le_iff_exists → SetLike.not_le_iff_exists`,
   `Ideal.ramificationIdx_pos` explicit-arg form; one call site
   in B4, `B4QuadSplit.lean:54`, uses the patched form). No
   statement changes. Tag: convenience-only.
10. **PrimeNumberTheoremAnd compatibility patch.** Declared in
    `lean/vendor/README.md:13,19-21` (openai/math's
    `lean/patches/PrimeNumberTheoremAnd-lean4341.patch`, also
    adds `PrimeNumberTheoremAnd/SiegelZeros/`). The patch *text*
    is not in the repo — `check.sh` fetches it from upstream at
    network time — so this is a declaration, not an audited
    change. Tag: convenience-only (its stated purpose is
    compatibility with the pinned Mathlib).
11. **Seam arithmetic (coverage joins), recomputed here.**
    Lean covers `log|d| ≥ 35.0131`, i.e. `|d| ≥ e^35.0131` =
    `1.60692691262472e15` (recomputed; paper prints the rounded
    `1.6069·10¹⁵`). Sieve covers `[6·2²⁸, 1.65·10¹⁵]`; tables
    cover `d < 6·2²⁸`. Checks: `1.65·10¹⁵ > e^35.0131` — overlap
    ≈ 4.3073·10¹³, *no gap*; `6·2²⁸ = 1,610,612,736` exactly,
    shared boundary of tables and sieve — *no gap*; the
    `e^T_N` recomputations match the printed table
    (2.8510e12, 1.2364e13, 7.9422e13, 3.4539e14 to the printed
    digits). Tag: source-faithful. Note the paper's prose
    "all of which have |d| < 2³⁰" for the tables (§1) is weaker
    than the actual boundary used (6·2²⁸) — convenience-only
    rounding, not load-bearing.
12. **Banks 2026 not used.** TeX lines 80–82: "His proof is not
    formalized, and we do not use it"; Lean has no Banks/LZZ2026
    reference (grep-clean). One line, no gate.

**Dangling check.** The conjunction of assumptions is satisfiable:
the three parts tile the d-range with overlaps at both seams;
the list's last line `1062350083 1978` lies below 6·2²⁸, agreeing
with "largest |d| attained at h = 1978" and with prop:sieve's
empty claim on the sieve range. No contradiction found between
the parts.

## Receipt

- `incoming/class-number-imaginary-quadratic-2000/PIN.md` — paper
  PDF/tarball SHA-256s, repo pin, toolchain pins, key-file
  hashes, and the lists data gate (green at pin, this VM; see M3
  for the exact numbers).
- **Forge build receipt (closed 2026-10-16):** independent build of the
  pinned project on runner `dell-laptop` via one-shot workflow
  `class-number-forge` (fragile-proof-audit main@`e835dca`; deleted
  after this note landed). Clone asserted at
  `7133a32cfce5f541c98dc4d65c98c9704747c406` before building.
  Run 38902574323, concluded **success** after 1h 19m 48s (finished
  2026-10-16 10:10 EDT): `lake exe cache get` then full `lake build`
  of the default target (B4 + vendor libs OAI, PrimeNumberTheoremAnd,
  TauCeti, BernoulliRegular), toolchain
  `leanprover/lean4:v4.34.1`, Mathlib `d13f23b`. An independent
  `#print axioms` file covering the eight user-facing theorems plus
  `zero_gap_for_h2000` reported all nine within
  `{propext, Classical.choice, Quot.sound}`:
  `classNumber_gt_{100,200,500,1000,2000}`, `zero_gap_all`,
  `zero_gap_large`, `re_LFunction_pos`, `zero_gap_for_h2000` — the
  workflow's verdict parser (unit-tested against sorryAx and missing
  listings) returned PASS. Author's build-time `#print axioms`
  lines (B4ClassNumber.lean:261–265, B4Chi8.lean:236–239) agree.
  Build log + `axioms.txt` uploaded as run artifact
  `class-number-forge-evidence`.
  Remaining receipt gaps (explicit): kernel replay (B4Replay.lean) and
  the Comparator were NOT re-run independently; their in-repo logs
  stay declarations. qsieve full re-run stays out of scope by design.
- **GAP (explicit):** qsieve full re-run not attempted — out of
  scope (188 processes / Threadripper-class box); the shipped
  logs were checked for completeness instead (188/188 finished,
  residual 0, bound-check failures 0).

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4 audit
of harvest issue #6's pick: **M1 PASS** — the formalized
`zero_gap_all`/`zero_gap_large`/`re_LFunction_pos` and the five
`classNumber_gt_N` say exactly what the paper's thm:gap/thm:lean
print (exact rationals; the `q ≠ 8` structure faithfully removed
at the user-facing theorems); **M2 qualified** — faithful
formalization of the paper's argument with the documented
interpolation-step departure (SZ Lemma 3 not formalized; its
conclusion for the box proved by a multiplicity estimate), and
the upstream OAI final theorem confirmed absent from the B4
import closure; **M3 PASS on disclosure** — AI contributions,
the Comparator caveat, and the non-formalized parts are all
stated where they are, in-repo logs recorded as declarations,
in-repo receipt GAPs named above; **M4 PASS** — fine print
cataloged with residual lines (the standing risks are the
unverified sieve program and the external MJ tables, both
explicitly out of the formalization by the paper's own split).
