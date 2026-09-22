# Audit note — COL-FP Kawasaki Collatz — VACUOUS

**Claim artifact:** harvest dossier II, Hit 1, “T is a contraction under `|·|`”.
**Paper:** Kawasaki, arXiv:2502.20642v2, Theorem 3.1 and Remark 3.1.
**Campaign objects:** `docs/blueprint/kawasaki-collatz.md`,
`scripts/gates/col_fp.py`, `results/col_fp_meta.json`,
`incoming/kawasaki-collatz-2502.20642v2.pdf`.
**Not in `EXPECTED_VERDICT`.**

## Bug report

| Field | Content |
|---|---|
| **Lemma the dossier named** | Banach contraction of `T` under `\|x-y\|` |
| **Instance** | odd pairs, ratio `3/2` |
| **False instance** | **Not a lemma of v2.** The PDF's Theorem 3.1 is a weighted pseudocontraction. Remark 3.1 says Theorems 2.2 and 2.3 do not apply. |

**Verdict: VACUOUS.** The `3/2` ratio is real and is the wrong object. Locking BREAK would repeat the Sárközy failure mode: a gate aimed at a paraphrase.

## What v2 actually does

v1's abstract said the fixed-point theorem shows Collatz. v2's abstract says only that the theorem is applied to Collatz, and the last page withdraws the application. Remark 3.1, verbatim in substance: for `λ ≡ 1`, `A = 1/2`, `B = 2`, `M = 2`, “the conditions of theorem 2.3 are not satisfied in other cases,” and “the conditions of theorem 2.2 are also not satisfied.”

The instrument agrees with the corrected reading of that remark. At `(1,3)`, Lemma 2.2 with `λ = 1` leaves a single live branch of Theorem 2.3(5), and that branch's ratio is `3/2`, which no `A ∈ (0,1)` accepts.

Theorem 3.1's inequality was checked on `{1,...,256}²`. No positive value. That sweep is not a proof, and it is not a refutation. The route, as printed in v2, ends in the author's own failed hypothesis check.
