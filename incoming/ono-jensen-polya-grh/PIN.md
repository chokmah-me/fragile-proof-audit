# PIN — ono-jensen-polya-grh-lean (harvest 2026-11-05)

Pinned 2026-11-06 at the user's tap (RiemannJensen audit start:
pin + M1 read). No verdict at pin time; the forge is a separate
step.

## Paper

Ken Ono, *An asymptotic Jensen-Polya criterion for GRH*,
arXiv:2610.38870v1, submitted 2026-10-28, 16 pages. Title,
author, and version verified on the arXiv abs page and API
2026-11-06. No supplementary information or peer-review file
exists for this arXiv paper; the comments field (16 pages,
"extends and generalizes old work") names no artifact. The
repo location appears only in the paper's appendix.

- `paper.pdf` — sha256
  `e5c91d73f5001ac2b9e3e0bad82d9f91bed0912bbf8aaf378ccd2605d3f44fd4`
- `arXiv-2610.38870-eprint.tar.gz` — sha256
  `058d10be4836b8fac139329dba867a69628423638e76fc358e79c88094548200`
- `main.tex` (1,487 lines, from the e-print) — sha256
  `2e9d6dc3cc0811847ddc09540f991cb7dcfa6035553be2745c48d765575b58a6`

Claim (abstract): unconditionally, for every number field K,
J_{K,d}(X) is nonzero and has at least d - C_K sqrt(d log d)
distinct negative real zeros for all sufficiently large d; the
proportion of real zeros tends to 1. Abstract's last sentence:
"The main theorems have been autoformalized in Lean 4 by
AxiomProver."

Paper's own theorem layout (one shared counter for theorem /
proposition / remark / lemma / corollary):

- Theorem 1 (`thm:main`, tex l.120): the Riemann case. Exists
  absolute C > 0 such that for each d >= 2, J_d(X) has at
  least d - C sqrt(d log d) distinct negative real roots.
- Theorem 3 (`thm:Dedekind`, tex l.175; it is number 3 because
  Remark 2 at l.124 shares the counter): the general case.
  For each number field K, exist C_K > 0 and d_0(K) >= 2 such
  that for every d >= d_0(K), J_{K,d}(X) is nonzero and has at
  least d - C_K sqrt(d log d) distinct negative real zeros.

## Canonical artifact

`AxiomMath/RiemannJensen` @ `c1e023fa3ae7161219dde3dcb73f0c28ff972be2`
(default branch main; HEAD verified still at this commit by
`git ls-remote` on 2026-11-06; the repo was created and pushed
2026-10-23, before the arXiv submission). No tags or releases;
the commit is the pin. Tree: 152 `.lean` files, 43,599 lines
of Lean total, 2.5 MB.

- codeload tarball of the pinned commit — sha256
  `b79c33b1e844df90d34720fc7911d638f2221081b33ec1d75d0ff4bdc08ddab9`
- `repo-c1e023f/` — the extracted tree (includes the repo's
  own `.github/workflows/lean.yml` CI and `.gitignore`).
- Toolchain: `leanprover/lean4:v4.35.0` (`lean-toolchain`
  sha256
  `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c`).
- Mathlib: manifest rev `56a005855ea17e0b0958f73ec801ae140b0a1679`
  (the v4.35.0 rev), `lake-manifest.json` sha256
  `f1a399af75b1ff96c05a279c9cd0c780a6852315129c7719981bfbffd0c6f609`.

Key files (sha256):

- `Challenge.lean` (root shim) —
  `9847b6242b3e2be945f5d0212cb9cbecd885aca35259f5618d83aa6976df24b8`
- `Challenge/Basic.lean` (the challenge: definitions stated
  over Mathlib alone, four theorems with `sorry`) —
  `eeae0da96ab3d5784522a5745dc46353b1a804c3ea32972be4040cd4cd73354c`
- `Solution.lean` (root shim) —
  `058ee4b684edd9fec508dee865d96f295fe1fa9b2f1008f42c23add163d17741`
- `Solution/Basic.lean` (the four theorems restated
  identically, proved by delegation into the library) —
  `19700eeeec35078524b91f266ad31fcca4004e7b86a39a78e61543e5e749daa7`
- `RiemannJensen.lean` (root) —
  `cac6aa34296c285b837f4640c44fa97e283da543fd2727339a13d6b64592a4b0`
- `Comparator/comparator.json` —
  `03ed4e57b81c0175162fee813c2b4cc01d28167798b798ced55d7e875f3ec9ee`
- `lakefile.toml` —
  `a20a60102ae5ae36028deb083fc128d350bfa9b7a7fee215f26952befc442f97`

## Comparator configuration (as pinned)

- challenge_module `Challenge.Basic`, solution_module
  `Solution.Basic`.
- theorem_names (all four):
  `RiemannJensen.Challenge.exists_isDedekindZetaContinuation`,
  `RiemannJensen.Challenge.isDedekindZetaContinuation_unique`,
  `RiemannJensen.Challenge.dedekind_thm_main`,
  `RiemannJensen.Challenge.riemannJensen_main`.
- permitted_axioms: exactly `propext`, `Quot.sound`,
  `Classical.choice`.
- `enable_nanoda: true` (the independent-kernel checker is
  switched on in the author's own config).
- README states: "This repository has been verified with the
  comparator (Lean kernel only)", command
  `lake env comparator Comparator/comparator.json`. (A claimed
  run, to be reproduced by the forge, not taken as a receipt.)

## Pin seams (recon questions, recorded at pin)

1. **Version skew, paper vs artifact.** The appendix (tex
   l.1356-1362) states Lean 4.33.1 with Mathlib at
   `0df444a360ea`. The pinned repo builds on Lean v4.35.0 with
   Mathlib at `56a005855e`. The appendix's described artifact
   and the repo's current pin are not the same build; the
   audit target is the repo at c1e023f, and the note must say
   the appendix pin does not describe it.
2. **Scope wording.** Abstract: "the main theorems" (plural).
   Appendix: "Theorem~\ref{thm:Dedekind} has been formalized"
   plus "This work also establishes the Riemann case of
   Theorem~\ref{thm:main} for every d>=2." The comparator set
   (below) covers both, so the checkable claim is the
   appendix's, and it matches the abstract if both main
   theorems are in the set. They are.
3. **Two of the four comparator theorems are not paper
   theorems.** `exists_isDedekindZetaContinuation` and
   `isDedekindZetaContinuation_unique` fill a Mathlib gap
   (no analytic continuation of Dedekind zeta in Mathlib).
   They are load-bearing for the headline's meaning:
   `dedekindJensenK` is defined from
   `continuedDedekindZeta K := Classical.epsilon
   (IsDedekindZetaContinuation K)`, so without existence the
   headline would quantify over an arbitrary choice function,
   and without uniqueness the chosen function would not be
   pinned to the Dedekind zeta. The comparator set closing
   both is the artifact's own non-vacuity guard (BB6 vector
   A territory); the audit reads it as such.
4. **Pre-scan at pin (VM, source only, no build):** tree-wide
   grep finds `sorry` only in `Challenge/Basic.lean` (exactly
   4, the comparator theorems) and no `admit`,
   `native_decide`, or `axiom` declarations anywhere in the
   152 files.

## M1 first read (2026-11-06, statement level)

- `dedekind_thm_main` matches Theorem 3 (`thm:Dedekind`)
  hypothesis for hypothesis: exists C > 0, exists d0 >= 2,
  for all d >= d0, `dedekindJensenK K d != 0` and
  `(d:ℝ) - C sqrt(d log d) <= dedekindNegativeRootCountK K d`,
  where the count is distinct negative real roots
  (`roots.toFinset` filtered to x < 0). K ranges over all
  number fields (Type with Field + NumberField instances).
- `riemannJensen_main` matches Theorem 1's bound for every
  d >= 2 and adds a second conjunct the paper does not state:
  `nonrealJensenRootCount d <= C sqrt(d log d)` (nonreal
  roots counted with multiplicity). Given deg J_d <= d and
  J_d != 0 the added conjunct follows from the stated one
  (multiplicity budget), so it strengthens the formal
  statement without changing its content; and the statement
  as written forces J_d != 0 for all d >= 2 (the zero
  polynomial has root count 0 by the Mathlib convention the
  definitions use), which is the paper's own Theorems-1
  reading (the bound is asserted for every d >= 2, no
  large-d escape). To be recorded in the note's M1.
- Definitions read against the paper: `gammaCoeff j =
  (j!/(2j)!) * Re (iteratedDeriv (2j) centeredXi 0)` matches
  F_K(z) = xi_K(1/2 + sqrt z) = sum gamma_K(j) z^j / j! via
  the even Taylor expansion; `dedekindXi K s = s (s-1)
  Lambda_K(s) / 2` with
  `Lambda_K = |discr K|^{s/2} Gamma_R^{r1} Gamma_C^{r2}
  zeta_K^{cont}` matches eq. (xi-K-definition) including the
  1/2 factor. Modeling note: the Lean `dedekindXi` agrees
  with the entire xi_K only away from s = 1 and the Gamma
  poles (its own docstring says so); the Jensen coefficients
  are read at the center 1/2, where the two agree.
- `IsDedekindZetaContinuation K f`: `DifferentiableOn` on
  {1}^c and `f s = NumberField.dedekindZeta K s` for
  Re s > 1. The uniqueness theorem concludes agreement on
  all of {1}^c.

Next step (separate tap): forge — build the pinned tree plus
run the comparator on the self-hosted desktop runner,
fail-closed on the comparator's verdict, then the audit note.
