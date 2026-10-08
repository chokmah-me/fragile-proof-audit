# Audit note — SSS trace lower bound λ ≥ 1.80220 (2026-09-28)

**Claim artifact:** David Niedbala Giraudin, *A new lower bound for the
Schur–Siegel–Smyth trace problem*, arXiv:2609.29298 (submitted 2026-09-24).
**Harvest item:** `sss-trace-lower-bound` (2026-09-28 scan, rank 5).
**Campaign objects:** `results/sss_trace_gate_meta.json`; working copies of the
ancillary files kept at `~/workspace/sss-audit/` (not committed: third-party
ancillary downloads).

**Artifact pins (arXiv ancillary files, downloaded 2026-09-28):**
sha256 `3caa729730c5c52d755353ccf5e643372aadd0d792c37b14fcdb932ec6f1abe5`
`CERTIFICAT_C86.json` (241,197 bytes),
`d95c2effb81b6c8e7ca36f394a76a0d08b22d5c3987551628eb75d7cdfe6d4fd`
`prove_SSS_C86.py`, `13999f714961e8b37bf68a6ce8c86bb06629555fa9f065af2446046b876fca70`
`verify_C86.py`.

**Agent provenance (reconstructed):** Muse (Meta) · model `Muse Spark 1.3` · run date `2026-09-28` · added before the harness-pinning policy (2026-10-08); the verdict rests on pinned artifacts, independent of the agent transcript.

## Verdict: PASS (verify/audit)

The certificate replay succeeds end to end. λ_SSS ≥ 1.80220 is verified by
two independently written provers against the pinned JSON, with a hand-checked
derivation of every bound direction.

## What was run

| Run | Command | Result |
|---|---|---|
| Main verifier | `python3 verify_C86.py` (numpy 1.26.4, mpmath 1.2.1) | **VERIFIED λ^SSS ≥ 1.802200**, EXIT 0, 152 s |
| Independent prover | `python3 prove_SSS_C86.py` | **PROVED λ^SSS ≥ 1.80220**, EXIT 0, 261 s |
| Smoke control | `verify_C86.py` with CIBLE=1.80 | VERIFIED, 8 s (script functional) |
| Teeth control | point evaluation of g on [0.24,0.27] (closed forms) | min g = 1.80222174 at x=0.25274; false target 1.81 is genuinely below no certified bound — gap 0.0078 ≫ float64 rounding ~1e-13 |

## What the verifier checks (all [ok])

- Certificate structure: 6933 edges / 6932 masses, strictly increasing edges,
  non-negative masses summing to 1, support in [0,8], λ₀ = 0.5346669850888335 > 0,
  all λ_Q ≥ 0, all 18 polynomials with integer coefficients (14 active).
- Energy I(η) computed twice by structurally different methods (edge-jump sum in
  float64, cell double-sum in float128): agree to 1e-12; I(η) = 3.1305148801e-5 > 0
  (paper: 3.1305148803e-5).
- All 14 active polynomials monic with all-real roots; coefficient residuals of
  the root factorizations ≤ 1.3e-51 (measured against the exact integer
  coefficients — no root perturbation theory needed).
- Bisection on [0,14]: 24 levels, 1,699,227 intervals exhausted, g ≥ 1.80220
  everywhere. Level counts of the second prover match the paper exactly
  (18,504 / 36,482 / 72,162 / 143,178 / 284,664 / 489,354 / 427,770 / 199,340 / 8,202).
- Tail x ≥ 14: analytic, h(14) = 6.314406 with h′ > 0 increasing — huge margin.

## Hand-checked derivation (the part no script can vouch for)

- **Dual inequality** (paper Prop. 2): x ≥ λ + Σλ_Q log|Q(x)| + λ₀(2U_η(x)−I(η))
  for x ≥ 0 ⟹ λ ≤ λ_SSS, via OTS Lemma 2.4 (I(μ) ≥ 0 ⟹ ∫U_η dμ − ½I(η) ≥ 0 for
  *every* finite-energy η) and OTS Cor. 1.2 (λ_A ≤ λ_SSS). Both statements
  confirmed present in arXiv:2401.03252 (OTS, *Math. Comp.* 94 (2025),
  2005–2027); Smith's energy-constraint result ([8], Prop. 5.7) is the remaining
  inherited theorem. Directions of integration are correct.
- **Cell-potential unimodality**: u_j(x) = ((x−a)log|x−a| − (x−b)log|x−b|)/h − 1
  has derivative (log|x−a| − log|x−b|)/h, negative left of the midpoint,
  positive right — minimum at the midpoint, so the interval maximum is at an
  endpoint. The script's endpoint-max bound is exact.
- **Bisection bound directions** all correct: x ≥ t−H; |Q(x)| ≤ lead·∏(|t−ρ|+H)
  + E_Q with E_Q measured on [0,14] (valid since bisection stays in [0,14]);
  −λ_Q log|Q| lower-bounded via the |Q| upper bound (safe also at Q(x)=0, where
  the true term is +∞); U_η upper-bounded; I(η) lower-bounded by
  min(float64, float128) − 1e-12; EPS = 1e-9 subtracted per bound, ~100× the
  accumulated IEEE error (~1e-11 over the 6932-cell dot products).
- **Tail**: all 14 active polynomials are monic, so |Q(x)| ≤ (x+ρ_max)^deg is
  valid (log lead = 0); ρ_max = 4.938969; U_η(x) ≤ log x for x ≥ 8 since η
  lives on [0,8]; g′(x) ≥ 1 − 1.6535906937/(x+ρ_max) − 1.0693339702/x > 0 at
  x=14 and increasing.

## Notes

- The design is genuinely self-validating: η is *not* feasible for the primal
  problem (paper §3: three ∫log|Q|dη ≥ 0 constraints fail by ~1e-5) and Prop. 2
  does not require it — a data error can only weaken the bound. Confirmed, not
  just claimed.
- The script's `I(η) ≥ 0` check is a sanity check, not a logical requirement
  of Prop. 2 (which needs only finite energy). Harmless.
- Inherited (not re-derived): OTS Lemma 2.4 / Cor. 1.2 and Smith's Annals
  energy-constraint theorem. The audit covers the certificate and its
  verification; the framework is peer-reviewed prior work.
- Numerical infimum of g is 1.8022211895 (certificat field: 1.8022211894912388),
  certified value 1.80220 sits 2.1e-5 below — the margin is bisection depth, as
  the paper states.

## Verdict lock

Not a 25-gate campaign item; recorded as a standalone verify/audit PASS. The
25-gate verdict lock (17 BREAK / 8 PASS) is untouched.
