# Audit note — generalized Alice HH vs Bob HT (Janson–Nica–Segert) (2026-10-01)

**Claim artifact:** Svante Janson, Mihai Nica, Simon Segert, *The generalized
Alice HH vs Bob HT problem*, arXiv:2503.19035v1 (24 March 2025). Generalizes
Daniel Litt's viral 2024 coin-flip game (Alice scores per HH, Bob per HT in
*n* fair flips). Main result, Theorem 1.1: for distinct equal-length words
*A*, *B* over a *q*-letter alphabet, with the prefix/suffix self-overlap
index θ and asymptotic variance σ² from (4.10)/(4.19),

- P(Alice)−P(Bob) = (θ_BB−θ_AA)/√(2πσ²)·n^(−1/2) + O(n^(−1)) (1.8),
- individual win probabilities carry a −1 tie-split term (1.5)/(1.6),
- P(tie) = 1/√(2πσ²)·n^(−1/2) + O(n^(−1)) (1.7),
- exact fairness for every *n* iff θ_AA = θ_BB (Remark 1.2, Basdevant et al.).

Proof route: a self-proved Edgeworth expansion for finite-state Markov
chains (Theorems 3.1/3.2 — the authors could not find a reference), applied
to the de Bruijn block chain, with σ²>0 and the lattice condition (em4)
verified for the game (Theorems Tgss0, Tem4) and the three degenerate cases
handled explicitly (Examples Egss2, EH-T, EHH-TT).
**Campaign objects:** `results/litt_hh_ht_gate_meta.json`;
`scripts/gates/litt_game.py` (exact de Bruijn DP + all lanes, self-tested).

**Source pin:** arXiv e-print tarball for 2503.19035v1, SHA-256
`de954eead3b07c017c4e7ef206f9ba7812449973ea3816349df828fef0ef909f`
(fetched 2026-10-01; single-version paper, v1 == current tarball). Full
`main.tex` (4,563 lines) read for the proof-scrutiny lane — not the HTML
rendering alone.

## Verdict: PASS (verify/audit)

## What was run

| Lane | Result |
|---|---|
| Asymptotic replay of (1.5)–(1.8), 5 (q,A,B) cases incl. q=3, ℓ=4, exact DP to n=3000 | **all ratios → 1** (worst \|r−1\| = 1.1e−3 at n=3000; errors decay ~n^(−1/2) as claimed) |
| Litt original: (1.1) P(B)−P(A) ~ 1/(2√(πn)) | ratio **0.99998** at n=3000 |
| (1.2) individual 3/(4√(πn)), 1/(4√(πn)) terms | ratios 1.00003, 1.00015 |
| Exact fairness θ_AA=θ_BB (4 pairs, incl. q=3) | **exact** integer-count equality at n=10; \|Δ\|<4e−16 at n=3000 |
| Egss2 (A=HTT,B=TTH, σ²=0): symmetry + tie behavior | P(A)=P(B) to 1e−16 ✓; P(tie)=0.625 **constant** — (1.7) fails exactly as claimed |
| EH-T (A=H,B=T): (1.7) failure mode | P(tie)=0 for odd n ✓; even n: C(n,n/2)/2^n = **2.00×** the (1.7) value ✓ |
| Prop P4: group inverse (I−P_ℓ)^# = δ+θ−ℓq^(−ℓ) | max err 2.2e−16 (3 instances) |
| Lemma LW (ql2): (I−P_{≠B})⁻¹_AA = 2+θ_AA+θ_BB−θ_AB−θ_BA | err < 1e−12 (3 instances) |
| Teeth control: asymptotic lane re-run with constants ×1.1 | **correctly FAILS** (ratio → 1/1.1) |

## Proof scrutiny (hand-read, highest weight)

The full proof chain was read in the pinned source and the load-bearing
steps re-derived:

- **Theorem 3.1 (Edgeworth):** standard Nagaev perturbation argument, done
  carefully — Lemma LK (uniform spectral-radius bound), L2 (dominant
  eigenvalue + the l2b refinement via maximum principle), L5 (ρ(P(e^{it}))<1
  for t≠0 from (em4) — the key step, correct), reduction to Esseen's proof.
  Cumulant formulas (t1a)–(t1f) via Haviv; the game application re-derives
  σ² and γ_3 independently (gss9)/(gk3) — verified by hand algebra.
- **σ² = 2q^(−ℓ)(1+θ_AA−θ_AB−θ_BA+θ_BB)** and **γ_3 = 3σ²(θ_AA−θ_BB)** both
  check out term by term; the sign conventions (Ŝ = Alice−Bob) are
  consistent with (1.5)/(1.6).
- **Tgss0** (σ²=0 only for HT^{ℓ−1}/T^{ℓ−1}H): the combinatorial elimination
  is correct. **Tem4** ((em4) for the game): QL1/QL2 argument correct,
  including the ℓ≥3 {H^ℓ,T^ℓ} case via (0,2),(0,3),(1,N) generating Z².
- The (HH,TT) case fails (em4) but is **not** in Theorem 1.1's exclusion
  list — handled by direct calculation in Example EHH-TT (verified:
  Var S_n = n−1/2, P(S_n=0) = 2^(−2m−1)C(2m,m)); the final Proof of TAB
  assembles TAB0 + Tem4 + EHH-TT explicitly. No gap.
- Stationarity/irreducibility/aperiodicity of the de Bruijn block chain
  hold as claimed (uniform initial = stationary; a^ℓ self-loops).

**Doc nits (not findings):** (i) §2.1 defines ρ(A)=max|λ| but calls it the
"spectral norm" — it is the spectral radius; (ii) (jw5)'s second indicator
should read Θ(V,T), not Θ(U,V) (the derived formula is correct); (iii) the
Tgss0 proof writes the score sum to n−ℓ−1, should be n−ℓ+1.

## Honest scope

- This audit numerically replays the theorem's *consequences* and
  hand-verifies the proof's *logic*; it does not machine-check the analysis
  (no Lean formalization exists for this paper).
- The exact-fairness direction relies on Basdevant et al. externally; the
  audit confirms the identity numerically (exact at finite n) but does not
  re-derive their combinatorics.
- (1.1)/(1.2) cross-check the three prior independent analyses numerically;
  those papers themselves were not re-audited.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). This is a standalone verify/audit
PASS, recorded the same way as the other harvest targets — a new target
beyond the 9, selected by the user 2026-10-01.
