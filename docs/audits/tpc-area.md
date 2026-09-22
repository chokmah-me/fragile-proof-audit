# Audit note — TPC-AREA Agama Theorem 2.3 — BREAK

**Claim artifact:** infinitude of twin primes, via the area method.
**Route killed:** Theorem 2.3's fixed constant, which Theorem 3.1 cites.
**Campaign objects:** `docs/blueprint/tpc-area.md`, `scripts/gates/tpc_area.py`,
`scripts/controls/tpc_area_break_control.py`, `results/tpc_area_gate_meta.json`,
`incoming/agama-twin-1707.03265v4.pdf`.
**Lock:** `tpc_area` → BREAK.

## Bug report

| Field | Content |
|---|---|
| **Lemma** | Theorem 2.3: one `C(l_0)`, independent of `x`, lower-bounds the shift-`l_0` correlation by `Q(x)/(C x)` whenever the correlation is positive |
| **Instance** | `f = 1` on `{1,2} ∪ 3ℕ`, `l_0 = 1`, correlation identically `2` |
| **False instance** | `x = 30`: `Q = 66 > 60 = x S`. The ratio `Q/(2x)` is unbounded |

**Verdict: BREAK.** This does not say there are finitely many twin primes.
It says this majorization does not supply a constant `D(2)` that can be sent
to infinity in `x`.

## Why the dossier witness was not locked

The harvest test-fire used `f = 1` on multiples of 3 at `x = 12`. That
quadratic form is `6` and the shift-1 correlation is `0`. The theorem assumes
the correlation is positive. The gate records those two numbers and does not
treat them as the counterexample. The repaired `f` adds the values `f(1) = f(2) = 1`,
which makes the correlation `2` and leaves the ratio unbounded.

Corollary 2.2, the double-sum reindexing, matches `Q` on this `f`, on the
dossier `f`, and on `f = 1`. The identity is not the dead step. The dead step
is the sentence that inverts a uniform multiple of one correlation into a
lower bound with `C` fixed.
