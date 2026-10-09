# Audit note — OpenAI "Algebraicity of Weil classes on split abelian eightfolds": sign-convention BREAK (calibration)

**Claim artifact:** OpenAI, "Algebraicity of Weil classes on split abelian
eightfolds" (2026-09-18), pre-withdrawal PDF pinned at openai/math revision
`adc7f1241b42e322a6451854ab7e4b4c146bf78a`, SHA-256
`7318472a98297321fc61ab89aff328b72c9c8371ab90515e97bec2adb7223787`.
Withdrawn 2026-10-06; withdrawal notice at
`preprints/Algebraicity-of-Weil-classes-on-split-abelian-eightfolds-September-18-2026/README.md`
(openai/math @ `fd4aeeb2e`, `history.md`).
**Campaign objects:** `scripts/gates/oai_weil_sign.py`,
`scripts/controls/oai_weil_sign_control.py`,
`results/oai_weil_sign_gate_meta.json`,
`results/oai_weil_sign_control_meta.json`,
`incoming/oai-weil-classes-prewithdrawal.pdf`.
**Cited authority for trace signs:** Ekholm–Eliashberg–Murphy–Smith,
"Constructing exact Lagrangian immersions with few double points",
arXiv:1303.0588v2 (the paper's reference [6]), Lemma 3.4 proof.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run date
`2026-10-08` · the verdict rests on pinned artifacts, independent of the
agent transcript.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Lemma 3.6: each inserted reverse stabilization trace has sign (−1)^k, so at k = 4 each contributes +1 and m traces cancel I(f₁) = −m, giving total signed double count 0 |
| **Instance** | Source dimension 8 (k = 4); m = −I(f₁) > 0 reverse traces inserted "from the m-fold stabilization at the innermost end to ϕ₀ outward" |
| **False instance** | The inserted traces run stabilized → destabilized (destabilization direction = [6]'s G₃ trace, sign (−1)^{k−1} = −1 at k = 4), but the paper assigns them [6]'s G₂ sign (−1)^k = +1 (lift of the *inverse* stabilization homotopy — same direction, different homotopy, opposite sign). Replayed count: I_new = −m − m = −2m ≠ 0 |

**Verdict: BREAK.** The paper's own stated Eliashberg–Murphy hypothesis ("its
signed double count is zero") is not met on the replayed arithmetic, so the
subsequent oriented-surgery and embedded-brane construction is unsupported.

## What was gated

A sign-convention replay, not a geometry re-derivation:

- Pinned the paper's trace-direction description (destabilization direction),
  its sign formula ("the reverse trace has sign (−1)^k", (3.6): +1 at k = 4),
  its count (I(f₁) = −m, "the total signed double count is I(f₁) + m = 0"),
  and its explicit Eliashberg–Murphy hypothesis ("its signed double count is
  zero").
- Pinned [6]'s sign table from the Lemma 3.4 proof: G₁ (stabilization)
  (−1)^{k−1}, G₂ (inverse stabilization) (−1)^k, G₃ (destabilization)
  (−1)^{k−1}, G₄ (inverse destabilization) (−1)^k.
- Direction-matched the paper's inserted traces to G₃ (not G₂), compared
  signs (−1)^k claimed vs (−1)^{k−1} correct), replayed I_new = −2m ≠ 0,
  checked the E-M hypothesis: fails.

The deep symplectic geometry (why G₃ and G₂ differ — the opposite source
orientations of the two standard-cusp branches) is attested by [6]; the gate
checks the paper's formula against its own citation, which is the checkable
step. The gate was constructed without using the withdrawal notice.

## Discrimination control

`scripts/controls/oai_weil_sign_control.py` — **NO FALSE POSITIVE**:

- Same direction-match procedure on the paper's *outward* trace leg: paper
  claims (−1)^{k−1}, direction is stabilization → [6] G₁ = (−1)^{k−1}:
  MATCH, the gate does not fire there. The gate fires only on the
  reverse/destabilization leg.
- The paper's internal arithmetic under its claimed signs is consistent
  (−m + m·1 = 0), so the BREAK comes from the sign-vs-citation mismatch,
  not from misreading the paper's arithmetic.

## Not done, on purpose

- Did not re-derive the cusp-branch orientation signs from first principles;
  [6]'s sign table is taken as the cited authority, per paper-first gating
  (the paper itself cites [6] for these signs).
- Did not gate the two dependent withdrawals (Kuga–Satake for K3, rational
  Hodge for products of K3): their notices state they inherit this gap, so a
  separate gate would test nothing new.
- Did not assess whether the *theorem statements* are true; per standing
  doctrine the withdrawal itself "does not assert that the mathematical
  statement is false." Gates refute routes, not theorems.

## Calibration status

**TRUE-POSITIVE calibration target — NOT on the 32-gate verdict lock.**
The manuscript was withdrawn for exactly this sign error after the gate was
constructed; the gate's replayed count (−2m) matches the withdrawal notice's
corrected count exactly. None of the three withdrawn manuscripts had a Lean
formalization (checked against `lean/formalization.yaml` @ `fd4aeeb2e`) —
all three were in the unconfirmed ~58% of the corpus.
