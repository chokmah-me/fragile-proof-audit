> **AUDIT NOTE (2026-09-22).** Lead, not a record of verdicts. Inline test-fires were not checked against a pinned PDF when this file was written. Gate only from `incoming/`. COL-FP (Kawasaki 2502.20642v2) closed VACUOUS: `docs/audits/kawasaki-collatz.md`.

# Fragile-Route Harvest Dossier — Number Theory, 2020–present

**Configuration:** horizon 2020–present (2020–2023 included) · domain: number theory · ranked hits: 5 · exclusions supplied: none.
**Sweep date:** 2026-09-22. **Trust tags:** `verified` = identifier and claim re-checked live this session; `contested` = public criticism located, no formal published rebuttal; `lead` = single-source.

Gates refute routes, not theorems. Every gate below names an object, parameters, and a Confirm/Break criterion; four were test-fired on a laptop during this sweep (results inline).

---

## Hit 1 — Twin primes via the "area method"

**ID:** TPC-AREA · **Title:** *A proof of the twin prime conjecture* · **arXiv:** [1707.03265v4](https://arxiv.org/abs/1707.03265) (v4 dated March 2026; line originates 2017, latest revision in horizon) · **Author:** T. Agama.

**Still-believed statement.** Twin prime conjecture: infinitely many p with p+2 prime. Open; best unconditional results remain bounded-gap (≤ 246, Maynard–Polymath) ([Wikipedia: Twin prime](https://en.wikipedia.org/wiki/Twin_prime)).

**Claimed route.** (1) "Area identity" Theorem 2.1 from triangle decompositions → (2) Corollary 2.2, an exact decomposition of Σ_{n≤x−1}Σ_{j≤x−n} f(n)f(n+j) as Σ_{2≤n≤x} f(n)·Σ_{m≤n−1} f(m) → (3) Theorem 2.3: majorize the full double sum by 𝒞(l₀)·x·(correlation at shift l₀) → (4) invert the inequality to lower-bound the shift-2 correlation → (5) plug f = ϑ (prime-indicator × log) and the PNT to get #{p ≤ x : p+2 prime} ≥ (1+o(1)) x/(2𝒟(2) log²x) → ∞.

**Earliest pin.** Theorem 2.3's inversion: the chain asserts every shifted correlation Σ_{n≤x} f(n)f(n+j) is bounded by a *fixed constant* times the correlation at the chosen shift l₀, uniformly — "max{|M(l₀)|,…,|R(l₀)|} = C(l₀) … by inverting this inequality, the result follows immediately."

**Attack type:** F (the lemma is universal in f, finite-searchable) + C (Cor 2.2 is an exact identity, replayable).

**Gate sketch.** Object: Theorem 2.3 at x = 12. Take f(n) = 1 if 3 | n else 0, l₀ = 1. Confirm: a constant 𝒞(1) exists with total ≤ 𝒞(1)·x·corr(1). Break: total double sum > 0 while corr(1) = 0, so no finite 𝒞(1) exists.
**Test-fired this session:** Corollary 2.2 confirmed (x = 4, 7, 10: 8 = 8, 86 = 86, 288 = 288 — the identity is a true reindexing). Theorem 2.3 **BREAK**: total = 6, corr(1) = 0 at x = 12. The decisive majorization is false for periodic f; nothing in the paper's proof restricts f away from periodicity, and ϑ itself has rigid periodic structure (zeros at composites) of exactly the kind the counterexample exploits. Route dead at Theorem 2.3. **Control:** f(n) = 1 for all n (then all shifts correlate and the inversion is consistent) — the instrument can confirm.

**Scores.** F 8 (the false lemma is one displayed inequality; blueprintable in a week) · Fr 9 (single load-bearing inversion; constant folded into 𝒞(l₀)) · R 10 (counterexample at x = 12, milliseconds).

**Prior art.** No formal published rebuttal found; the paper has circulated since 2017 without acceptance, v4 (2026) still asserts the full conjecture. Status: `contested`-by-silence; this session's break appears to be the first explicit finite witness.

**Why our framework fits.** Pure Python `Fraction`-free integer evaluation; the counterexample is a 6-line program. Ideal generator/evaluator split: the gate is independent of the route's prose.

**Risks.** None material. Paper's notation is consistent across v4; the identity check confirms we read the same objects the author defines.

---

## Hit 2 — Catalan's constant is irrational

**ID:** CAT-G · **Title:** *Catalan's constant is irrational* · **arXiv:** [2609.04176v1](https://arxiv.org/html/2609.04176v1) (3 Sep 2026, this month).

**Still-believed statement.** Irrationality of Catalan's constant G = Σ (−1)^k/(2k+1)². Open — Calegari–Dimitrov–Tang (2024) proved the irrationality of the *twisted* L-value L(2, χ₋₃) and were "unable to prove G ∉ ℚ," as the paper itself acknowledges.

**Claimed route.** (1) Encode the tail recurrence T_m + T_{m+1} = 1/(2m+1)² in a weighted finite-difference residual matrix, prove full column rank → (2) Newton-completion produces a fixed scalar q̂_B → (3) Cauchy–Binet expansion of the residual determinant → (4) prime-power local saturation lemmas → (5) an asymptotic ledger evaluated at S/B = 1/20: raw quadratic coefficient 39/200 = 0.195 vs. computed gains −c_odd + Λ_mid + 83/2400 > 0.20466…, margin > 0 forces |N_B| < 1 for a nonzero integer N_B, contradiction.

**Earliest pin.** The zero-count at (2.12)/(2.16): the polynomial K(X), built from the tail recurrence with the factor (2X+3)², must vanish at the extra point X = −3/2 to force deg K ≥ 4B+1 > 4B ≥ deg K. Public analysis notes that "with the actual recurrence, K(i) does not vanish. So the zero count that forces deg K [≥] 4B+1 fails" ([Hacker News discussion](https://news.ycombinator.com/item?id=49560333)). The paper acknowledges AI authorship and AI-only verification ("The whole proof has passed the verification of Chatgpt 5.6 Solar").

**Attack type:** E (CAS/transcript replay — no human-checked computation) + A (the margin 0.20466… − 0.195 is an interval-arithmetic scalar) + B (rank lemma is a finite determinant computation at small B).

**Gate sketch.** Gate 2a (replay): compute T_m from definition, check the claimed recurrence and the K(−3/2) vanishing at small B (B = 4, 5, 6) with exact rational arithmetic. Confirm: K(−3/2) = 0 and determinant rank as claimed. Break: K(−3/2) ≠ 0 at any small B. Gate 2b (scalar): recompute the ledger constants c_odd, Λ_mid, 83/2400 by the paper's formulas under interval arithmetic.
**Test-fired this session (2a, partial):** the underlying tail recurrence (1.4) **CONFIRMED** exactly (T_m + T_{m+1} = 1/(2m+1)² to 50 digits at m = 1, 2, 3) — the recurrence layer survives; the kill must come at the K-polynomial layer (2.12) or the ledger, consistent with the public suspicion. **Control:** replay the analogous determinant for the classical Apéry ζ(3) recursion, where the zero-count is genuinely correct — opposite verdict available.

**Scores.** F 7 (determinants and p-adic valuations are mathlib-shaped; ledger replay is engineering, not insight) · Fr 8 (unpublished, two weeks old, AI-generated, no human verification, exact-one margin in the zero count) · R 8 (small-B determinant replay finishes in minutes; ledger replay in an afternoon).

**Prior art.** No formal rebuttal published; substantive public criticism with a named suspect step exists (HN, 2026-09-04). Status: `contested`, hot.

**Why our framework fits.** Exact `Fraction` determinant evaluation at small B; interval arithmetic via `mpmath` for the ledger constants; both are laptop jobs. The AI-generated numerics ("needed numerical data in the proof were produced by AI") are precisely the replayable stratum this campaign gates.

**Risks.** HTML version may garble matrix definitions — pull source/PDF before coding the gate. The margin is positive (0.20466 > 0.195), so a Confirm on 2b is a real possibility; the kill concentrates on 2a.

---

## Hit 3 — Generalized Erdős–Straus 5/a = 1/b + 1/c + 1/d

**ID:** ES-5 · **Title:** *Almost a Complete Proof of the Generalized Erdős–Straus Conjecture: 5/a = 1/b + 1/c + 1/d* · **arXiv:** [2508.07367v1](https://arxiv.org/html/2508.07367v1) (10 Aug 2025).

**Still-believed statement.** Erdős–Straus 4/n (and generalizations k/n = sum of three unit fractions): believed true, open; 4/n verified to at least n ≤ 10¹⁷ (Salez, cited in the paper's references).

**Claimed route.** (1) Reduce to finitely many residue classes of a modulo small composite moduli → (2) for each class, display a parametric identity producing the three unit fractions — e.g. (33): 5/(1+5(7+12x)) = 1/(8(3+5x)) + 1/(24(3+5x)) + 1/(4(3+5x)) for q ≡ 7 (mod 12) → (3) assemble the classes into a covering of (almost) all a.

**Earliest pin.** The covering step: the union of the displayed identity families must actually cover every residue class of a modulo the working modulus. The title's own hedge ("Almost a Complete Proof") marks the seam.

**Attack type:** A (each displayed identity is an exact rational identity, checkable symbolically) + F (coverage sweep: enumerate the residue classes claimed covered vs. all classes mod M).

**Gate sketch.** Object: identity families and their class coverage. Parameters: every displayed identity, x = 0…20 spot checks; then full coverage enumeration mod M = lcm of the moduli used. Confirm: identities exact AND union covers all a. Break: a false identity, or an uncovered residue class.
**Test-fired this session:** identity (33) **CONFIRMED** exactly at x = 0, 1, 7 (Fraction arithmetic, e.g. 5/36 = 5/36 at x = 0). The identities are honest; the kill surface is coverage completeness. **Control:** run the same coverage sweep on the classical complete covering for 4/n (mod 840 classes), where the correct verdict is full coverage.

**Scores.** F 9 (finite residue-class enumeration is the most mathlib-native object in this dossier) · Fr 7 (author hedges; identities verified true; thin prose at the assembly step) · R 9 (full coverage sweep at M of modest size finishes in seconds).

**Prior art.** No rebuttal found. Related serious work exists (the 2026 sieve-dimension analysis of the n ≡ 1 mod 24 class, [2608.24035](https://arxiv.org/html/2608.24035v1)), which treats the covering problem as deep — evidence that a complete elementary covering is unlikely to be this short. Status: `verified`-live, unrebutted.

**Why our framework fits.** This is the archetype the stack was built for: exact rational identity audit plus finite covering enumeration.

**Risks.** The hedge "almost" may mean the author already concedes an uncovered class, which would demote the hit to calibration. Determine from the paper's own remark section before writing the full gate.

---

## Hit 4 — Legendre's conjecture via Newman-type exponential sums

**ID:** LEG-NS · **Title:** *Real exponential sums over primes and prime gaps* · **arXiv:** [2307.08725v2](https://arxiv.org/html/2307.08725v2) (v2, 2025).

**Still-believed statement.** Legendre's conjecture: a prime between n² and (n+1)² for every n. Open. Note the paper claims more: Proposition 4.6 asserts Legendre "for all n sufficiently large" via π(x + √x) − π(x) ~ √x/log x — itself an unproven short-interval asymptotic far beyond current knowledge.

**Claimed route.** (1) Rebuild D. Newman's PNT method in ~10 modular steps with a weighted exponential sum over primes → (2) prove a Tauberian estimate (Theorem 2.18) for primes in intervals of length x^λ → (3) specialize λ = 1/2 → (4) conclude π(x+√x) − π(x) ~ √x/log x → (5) Legendre for large n.

**Earliest pin.** Theorem 2.18 at λ = 1/2: the whole claim rides on a single short-interval estimate whose implied error term must beat known barriers; community reviewers already "smell something fishy (…something doesn't actually converge, or doesn't actually meromorphically extend?)" ([r/math thread](https://www.reddit.com/r/math/comments/16k7q7t/recent_claimed_proof_of_legendres_conjecture/)).

**Attack type:** G (illicit limit/Tauberian swap) with a finite anchor: A (numerically evaluate the paper's explicit weighted-sum bound at moderate x and check whether the stated inequality between displayed quantities holds at computable depth).

**Gate sketch.** Object: the decisive displayed estimate in Theorem 2.18, instantiated at x = 10^6…10^10 with the paper's own constants. Confirm: stated inequality between the explicit sum and its claimed bound holds at all sampled depths with margin. Break: the inequality reverses or the error term exceeds the main term at every accessible scale. **Control:** same instrument on Newman's classical setting (full PNT, long interval), where Confirm is the correct verdict.

**Scores.** F 5 (analytic estimates are formalizable but not week-scale) · Fr 8 (single load-bearing theorem; cross-specialty author; structured but thin at convergence) · R 5 (the finite anchor is weaker than Hits 1–3; a Break needs careful reading of which displayed line is load-bearing).

**Prior art.** Public expert skepticism, no formal rebuttal located. Status: `contested`.

**Why our framework fits.** The gate is a numeric interval check against the paper's own constants — pure `mpmath`.

**Risks.** Highest risk in the dossier that the residue is not truly finite: if Theorem 2.18's statement hides the failure in an inexplicit o(1), the gate downgrades to prose audit. Read v2 fully before committing.

---

## Hit 5 — Goldbach via a "semi-continuous model of even numbers"

**STALE (2026-09-23): paper is now v5 (19 May 2026), not v2 — claim shifted to a "relative proof" (74/75 structures; dominant structure needs admitted-unproven inequalities). Gated and BROKEN (route) as v5: see `docs/audits/gb-sce.md`. This entry's v2-era equation numbers no longer apply.**

**ID:** GB-SCE · **Title:** *Proof of the Goldbach's strong Conjecture by Using Semi-continuous Model of Even Numbers* · **arXiv:** [1909.13230v2](https://arxiv.org/html/1909.13230v2) (v2, October 2024 — in horizon by version).

**Still-believed statement.** Goldbach: every even n ≥ 4 is a sum of two primes. Open; verified to 4×10¹⁸ by others.

**Claimed route.** (1) Model even numbers "semi-continuously," define partition counts b_E, c_E → (2) derive the master inequality (24): E/ln E − 1.2551·(E/2)/ln(E/2) < b_E → (3) chain (19), (21), (24) with a chosen lower bound A = 1.2551·(E/2)/ln(E/2) − 1 → (4) conclude b_E ≥ 1 for all even E.

**Earliest pin.** Inequality (24): one displayed estimate with the magic constant 1.2551 carries the whole argument — the canonical fragility signature.

**Attack type:** A (scalar gate under numeric evaluation).

**Gate sketch.** Object: inequality (24). Parameters: E = 10^4 … 10^8 against the true Goldbach partition count (or any defensible reading of b_E). Confirm: LHS < true partition count at all sampled E. Break: reversal at any E.
**Test-fired this session:** at E = 10^6 the LHS of (24) evaluates to ≈ 24 559, while the true number of Goldbach partitions of 10^6 is 5 402 (≈ E/(2 log²E)·singular-series scale) — the displayed inequality is **numerically reversed by a factor ~4.5** under the natural reading of b_E. Strong Break lead, pending a careful read of the paper's idiosyncratic definition of b_E ("semi-continuous" counts may not coincide with partition counts — the discrepancy may be definitional rather than fatal; either way the load-bearing inequality does not say what the route needs). **Control:** the same scalar chain at E/ln E vs. the proven-true Chebyshev lower bound for primes, where Confirm is correct.

**Scores.** F 8 (one inequality, exact evaluation) · Fr 9 (sweeping claim, one displayed estimate, constants folded into 1.2551) · R 8 (seconds; only the definitional ambiguity of b_E costs a point).

**Prior art.** No rebuttal found; v1 dates to 2019, v2 refreshed 2024 without acceptance. Status: `verified`-live, unrebutted.

**Why our framework fits.** Scalar-gate archetype: sign/bound/constant fails under numeric eval.

**Risks.** The definitional gap (b_E vs. true partition count) is the only shield the route has; the gate report must quote the paper's definition verbatim before declaring Break.

---

## Next-three (ordered by expected yield per hour)

1. **TPC-AREA gate write-up (half a day).** The Break is already in hand (x = 12 witness, 6 vs 0). Package it: minimal counterexample, statement of Theorem 2.3 verbatim, one-paragraph kill note. Highest certainty of a clean, citable route-refutation.
2. **CAT-G Gate 2a (one day).** Exact-rational replay of the residual-matrix construction at B = 4…8: rank check plus the K(−3/2) zero-count. The recurrence layer already confirmed; public suspicion and the one-zero margin make this the highest-information gate in the dossier — a Confirm here upgrades the paper's status materially, a Break kills a live, this-month claim.
3. **ES-5 coverage sweep (half a day).** Enumerate covered vs. uncovered residue classes of a modulo the paper's working modulus. Identities already confirmed true, so the sweep result is decisive either way and trivially reusable as a Lean blueprint if it Confirms.

## Exclusion log

Refused, for the record: **Suman's ζ(5) claim** ([2407.07121](https://arxiv.org/abs/2407.07121), withdrawn; formal rebuttal at [2411.16774](https://arxiv.org/html/2411.16774v3)) — already rebutted, kept only as calibration that the base-case-kill pattern (Type B) is what actually lands on irrationality claims. **Sauvaget's Giuga–Agoh "elementary proof"** (hal-00599178, 2011) — outside horizon. **Carella's Catalan note** ([2203.01832](https://arxiv.org/abs/2203.01832)) — conditional on prime triples, advertises no unconditional proof. **Bradford's 4/n patterns** ([2403.16047](https://arxiv.org/abs/2403.16047)) — states a conjecture plus a correspondence theorem, claims no proof of the conjecture; fails admission. **Sabihi's prime-distribution omnibus** ([1605.01722](https://arxiv.org/html/1605.01722v5)) — rests on an unproven "proven Firoozbakht," 2018 vintage, outside horizon spine. **RH claims** ([1703.03827](https://arxiv.org/html/1703.03827v14), the Watkin list) — no finite residue; G-type prose gaps only. **de Polignac sieving preprints** ([2108.13834](https://arxiv.org/html/2108.13834v4), [1912.09290](https://arxiv.org/pdf/1912.09290)) — hedge titles ("a step towards," "cases of"), no full claim to gate. **The Erdős–Straus sieve paper** [2608.24035](https://arxiv.org/html/2608.24035v1) — reads as serious partial analysis, not a fragile full-proof claim; monitor, don't gate. **ProofAtlas Agoh–Giuga board** — a research-state map with openly unreproduced enumerations, not a claimed proof; flagged as a future replay target, not a harvest hit.

