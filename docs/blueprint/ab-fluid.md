# ab-fluid — Blueprint

**Target.** Forced finite-time blowup for 3D Euler, planar Boussinesq, and IPM
(Alpöge–Buckmaster). Harvest ID `ab-fluid`, fragility 5.

**Repo.** `tristanbuckmaster/fluid_lean` at pinned commit
`d0124689230b58b4f86e7b90ac59de06404b3b6b` (sparse clone at
`~/workspace/ab-fluid-verify`, detached HEAD).

**Papers (pinned under `incoming/`).**
- `ab-fluid-ipm-arxiv.pdf` — arXiv 2609.16470, 57 pp.
- `ab-fluid-euler-nyu.pdf` — NYU-hosted Euler manuscript, 112 pp.
- `ab-fluid-boussinesq-nyu.pdf` — NYU-hosted Boussinesq manuscript, 76 pp.

## Claim

Smooth space-time forcing drives finite-time blowup:

1. **3D Euler** (`euler-blowup/`): smooth classical solution on `[0,T)×ℝ³`,
   compactly supported finite-energy data, smooth force with all mixed
   derivatives bounded up to `T` supported in one fixed ball;
   `‖ω(t)‖∞ → ∞` and `∫₀ᵀ ‖ω‖∞ = ∞`; uniqueness in the finite-energy
   Lipschitz class on shorter intervals. No blowup rate certified.
2. **Planar Boussinesq** (`boussinesq-blowup/`): for every buoyancy `κ>0`,
   finite-time gradient blowup with bounded temperature, unbounded vorticity
   (limsup), smooth compactly supported forces, strong-class uniqueness.
3. **IPM**: extends the Córdoba–Martínez–Zoroa blowup to uniformly
   space-time smooth forcing (arXiv paper).

## Proof architecture

Each project reduces the PDE to a finite-dimensional **reduced ODE**
(a "tilted" 3-state system with 4 parameters, 3 auxiliary table lookups,
4 perturbation slots) via an explicit ansatz. The ODE is shown to drive a
"landing window" criterion (`LandingWindowsW` / `LandingWindowsODE`), which
the analytic layer lifts to PDE blowup (`theorem01prime` →
`euler_smooth_force_blowup`).

The load-bearing numerics are **interval certificates**: thousands of
`PieceCert` records, each carrying lower/upper polynomial barrier
coefficients (`lo`, `hi`), a time mesh (`u0`, `len`, `cuts`), checked by
`pCheckPiece` — an exact fixed-point (`2^60`) interval Picard-contraction
check (`pLeafOK`) against the explicit RHS (`otRhs3P`), the hybrid step
table (`hTab`), and perturbation bounds (`Om`).

**Scale (Euler).** 832 files under `EulerBlowup/Num/Cert/`; ~2,900
`PieceCert` defs; 8 dressed sub-boxes (`SB0`–`SB7`) tiling parameter
`[0, 1/100]` in eighths of `1/800`; ~70 `ODChunk`s binding
`(P, Om, piece-list)`.

## Gate design (`scripts/gates/ab_fluid.py`)

**Type A (scalar/inequality gate).** The blowup criterion has no single
scalar inequality; the load-bearing check is the per-piece Picard
contraction `0 < (Ahi + Bhi·R − PertHi).lo ∧ 0 < (Alo + Blo·R + PertLo).lo`
inside `pLeafOK`. The gate replays this from scratch.

**Type E (certificate replay).** From-scratch Python transcription of:
- `Kernel.lean` DI arithmetic (exact, including fast-path rounding),
- `Expr.lean` evaluators (`evalI`, `evalD`),
- `Check.lean` (`IPoly.encl`, `tabH`, `otAux`),
- `CheckP.lean` (`pLeafOK`, `pCheckPiece`),
- `OverTiltCertP.lean` RHS expressions.

Replays every `ODChunk` piece: parses `PieceCert`/`Array DI`/`List PieceCert`
defs, resolves `(P, Om)`, runs `pCheckPiece`. Plus:
- **Coverage:** verifies the 8 sub-box `[a,b]` rationals tile `[0,1/100]`
  exactly (`dCellsCover` logic).
- **Controls:** inverted barrier and doubled-`hi` perturbations must be
  rejected.

**Out of scope (documented, not replayed).**
- The Lean kernel proof that `pCheckPiece = true` implies the analytic
  `LandingWindowsW` (the `decide +kernel` bridge and the ODE/PDE lifting
  lemmas) — trusted to Lean+Mathlib, not re-derived.
- The `chainOK`/`headIs` chaining and `landOK`/`posOK`/`negOK` side
  conditions — structural, checked by Lean `decide`.
- Boussinesq and IPM certificates — same machinery, not re-run
  (Euler is the flagship; the gate covers the Euler route).
- Full `lake build` (needs ~100–150 GB RAM; this VM cannot do it).

**Verdict rule.** PASS iff every replayed piece passes, coverage tiles,
and both controls reject. Any piece failure or control non-rejection →
FAIL (route refuted). Provenance flags (AI-generated, third-party rebuild)
are recorded but cannot alone produce BREAK — doctrine: gates refute
routes, not theorems.
