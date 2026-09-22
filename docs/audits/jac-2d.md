# Audit note — JAC-2D (Su's claimed 2D Jacobian conjecture proof)

**Claim artifact:** Yucai Su, arXiv:1603.01867v43.
**Campaign objects:** `docs/blueprint/jac-2d.md`, `scripts/gates/jac_2d.py`,
`scripts/controls/jac_2d_break_control.py`, `results/jac_2d_gate_meta.json`,
`incoming/jac2d-su-1603.01867v43.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Remark 2.7 (degree-bound preservation under real powers of a bounded-degree formal series) and Lemma 2.8 / eq. (2.41) (explicit low-order coefficient formulas in the \(G=\sum c_\alpha F^\alpha\) expansion) |
| **Instance** | Two independent genuine Keller pairs (\(m{=}4,n{=}2\) and \(m{=}6,n{=}3\)), plus abstract generic-coefficient replay of Remark 2.7 at two rational exponents |
| **False instance** | **None.** All four clauses of (2.41) hold exactly on both instances; both parts of Remark 2.7 hold to the tested order |

**Verdict: PASS (escalate)** on the Type-D/E route. **Type G not attempted.**

## What was gated

- Remark 2.7 parts (i) and (ii), replayed abstractly with tight-degree
  generic symbolic coefficients (so the bound is exercised, not vacuous).
- Lemma 2.8 / eq. (2.41) (i)-(iv), replayed against two from-scratch
  constructed Keller pairs whose invertibility (hence constant-Jacobian
  hypothesis) is elementary and unconditional — no dependence on the very
  conjecture the paper is trying to prove.
- A provenance check against the pinned PDF that corrects the harvest
  dossier's characterization of Remark 2.7 as deferring a proof to an
  unshown symbolic computation (see blueprint for the exact quote).

## Discrimination control

Perturbing the Keller pair by one monomial breaks the constant-Jacobian
hypothesis and breaks three of the four (2.41) clauses on the same code
path (`c_{-1}=0` happens to survive this particular perturbation — recorded,
not hidden). Confirms the gate is not a check-that-cannot-fail.

## Not done, on purpose

- Did not attempt to replay the paper's later machinery (Lemma 2.17's
  root-of-unity argument at (2.72)/(2.103), the height/estimate
  Propositions around (2.108), or the Procesi-authored appendix proof of
  Theorem 1.3). This session's earliest-checkable-skeleton pin covers only
  (2.37)-(2.49); the dossier's own risk note flags the extraction cost
  beyond this point as the highest in the corpus.
- Did not attempt Type G (whether the overall induction closes to a
  contradiction). A PASS on the coefficient skeleton says nothing about
  that.
- Did not search for a published rebuttal; none was found during this
  session's paper read. The dossier's `contested` status and Fr=8 fragility
  score (43 versions, no acceptance) are independent of this gate.

## Lean

None this landing. PASS -> escalate; also mathlib has no Keller-map /
Jacobian-conjecture coverage to scaffold against.
