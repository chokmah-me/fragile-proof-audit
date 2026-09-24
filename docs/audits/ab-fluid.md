# ab-fluid audit — Alpöge–Buckmaster forced blowup (Euler / Boussinesq / IPM)

**Harvest ID:** `ab-fluid` · **Fragility:** 5 · **Date:** 2026-09-24
**Repo:** `tristanbuckmaster/fluid_lean` @ `d0124689230b58b4f86e7b90ac59de06404b3b6b`
**Verdict:** **PASS** (Euler + Boussinesq routes; Type A + Type E + Type G)

## Claim

Smooth space-time forcing drives finite-time blowup for 3D Euler, planar
inviscid Boussinesq (every buoyancy `κ > 0`), and IPM. The Euler theorem
(`euler_smooth_force_blowup`): smooth classical solution on `[0,T)×ℝ³`,
compactly supported finite-energy data, smooth force with all mixed
derivatives bounded up to `T` in one fixed ball; `‖ω(t)‖∞ → ∞` and
`∫₀ᵀ‖ω‖∞ = ∞`; uniqueness in the finite-energy Lipschitz class on shorter
intervals. No blowup rate is certified.

The Boussinesq theorem (`boussinesq_smooth_force_blowup`; PDF Theorem 1.1,
"For the fixed data (1.4), there are odd forces … and a time T* ∈ (0, ∞)
such that … This solution blows up as t ↑ T* in the sense that
sup ‖θ(t)‖∞ < ∞, lim ‖∇θ(t)‖∞ = ∞, lim sup ‖ω(t)‖∞ = ∞"): for every
buoyancy `κ > 0` (via the paper's scaling reduction, Lemma 1.2),
finite-time gradient blowup with bounded temperature and unbounded
vorticity limsup, smooth compactly supported forces, strong-class
uniqueness.

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

**Type E — Boussinesq certificate replay.** The same transcription, run
unmodified against `boussinesq-blowup/` (`scripts/gates/
ab_fluid_boussinesq.py`, sharing `ab_fluid_parse`/`ab_fluid_check`):

- **5,249 / 5,249** `(chunk, piece)` occurrences pass, **2,603** unique
  `PieceCert`s, **135** `ODChunk`s, 128-cell `hTab`, in 158.4 s. (Same
  occurrence count as Euler: both certs are emitted by the same generator
  with identical chunking.)
- **Coverage:** the 8 sub-box rationals tile `[0, 1/100]` exactly,
  same 1/800 tiling.
- **Controls:** baseline passes; inverted barrier rejected; doubled-`hi`
  rejected (receipt: `results/ab_fluid_boussinesq_control_meta.json`).
  Separate control receipt kept because the Boussinesq cert is an
  independent artifact — a pass here is not implied by the Euler pass.

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
- The IPM certificate was not re-run (AffineCore route carries the
  comparator-pending gap above).
- No full `lake build` (needs ~100–150 GB RAM; this VM cannot).

## Disposition

**PASS (Euler + Boussinesq routes).** Both interval certificates — the
only parts of either proof a machine checks by brute force — replay green
under an independent transcription (Euler: 5,249/5,249; Boussinesq:
5,249/5,249), with exact coverage and working controls. Type G shows no
statement/proof mismatch for Euler, whose review and comparator design
are complete. The provenance flags (AI-generated, released under
pressure) are recorded but, per doctrine, do not refute the route. Gates
refute routes, not theorems; here the Euler and Boussinesq routes stand.
**Scope note:** the IPM/AffineCore route was not certificate-replayed and
is not covered by this PASS — its comparator run is pending and its
statement is human-unreviewed at this commit. The Boussinesq
statement-review caveat (maintainer had not read `Challenge.lean` at this
commit) remains a process note; it is not a mathematical finding.
