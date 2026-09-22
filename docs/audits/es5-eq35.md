# Audit note — ES-5 Ghermoul equation (35) — BREAK

**Claim artifact:** Theorem 2.1(3) for `u ≡ 2 (mod 7)`.
**Paper:** Ghermoul, arXiv:2508.07367v1, equation (35), page 10.
**Campaign objects:** `docs/blueprint/es5-eq35.md`, `scripts/gates/es5_eq35.py`,
`scripts/controls/es5_eq35_break_control.py`, `results/es5_eq35_gate_meta.json`,
`incoming/es5-2508.07367.pdf`.
**Lock:** `es5_eq35` → BREAK.

## Bug report

| Field | Content |
|---|---|
| **Lemma** | Setting `y = 1` in `p4` produces equation (35) |
| **Instance** | `x = 0`, so `q = 24` and `a = 121` |
| **False instance** | The printed line says `5/121 = 5/61` |

**Verdict: BREAK.** The right-hand side of (35) is the right-hand side of (34).
It sums to `5/61`, the value of `5/a` for `q = 12`, not for `q = 24`.

## What this does not say

`p4` at `y = 1` is an identity: the same `q = 12(7x+2)` has a correct
three-term decomposition in the display immediately above (35). The residue
class is not empty. The proof's last line for that class is.

`q ≡ 0 (mod 252)` is the author's Conjecture 2. Theorem 2.1 says it does not
address that case. No lock is claimed about it.
