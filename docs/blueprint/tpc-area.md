# Blueprint — TPC-AREA: Agama area method, Theorem 2.3

**Status:** BREAK, locked as `tpc_area`.
**Source:** T. Agama, arXiv:1707.03265v4 (8 Mar 2026; date line 10 Mar 2026).
**Local PDF:** `incoming/agama-twin-1707.03265v4.pdf`
**Gate:** `scripts/gates/tpc_area.py`
**Control:** `scripts/controls/tpc_area_break_control.py`
**Lead:** `corpus/Fragile-Route_Harvest_Dossier.md`, Hit 1. The dossier's
test-fire used a function outside the hypothesis. The locked witness does not.

## Quoted claim

Theorem 2.3 (PDF p. 6), quantifiers read as Theorem 3.1 uses them: one
constant depending on the shift and the function, not on `x`.

```text
Let f: N → R+. If sum_{n≤x} f(n)f(n+l_0) > 0, then there exists
C := C(l_0) > 0 fixed such that
  sum_{n≤x} f(n)f(n+l_0)
    ≥ 1/(C(l_0) x) * sum_{2≤n≤x} f(n) * sum_{m≤n-1} f(m).
```

The proof reaches this by writing every shift correlation as a constant times
the `l_0` correlation, taking `C(l_0)` to be the max of those constants, and
inverting. Theorem 3.1 invokes the same shape with `f = ϑ` and one `D(2)`
inside an `x → ∞` lower bound.

Corollary 2.2, the reindexing, is a true identity for the functions below.
It is not the break.

## Dossier witness, not used

`f = 1` on multiples of 3, `x = 12`, `l_0 = 1`. The double sum / quadratic
form is `Q = 6` and the shift-1 correlation is `S = 0`. Theorem 2.3 assumes
`S > 0`. A break recorded on this `f` would be vacuous.

## False instance

```text
f(n) = 1  if n ∈ {1, 2} or 3 | n,   else 0
l_0 = 1
```

For `x ≥ 2` the only shift-1 products are `f(1)f(2)` and `f(2)f(3)`, so
`S(x,1) = 2 > 0`. The quadratic form is exact:

```text
T = floor(x/3)
Q(x) = 1 + T(T+3)/2
Q(x)/(x S(x,1)) = Q(x)/(2x)  → ∞
```

At `x = 30`, `T = 10`, `Q = 66`, `x S = 60`. The inequality fails for
`C = 1`. At `x = 3000` the ratio is `83.58...`. No single finite `C(1)`
works for every `x`.

## Regime where the inequality holds

`f = 1`. Then `S(x,1) = x` and `Q(x) = x(x-1)/2`, so
`x S - Q = x(x+1)/2 > 0`. `C = 1` works at every `x`. The control checks
this with the gate's own sums.
