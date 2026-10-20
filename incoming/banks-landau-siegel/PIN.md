# Input pin — Banks, On the OpenAI proof that Landau–Siegel zeros do not exist (arXiv:2610.15483)

Pinned and audited 2026-10-20. Source: Emergent Mind harvest
2026-10-20 (fragility 1, ranked #1 in its batch); target pick set by
the user 2026-10-20 ("Banks as the target pick"). Scope of the pick:
**M1–M4 statement-fidelity audit of Banks's paper as two verdict
objects — V-A, the explicit theorem for q ≥ q₀ = 10¹⁰ with
δ₀ = 3.0×10⁻³, including its fidelity to the OpenAI argument it
rearranges; V-B, the all-conductors upgrade c = δ₀ for q ≥ 3,
which is a consumption of Lu–Zaman–Zhao Theorem 1.1** — plus a
consumption check of that theorem at its primary source. The
verdict lock is not touched. No author contact.

## The paper

- William D. Banks, *On the OpenAI proof that Landau–Siegel zeros
  do not exist*, arXiv:2610.15483v1, submitted 2026-10-11. 19 pages,
  single TeX file. Headline: the OpenAI interpolation-determinant
  argument rearranged as a direct proof with explicit constants.
  - PDF: `banks-2610.15483.pdf`
    `54891704515ba9d58ae60ce4c16f4b368a377a9732ca98e26172209fa0647d6f`
  - E-print tarball: `banks-2610.15483-eprint.tar.gz`
    `33616defcbd665865217183bb099f94c34b5e3f5514efd7ce5d37feb7fc44836`
  - `Effective_SZs.tex` (in tarball):
    `34a1586c6c285474c62d8d504f1a3077667a041c6bf507ad042cd5d6a86f2cfc`
  - No ancillary files and no code (the tarball also carries
    `figure1.png` and a style file). Working copies and per-check
    evidence in `~/workspace/banks-recon/` (`internal-check.md`,
    `lzz-check.md`, `openai-check.md`).

## Consumed sources (as cited by the paper)

- OpenAI, *Uniform exclusion of Landau–Siegel zeros*, manuscript
  dated October 1, 2026. Pinned from the openai/math repo at
  `adc7f1241b42e322a6451854ab7e4b4c146bf78a` (path
  `preprints/Uniform-exclusion-of-Landau-Siegel-zeros-October-1-2026/`;
  git blob hashes of paper.pdf / paper.tex / README reproduce at
  that commit; the third-party rebuild repo's vendored PDF is the
  same blob).
  - PDF (9 pp): `fab9f6e84ece2a37d834b2c031d8eb14e81413d9f6270791e7b5468b295214ef`
  - TeX: `b011ba9c1f55ee2164292492c55e0c6d75c458eb30d4808808f9953823b8ded4`
- R. F. Lu, A. Zaman, H. Zhao, *Numerical computations concerning
  Landau–Siegel zeros*, arXiv:2602.03626v1 (submitted 2026-02-03,
  20 pp). Theorem 1.1 is the small-conductor leg of Banks's V-B.
  - PDF: `77388d40267e90684e02ec8e666a9d55b0ceb159fa6b5b9eea1faf3dd09b1a40`
  - E-print tarball: `0f369e2b6b3ba8c0329afc14693ece72781c043c942837ef79e907e71e74c8ab`
  - Main TeX (`landau-siegel-computations-arxiv-v1.tex`):
    `0f5239418a9795ea5c75d972a5f9cff2379cb2a47e798376b2d4c8126ce23639`
  - Its bottom segment (q ≤ 4×10⁵) is itself imported from Platt
    (2016); its code is public at
    github.com/asif-z/landau-siegel-zero-tester @ a783ffdfb,
    not run in this audit.

## Adjacent artifacts (recorded, not audited)

- OpenAI's own Lean formalization of the source statement
  (openai/math family 003 at adc7f12: comparator `SiegelZeros.lean`
  + a 306-file solution tree; the scope doc itself states no
  explicit value of c is given). Not built in this audit.
- AolinHAN/landau-siegel-lean @ `919e60f4630399ba27e1f3c3d4a39d754842cf9c`,
  a third-party formalization of the same statement; its author
  records a build and an axiom audit of 406 theorems (2026-10-10)
  and reports no gap in the OpenAI argument. Not re-run here.
