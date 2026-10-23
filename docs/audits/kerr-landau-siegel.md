# Audit note — Kerr, "A simpler proof that there are no Landau–Siegel zeros"

**Claim artifact:** Bryce Kerr (UNSW Canberra), *A simpler proof
that there are no Landau--Siegel zeros*, arXiv:2610.21099,
submitted 15 Oct 2026. Local PDF
`~/workspace/kerr-recon/paper-2610.21099.pdf`, sha256
`30dc40c959735eaaddd3609919695f87258ec2807fb615a9a4386702f3536116`
(byte-identical to the triage download of 2026-10-20). No
supplementary file; the paper is 419 lines of LaTeX source,
read in full.
**Claim:** there is an absolute constant c > 0 such that every
real zero β ∈ (0,1) of L(s, χ), for χ(n) = (q/n) with q a
fundamental discriminant, satisfies (1−β) log|q| ≥ c. The paper
presents itself as a simplification of the OpenAI proof
(*Uniform exclusion of Landau--Siegel zeros*, 1 Oct 2026).
**Harvest item:** Bryce Kerr (queue 4th at triage 2026-10-20;
head after Cryptids closed; paper audit, no runner needed;
Grandmaster's Methods at recon).
**Campaign objects:** `incoming/kerr-landau-siegel/PIN.md`;
working notes `~/workspace/kerr-recon/` (GM-RECON.md,
VERIFY.md, DEEPEN.md).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`,
audit date `2026-10-23`. Machine legs: none (paper audit). One
computational cross-check: the three leading constants of the
pigeonholing lemma recomputed by direct enumeration over the
region i + 8(j+k) ≤ D at D = 200/400/800 (VERIFY.md §M2.6).
**Harness pin** (`scripts/harness_pin.py`,
2026-10-23T15:37:06Z): agent Muse (Meta), model `Muse Spark
1.3`; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

**Scope of this audit:** M1 statement fidelity, M2 argument
check (every lemma re-derived by hand from the LaTeX source),
M3 credit honesty, M4 fine-print inventory; DEEPEN as the
pre-verdict pass. No author contact (standing policy). The
32-gate verdict lock is untouched. This audit's verdict is on
Kerr's argument as printed; the OpenAI artifact it simplifies
is not an input to the proof and carries no verdict here.

**Status:** CLOSED 2026-10-23 — verdict **PASS**.

## M1 — statement fidelity

The theorem proved is the theorem stated, quantifiers
included. The simplification claim is also accurate: same
biquadratic field K = Q(√q, √2), same evaluation points
(θₙ, σθₙ, στθₙ), same Frobenius input as the OpenAI proof;
the two replacements are exactly the ones advertised —
 pigeonhole in place of interpolation + determinant, and
Masser 1981 in place of a bespoke zero estimate.

## M2 — argument check

All steps re-derived (full detail in
`~/workspace/kerr-recon/VERIFY.md`):

1. **Frobenius congruences** θₙᵖ ≡ σθₙ / στθₙ for χ(p) = −1:
   checked componentwise, including the √(2q) sign
   (2/p)·χ(p). Correct.
2. **Lemma basis:** the (x₁ᵖ − x_ℓ)ᵉ expansion shifts the
   weight i + 8(j+k) by t(8−p) < 0 (p > 8), so the change of
   basis is triangular with unit diagonal over O. Correct.
3. **Coefficient count:** embedding bound and the
   (⌊y⌋+1)⁴ > y⁴ count. Correct.
4. **Evaluation residues:** G_{ijk}(point) ∈ p^{⌊i/p⌋}O;
   coefficient residues mod p^{k_p−⌊i/p⌋} determine the
   values mod p^{k_p}; CRT gives P^{4r} ∏ p^{−4E_p}. Correct.
5. **Pigeonholing:** the count comparison reduces exactly to
   the printed count condition; ‖F(point)‖ ≤ P/2 against a
   field norm divisible by P⁴ forces F(point) = 0. Correct.
6. **Constants** r = D³/384, W = 5D⁴/6144, E_p = D⁴/(1536p):
   re-derived by integration and cross-checked numerically;
   the inequality the proof needs is (5/4) log B, the paper
   assumes (13/10) log B, and 5/4 < 13/10 < 4/3. Correct,
   with margin.
7. **Analytic step:** Mertens minus the χ(p) = 1 sum, with
   log Q = (4/3) log N + O(log log N); the error terms are
   o(log N) at the stated quantifiers (γ large, ε small in
   terms of γ). Correct.
8. **Lemma dim (μ(Γ) ≥ 4/3):** the rank equality
   rank_Z(Γ∩L) = dim_C span_C(π⁻¹(L) ∩ Z⁴) holds because the
   vectors are rational; π is injective on that span by the
   hypothesis on ker π. Correct.
9. **Final application:** (θₙ, σθₙ, στθₙ) = Σ n_j γ_j
   verified for all four generators and all three
   coordinates; det(γ₁,γ₂,γ₃) = 4√(2q) ≠ 0 recomputed; the
   kernel vector v = (√(2q), √2, −√q, −1) satisfies π(v) = 0
   and its coordinates are the biquadratic basis, Q-linearly
   independent; Masser then gives deg F ≥ ((N−1)/3)^{4/3} > D,
   contradicting F ∈ L_D. Correct.

No gap found. The two steps a casual read glides over — the
basis triangularity and the rank equality in Lemma dim — both
hold, for the reasons recorded in VERIFY.md.

## M3 — credit and disclosure

OpenAI is credited in the abstract, the introduction, and at
each borrowed component. Banks is thanked for the exposition
draft (arXiv:2610.15483) that led to the manuscript.
**ChatGPT assistance with the mathematical development and
preparation is disclosed in the acknowledgement, in plain
words.** Davenport, Masser, and Milne are cited at the points
of use. No credit issues.

## M4 — fine-print assumption inventory

1. **Davenport bias consequence** (Lemma analytic): cited,
   not proved; standard and correctly stated. SURVIVES as a
   cited classical input.
2. **Masser 1981** (Lemma masser): cited, not proved; the
   quoted grid-vanishing form is what the application needs
   (n = 3, M = N−1). SURVIVES as a cited classical input.
   (These two are the triage's "fragility 2": the proof's
   entire external load, both fenced here.)
3. **Small-|q| closure** is by finiteness and is not written;
   one standard line for the reader to supply. SURVIVES.
4. **O = Z[√q, √2] need not be maximal** — nothing in the
   argument uses maximality (norms stay integral, |O/mO| = m⁴
   for any Z-basis). SURVIVES.
5. **q < 0** reads correctly throughout with |q|. SURVIVES.
6. **No dependence on the OpenAI proof as an input.**
   SURVIVES as scoped.

Nothing WEAKENS; nothing EVAPORATES.

## DEEPEN — pre-verdict pass

Run 2026-10-23 (full text in `~/workspace/kerr-recon/DEEPEN.md`).
Alternatives considered: PARTIAL over the two cited inputs
(rejected — fenced classical citations are the house standard,
and both are correctly stated at the point of use); PARTIAL
over the unwritten small-|q| step (rejected — finiteness
closure, not a gap in the method). The one live risk the pass
recorded: if Masser's theorem as quoted differed from the
1981 original in a needed hypothesis, the last step would
fail; the quoted form matches the application exactly.
Nothing in the pass moved the verdict.

## Verdict lock

Untouched (17 BREAK / 15 PASS).

**Verdict: PASS.** Kerr's simplification is complete as
printed: the pigeonhole replaces the interpolation/determinant
machinery without loss, Masser 1981 supplies the zero
estimate, and the inequality chain closes with margin.
