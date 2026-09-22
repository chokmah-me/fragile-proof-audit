# Blueprint — COL-FP: Kawasaki accelerated Collatz map (VACUOUS)

**Status:** closed as VACUOUS. No `EXPECTED_VERDICT` row.
**Source:** T. Kawasaki, arXiv:2502.20642v2 (7 Mar 2025; PDF date line 10 Mar 2025).
**Local PDF:** `incoming/kawasaki-collatz-2502.20642v2.pdf`
**Instrument:** `scripts/gates/col_fp.py` (not registered in `check.py`)
**Lead:** `corpus/Fragile-Route_Harvest_Dossier_II.md`, Hit 1. The dossier cites v1.

## What v2 defines

Page 7. `N = {1, 2, 3, ...}`, `d(x,y) = |x-y|`, and

```text
T(1) = 1
T(x) = x/2                  if x is even
T(x) = (3x+1)/2            if x is odd and x >= 3
```

The odd branch is `C^2`, using that `3x+1` is even for odd `x`. The text says that a proof of `T^{t(x)}(x) = 1` for every `x` would yield Collatz. It does not supply that proof.

## What the dossier attacked

Uniform Banach contraction: `|T x - T y| <= c |x-y|` with `c < 1`. On odd pairs this is false, and the ratio is exact:

```text
|T(2k+1) - T(2l+1)| = 3|k-l| = (3/2) |x-y|
```

Witnesses `(3,5), (5,7), (7,9), (3,9), (9,11)` all give `3/2`. v2 never states this contraction. The load-bearing definition (p. 1) is the weighted inequality

```text
α d(Tx,Ty)^2 + β d(x,Ty)^2 + γ d(Tx,y)^2 + δ d(x,y)^2
  + ε d(x,Tx)^2 + ζ d(y,Ty)^2  <=  0
```

with the nine-case tables of Theorem 3.1 (pp. 7–8), including `β0, δ0, ε0, ζ0` for both arguments odd and at least 3.

## What was recomputed

`scripts/gates/col_fp.py`:

- The five dossier pairs have ratio `3/2`. The same pairs under `x ↦ ⌊x/2⌋` have ratio at most `1/2`. A contraction checker can decline; the dossier object is not that checker.
- Theorem 3.1's weighted sum is `<= 0` on all `256²` pairs in `{1,...,256}`. Maximum attained is `0`. This is a finite sweep, not a proof of Theorem 3.1.
- Lemma 2.2 at `λ ≡ 1` sends each coefficient to its swapped partner. Theorem 2.3(5) at `(x,y) = (1,3)` has first-branch denominator `-1` and swapped-branch ratio `3/2`. No `A ∈ (0,1)` works for this `λ`. Remark 3.1 (p. 12) already says the hypotheses of Theorems 2.2 and 2.3 are not satisfied. One slip: the remark substitutes `α_λ(x,y) = α(x,y)`, while Lemma 2.2 at `λ = 1` says `α_λ(x,y) = α(y,x)`. The conclusion of the remark survives the corrected substitution on `(1,3)`.

## Disposition

Do not lock a BREAK. Reopen only if a later version claims `|Tx-Ty| <= c|x-y|` with `c < 1`, or claims some `λ` for which Theorem 2.2 or 2.3 applies to this `T`. Collatz-as-a-monitor stays closed (`docs/WORKPLAN.md`).
