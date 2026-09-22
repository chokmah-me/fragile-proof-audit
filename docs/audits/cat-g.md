# Audit note — CAT-G polynomial claim between (2.3) and (2.4) — BREAK

**Claim artifact:** the sentence after (2.3) that calls a rational function a
polynomial of degree at most `2B-3`.
**Paper:** Zhi-Wei Sun, arXiv:2609.04176v1, Theorem 2.1, page 4.
**Not:** Zenodo 22830611, which is a different manuscript.
**Campaign objects:** `docs/blueprint/cat-g.md`, `scripts/gates/cat_g.py`,
`scripts/controls/cat_g_break_control.py`, `results/cat_g_gate_meta.json`,
`incoming/sun-catalan-2609.04176.pdf`.
**Lock:** `cat_g` → BREAK.

## Bug report

| Field | Content |
|---|---|
| **Lemma** | For `j ≤ S < B`, the weighted sum under `Pi_i` is a polynomial of degree ≤ `2B-3`, so the forward difference of order `a+2B` vanishes |
| **Instance** | `B = 2`, `S = 1`, `j = 1`, `a = 0` |
| **False instance** | The order-4 difference equals `3596288/99225` |

**Verdict: BREAK.** `Pi_i = prod_{h=1}^{B} (2(h+i)+1)^2` does not contain
`(2i+1)^2`. The `k = 0` term of the sum written between (2.3) and (2.4) has
that denominator. The same passage then prints `T_{i+1}` where (2.3) has
`T_i`, and `T_0 > 8/9 > T_1`.

## What this does not say

The tail recurrence (1.4) is true. It is not the verdict.

`K(-3/2) = 0` in (2.16) is not the witness. For the polynomial `D` in (2.9)
at `S = 1`, `B = 2`, `λ_1 = 1`, one has `D(-3/2) = 0`. The integer claim
(2.13) does fail (`K(0) ≠ 0` for that same `D`), and it fails later than the
polynomial sentence.

Nothing here says whether Catalan's constant is irrational. Section 9 of the
paper, and the separate numerical note on Zenodo 22830611, are not this gate.
