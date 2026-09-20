# Audit note — Suman ζ(5) (Phase 1(b))

**Claim artifact:** Shekhar Suman, *A note on the Irrationality of ζ(5) and higher odd zeta values*, arXiv:2407.07121v6 (withdrawn as v7).  
**Refutation:** Chen–He–He–Huang–Li–Tang–Wu–Xu–Yang–Yu, arXiv:2411.16774.  
**Campaign objects:** `docs/blueprint/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean`, `FragileProofAudit/IrrationalityCriterion.lean`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Eq. (48) has no integer solutions (induction base for Theorem 1) |
| **Instance** | `n = 1`, `d_1 = lcm(1) = 1`, constraints `0 ≤ k ≤ d_1` and `d_1 ∣ k b` |
| **False instance** | Solutions `(a,b,k) = (2,1,0)` (`a = 2b`) and `(1,1,1)` (`a = b`) |

Suman dismisses these because they would force `ζ(5) ∈ {1,2}`. Solvability of Eq. (48) is independent of whether ζ(5) is an integer; the induction never starts.

## What was gated

Python gate (`results/suman_gate_meta.json`):

- `d_1 = 1`
- both families found under **Eq. (48)** range `0 ≤ k ≤ d_n`
- documented that the Eq. (47)-style range `1 ≤ k ≤ d_1 − 1` is **empty** (Claude harvest trap)
- `ζ(5) ≈ 1.0369277551…`, gap from 1 ≈ 0.0369 (Suman’s “absurd” values are numerically false, but that is not needed for the algebraic kill)

## What Lean proves

- `FragileProofAudit.SumanZeta5.BaseCase.not_no_solutions` — negation of “no solutions at n=1”
- Explicit witnesses and parametric families
- `FragileProofAudit.IrrationalityCriterion.irrational_of_integer_forms_tendsto_zero` — classical Apéry/Chen kernel criterion (shared with Kim 1(c))

**Not claimed:** ζ(5) ∈ ℚ. Gates refute the route, not the theorem.

## Secondary (not primary object)

Chen et al. also note Suman’s `I_n` fails Prop. 3.1 condition (3) (`Dε ≮ 1`). Deferred; base-case kill is sufficient for Phase 1(b).

---

## False-positive control (2026-09-20)

Harness: `scripts/controls/break_control.py`.

A BREAK is the only artefact this campaign could ever send to an author, so the
question is the inverse of the PASS audit: **could this gate fire on a correct
paper?** Jana-Karmakar is the precedent -- an omitted Pochhammer convention
produced 66 false mismatches against a clean paper.

### The machinery alone has no discriminating power

`solutions_at_n` *derives* `a` from `(b, k)` as `a = 2b - kb/d` whenever
`d | kb`, so a witness exists at every `n` provided `k = 0` is in range:

| n | d_n | witnesses `0 <= k <= d` | witnesses `1 <= k <= d-1` |
|---|---|---|---|
| 1 | 1 | 10 | **0** |
| 2 | 2 | 12 | 2 |
| 3 | 6 | 14 | 4 |
| 4 | 12 | 16 | 6 |
| 5-8 | 60-840 | 20 | 10 |

The search never declines to fire. The **entire** verdict therefore rests on a
single transcription fact -- whether `k = 0` is admissible in (48) -- which is
now checked three independent ways.

### 1. Verbatim from the pinned PDF

- (47) is printed with the narrower window `1 <= k_i <= d_n - 1, n >= b`.
- (48) is printed as
  `d_n a - 2 d_n b = -k_i b where d_n | k_i b, 0 <= k_i <= d_n, n >= 1`.

So `k = 0` is the *paper's own* endpoint, not the gate's choice. The campaign's
earlier rejection of the `1 <= k <= d_1 - 1` snippet (see WORKPLAN "Do not
reopen") was correct.

### 2. The induction hypothesis is purely algebraic

(49) -- the induction hypothesis -- is printed as
`d_n a - 2 d_n b = -k_i b where d_n | k_i b, 0 <= k_i <= d_n, n >= 1`, with
**no mention of ζ(5)**. The base case must therefore discharge an *algebraic*
unsolvability claim. What the paper's base case actually does is derive exactly
`a = 2b` and `a = b` and then reject them because they force ζ(5) ∈ {1, 2}:

> *"So we have a − 2b = 0 or − b. But since ζ(5) = a/b, so we have ζ(5) = 1 or 2
> which is absurd because it is well known that ζ(5) is not an integer."*

That is an arithmetic argument discharging an algebraic obligation, and the
induction step (50)-(57) then consumes the algebraic form. The gate refutes
what the paper asserts, not a strawman.

### 3. Independent corroboration

Chen et al. (arXiv:2411.16774v3, ten authors) reach the identical conclusion:

> *"Here lies the critical error: the claim that equation [6, Eq. (48)] has no
> integer solutions is logically independent of whether ζ(5) is an integer or
> not... The existence of integer solutions for [6, Eq. (48)] at n = 1 directly
> invalidates the induction base case."*

All three textual markers verified mechanically against the pinned PDF.

**Control verdict: NO FALSE POSITIVE.** 1(b) stands.

### One reading note

The gate's `zeta5_gap()` check (|ζ(5) − 1| > 0.03) computes the very fact the
paper uses to escape. It documents the conflation; it is not evidence *for* the
BREAK, and the `ok` acceptance criterion should be read that way.
