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

**Type G — no discrepancy (Euler); process caveats elsewhere.**
- `sorry`: one per `Challenge.lean`, each deliberate (challenge-side
  statement file). Zero in any proof development, vendor included.
- `axiom`: none. `native_decide`: none. `admit`: none.
- `Solution.lean` proves exactly the `Challenge.lean` statement
  (verified textually identical).
- The `build_skips_main_file` harvest flag is **false at this commit**:
  both `Main.lean` files are inside the `lake build` import closure
  (1,113 modules from default targets; `EulerBlowup/Main.lean` is imported
  by `Hypotheses.lean`, `Kit/Bootstrap.lean`, `Ring*.lean`,
  `Ring3D/*.lean`, etc. — it is the shared planar-statement layer, not a
  stale leftover). The flag's "hence never compiled" inference was wrong.
- Statement-vs-prose divergences (sup-norms rendered as pointwise
  minorants, integral divergence as arbitrarily large minorant integrals,
  no certified blowup rate, pressure-free weak uniqueness) are all
  **documented** in `formalization.yaml`'s `fidelity.divergences` and
  verified faithful.
- Toolchain is pinned (`leanprover/lean4:v4.32.2`, Mathlib via
  `lake-manifest.json`) in each project — the "no toolchain pin" flag
  was wrong. (Mathlib rev is v4.32.0 vs toolchain v4.32.2; READMEs note
  4.32.2 = 4.32.0 plus two kernel soundness fixes, Mathlib from source.)
- Euler review status: `author-verified` (Alpöge read `Challenge.lean`).
- **Boussinesq caveat:** review status `unreviewed` — the maintainer had
  not read `Challenge.lean` at this commit (README concurs).
- **AffineCore gap:** `Challenge.lean`/`Solution.lean` are declared
  `lean_lib`s but are **not** default targets (bare `lake build` never
  type-checks them), and `formalization.yaml` states the comparator run
  is **pending** — the bridge connecting the 1,100+-module proof to the
  trusted statement has not been executed at this commit. Statement also
  human-unreviewed. This is a genuine verification-chain gap for the
  affinecore route (not covered by this gate, which replays Euler).

## Provenance notes (not verdict-affecting)

- Lean code written by Claude under Alpöge's direction; Alpöge reportedly
  read `Challenge.lean` (Euler). Per doctrine, authorship is not evidence.
- A third-party rebuild was attempted (goodcarp/navier-stokes, targeting the
  pinned `d012468` commit, Lean 4.32.2, Mathlib built from source) but is
  **incomplete on record**: the build reached 9,739/9,769 modules over ~19.5 h
  before the host rebooted and the build tree was lost. No completed
  independent rebuild of this commit exists on record; the OpenAI
  NavierStokesAndEuler comparator replay is a separate repo, not fluid_lean.
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

**PASS (Euler route).** The entire Euler interval certificate — the only
part of the proof a machine checks by brute force — replays green under an
independent transcription, with exact coverage and working controls.
Type G shows no statement/proof mismatch for Euler, whose review and
comparator design are complete. The provenance flags (AI-generated,
released under pressure) are recorded but, per doctrine, do not refute
the route. Gates refute routes, not theorems; here the Euler route stands.
**Scope note:** Boussinesq and AffineCore were not certificate-replayed,
and carry the process caveats above (unreviewed statements; affinecore
comparator pending) — they are not covered by this PASS.
