# Litt game formalization — workplan

**Target:** Janson–Nica–Segert, *The generalized Alice HH vs Bob HT problem*,
arXiv:2503.19035v1, source tarball SHA-256
`de954eead3b07c017c4e7ef206f9ba7812449973ea3816349df828fef0ef909f`.
Audit: standalone PASS (`docs/audits/litt-generalized-hh-ht.md`).

**Scope:** the combinatorial core, the de Bruijn block chain itself, and exact
fairness. This is correct-proof infrastructure, not a BREAK; the 25-gate
verdict lock stays untouched.

**Parked (explicitly not milestones):** the Edgeworth expansion for finite-state
Markov chains (Theorems 3.1/3.2) and the asymptotic formulas (1.5)–(1.8) with
O(n⁻¹) errors. Rationale: the analytic infrastructure does not exist in
mathlib (no Edgeworth anywhere; the CLT is i.i.d.-only; Perron–Frobenius is
definitions-only) — that is a separate research-formalization project.

## M1 — θ combinatorics (`Theta.lean`)

Alphabet `Fin q`, words `List (Fin q)`. Define the overlap set
Θ(U,V) = {1 ≤ k ≤ ℓ−1 : suffix of U of length k = prefix of V of length k}
and θ_UV = (∑_{k ∈ Θ(U,V)} q^k) / q^ℓ as a nonnegative rational.
Prove: basic properties, worked examples (θ_HH = 1/2, θ_HT = 0 for q = 2),
overlap characterization lemmas.
Close: sorry-free, `#eval` spot checks.

## M2 — Game model (`Game.lean`)

Occurrence count of a word as a (possibly overlapping) contiguous sublist of a
length-n sequence. Finite uniform space `Fin n → Fin q`; probabilities as
counting measure (`Finset` cardinalities over q^n — no measure theory).
Define Alice/Bob scores, the difference S_n, win/lose/tie events.
Lemmas: score under concatenation, letter-permutation symmetry.
Close: sorry-free.

## M3 — The chain itself (`Chain.lean`)

The de Bruijn block chain of §4 (states are length-ℓ blocks per the paper —
confirm the exact state space against the pinned `main.tex`; the audit
records a^ℓ self-loops):
- state type and transition kernel (append letter a ∈ `Fin q` w.p. 1/q, drop
  first letter);
- irreducibility by explicit path construction (spell the target block);
- aperiodicity via the constant-block self-loop;
- uniform stationary distribution (in-degree = out-degree = q);
- **bridge lemma:** chain partial sums of the score function = the substring
  occurrence counts of M2.

Infrastructure gap (honest): mathlib has no finite-Markov-chain
stationary-distribution theory, so the general lemmas (finite irreducible
chain → unique stationary distribution) get built here as reusable
infrastructure. Close: sorry-free.

## M4 — Exact fairness (`ExactFairness.lean`)

θ_AA = θ_BB → ∀ n, P(Alice wins) = P(Bob wins) (Basdevant et al., Remark 1.2).
Step 0: obtain Basdevant et al. [1] and transcribe the combinatorial
argument. Fallback: a chain-based route via M3 (the group-inverse identities
of M5 express θ through the chain's resolvent). Depends on M1+M2; M3
optional. Close: sorry-free.

## M5 (stretch) — Chain spectral identities

Prop P4: group inverse (I−P)^# = δ+θ−ℓq^(−ℓ); Lemma LW (ql2) resolvent
identity (I−P_{≠B})⁻¹_AA = 2+θ_AA+θ_BB−θ_AB−θ_BA; the variance formula
σ² = 2q^(−ℓ)(1+θ_AA−θ_AB−θ_BA+θ_BB) as finite matrix algebra. Formalizable
once M3's transition matrix is in place; feeds any future Tier-3 attempt.

## Standards

Repo conventions throughout: every milestone closes sorry-free with
`lake build` EXIT 0 (long builds go through the `full-build` CI workflow),
`#print axioms` audit at close. Commit per milestone on `selfhosted-runner`.

## Rough estimates

M1 1–2 wks; M2 ~2 wks; M3 3–6 wks (new infrastructure); M4 2–4 wks
(depends on the Basdevant transcription); M5 2–3 wks.
