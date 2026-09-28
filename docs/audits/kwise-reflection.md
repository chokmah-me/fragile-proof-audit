# Audit note — k-wise independent bits reflection (2026-09-28)

**Claim artifact:** Roy Hermann, *Reflection of optimal supports for k-wise
independent bits*, arXiv:2609.25595 (submitted 2026-09-22).
**Harvest item:** `k-wise-independent-bits-reflection` (2026-09-28 scan, rank 6).
**Campaign objects:** `results/kwise_reflection_gate_meta.json`; working copies
at `~/workspace/kwise-audit/` (third-party ancillary downloads, not committed).

**Artifact pins (arXiv ancillary files, downloaded 2026-09-28):**
sha256 `062ab99260010e6ff89ffc07fb4ad9cd33afa60a67530c8aa4b98594f1a7f3cb`
`README.txt`, `2c065e31a7f9e5340fa12068d2c5aa885e7b45f98a78c980ca23ba047fa11ed3`
`reflection-certificate.json`,
`0d2ceb9bdd5796828634b5e2f245285487a3b0b24b68b978f3c1e2289cd97383`
`reflection-verification.json`,
`e550eaabb5b84826bb4603c70080bdd5ca3596e70210dc7645240c2c268e08de`
`verify_reflection.py`.

## Verdict: PASS (verify/audit)

The exact-arithmetic verifier reproduces PASS, its outputs are byte-identical
to the pinned JSONs, the checked identities are exactly the paper's equations,
and an independent computational path confirms the reflection identity.

## What was run

| Run | Result |
|---|---|
| `python3 verify_reflection.py` (stdlib only, exact `Fraction` arithmetic) | **PASS**, EXIT 0, 5.1 s — 1,390 basis cases, 8,510 exact reflection identities, 9,900 exact moment identities |
| Reproducibility: re-ran the script, diffed regenerated JSONs vs pinned | **byte-identical** (except `elapsed_seconds`) |
| Independent cross-check `cross_check.py` (direct Gaussian elimination of the moment system at random rational p, vs the script's Lagrange+binomial path) | 29 random cases PASS |
| Teeth control: same check with corrupted factor (s+2 instead of s+1) | correctly FAILS |

## What the verifier checks

- Exhaustive: every dual-feasible basis for 3 ≤ n ≤ 14, even 2 ≤ k ≤ min(8,n−1).
- 60 reproducible larger cases (seed 20260905), 20 ≤ n ≤ 150, even 2 ≤ k ≤ 16.
- For each basis: the reflection identity as a **polynomial identity in p**
  (coefficient-by-coefficient), all k+1 binomial moment identities
  coefficient-by-coefficient, and Q_I(t) ≥ 0 at every integer support point.
- The n=11, k=4 exceptional pair (p=1/3 → 2/3): one-sided signs from exact
  Taylor coefficients at the boundary; boundary weights match the paper's §4
  exactly: (110/243, 44/81, 1/243) at p=1/3 and (22/81, 55/81, 4/81) at p=2/3
  (confirmed in the regenerated JSON).
- Endpoint degeneracy: the identity is used only on (0,1); verified that a
  reflected weight goes negative at p=0, i.e. the restriction is material.

## Code-to-paper fidelity (decoded by hand)

The script's core check is
`(s+1)(1−p)·z_{n−1−s}(1−p) = (n−s)·p·w_s(p)` as polynomials
(`reflect_poly` = substitution p→1−p; `mul((1,−1),·)` = ×(1−p);
`mul((0,1),·)` = ×p). This is exactly the paper's equation (4),
w_{n−1−s}^{I*}(1−p) = p(n−s)/((1−p)(s+1))·w_s^I(p), cleared of denominators.
The moment check is exactly equation (1); the endpoint check is exactly (9).

## Hand-checked proof steps

- Lagrange reflection ℓ_{s*}^{J*}(x) = ℓ_s^J(n−1−x): substituting
  t* = n−1−t, the (−1)^k factors in numerator and denominator cancel. ✓
- Binomial reweighting E[(n−X)f(X)] = n(1−p)E[f(Y)] (eq. 7): elementary from
  (n−x)C(n,x) = n·C(n−1,x). ✓
- The positivity of the factor p(n−s)/((1−p)(s+1)) on (0,1) is immediate, so
  sign patterns reflect as claimed.

## Notes

- The paper discloses substantive AI generation (OpenAI GPT-6 Astra via Codex:
  problem selection, proof, exposition, verifier) and states no independent
  expert verification is claimed. This audit is a first independent check of
  the computational claims; it is not peer review of the general proof.
- Finite checks supplement the written all-n proof; the dual-feasible basis
  characterization ([1, Theorem 3.3], Berend–Ernst–Kontorovich–Kumar,
  J. Theoret. Probab. 39 (2026)) is inherited, as is the uniqueness argument
  (Lemma 2, standard LP duality).
- Scope: even k only, as stated; the paper explicitly does not claim the
  lexicographic-ordering part of BEKK Conjecture 5.10.

## Verdict lock

Standalone verify/audit PASS. The 25-gate verdict lock (17 BREAK / 8 PASS) is
untouched.
