# Input pin — Frei–Sofos–Widmer, quasi-Riemann hypothesis applications (arXiv:2610.18491)

Pinned 2026-10-19 (recon) and audited 2026-10-20. Queue position set by
the user 2026-10-18 ("Put in queue"); audit dispatched 2026-10-20 at the
user's tap on the harvest Idea card. Scope of the pick: **M1–M4
statement-fidelity audit of the paper's conditional core (V-A) and of its
unconditional instantiation (V-B), kept as two separate verdicts**, plus
a statement-level audit of the consumed Lean artifact
(AxiomMath/DedekindZetaZeroFree). The verdict lock is not touched. No
author contact.

## The paper

- Christopher Frei, Efthymios Sofos, Martin Widmer, *Some applications
  of the quasi-Riemann hypothesis to class groups and small generators
  of number fields*, arXiv:2610.18491v2, submitted 2026-10-13 (v2
  2026-10-14). Headline: the Ellenberg–Venkatesh ℓ-torsion bound made
  "unconditional" via the quasi-Riemann hypothesis (QRH(δ)).
  - PDF: `fsw-2610.18491.pdf`
    `2432308ec3ec4586985365a10403a7b06ed6d524d36544ba1dad2f7f63cc036f`
  - E-print tarball: `fsw-2610.18491-eprint.tar.gz`
    `02a69908c488c0a3baf5a6dc4e35036d441885f6edaabab843f970279c8ba7cf`
  - `main.tex` (in tarball):
    `7e8aed18c8e3d0f90f2666505bd7d411c7935170acf984670118fcafdf592aef`
  - `main.bbl` (in tarball):
    `c4f130b98eceb2583c911be0a564000987dbd79d3962b876e15a95eae3256d55`
  - v1 e-print tarball (retrieved 2026-10-20 for the A11 delta):
    `50e1d13adaf557e9b242a453be3a1fe4f04d5d83acaf6f0e052780651c45f4dd`
  - Working copies in `~/workspace/fsw-recon/`; audit evidence in
    `~/workspace/fsw-recon/audit-work/` (paper-math.md, lean.md,
    citations.md). Audit brief: `~/workspace/fsw-recon/AUDIT-BRIEF.md`.

## Consumed sources (as cited by the paper)

- Cureton–Thorner (Hexagon), *A refinement of the zero-free region for
  Dedekind zeta functions*, hexagon:2610.00200. The paper cites **v1**
  (QRH(1/6000) for all Dedekind zeta functions).
  - v1 PDF (33 pp): `ae3ec63272056714c81c6a56ac860c76885a384d9569cbf6ca45cd4cb9433d09`
  - v2 PDF (36 pp, Re s > 31/32): `46cc2c2ac941a7c702b61641ff30f6a3fa9e88d273559aa014c278b08ab1d126`
- OpenAI, *The Quasi-Riemann Hypothesis* (the OAI1112 paper; QRH(1/12)
  for Dirichlet L and finite-order Hecke L over Q(√−3)).
  - PDF (49 pp, fetched from the bibliography's GitHub link):
    `f919b57829b178c8e60e7c17b018cf773e7907cf642ef5a3347d8a826e8dbf18`
- D. R. Heath-Brown, *ℓ-Torsion in Class Groups via Dirichlet
  L-functions*, arXiv:2412.07701v2 (Int. J. Number Theory 22(02),
  2026). His Theorem 5 is the cubic-case reduction the paper consumes.
  - E-print: `7d253fa68b3ca5f3d36ae921b5e5f8a5dbffcf9218f0511f37f127c9e11d8ca0`
  - PDF: `9875f3d053a27430e85f59de70249db8f0154fe54549596985934561c8acf896`

## The Lean artifact

- AxiomMath/DedekindZetaZeroFree @
  `09afbb4ce6570c1615d58509dc197fc9f0956b7d` (HEAD, tree clean at audit
  time). Toolchain `leanprover/lean4:v4.35.0-rc3` (repo pin). Mathlib
  rev `0493595ecd5da8ef14742febab99728f98e948e8`. 5,528 `.lean` files
  (3,867 library, 1,658 vendor, Challenge 1, Solution 1). Formalizes
  Hexagon **v2** Theorem 1.1 (Re s > 31/32). Local clone:
  `~/workspace/fsw-recon/lean-repo/`.
- No SI or peer-review file exists for any of these preprints.
