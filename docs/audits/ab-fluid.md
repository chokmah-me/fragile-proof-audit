# ab-fluid audit — Alpöge–Buckmaster forced blowup (Euler / Boussinesq / IPM)

**Harvest ID:** `ab-fluid` · **Fragility:** 5 · **Date:** 2026-09-24
**Repo:** `tristanbuckmaster/fluid_lean` @ `d0124689230b58b4f86e7b90ac59de06404b3b6b`
**Verdict:** **PASS** (Euler route; Type A + Type E + Type G)

## Claim

Smooth space-time forcing drives finite-time blowup for 3D Euler, planar
inviscid Boussinesq (every buoyancy `κ > 0`), and IPM. The Euler theorem
(`euler_smooth_force_blowup`): smooth classical solution on `[0,T)×ℝ³`,
compactly supported finite-energy data, smooth force with all mixed
derivatives bounded up to `T` in one fixed ball; `‖ω(t)‖∞ → ∞` and
`∫₀ᵀ‖ω‖∞ = ∞`; uniqueness in the finite-energy Lipschitz class on shorter
intervals. No blowup rate is certified.

## What was checked

**Type E — full certificate replay (the load-bearing numerics).**
An independent from-scratch Python transcription of the Lean fixed-point
(`2^60`) interval machinery (`Kernel.lean` DI arithmetic incl. fast-path
rounding, `Expr.lean` `evalI`/`evalD`, `Check.lean` `IPoly.encl`/`tabH`/
`otAux`, `CheckP.lean` `pLeafOK`/`pCheckPiece`, `OverTiltCertP.lean` RHS)
replayed **every** dressed-chunk piece of the Euler certificate:

- **5,249 / 5,249** `(chunk, piece)` checks pass (`pCheckPiece = true`),
  across **135** `ODChunk`s, 2,911 unique `PieceCert`s, 128-cell `hTab`,
  in 47.5 s.
- **Coverage:** the 8 sub-box `[a,b]` rationals tile `[0, 1/100]` exactly
  (`0, 1/800, 2/800, …, 8/800`), confirming `dCellsCover`.
- **Controls (both reject as required):** inverted `lo`/`hi` barrier →
  rejected; doubled `hi` coefficients → rejected. (Weak perturbations
  within the barrier slack correctly still pass — the checker is
  sensitive, not vacuous: malformed inputs are also rejected.)

**Type A — blowup criterion.** There is no single scalar inequality; the
criterion is the per-piece Picard contraction
`0 < (Ahi + Bhi·R − PertHi).lo ∧ 0 < (Alo + Blo·R + PertLo).lo`
inside `pLeafOK`, replayed above for every piece.

**Type G — no discrepancy.**
- `sorry`: one per `Challenge.lean`, each deliberate (challenge-side
  statement file; the affinecore header says so explicitly). Zero in any
  proof development.
- `axiom`: none. `native_decide`: none. `admit`: none.
- `Solution.lean` proves exactly the `Challenge.lean` statement
  (verified textually identical).
- The `build_skips_main_file` harvest flag is a misnomer:
  `EulerBlowup/Main.lean` is a *planar* (R2) Boussinesq layer, not the
  Euler entry point; the real route is
  root → `Ring.Main` + `Ring3D.Final` + `Cert.FinalPrime` → `Solution`.
  Nothing is skipped that the proof needs.
- Toolchain is pinned (`leanprover/lean4:v4.32.2`, Mathlib via
  `lake-manifest.json` at `81a5d25`) in each of the three projects —
  the harvest's "no toolchain pin" flag was wrong.
- Standard axioms only (`propext`, `Classical.choice`, `Quot.sound`).

## Provenance notes (not verdict-affecting)

- Lean code written by Claude under Alpöge's direction; Alpöge reportedly
  read `Challenge.lean` (Euler). Per doctrine, authorship is not evidence.
- A third-party rebuild is documented; the rebuild commit/result were
  located during recon (see blueprint).
- Papers pinned: `incoming/ab-fluid-ipm-arxiv.pdf` (57 pp, arXiv
  2609.16470), `incoming/ab-fluid-euler-nyu.pdf` (112 pp),
  `incoming/ab-fluid-boussinesq-nyu.pdf` (76 pp), with SHA-256 sidecar.

## Boundaries (not replayed)

- The Lean kernel bridge (`decide +kernel`: `pCheckPiece = true` ⇒
  analytic `LandingWindowsW`) and the ODE→PDE lifting lemmas are trusted
  to Lean+Mathlib, not re-derived.
- `chainOK`/`headIs` chaining and `landOK`/`posOK`/`negOK` side conditions:
  structural, kernel-checked in Lean.
- Boussinesq and IPM certificates use the same machinery but were not
  re-run (Euler is the flagship; gate covers the Euler route).
- No full `lake build` (needs ~100–150 GB RAM; this VM cannot).

## Disposition

**PASS.** The entire Euler interval certificate — the only part of the
proof a machine checks by brute force — replays green under an
independent transcription, with exact coverage and working controls.
Type G shows no statement/proof mismatch. The provenance flags
(AI-generated, released under pressure) are recorded but, per doctrine,
do not refute the route. Gates refute routes, not theorems; here the
route stands.
