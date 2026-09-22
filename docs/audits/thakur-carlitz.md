# Audit note — Thakur's Carlitz–Wieferich degree conjecture (Track D#5)

**Claim artifact:** Thakur (2015): every `c`-Wieferich prime of `𝔽_q[T]`,
`q` an odd prime power, has degree divisible by the characteristic `p`.
**Refutation artifact:** D. Niedbala Giraudin, arXiv:2607.15305v2, Theorem 1.1.
**Campaign objects:** `docs/blueprint/thakur-carlitz.md`,
`scripts/gates/thakur_carlitz.py`,
`scripts/controls/thakur_break_control.py`,
`results/thakur_carlitz_gate_meta.json`,
`results/thakur_break_control_meta.json`,
`incoming/thakur-carlitz-2607.15305.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Every `c`-Wieferich prime of `𝔽_q[T]` (odd characteristic `p`) has `p \| deg P` |
| **Instance** | `q = 19³`, `𝔽_q = 𝔽_19[c]/(c³ − 8c² − 4c − 11)`, explicit quintic `P(T)` |
| **False instance** | `P` is an irreducible `c`-Wieferich prime of **degree 5**, and `19 ∤ 5` |

**Verdict: BREAK.** Attack type **F**.

## What was gated

Everything the witness needs, closed in a pure-Python finite-field engine
(`scripts/harness/finite_field.py`) — no Sage, no Magma, per the campaign stack:

- **Irreducibility** of `P` over `𝔽_{19³}`, via the standard distinct-degree
  test, plus the separate check that `P` has no linear factor.
- **`P | [5]`** — the Frobenius/Carlitz bracket closes at the claimed degree.
- **`M₅(θ) = 0`**, computed **two independent ways**: a nested Horner-style
  form and a raw sum form. Both vanish and are required to agree before the
  verdict issues.
- **Degree and divisibility.** `deg P` is now read off the transcribed
  polynomial (`len(POLY_P) − 1`) and `19 ∤ deg P` computed from it.

## Check that cannot fail — removed

Until 2026-09-21 these last two were `degree_is_5 = True` (a literal) and
`divisibility_fails = (5 % 19) != 0` (a constant), both sitting in the verdict
conjunction. Neither could ever have failed. They are now computed from
`POLY_P`, which turns them into a real transcription check: a mis-copied
witness of the wrong degree trips the gate instead of sliding past. The same
computed degree now also drives the Frobenius computation, so the two cannot
drift apart.

This was the second instance of the defect `es_cover`'s `odd_k_automatic_fold`
taught the campaign about. It is cheap to reintroduce and the fix is cheap;
what it costs is the reader's ability to tell which conjuncts carry
information.

## Provenance

Second Track D target whose corpus-doc text was **image-corrupted** and
unusable. Built by fetching and reading the real PDF.

## Control

`scripts/controls/thakur_break_control.py` — **NO FALSE POSITIVE.**

- **Positive control:** the Bamunoba–Bergström `(d, p) = (6, 3)` known
  `c`-Wieferich prime is fed to the same machinery and correctly reported
  `is_c_wieferich = True`. This is the important one — it shows the detector can
  say *yes* on a case it did not construct, at a different degree and a
  different characteristic.
- **Negative control:** 10 random irreducible quintics over `𝔽_19` yield **0**
  `c`-Wieferich hits, as expected. So the test is not an always-true detector.
- **Lemma 2.3** (no linear factor of `gcd([5], M₅)`) checked.
- Transcription against the pinned PDF.

Note the control's generic path handles `degree ≠ 5`, which is what made the
`(6,3)` positive control possible at all.

## Lean

None. Carlitz module theory and `𝔽_q[T]` Wieferich primes have no mathlib
coverage. Not attempted.

## Not done, on purpose

Did not search for further counterexamples, characterise which degrees admit
them, or verify the paper's Theorem 5.1 (degree 4 impossible) or its
closed-form/gcd claims. One explicit witness kills the universally quantified
lemma; the rest is the paper's business.
