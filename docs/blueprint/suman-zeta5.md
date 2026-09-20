# Blueprint — Phase 1(b): Suman ζ(5) refutation-object

**Status:** Phase 1(b) done — base-case kill landed  
**Sources:** arXiv:2407.07121v6 (claim; withdrawn later as v7) · arXiv:2411.16774 (Chen–He–He–Huang–Li–Tang–Wu–Xu–Yang–Yu)  
**Local PDFs:** `incoming/suman-2407.07121v6.pdf`, `incoming/chen-2411.16774.pdf`  
**Attack type:** B (base-case kill) + criterion mismatch

## Claim

ζ(5) and higher odd zetas irrational via Beukers-style integrals + Diophantine induction
(Suman, Theorem 1 / Theorem 2).

## Notation (Suman)

For `n ≥ 1`,

```text
d_n = lcm(1, 2, …, n)
```

hence `d_1 = 1`. Assume for contradiction `ζ(5) = a/b` with `a, b ∈ ℕ`, `gcd(a,b)=1`.

## Quoted equations (Suman v6)

After reducing the rational assumption to a linear Diophantine condition, Suman writes
(Eq. (47), the n≥b form used for the final contradiction):

```text
d_n a − 2 d_n b = −k_i b
  where d_n | k_i b,  1 ≤ k_i ≤ d_n − 1,  n ≥ b.     (47)
```

He then claims the following stronger family is impossible (Eq. (48) — the induction
target; **this is the load-bearing “no solutions” lemma**):

```text
d_n a − 2 d_n b = −k_i b
  where d_n | k_i b,  0 ≤ k_i ≤ d_n,  n ≥ 1.           (48)
```

(Suman v6, pp. 6–7; numbering as in the PDF.)

### Base case n = 1 (Suman’s own reduction)

With `d_1 = 1`, Eq. (48) becomes:

```text
a − 2b = −k_i b,   0 ≤ k_i ≤ 1,   1 | k_i b.
```

The two admissible `k_i` give:

| `k_i` | equation        | integer solutions      |
|------:|-----------------|------------------------|
| `0`   | `a − 2b = 0`    | `a = 2b` (any `b ≠ 0`) |
| `1`   | `a − 2b = −b`   | `a = b`  (any `b ≠ 0`) |

Suman dismisses these because they would force `ζ(5) ∈ {1,2}`, “absurd” since ζ(5) is
not an integer. That conflates solvability of (48) with arithmetic of ζ(5).

### Do not use the empty-range snippet

Claude’s harvest snippet used the **(47)** range `1 ≤ k ≤ d_1 − 1 = 0`, which is empty,
so `∃ … 1 ≤ k ∧ k ≤ 0 ∧ …` is uninhabited and cannot demonstrate solutions. The
induction is on **(48)** with `0 ≤ k_i ≤ d_n`. Gate and Lean must use that range.

## Chen et al. (arXiv:2411.16774) — kill + criterion

### Base-case kill (their §2)

Chen et al. restate the n=1 case and note that `a = 2b` and `a = b` are valid integer
solutions of Eq. (48). Solvability of (48) is logically independent of whether ζ(5) is
an integer; the induction base fails, so Theorem 1 fails.

### Proposition 3.1 (standard irrationality criterion) — quote

> Suppose that we can construct sequences of pairs of rational numbers `a_n`, `b_n` with:
>
> 1. There is `0 < ε < 1` such that `0 < |a_n α − b_n| < ε^n` for all sufficiently large `n`.
> 2. Let `d_n ∈ ℕ` be a common denominator of `a_n`, `b_n`: `d_n a_n ∈ ℤ`, `d_n b_n ∈ ℤ`,
>    and `d_n < D^n` for some real `D`.
> 3. `D ε < 1`.
>
> Then `α` is irrational.

(Chen et al., Prop. 3.1; proof by contradiction → integer in `(0,1)`.)

**Secondary gate (decay):** numerical checks show Suman’s `I_n` fails condition (3) of
Prop. 3.1 (`Dε ≮ 1`). Primary Phase 1(b) object is the base-case kill of (48); the
criterion module is shared scaffolding for Kim (1(c)).

## Load-bearing lemma chain

`I_n` representation → rational assumption → Eq. (47)/(48) has **no** integer solutions
in the stated range → induction on n → contradiction → ζ(5) irrational.

**Break point:** Eq. (48) at `n = 1` **does** have solutions.

## Formalizable slice

1. `IrrationalityCriterion` — Chen Prop. 3.1 (Apéry-shaped).
2. `SumanZeta5/BaseCase` — explicit witnesses for (48) at `n=1`; negate “no solutions.”
3. Do **not** claim ζ(5) is rational (gates refute routes, not theorems).

## Numeric gate

`scripts/gates/suman_eq48.py`

- Enumerate integer solutions of (48) at `n=1` under `0 ≤ k ≤ d_1`.
- Expect families `a = 2b` (`k=0`) and `a = b` (`k=1`).
- Confirm `ζ(5) ≈ 1.0369277551…` ⇒ `a = b` would require ζ(5)=1, off by ≈0.037 —
  Suman’s “absurd” dismissal does not cancel the algebraic solutions.
- Meta: `results/suman_gate_meta.json`; registered in `scripts/gates/check.py`.

## Confirm / break

Break (expected): solutions exist under Suman’s own (48) range.  
Abort: if faithful transcription finds no solutions → re-read both PDFs before Lean.

## Fill checklist

- [x] Quoted Eq. (48) and k-range from Suman (`0 ≤ k_i ≤ d_n`; `d_1 = 1`)
- [x] Quoted Prop. 3.1 from Chen et al.
- [x] Python gate witnesses (`results/suman_gate_meta.json`, verdict BREAK)
- [x] Lean witnesses + criterion (`SumanZeta5/BaseCase`, `IrrationalityCriterion`)
- [x] Audit note under `docs/audits/suman-zeta5.md`
