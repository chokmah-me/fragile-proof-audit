# Input pin — Gu, Kemeny, Yelin, Lukin, Discovering state-of-the-art quantum circuits with large language models (arXiv:2610.22367)

Pinned 2026-10-25. Source: Emergent Mind harvest 2026-10-20
(fragility 1, ranked #4 in its batch); code-availability probe
at the user's tap 2026-10-25 found the full release
(~/workspace/quantum-circuits-recon/PROBE.md); target pick set by
the user the same day. Scope of the pick: **M1–M4 audit with
three legs — (1) evaluator replay of all 8 tasks (discovered +
baseline circuits) against the repo's `results.jsonl` and the
paper's Table I; (2) evaluator-fidelity read (grader/reference
independence, test-draw construction, failure budgets), the
evaluator being the claim's trusted base; (3) the Lean leg:
build and axiom-audit `lean/divsteps` and `lean/dqi` and
M1-check their statements against the three claims in the
paper that cite the repo as `gu2026lean`** — plus M1–M3 checks
of the paper text itself. The verdict lock is not touched. No
author contact.

## The paper

- Andi Gu, Alek H. Kemeny, Susanne F. Yelin, Mikhail D. Lukin,
  *Discovering state-of-the-art quantum circuits with large
  language models*, arXiv:2610.22367v1, submitted 2026-10-15.
  46 pages, 10 figures, 6 tables; Supplementary Information is
  inside the paper. Headline: an evaluator-guided LLM search
  (OpenEvolve, Claude Mythos 5 proposer, hand-written task
  specifications) discovers circuits beating the state of the
  art on both Toffoli and qubit counts in 7 of 8 tasks (largest
  gain 39× TQ-cost, fixed-point Gaussian), and a new reversible
  divsteps architecture for prime-field modular inversion in
  the 8th.
  - PDF: `quantum-circuits-2610.22367.pdf`
    `3607f457c3349db74e10b131abadef23a4a2dea0fefa0cf6ac6d0ed9f37fdfd9`
  - E-print tarball: `quantum-circuits-2610.22367-eprint.tar.gz`
    `ec714a639c886a1f8ef78d14a255adfdac24a5405b2cf563978b64ce591ec989`
  - `main.tex` (in tarball): 3,968 lines (hash in the audit
    note's working evidence, ~/workspace/quantum-circuits-recon/).
  - No code link in the arXiv record and no code-availability
    statement in the paper; the repo is cited in the
    bibliography as `gu2026lean` (entry "uncompute", A. Gu
    2026, URL in the compiled .bbl) at three load-bearing
    points. Recorded in the probe note; a recon catch is banked
    there (grep the .bbl for URLs before recording `code: none`).

## The code

- github.com/andigu/uncompute (first author's account),
  Apache-2.0, created 2026-10-15, HEAD
  `64b5a13aa249f1360846657392e6c66817b26d0f` (2026-10-16,
  2 commits: initial + README update). ~123 MB, 350 files.
  Local copy: `~/workspace/quantum-circuits-recon/repo`,
  fetched as the codeload tarball of the pinned commit after a
  git clone died in a VM reboot (2026-10-25); verification is
  stronger than a checkout: all 302 file blobs in the GitHub
  API recursive tree at the pin were recomputed locally
  (git blob SHA-1) and match, no missing, no extras. Execution
  runs happen in a sibling copy (`repo-run/`) so the verified
  tree stays pristine.
  - `tasks/<task>/` × 8 (dqi-reed-solomon, dqi-hermitian,
    hhl-angle, coulomb-potential, gaussian, chemistry-fe2s2,
    lattice-gauge-plaquette, modinv-point-add): each with
    `grader.py`, `reference.py`, `contract.json`, `circuits/`
    (discovered + reconstructed baseline), `results.jsonl`
    (exact certified counts, op-stream hash `h_ops` per
    circuit, evaluator verdict per circuit).
  - Evaluator: `uncompute/evalcore/` (kernel incl.
    `_kernel.c`, executor, protocol, compact reader, report)
    plus Builder / serializer / simulator in `uncompute/`.
    Circuit model: kickmix (Babbush et al. 2026,
    arXiv:2603.28846, as cited by the repo README).
  - Lean projects: `lean/divsteps` (Hddivsteps590; Lean
    4.32.2, Mathlib v4.32.2 — the house toolchain) and
    `lean/dqi` (Dqi; Lean 4.33.1, Mathlib v4.33.1); 43 .lean
    files total; lakefiles and toolchains pinned in-repo.

## Adjacent artifacts (recorded, not audited)

- tatra-labs/kickmix-arena (third party, 2026-10-22): an
  independent re-implementation of the evaluator loop whose
  README states the original evaluator "was not released."
  Contradicted by the pinned repo above (pushed 2026-10-16);
  recorded as a disagreement in the probe note. Not used.
- OpenEvolve (algorithmicsuperintelligence/openevolve), the
  public search framework the paper's Methods cite: the
  search harness, not the evaluator; the audit does not re-run
  the LLM search (the claim audited is the discovered
  circuits' certified costs and correctness, not the search's
  reproducibility).
