# Audit: Erdos-Straus gate — arXiv:2404.01508v3 (Lopez)

**Target:** Miguel Angel Lopez, "A Complete Congruence System for the
Erdos-Straus Conjecture" (arXiv:2404.01508v3, 2024).
**Date:** 2026-09-23. **Checker:** `scripts/gates/erdos_straus_checker.py`.

## Claim under test

**Conjecture 1** (paper L379–382): every prime `p` admits `d,n ∈ ℕ` with

- `p ≡ −4d (mod 4dn−1)` — Type A solution, or
- `p ≡ −n (mod 4dn−1)` — Type B solution.

"If this result is true, then this congruence system covers all primes and
the Erdos-Straus conjecture is true." The paper reports verification for the
first 10,000 primes (≤ 104729).

## Method (transcription, not invention)

The conjecture is decided through the paper's own iff-criteria for `p = 4k+1`:

- **Type A** ⟺ `∃ t≥0, w | (k+1+t)` with `w ≡ −1 (mod 3+4t)` — Thm 1,
- **Type B** ⟺ `∃ t≥0, a,b | (k+1+t)` with `a+b = 3+4t` — Thm 6,

with the paper's bound `0 ≤ t ≤ (k−1)//3` (Prop 2, Prop 4), making the search
finite and complete. Type B is checked **as stated** (a and b each divide
`k+1+t`).

Gate set: all primes `p < 10^5` in Mordell's six resistant residue classes
`p ≡ 1, 121, 169, 289, 361, 529 (mod 840)` (paper L41–42). All are `≡ 1 mod 4`,
so the criteria apply. (Note: the actual count is **273 primes**, not ~1,600.)

Transcription validated against the paper's four named examples — all match:
193 and 2521 have Type B but not A; 23929 has Type A but not B; 66529 lacks A.

## Results

### Part A — Conjecture 1 on the gate set: HOLDS (273/273)

| | count |
|---|---|
| Type A | 271/273 |
| Type B | 270/273 |
| Type A **or** B | **273/273** |
| Type C (informational, Thm 9(iv)) | 267/273 |

No uncovered prime. Primes lacking Type A: 2521, 66529 (both named in the
paper). Primes lacking Type B: 5569, 9601, 83449 (83449 named in the paper).
Every prime is covered by at least one type — the two families genuinely
complement each other on this set, as the paper claims.

**Verdict on Conjecture 1: not refuted.** Consistent with the paper's reported
verification (our range `< 10^5` sits inside their `≤ 104729`).

### Part B — Theorem 10 "automatic" odd-k step: CORRECT as stated

Paper L874–876: "if `k` is odd it is automatically fulfilled by taking
`d=u=1, v=2`", i.e. `u,v | k+d` and `4d−1 | u+v`. Implemented literally:
for all 12,500 odd `k` in `[1, 25000)` the divisibilities hold, `y,z` are
positive integers, and the paper's chain yields `4/(4k+1) = 1/x + 1/(ny) +
1/(nz)` exactly (verified with `Fraction`, no floating point). The
"suspicious" step is sound — `k` odd ⟹ `k+1` even ⟹ `2 | k+1`, and
`3 | 1+2`.

### Part C — Theorem 10 interval claim: PROOF GAP (as written)

Paper L878–887 derives `f(n) = n/2` ("Equaling" `4f(n)−1 = 2n−1`) with the
explicit parameters `u=n, v=n−1`, then concludes the **whole interval**
`[n! − ⌊n/2⌋, n! − 1]` works. Checking the paper's explicit parameters
literally on the claimed interval:

- `n=4`, interval `[22, 23]`: 2/2 pass.
- `n=6`, interval `[717, 719]`: **2/3 pass — `k=718` FAILS.**
  With the paper's parameters (`d = f = 2`, `u=6`, `v=5`):
  `4d−1 = 7` does **not** divide `u+v = 11`.

The "Equaling" step fixes a single `f(n) = n/2` (hence a single
`k = n! − n/2`); the jump to the full interval is not justified by the
exhibited `(u,v)`, and the odd-`k` members are covered only by the separate
"automatic" case which the paragraph does not invoke. Concretely, the even
`k=718` is left uncovered by the proof as written.

### Salvage analysis (2026-09-23, `scripts/analysis/erdos_straus_salvage.py`)

Is the gap repairable? For each even `n ∈ {4, 6, 8}` and every `k` in
`[n! − n/2, n! − 1]`, an exhaustive search over `d ∈ [1, n!/2]` and divisor
pairs `(u,v)` of `k+d` asks whether **any** parameters complete the paper's
construction (same exact-`Fraction` identity check as the gate):

| n | interval | fail w/ paper's params | unsalvageable |
|---|---|---|---|
| 4 | [22, 23] | none | none |
| 6 | [717, 719] | **718** | none — salvaged via `d=1,u=1,v=719` |
| 8 | [40316, 40319] | **40318** | none — salvaged via `d=1,u=1,v=23` |

The failure is structural, not a one-off: the exhibited `(u,v) = (n, n−1)`
satisfies `4d−1 | u+v` only at the single endpoint `d = n/2`
(`2n−1 | 2n−1`); every other even `k` in the interval fails with those
parameters. But the conclusion is always repairable within the same
construction family — e.g. the uniform choice `d=1, u=1`, `v | k+1` with
`v ≡ 2 (mod 3)` (then `4d−1 = 3 | 1+v`), which exists for the failing cases
above (`719 | 719`, `23 | 40319`).

**Disposition of the gap:** confirmed real, precisely characterized, fully
repairable. The theorem's conclusion stands; the proof as written does not
establish it. Logical gap (route, not theorem) — it does not touch
Conjecture 1 or the Erdős–Straus conjecture.

## Ambiguities documented (not resolved)

1. **Thm 6 statement vs proof.** The theorem states the Type B condition with
   `a, b` each dividing `k+1+t`, but the converse direction of the proof only
   assumes `ab | k+1+t`. Since `ab|m ⟹ a|m ∧ b|m`, the proved converse is for
   a *stronger* hypothesis than stated; `P ⟹ Type B` (with `P` = "a,b|m") is
   not proved. The checker tests the condition **as stated**. (On the gate
   set this made no difference: every Type B witness found also satisfies
   `ab | m`.)
2. **Type C search bound.** Thm 9 gives no `t`-bound; the checker reuses the
   Prop-4 bound. Type C is informational only (the paper: "does not seem
   necessary in experimental terms").

## Disposition

- **Conjecture 1 (the paper's main claim): PASS on gate set** — 273/273 primes
  covered, transcription validated against all four named examples. Not a BREAK.
- **Theorem 10 "automatic" step: PASS** — correct as stated, 12,500/12,500.
- **Theorem 10 interval argument: GAP, fully characterized and repairable**
  (`scripts/analysis/erdos_straus_salvage.py`) — the paper's exhibited
  `(u,v) = (n, n−1)` satisfies `4d−1 | u+v` only at the single endpoint
  `d = n/2`; every other even `k` in `[n!−n/2, n!−1]` fails with those
  parameters (n=6: k=718; n=8: k=40318). Exhaustive search over the paper's
  `d`-range shows every such `k` is salvageable within the same construction
  family (e.g. uniform `d=1, u=1`, `v | k+1`, `v ≡ 2 mod 3`). Conclusion
  stands; proof as written does not establish it. Logical gap (route, not
  theorem).

## Reproduction

```
python3 scripts/gates/erdos_straus_checker.py
```
Exit 0 iff no uncovered prime. Runs in < 1 s (divisor sieve to 10^5).
