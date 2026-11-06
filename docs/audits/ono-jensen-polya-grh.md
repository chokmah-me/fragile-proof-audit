# Audit note — Ono, An asymptotic Jensen-Polya criterion for GRH, Lean formalization (arXiv:2610.38870v1, 2026-11-06)

**Harness pin**: scripts/harness_pin.py — agent: Muse (Meta); model: `Muse Spark 1.3`; pinned at 2026-11-06T16:21:05Z; skills: lean-proof-forge (forge design), computational-claim-gate; the note is written to the ReplayGate audit-note contract (M2 contract freeze), with the deployed linter's own rules read at write time.

**Verdict: PASS.** The pinned artifact builds cleanly and the author's comparator accepts the solution.
The pinned Lean artifact builds cleanly from its pinned commit on
the self-hosted runner, and the author's own comparator
configuration, run with the core `lake comparator` at the
artifact's own toolchain, accepts the solution: exit 0, the nanoda
kernel and the Lean default kernel both accept, closing line "Your
solution is okay!". All four comparator theorems are proved from
exactly the standard three axioms, including the two
Dedekind-zeta continuation theorems that keep the headline
non-vacuous. The one seam of record is the paper's own appendix,
which pins a different toolchain than the artifact carries; that
skew is documented in M4 and does not touch the verdict, which is
about the repository as pinned. This audit's first forge run
failed on a harness bug in its own workflow (M2); the artifact was
never at fault, and the corrected run is the one this verdict
rests on.

**Claim artifact:** Ken Ono, *An asymptotic Jensen-Polya
criterion for GRH*, arXiv:2610.38870v1, submitted 2026-10-28, 16
pages, sole author. Title, author, and version verified on the
arXiv abs page and API 2026-11-06. No supplementary information
or peer-review file exists for this paper. `paper.pdf` sha256
`e5c91d73f5001ac2b9e3e0bad82d9f91bed0912bbf8aaf378ccd2605d3f44fd4`;
e-print tarball sha256
`058d10be4836b8fac139329dba867a69628423638e76fc358e79c88094548200`;
`main.tex` sha256
`2e9d6dc3cc0811847ddc09540f991cb7dcfa6035553be2745c48d765575b58a6`.
Claim (abstract): unconditionally, for every number field K,
J_{K,d}(X) is nonzero and has at least d - C_K sqrt(d log d)
distinct negative real zeros for all sufficiently large d. The
abstract's last sentence: "The main theorems have been
autoformalized in Lean 4 by AxiomProver."

**Canonical artifact:** `AxiomMath/RiemannJensen` @
`c1e023fa3ae7161219dde3dcb73f0c28ff972be2` (HEAD re-verified by
`git ls-remote` at pin time, 2026-11-06; the repo was pushed
2026-10-23, before the arXiv submission; no tags or releases, the
commit is the pin). 152 Lean files, 43,599 lines, toolchain
`leanprover/lean4:v4.35.0` (`lean-toolchain` sha256
`ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c`),
Mathlib manifest rev `56a005855ea17e0b0958f73ec801ae140b0a1679`
(`lake-manifest.json` sha256
`f1a399af75b1ff96c05a279c9cd0c780a6852315129c7719981bfbffd0c6f609`).
Key files: `Challenge/Basic.lean` sha256
`eeae0da96ab3d5784522a5745dc46353b1a804c3ea32972be4040cd4cd73354c`;
`Solution/Basic.lean` sha256
`19700eeeec35078524b91f266ad31fcca4004e7b86a39a78e61543e5e749daa7`;
`Comparator/comparator.json` sha256
`03ed4e57b81c0175162fee813c2b4cc01d28167798b798ced55d7e875f3ec9ee`.

**Comparator configuration (author's, as pinned):**
challenge_module `Challenge.Basic`, solution_module
`Solution.Basic`; theorem_names exactly four:
`RiemannJensen.Challenge.exists_isDedekindZetaContinuation`,
`RiemannJensen.Challenge.isDedekindZetaContinuation_unique`,
`RiemannJensen.Challenge.dedekind_thm_main`,
`RiemannJensen.Challenge.riemannJensen_main`; permitted_axioms
exactly `propext`, `Quot.sound`, `Classical.choice`;
`enable_nanoda: true`. The README claims the repository "has been
verified with the comparator (Lean kernel only)", via the
standalone comparator tool. That standalone tool is deprecated:
its own README states it merged into Lean core at v4.35.0 as
`lake comparator`, same JSON config format. This audit reproduces
the claim with the core comparator at the artifact's own
toolchain, the successor of the author's route, driven by the
author's hash-pinned config.

**Harvest item:** `ono-jensen-polya-grh` (ReplayGate feedstock
harvest 2026-11-05, registered claim; execution order set by an
Argon double-check adjudicated the same day: Cranston-Li first,
this audit second). **Campaign objects:**
`incoming/ono-jensen-polya-grh/` (paper PDF, e-print, `main.tex`,
`repo-c1e023f/` full tree, `PIN.md`).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`,
run date 2026-11-06. The forge workflow
(`.github/workflows/riemannjensen-forge.yml`) was written by the
main agent, adversarially reviewed, and passed the pre-dispatch
gate before each dispatch. No script was drafted by an outside
model for this audit; the comparator config, the build, and the
independent axiom check are the author's and this workflow's.

## M1 — Statement fidelity: PASS (checked line by line at pin)

The paper numbers its results on one shared counter: Theorem 1
(`thm:main`, tex l.120) is the Riemann case; the general case
(`thm:Dedekind`, tex l.175) is literally Theorem 3, because
Remark 2 at l.124 shares the counter.

- `dedekind_thm_main` matches Theorem 3 hypothesis for
  hypothesis: exists C > 0, exists d0 >= 2, for all d >= d0,
  `dedekindJensenK K d != 0` and
  `(d:ℝ) - C sqrt(d log d) <= dedekindNegativeRootCountK K d`,
  where the count is distinct negative real roots
  (`roots.toFinset` filtered to x < 0). K ranges over all number
  fields.
- `riemannJensen_main` matches Theorem 1's bound for every
  d >= 2, and adds a second conjunct the paper does not state:
  `nonrealJensenRootCount d <= C sqrt(d log d)` (nonreal roots
  counted with multiplicity). Given deg J_d <= d and J_d != 0,
  the added conjunct follows from the stated one by the
  multiplicity budget, so it strengthens the formal statement
  without changing its content. The statement as written also
  forces J_d != 0 for all d >= 2, which is the paper's own
  reading of Theorem 1 (the bound is asserted for every d >= 2,
  with no large-d escape). Recorded here so a reader comparing
  statements is not surprised; graded as fidelity, not drift.
- Definitions read against the paper: `gammaCoeff j =
  (j!/(2j)!) * Re (iteratedDeriv (2j) centeredXi 0)` matches
  F_K(z) = xi_K(1/2 + sqrt z) = sum gamma_K(j) z^j / j! via the
  even Taylor expansion; `dedekindXi K s = s (s-1) Lambda_K(s) /
  2` with `Lambda_K = |discr K|^{s/2} Gamma_R^{r1} Gamma_C^{r2}
  zeta_K^{cont}` matches the paper's xi_K definition, including
  the 1/2 factor.
- The continuation pair: `IsDedekindZetaContinuation K f` is
  `DifferentiableOn` on {1}^c together with agreement with
  `NumberField.dedekindZeta K` for Re s > 1; the uniqueness
  theorem concludes agreement on all of {1}^c. These are not
  paper theorems; their role is M4 item 1.

## M2 — Argument (build + comparator reproduction): PASS

Two forge runs on the self-hosted desktop runner
(DESKTOP-7HDI2D1), both with the target HEAD and the nine key
file hashes verified fail-closed before building:

- Run 1,
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42237453746
  (main@054da2c): gate success; forge 12m 33s; library build
  green (9,195 jobs); the comparator step lasted 0s and exited 2
  with a one-line log, "error: `nanoda` kernel `nanoda_bin` was
  not found"; verdict FAIL. Root cause was a bug in this audit's
  own workflow: prerequisites verified `nanoda_bin` by absolute
  toolchain-prefix path, but the comparator resolves external
  kernels by bare name via `which` on its own process PATH
  before any sandboxing (confirmed in the Lean v4.35.0 source,
  `src/lake/Lake/CLI/Check.lean`, `resolveExternalKernels`), and
  the toolchain bin directory was on no PATH. Exit 2 in the
  comparator's own code table is "the judgment could not run at
  all", not a rejection. The target was never at fault. Fix
  landed main@b55bcfc: prerequisites append the toolchain bin
  directory to the step path and assert `command -v nanoda_bin`
  succeeds; the comparator step re-exports the path and writes a
  setup failure instead of invoking the comparator if the lookup
  still fails. Pre-dispatch gate PASS on the fixed workflow.
- Run 2,
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42245414733
  (main@b55bcfc; 28m 35s wall): **conclusion success, every step
  green.** Forge job 20m 30s: prerequisites passed with the
  nanoda assertion printing the resolved path
  `/home/dyb/.elan/toolchains/leanprover--lean4---v4.35.0/bin/nanoda_bin`;
  Mathlib cache 9,030 files; library build "Build completed
  successfully (9195 jobs)" in 10m 33s; comparator step 8m 00s;
  independent axiom check 19s; verdict step PASS.

The comparator's own log from run 2 (evidence artifact, quoted):
it builds `Challenge.Basic` inside the sandbox (3,775 jobs) with
exactly four sorry warnings, at `Challenge/Basic.lean` lines 94,
100, 144, 154 — the four challenge theorems, which carry `sorry`
by design; exports the fixed target set (the four theorems, the
three permitted axioms, and the kernel primitive constants) from
`Challenge.Basic`; builds `Solution.Basic` (9,194 jobs); exports
the identical target set from `Solution.Basic`; then "Running
nanoda kernel on solution" / "nanoda kernel accepts the
solution"; "Running Lean default kernel on solution" / "Lean
default kernel accepts the solution"; and the closing line "Your
solution is okay!". Comparator exit code 0. Statement identity
between challenge and solution is the comparator's own check: it
judges the exports, not the source text.

The independent `#print axioms` pass (run 2, after the
comparator, corroboration only) returned, for each of the four
theorems, exactly the standard three:

- `RiemannJensen.Challenge.exists_isDedekindZetaContinuation`:
  [propext, Classical.choice, Quot.sound]
- `RiemannJensen.Challenge.isDedekindZetaContinuation_unique`:
  [propext, Classical.choice, Quot.sound]
- `RiemannJensen.Challenge.dedekind_thm_main`:
  [propext, Classical.choice, Quot.sound]
- `RiemannJensen.Challenge.riemannJensen_main`:
  [propext, Classical.choice, Quot.sound]

No `sorryAx` in any listing. The source policy scan (both runs)
found `sorry` only in `Challenge/Basic.lean` (exactly 4), and no
`admit`, `native_decide`, or `axiom` declaration anywhere in the
152 files. The Solution build in the open completed 9,196 jobs.

## M3 — Credit honesty: PASS

The credit claims check out, with one route substitution made by
this audit and disclosed here. The abstract credits the
formalization to AxiomProver; the pinned repository is
AxiomMath's, predates the arXiv submission by five days, and is
the artifact the paper's appendix names. The appendix's scope
statement (Theorem `thm:Dedekind` formalized, plus the Riemann
case of `thm:main` for every d >= 2) matches the comparator set
exactly; the abstract's "the main theorems" is accurate against
that set, neither wider nor narrower. The README's comparator
claim was a claim, not a receipt — no run output ships with the
repo, and the author's own CI builds only the default target,
never the comparator — and run 2 of this audit now supplies the
receipt. The route substitution: the README's command invokes
the standalone comparator (`lake env comparator`), which is
deprecated; this audit ran its merged successor, the core
`lake comparator` at the artifact's own pinned toolchain
v4.35.0, with the author's config byte-identical to the pin. The
judgment reproduced is the one the README describes (Lean kernel
plus the configured nanoda kernel, permitted axioms enforced);
the binary that rendered it is the successor tool, and this note
says so rather than letting the README's wording stand as if the
original tool had been run. No hidden dependency was found: the
permitted-axiom set is the standard three, enforced by the
comparator itself and corroborated by the independent listings
in M2.

## M4 — Fine-print assumption inventory

1. **The epsilon definition and its non-vacuity guard.**
   `continuedDedekindZeta K` is defined as
   `Classical.epsilon (IsDedekindZetaContinuation K)` — a choice
   over a predicate that Mathlib does not yet know is inhabited.
   Without the existence theorem, `dedekind_thm_main` would be a
   statement about an unspecified choice function; without
   uniqueness, that function would not be pinned to the Dedekind
   zeta. The author's comparator set includes both theorems, and
   both passed both kernels. The artifact's own guard closes the
   vacuity hole by construction (Stellar BB6 vector A
   territory); the audit credits it as part of the artifact, not
   as an external assumption.
2. **Appendix toolchain skew.** The paper's appendix (tex
   l.1356-1362) pins Lean 4.33.1 with Mathlib at `0df444a360ea`.
   The pinned artifact builds on Lean v4.35.0 with Mathlib at
   `56a005855ea17e0b0958f73ec801ae140b0a1679`. The appendix's
   described build is not this artifact. This verdict covers the
   repository at `c1e023f` only; any 4.33.1 build of these
   sources, if one exists, was not audited.
3. **The extra conjunct in `riemannJensen_main`** (M1): the
   nonreal-root-count bound is implied by the paper's stated
   bound plus the degree budget, so the formalization proves
   marginally more than the paper states, in a direction that
   cannot rescue a false headline.
4. **Modeling boundary of `dedekindXi`.** The Lean completed
   zeta agrees with the paper's entire xi_K only away from
   s = 1 and the Gamma poles; the definition's own docstring
   says so. The Jensen coefficients are read at the center 1/2,
   inside the agreement region, which is where the paper's
   criterion also lives. The comparator judges the formal
   statements as written; the center-1/2 fidelity is M1's read.
5. **Trusted base.** Lean 4.35.0 kernel; nanoda as an
   independent second kernel (it accepted the solution export);
   Mathlib at the manifest rev above; the comparator's
   bubblewrap sandbox discipline (bubblewrap 0.9.0 on the
   runner, smoke-tested in prerequisites before any verdict
   rode on it). No project axiom exists in the tree.
6. **This audit's own run 1 failure** (M2) is recorded so the
   artifact's history is not misread later: the first forge's
   FAIL was the audit workflow's PATH bug. It is not counted
   against the artifact anywhere in this note.

## Honest scope

This audit verifies the Lean artifact at the pinned commit
against the paper's Theorem 1 and Theorem 3 as formalized,
through the author's own comparator configuration, with both
kernels the configuration names. It does not verify the paper's
prose proofs, it does not bear on GRH itself (the paper proves
an asymptotic criterion; the criterion's mathematics is the
paper's, checked here only as formalized), and it does not cover
any build at the appendix's 4.33.1 pin.

## Results

- `results/riemannjensen_forge_run1_evidence.zip` — run 1
  artifact (5,879 bytes, sha256
  `db4cdd456fc65582ecebc575fc63ce3f74a0b20e20e43d8477a6261d61080c3a`),
  verdict FAIL on the harness PATH bug.
- `results/riemannjensen_forge_run2_evidence.zip` — run 2
  artifact (6,341 bytes, sha256
  `58270cb803a15f8d77ffd7147f9d90a82cd1d394faa5da3f9d32ec68df936b8a`),
  verdict PASS.
- `results/riemannjensen_verdict.txt` — `PASS` (from run 2).
- `results/riemannjensen_axioms.txt` — the four `#print axioms`
  listings from run 2.
- `results/riemannjensen_comparator_log.txt` — the comparator's
  own log from run 2 (both kernels accept; "Your solution is
  okay!").

**Verdict: PASS.**
