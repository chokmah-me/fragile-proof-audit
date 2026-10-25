# Audit note — Binder, Ivrii, Prause, Smirnov, Brennan's Conjecture and the Universal Integral Means Spectrum (arXiv:2610.23853v1, 2026-10-16)

**Claim artifact:** Ilia Binder, Oleg Ivrii, Istvan Prause,
Stanislav Smirnov, *Brennan's Conjecture and the Universal
Integral Means Spectrum* (arXiv:2610.23853v1). The paper
validates the October 2026 OpenAI Brennan/Kraetzer preprints and
presents "a drastically shorter proof of a significantly stronger
statement": the bounded universal integral means spectrum
satisfies B_b(t) ≤ t²/4 for t ∈ [−2,2] (Brennan's conjecture is
the t = −2 case), with the inequality strict for
t ∈ ]−2,2[∖{0}, which excludes Kraetzer's conjectured equality
B_b(t) = t²/4 at every interior point. The authors state plainly
that the note gives "a full argument only for a non-strict
inequality" and that the strictness details are deferred to a
separate paper.
**Harvest item:** Emergent Mind harvest 2026-10-20 (main@f942caf),
fragility 1 on the harvest signal (`disclosed_llm_help`), ranked
#2 in its batch; M1 pre-check at the user's tap 2026-10-25,
target pick set by the user the same day with the V-A / V-B
split fixed in advance.
**Campaign objects:** `incoming/brennan-integral-means/PIN.md`.
**Pinned sources:** Brennan PDF sha256 `415931c4…a5`, e-print
`0ae5cfdf…98`, `main.tex` `d7adc181…7a`; OpenAI Brennan preprint
PDF `27a773e8…bd` and OpenAI Kraetzer preprint PDF `b258aff1…f`
(openai/math @ 1581d4cb). Working copies and per-check evidence
in `~/workspace/brennan-recon/` (`M1-PRECHECK.md`, `VERIFY.md`
checks B1–B14, `checks.py` / `checks-output.txt`,
`DEEPEN.md`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-25` · harness pin via
`scripts/harness_pin.py` (agent Muse (Meta), model Muse Spark
1.3, skills dir mtime 2026-10-09T20:02:43Z). The paths that could
carry or kill this claim were enumerated before the audit
(B1–B14). A DEEPEN pre-verdict pass (the standing companion
prompt for harvest audits) was run on the draft verdicts before
they were finalized; it changed no verdict and sharpened two
framings (the B13 localization expansion written in full; the
V-B GAP recorded as an author-named absence, not a found
defect).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-25T22:05:08Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

A Grandmaster's Methods pass at recon (harvest 2026-10-20)
framed this paper's method family: validation-then-compression
of an AI proof drop, where the audit edge is the cuts and the
deferred parts. That is exactly where this audit's one GAP sits.

**Scope of this audit:** M1 statement fidelity, M2 argument
check at fidelity grade, M3 credit honesty, M4 fine-print
inventory, for two claim objects kept separate throughout:
**V-A**, the non-strict bound B_b(t) ≤ t²/4 on [−2,2], the
argument actually printed in the note; and **V-B**, the
strictness assertion on ]−2,2[∖{0}, carrying the
Kraetzer-failure consequence and the corollary
B(t) < t²/4 on ]−2, 6−4√2[∖{0}. "Fidelity grade" here means:
every load-bearing derivation in the Proofs section was
followed line by line and re-derived, the three algebraic
identities the proof turns on were machine-checked (sympy and
finite differences on a concrete map), and the consumed
classical statements (Makarov's identity, the Carleson–Makarov
reduction, the two OpenAI results as described) were checked at
statement level against their sources, not re-proved. No Lean
artifact exists for this claim and none was built. No author
contact. The 32-gate verdict lock is untouched.

## Verdicts

- **V-A (non-strict bound B_b(t) ≤ t²/4, −2 ≤ t ≤ 2): PASS.**
  The statement is identical in the abstract's consequence, in
  the printed theorem, and in what the proof delivers, endpoints
  included (t = 0 immediate; t = 2 by area and monotonicity;
  −2 ≤ t < 2 by the main argument). Every derivation in the
  proof checks (B1–B14 in the working evidence): the
  superharmonicity and critical-point machinery, the index
  count M(h) − S(h) ≥ 0, the signed-area inequality, the
  integral-means expansion, the X(r) bookkeeping (machine:
  sympy residual exactly 0 at five integer-exponent parameter
  cases, ≤ 2.8×10⁻⁸ over 200 random admissible points), and the
  localization step that bounds the tail uniformly in the
  dilation parameter. The argument is self-contained: it cites
  no OpenAI lemma, so there is no rearrangement-fidelity
  question of the Banks kind; the compression claim is borne
  out, 7 pages complete as printed for this claim object.
- **V-B (strictness on ]−2,2[∖{0}, with its dependents):
  GAP.** The strict inequality is asserted in the theorem with
  a proof sketch only: the perturbed weight V*_ξ is displayed
  and the method named ("replacing the pointwise positivity by
  an averaged one"), and the paper states "We defer the
  details to a separate paper." No follow-up is in the arXiv
  record as of this audit (v1 only). The one strictness point
  proved anywhere in the consumed record is OpenAI's
  B_b(−1) < 1/4. This GAP is an absence named by the authors
  themselves, not a defect found in what is printed; it is
  inherited by the Kraetzer-failure form of the headline, by
  the B(t) < t²/4 corollary, and by any reading of "stronger
  than OpenAI" that needs strictness at a point other than
  t = −1. If the follow-up paper appears, V-B becomes
  auditable and this split tells that audit what to read.

## The claim and its citation topology

| Citation | What it supplies | Used at | Load-bearing? |
|---|---|---|---|
| OpenAI, *Brennan's conjecture and sharp inverse-square integral means* (2026-09-24), openai/math @ 1581d4cb | The Brennan proof being validated; B_S(−2) = 1 for the schlicht class | framing only (§§1.2, abstract); no lemma consumed | NO for V-A/V-B as argued here: the note's proof is independent |
| OpenAI, *A strict inverse-first-power bound for univalent functions* (2026-09-24) | B_b(−1) < 1/4: Kraetzer false at t = −1 | framing; the only proved strictness point in the record | YES for context of V-B: it is all the strictness currently proved anywhere |
| Makarov, Thm 5.4 (identity B(t) = max{B_b(t), 3t−1}) | Converts the B_b bound into the B(t) corollary; at t = −2 gives B(−2) = B_b(−2) | §1.1, Results corollary | YES for the Brennan reading and the corollary; NO for the B_b bound itself |
| Carleson–Makarov | Reduction of Brennan's conjecture to the spectrum statement B(−2) = 1 | §1.1 | YES for the Brennan reading of the t = −2 endpoint |
| Sard, area formula, Poincaré–Hopf, Cauchy/Koebe distortion bound | Standard in-proof inputs | Proofs §§1–3 | YES as classical inputs, fenced in M4 |

## M1 — Statement fidelity

Statement identity: exact. The theorem printed in the Results
section asserts the bound on the whole interval [−2,2] over the
full bounded-univalent class (B_b is defined as the sup over all
bounded univalent f, eq. def-univ; no restricted subclass appears
anywhere), strictness on the open interval minus 0, and nothing
else. The three headline predicates all sit in that one
sentence: the bound itself; Brennan at t = −2 (the theorem gives
B_b(−2) ≤ 1, and the paper's own reduction chain, Carleson–
Makarov plus Makarov's identity with 3t−1 = −7 at t = −2, makes
that the conjectured statement, the matching lower bound being
the classical slit example the introduction itself uses); and
the exclusion of Kraetzer's equality (printed as eq. t24) at
every interior t ≠ 0. "Significantly stronger" is accurate at
statement level against the pinned OpenAI results: Brennan
alone, and strictness at the single point t = −1. The M1
pre-check (2026-10-25, `M1-PRECHECK.md`) ran before the pick and
its kill criterion, a predicate missing from the theorem or a
silently restricted class, was not triggered. The
statement/proof mismatch in this paper is not M1 but M2, and it
is the authors' own disclosure: the theorem's strictness half
is the part whose proof is deferred (see V-B).

## M2 — Argument check (V-A)

All fourteen checks B1–B14 in `~/workspace/brennan-recon/
VERIFY.md` hold. The load-bearing ones:

1. **Potential machinery (B2–B6).** Δℓ_ξ = −4k/s² < 0 off the
   pole; ∂_zℓ_ξ factors as −(G−ξ)·kz̄/(s(f−ξ)), so critical
   points are exactly the fibers G(z) = ξ; at a critical point
   V_ξ = 2kT; det DG has the printed form, and the
   Hessian–Jacobian identity det D²ℓ_ξ =
   −(16k⁴|z|⁴/(s⁴|f′|²))·det DG gives the sign dictionary
   (det DG < 0 ⟺ local maximum, > 0 ⟺ saddle) the count needs.
   Machine cross-checks on f(z) = z + 0.3z²: Laplacian to
   8×10⁻⁶, Jacobian formula to 1.5×10⁻¹⁰ relative, V = 2kT to
   2×10⁻¹⁶, Hessian identity to 1×10⁻⁵ (all finite-difference).
2. **Counting (B7–B8).** Superlevel components are Jordan
   domains (a hole forces an interior minimum of a strictly
   superharmonic function); the pole's gradient index is +1, so
   Poincaré–Hopf gives 1 = M_j − S_j + P_j per component and
   M(h) − S(h) = #{components} − P(h) ≥ 0 summed (P ≤ 1 by
   univalence; P = 1 forces the pole's own component). Layer
   cake over heights then gives Σ_{G(z)=ξ} T(z)^q sgn det DG ≤ 0
   for a.e. ξ, sign and (2k)^q factor both verified.
3. **Signed area (B9).** The real area formula split by the
   sign of det DG turns the fiber inequality into
   ∫ ψ(G)T^q det DG dA ≤ 0 for admissible ψ, exactly as
   printed, integrability side condition stated.
4. **Integral means and the X(r) identity (B10–B12).**
   Δ|f′|^t = t²|f′|^t|f″/f′|² gives both M-derivative
   identities and, as a side product, the subharmonicity of
   |φ′|^t for every t ≠ 0 that the final monotonicity uses,
   negative t included. The θ-integral expansion's three
   coefficients reproduce by hand; the closing algebra
   ([expansion] = X′(r) + (4k²/t²)r^{q−1}s^b(4r² − q/k)M) is
   machine-verified (above), including the paper's side
   identity (2k−1)t + b + 2 = k(t+2).
5. **Localization and the tail (B13–B14).** The M1 pre-check's
   one lead, the source draft's commented-out t < 0 case split
   replaced by localization for all t, closes clean: the
   printed route never integrates through the origin
   singularity (ψ = 1_Δ vanishes there), so it is sign-agnostic.
   The uniformity in ρ the paper compresses into "Cauchy
   estimate" is the Koebe/Cauchy bound (1−|w|²)|φ′(w)| ≤
   2·sup|φ| for bounded univalent φ, applied at w = ρz; with
   the middle annulus compact and |f′| bounded below there, the
   tail bound is uniform in ρ, monotone convergence in ρ and
   in r gives β_φ(t) ≤ b+1, and k ↓ q/4 lands on t²/4 exactly.
   The t = 2 endpoint (area + monotonicity, β ≤ 1) is
   independent of the main argument and correct.

**M2 verdict on V-A: the printed argument is complete and
correct at fidelity grade.** No dropped hypothesis, no step
that does not match its statement, no hidden case split was
found. The residual depth not bought is named under M4/GAPs:
this is one harness's proof-read, not a formalization.

## M3 — Credit honesty

Credit is explicit, repeated, and accurate against the pinned
sources. The abstract and §1.2 credit OpenAI with proving
Brennan's conjecture and disproving Kraetzer's (precisely:
false at t = −1, via the pinned strict-bound preprint), give a
full account of their method including the probabilistic
construction the note discards, and assess it fairly ("while
none of the techniques appear unprecedented, their combination
in this context was missed by the human experts"). The note
claims exactly its own contribution: the redundancy
observation, the shorter proof, the stronger statement.
Antecedents (Ahlfors, Chuaqui–Osgood, Milnor, persistence,
Hedenmalm–Shimorin, Ruelle, Beliaev) are credited in place;
Makarov's identity and the Carleson–Makarov reduction are cited
at the point of use. AI-use disclosure is specific and
consistent: "Only some of us used AI agents to help with
understanding, and the write up below was done without AI help"
(§1.3), matching the abstract's framing; the harvest signal
`disclosed_llm_help` is borne out. One prose looseness, no
verdict impact: the abstract's "disproving Kraetzer's more
general t²/4 conjecture" is looser than §1.2's exact scope
(false at t = −1); falsity at one point does disprove the
all-t equality as stated, so the abstract is loose, not wrong
(the Banks M3 pattern: a prose slip about the source, touching
no statement). In the authors' favor: §1.3 declares the
method's limits unprompted ("it is not clear whether it can
ever give a sharp estimate from above or provide description
of the extremal map").

## M4 — Fine-print inventory

1. **Makarov's identity** B(t) = max{B_b(t), 3t−1}, consumed at
   statement level. If it failed: V-A's bound on B_b SURVIVES;
   the Brennan reading of the t = −2 endpoint WEAKENS to the
   Carleson–Makarov reduction alone; the B(t) corollary
   EVAPORATES (it is V-B's dependent in any case).
2. **Carleson–Makarov reduction** of Brennan to B(−2) = 1,
   consumed at statement level. If it failed: the bound
   SURVIVES as a spectrum theorem; its Brennan name WEAKENS.
3. **Classical in-proof inputs** (Sard, area formula,
   Poincaré–Hopf, Cauchy/Koebe bound, monotone convergence):
   all standard, satisfiable by the claim's instances, no
   machine or computational trusted base. SURVIVES.
   Source-faithful.
4. **Uniformity in ρ** at the three points in M2 item 5:
   verified in full; the paper's compression of the first into
   "Cauchy estimate" is convenience-only and the risk did not
   realize.
5. **V-B strictness deferred by the authors.** Inheriting
   claims are listed under the V-B verdict. Tag: risk-inducing
   if the theorem is quoted without its deferral sentence; the
   paper itself never hides it (the deferral sits in the same
   Results section as the theorem).
6. **a.e. qualifications** (a.e. ξ, regular heights): the final
   bound integrates over ξ and depends on no single fiber.
   SURVIVES, no residual.
7. **Sharpness and extremals:** not claimed; explicitly
   disclaimed (§1.3). By V-B's own assertion the bound is not
   the spectrum in the interior; at t = −2 it is sharp by
   Brennan plus the classical slit example. No hidden existence
   assumption.

## DEEPEN — pre-verdict pass

Run 2026-10-25 (full text in `~/workspace/brennan-recon/
DEEPEN.md`). Alternatives considered: V-A PARTIAL over the two
consumed classical inputs (rejected, fenced published citations
are the house standard and both are correctly stated at the
point of use); V-B PARTIAL instead of GAP (rejected, PARTIAL in
this house means a present, checked partial argument, FSW
shape; for strictness there is no argument in the artifact);
one combined verdict (rejected at the pick, the split is what
keeps a true PASS from laundering an absent proof). The pass
also confirmed the proof's three algebraic load-bearers and
its topological step were the places a break would have to
live, and all had been machine-checked or re-derived. Nothing
in the pass moved a verdict.

## GAPs

1. **V-B strictness** (above): asserted, proof deferred, no
   follow-up in the record. Ceiling on any audit of this
   artifact, not a finding against the authors.
2. **No formalization.** The verdict is a fidelity-grade
   proof-read by one agent harness, with machine checks of the
   algebraic identities but no Lean artifact and no second
   reader. Same grade as Banks and Kerr, recorded the same way.
3. **Consumed classical statements not re-proved** (M4 items
   1–2) and the OpenAI preprints consumed at statement level:
   their correctness is not a verdict object of this audit, and
   V-A does not depend on the OpenAI arguments, only on the
   framing.

## Verdict lock

**Verdicts: V-A PASS, V-B GAP.** The non-strict bound is
complete and correct as printed; strictness is a GAP the
authors name themselves. The 32-gate verdict lock is untouched
(17 BREAK / 15 PASS).
