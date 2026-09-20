# Audit note — odd-zeta preprint 202601.1609 (Phase 2(d), corrected 2026-09-20)

**Claim artifact:** Archan Chattopadhyay, *On the Irrationality of the Odd Zeta Values*,
Preprints.org 202601.1609.v1 (doi:10.20944/preprints202601.1609.v1).
**Campaign objects:** `docs/blueprint/odd-zeta-202601.md`,
`scripts/gates/odd_zeta_1609.py`, `results/odd_zeta_gate_meta.json`.

**PDF pin:** `incoming/odd-zeta-202601/preprints202601.1609.v1.pdf`
sha256 `686998ff30f778fba4aa9a3874ccf09637bd76663a4edb7c39fae24b1125aae2`
(gitignored per repo convention; SHA recorded here and in the gate meta JSON).

## Correction to the prior (2026-09) verdict

The original Phase 2(d) note, written against OCR/indexed excerpts before the
PDF could be pinned, claimed:

> Lemma 3.2 defines `A_m := D_m` (an LCM) and `B_m := Ω D L_{≤K}`; `W_m`,
> `Ω_m`, `F_{m,k}`, `K`, `D_m` have no closed evaluable form. `Λ_m` is not a
> number.

**This is false.** Against the actual PDF, every symbol in Lemma 3.2 is an
explicit finite object:

- `W_m^{(q)}(x) := C((q+1)m, m) x^m(1-x)^{qm}` — explicit polynomial.
- `Ω_m^{(q)} := (q+1)m + 1` — explicit integer.
- `F_{m,k}^{(q)} := ((q+1)m)!(m+k)! / (m!((q+1)m+k+1)!)` — explicit rational.
- `D_m^{(q)} := lcm_{1≤k≤K} den(F_{m,k}/k^{2n+1})` — explicit LCM, computable
  for any finite `K`.
- `A_m := D_m`, `B_m := Ω_m D_m L_m^{(≤K)}`, `Λ_m := A_m ζ(2n+1) − B_m`.

`scripts/gates/odd_zeta_1609.py::demonstrate_lambda_evaluable` computes
`A_m, B_m, Λ_m` exactly at `n=2` (ζ(5)), `m=4`, `q=1`, `K=4` — a concrete
witness that the construction is a real number, not a symbolic dead end.
**That specific BREAK is retired.**

## The real break: Lemma 5.1 never fires (Phase 2(d), reopened as BREAK)

### Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma 5.1** | "With λ>0, there exist parameters `q ∈ ℕ, δ ∈ (0,1), α>0` which satisfy (24)," where (24) is `1+q+λα < min(γ^{(q)}(α), −log δ)` and `λ := κ+2`, `κ := 2n+1` |
| **Instance** | The paper's own λ, i.e. `λ = 2n+3` for `n = 1, 2, 3, 4, 5` (ζ(3), ζ(5), ζ(7), ζ(9), ζ(11)) |
| **False instance** | For every admissible `q > e^λ−1` sampled across ~300 orders of magnitude above that boundary, `g(α*)` — the paper's own closed form at its unique critical point `α* := q/(e^λ−1) − 1` — is **strictly positive**. No `q` exists making `g(α*) < 0`, so no admissible `(q, α, δ)` exists |

**Verdict: BREAK.** Lemma 5.1's displayed existence claim is false at every
`n ≥ 1` the theorem claims to cover — including `n = 1` (ζ(3)), which is
already known true by Apéry, but this paper's own construction cannot reach
even that case. Without admissible parameters, condition (24) never holds,
the exponential-decay bound of §4.3 is never invoked, the hypothesis of
Theorem 5.1 (the irrationality criterion) is never established, and
Theorem 1.1 is unproven by this route for every odd zeta value.

### What was gated

Closed form (paper's own, verified against the PDF, eq. between (23)-(24)):

```
g(α*)(λ, q) = (1+q)(1 + log(1+q) − λ) − q·log(q/(e^λ − 1))
```

- At the domain boundary `q = e^λ − 1` (where `α* → 0`), `g(α*) = g(0) = 1+q
  = e^λ` **exactly** — positive by construction, for any λ.
- Sampled `q` from that boundary out to `qmin·10^300`, for `λ = 5, 7, 9, 11,
  13` (n = 1..5): minimum observed `g(α*)` is `≈ e^λ` (achieved right at the
  boundary) and it only grows from there. Never negative, anywhere sampled.
- This is a numeric gate (finite sampling across 300 orders of magnitude,
  monotone-looking, consistent with the paper's own `∂_λ g(α*) = q/(e^λ−1)
  − 1 > 0` on the admissible domain), not a closed-form proof that no valid
  `q` exists for *any* real number — but the sampled range comfortably
  exceeds anything a numerical claim in a preprint could be relying on.
- Contrast: the paper's own worked existence sketch implicitly needs `λ`
  small (its limit argument `lim_{λ→0+} g(α*) = −∞` is real), but the
  paper's *own* λ is pinned at `2n+3 ≥ 5` by its definition of κ. The
  informal region where `g(α*) < 0` is achievable (small λ, moderate q) is
  nowhere near the paper's actual operating point.

## Lean

None. Gate-before-prove; this is a numeric/analytic gate on the paper's own
displayed closed form, not requiring a Lean slice to be informative. A Lean
formalization (if ever pursued) would fix a rigorous upper bound proving
`g(α*)(λ,q) > 0` for all `λ ≥ 5, q > e^λ−1` — likely tractable via the same
convexity/monotonicity facts the paper itself proves (§5.1), turned against
its own conclusion.

## Not done, on purpose

- Did not invent a Chen-1999 beta kernel.
- Did not fall back to Kim ζ(5).
- Did not claim a closed-form proof of `sup_q λ*(q) < 5`; the numeric
  sampling across 300 orders of magnitude is the gate, consistent with this
  project's "numeric gate, escalate if it ever flips" discipline.

---

## False-positive control (2026-09-20)

Harness: `scripts/controls/break_control.py`. This gate has already issued one
verdict that had to be retracted (see the correction section above), which
makes it the campaign's highest false-positive risk.

### 1. Algebraic self-consistency (the Jana-Karmakar trap)

`g_alpha_star()`'s closed form against direct evaluation of `g` at `alpha*`:
worst relative disagreement **6.2e-60** over 21 `(lambda, q)` points. And
`alpha*` is confirmed to be the **minimiser**, not a maximiser -- `g` is convex
in `alpha` since `d²g/dalpha² = 1/(1+alpha) - 1/(1+q+alpha) > 0`. Had it been a
maximiser the gate would have been minimising the wrong quantity and the BREAK
would have been an artefact.

### 2. Discrimination: can this gate ever decline to fire?

Large-`q` behaviour is governed by `c(lambda) = 1 - lambda + log(e^lambda - 1)`;
`c < 0` means `g(alpha*) -> -infinity`, so admissible `q` genuinely exist and a
correct gate **must not** break. Dense scan, 3001 points over 60 decades:

| lambda | c(lambda) | min g(alpha*) | admissible q? |
|---|---|---|---|
| 0.1 | -1.3522 | -1.42e+59 | **yes** |
| 0.3 | -0.3502 | -1.23e+59 | **yes** |
| 0.45 | -0.0151 | -8.57e+57 | **yes** |
| 0.5 | +0.0672 | 1.64872 | no |
| 2.0 | +0.8546 | 7.38906 | no |
| **5, 7, 9, 11, 13** | ~+1 | 148.4 … 442414 | **no** |

The instrument reports admissible `q` exactly where they exist and none at the
paper's `lambda = 2n+3`, with the transition at `lambda* ~ 0.458`. A gate that
broke on every input would be worthless; this one discriminates.

### 3. The BREAK is an infimum, not a sample

This **upgrades** the "not done, on purpose" caveat below. For `lambda >= 0.5`
the minimum of `g(alpha*)` over the whole admissible domain `q > e^lambda - 1`
is attained at the domain boundary, where `g = g(0) = 1 + q = e^lambda`
exactly. The dense scan reproduces this to six figures:

`148.413 = e^5`, `1096.63 = e^7`, `8103.09 = e^9`, `59874.2 = e^11`,
`442414 = e^13`.

So "no admissible `q`" is not a claim about ten sampled points; it is
`inf_q g(alpha*) = e^lambda > 0`. The 300-orders-of-magnitude sampling was not
hiding a dip -- there is no dip to hide.

### 4. Convention sensitivity

`lambda` in `{3, 5, 7, 9, 11, 13, 15}`: no admissible `q` at any. The BREAK does
not depend on the `lambda := kappa + 2 = 2n + 3` convention.

**Control verdict: NO FALSE POSITIVE.** 2(d) stands.
