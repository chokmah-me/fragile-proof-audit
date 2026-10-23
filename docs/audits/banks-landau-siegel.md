# Audit note — Banks, On the OpenAI proof that Landau–Siegel zeros do not exist (arXiv:2610.15483v1, 2026-10-11)

**Claim artifact:** William D. Banks, *On the OpenAI proof that
Landau–Siegel zeros do not exist* (arXiv:2610.15483v1). The paper
gives "a detailed account" of the OpenAI manuscript *Uniform
exclusion of Landau–Siegel zeros* (October 1, 2026), "arranged as
a direct proof with explicit constants": for every primitive real
Dirichlet character χ of conductor q ≥ q₀ = 10¹⁰, every real zero
β ∈ (0,1) of L(s,χ) satisfies (1−β) log q ≥ δ₀ = 3.0×10⁻³, and,
combined with a computation of Lu, Zaman and Zhao, the same
constant δ₀ serves for every conductor q ≥ 3. The argument is an
interpolation determinant argument in the biquadratic field
ℚ(√d, √2): a real zero close to 1 forces χ(p) = −1 for most primes,
and the Frobenius congruence at those primes forces a nonzero
determinant to be divisible by more prime powers than its
Archimedean size allows. Banks states plainly that the ideas are
OpenAI's and that "the explicit constants, and the presentation,
are new."
**Harvest item:** Emergent Mind harvest 2026-10-20 (main@f942caf),
fragility 1 on the harvest signal (`single_author`); target pick
set by the user 2026-10-20.
**Campaign objects:** `incoming/banks-landau-siegel/PIN.md`.
**Pinned sources:** Banks PDF sha256 `54891704…7d6f`, e-print
`33616def…836`, `Effective_SZs.tex` `34a1586c…f2cfc`; OpenAI
manuscript PDF `fab9f6e8…14ef` (openai/math @ adc7f12); Lu–Zaman–Zhao
PDF `77388d40…a40` (full hashes in PIN). Working copies and
per-check evidence in `~/workspace/banks-recon/`
(`internal-check.md` checks B1–B12, `lzz-check.md`,
`openai-check.md`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-20` · harness pin via `scripts/harness_pin.py`
(agent Muse (Meta), model Muse Spark 1.3, skills dir mtime
2026-10-09T20:02:43Z). The paths that could carry or kill this
claim were enumerated before the audit (B1–B12). A DEEPEN
pre-verdict pass (the standing companion prompt for harvest
audits) was run on the draft verdicts before they were finalized;
it changed two framings (V-B is stated as a consumption verdict
with its two-link chain inside the verdict line; the Lean
artifacts moved from a footnote into the GAP list) and no verdict.

**Harness pin** (`scripts/harness_pin.py`, run date
2026-10-20): agent Muse (Meta), model `Muse Spark 1.3`;
skills dir mtime 2026-10-09T20:02:43Z. (Restyled 2026-10-23
from the Agent provenance paragraph above, which carries the
same data in prose form; the pin's generation timestamp was
not recorded in the original note, and no data has been added
beyond what that paragraph records.)

A Grandmaster's Methods pass at recon (harvest 2026-10-20) framed
this paper's method family: validation-then-compression of an AI
proof drop, where the audit edge is the cuts and the
analytic/computation join. Both are exactly where this audit
looked hardest, and both held.

**Scope of this audit:** M1 statement fidelity, M2 argument
correspondence at fidelity grade, M3 credit honesty, M4
fine-print inventory, for two claim objects kept separate
throughout: **V-A**, Banks's explicit theorem for q ≥ 10¹⁰
(§§2–7 of the paper), including its fidelity to the OpenAI
argument; and **V-B**, the upgrade to c = δ₀ for all q ≥ 3,
which is a consumption of Lu–Zaman–Zhao Theorem 1.1.
"Fidelity grade" here means: every lemma statement was checked
against its use, every load-bearing derivation in §§2, 4, 5, 6
was followed line by line, the §7 constant arithmetic was
recomputed independently (mpmath), and §3's convex-geometry
proof was read end to end including its closing contradiction;
it does not mean an independent re-derivation of the whole
proof. The consumed computation (LZZ) was checked at statement
level against its primary source, not re-run. No author contact.

## Verdicts

- **V-A (explicit theorem, q ≥ 10¹⁰, δ₀ = 3.0×10⁻³): PASS.**
  The statement is identical in the abstract, in Theorem 1.1 and
  in what §7 actually proves; the proof delivers a strictly
  better constant than the one printed (δ₀ exact =
  3.0696×10⁻³, recomputed); the internal checks B1–B8 and B11
  found no defect, no dropped hypothesis and no step that does
  not match its statement. The argument is OpenAI's, as declared:
  the correspondence is structural and numerical, down to the
  constants (M2). The one blemish found anywhere in the paper is
  a prose slip about the source, recorded under M3; it touches
  no statement or proof step.
- **V-B (c = δ₀ for all q ≥ 3): PASS as a consumption
  verdict.** Banks performs the instantiation in the body of the
  paper (the proof of the second assertion, §1.2), the quoted
  Lu–Zaman–Zhao Theorem 1.1 matches its primary source verbatim
  in constant, range and scope, and the join arithmetic
  (c₀ > 1/5 > δ₀) is correct, endpoint included. The chain under
  the verdict has two computational links, not one: LZZ's own
  run for 4×10⁵ < q ≤ 10¹⁰ and Platt (2016), imported by LZZ,
  for q ≤ 4×10⁵. Neither computation was re-run here, and the
  LZZ run is single-source and unreplicated as of this audit;
  that dependence is a named GAP below, and Banks himself flags
  it in the paper ("a computation that we have not verified",
  Remark after §7). If the LZZ theorem fell, V-B's explicit
  constant would fall with it; the existence of some c > 0 for
  all q ≥ 3 (the finiteness argument, B11) and V-A would stand.

## The claim and its citation topology

| Citation | What it supplies | Used at | Load-bearing? |
|---|---|---|---|
| OpenAI, *Uniform exclusion of Landau–Siegel zeros* (2026-10-01), openai/math @ adc7f12 | The theorem (ineffective c > 0, q ≥ 3) and the entire argument | everywhere; credited §1.1, abstract, Acknowledgments | YES for V-A: it is the argument being rearranged |
| Lu–Zaman–Zhao, arXiv:2602.03626, Thm 1.1 | No real zero β ≥ 1 − 1/(5 log q) for q ≤ 10¹⁰ | §1.2, proof of the second assertion | YES for V-B only |
| Platt (2016), via LZZ | The same exclusion for q ≤ 4×10⁵, with a stronger region | inside LZZ's proof, not cited by Banks directly | YES for V-B, second link |
| Davenport, *Multiplicative number theory*, Ch. 12/14 | Partial-fraction formula for L′/L; classical exceptional-zero background | §2, §1.1 | Classical input |
| Rosser–Schoenfeld, Thm 6 | Explicit Mertens with the H ≥ 319 threshold | §2 (Lemma 2.1) | Classical input, explicit form load-bearing for the constants |
| Laurent (1991) | Interpolation determinant method | §1.1 attribution | Method credit |

## M1 — Statement fidelity (B1, B10, B11)

**Statement identity: exact.** Abstract, Theorem 1.1 and the §7
conclusion assert the same quantifiers: primitive real χ,
conductor q ≥ q₀, every real zero β ∈ (0,1), bound
(1−β) log q ≥ δ₀. There is no exceptional set, no hidden case
split, and no place where the printed theorem is weaker than the
headline. The title's "Landau–Siegel zeros do not exist" is the
uniform-gap statement itself, not a stronger paraphrase.

**Against the source:** OpenAI Theorem 1 (p. 1, verbatim): "There
is an absolute constant c>0 such that every real zero β∈(0,1) of
every primitive nonprincipal real Dirichlet L-function of
conductor q≥3 satisfies (1−β) log q ≥ c." Same quantifiers.
Banks's two differences are declared additions, not drift:
(i) the explicit values q₀, δ₀ are his stated contribution, and
the all-q explicit form is obtained through LZZ, which the
source does not contain; (ii) OpenAI's word "nonprincipal" is
dropped, which is vacuous at q ≥ 3 (the principal character has
conductor 1).

**The second assertion (B11):** the existence of some c > 0 for
all q ≥ 3 follows from the first assertion by finiteness:
finitely many primitive real characters of conductor < q₀, each
L(s,χ) entire and not identically zero, hence finitely many
zeros in [0,1], each contributing (1−β) log q > 0. The argument
as printed is complete. Only the *value* c = δ₀ needs LZZ (M2).

## M2 — Argument correspondence (B2–B8, B9, B10)

**The §7 constants: recomputed, all exact.** With λ = 3/2 in the
bias lemma: C₁ = 2e^{3/2}/9 = 0.995931, C₂ = e^{3/2}/4 =
1.120422; H = 9216·97² = 86,713,344; ω = ⌈8(C₂ + 8/5)⌉ = 22;
δ₀ = 9/(128·23·C₁) = 81/(5888 e^{3/2}) = 3.0696×10⁻³. Every
absorption in Steps 3–4 checks numerically, several exactly:
768·97²/H = 1/12; log H + 3 + (13/12) log 8 = 23.531 < 24
against log q₀ = 23.026; 1/(2H) + 13/24 + 24/23 = 1.58514 < 8/5;
3(C₂ + 8/5)/(4ω) = 0.092742 ≤ 3/32; the main-term identity
1 − (13/12)(3/4) = 3/16 and the equivalence δ ≥ δ₀ both
re-derive as printed. The published δ₀ = 3.0×10⁻³ is a
round-down of what the proof gives.

**The sections:** §2's bias lemma follows from the classical
log-derivative bound by discarding every zero except β (each
discarded term is positive), with κ = ½log π − ½ψ(3/2) = 0.5541
recomputed; the prime-sum bookkeeping, including the p | q tail
(≤ L/H) and the Mertens split at H ≥ 319, is conservative at
each step (B3). §3's interpolation proposition and its box
corollary check at statement level, including the dimension
count (1/8)T₁T₂T₃ = 4096N⁴ > (4N−3)⁴ (B4). §4's greedy
selection and degree lemma check, counting argument included
(B5); §5's Archimedean bound is Hadamard applied to
|g(θ_vn)| < 8N√q, a loose but valid bound, giving eq. (arch)
exactly (B6); §6's Frobenius congruence (a^p ≡ −a, b^p ≡ (2/p)b
mod p𝒪 at primes with χ(p) = −1) and the prime-power extraction
are correct, the weight drop w ↦ w − m(p−H) being exactly where
p > H is spent, and the p-adic corollary's floor and Chebyshev
losses are as stated (B7). §1.5/§4.1 setup checks: χ(p) = (d/p)
for odd p in both cases D = d and D = 4d; d = 2 occurs only at
q = 8 and is excluded by q ≥ 9; the kernel vector
ξ = (ab, b, −a, −1) and det = 4ab for the map Φ were verified
directly (B8). One fine-print point, not a defect: 𝒪 = ℤ[a,b]
need not be the full ring of integers of K, and the argument
never needs it to be; Δ ∈ 𝒪 suffices for Nm(Δ) to be a nonzero
rational integer.

**Correspondence to OpenAI (B10): structural and numerical.**
Banks's characterizations of the source verify: the source proof
is by contradiction along a sequence of characters with δ → 0
(its §6), closing at 1 ≤ 13/16 + 1/16 = 7/8; the construction is
the same interpolation determinant in the same biquadratic
field, with the same Frobenius congruence at the same admissible
primes, and the same single analytic input (the classical
log-derivative inequality; Mertens and Chebyshev ride along as
background estimates in both). The numerical lineage is direct:
the source's Lemma 6 evaluates c₀ = (4·97²)⁻¹ and C₀ = 192,
which are precisely the constants of Banks's degree lemma, and
the source's closing main term 13/16 is Banks's
(13/12)(3/4)·S₁ log M coefficient. What Banks changed is what
he says he changed: the contradiction-along-a-sequence framing
became a direct argument, and the constants the source leaves
symbolic (its γ is "sufficiently large" in terms of unevaluated
constants, so no δ₀ is extractable from it) are evaluated
throughout. Nothing in the rearrangement drops a hypothesis the
source needed, and nothing silently strengthens the conclusion.

**The join (B9): exact.** LZZ Theorem 1.1 (their TeX lines
70–76, §1, so the printed number matches Banks's citation):
"If q ≤ 10¹⁰ and χ is a quadratic Dirichlet character modulo q,
then L(σ,χ) ≠ 0 for σ ≥ 1 − 1/(5 log q)." Banks quotes it
without a constant slip, a range slip or a scope slip: the
endpoint ≥ is included, which is what makes his c₀ > 1/5 strict
(c₀ is a minimum over a finite set, hence attained); the range
q ≤ 10¹⁰ covers his need (q < 10¹⁰) with no gap at the top;
"quadratic character modulo q" and Banks's "primitive real
character of conductor q" describe the same population at
q ≥ 3, with no parity restriction on either side. What LZZ
rests on, per their paper: an explicit Heath-Brown /
Thorner–Zaman inequality plus a per-discriminant numerical
refutation in FLINT/Arb ball arithmetic (prime sums to
1.3×10⁸, 150,000 core-hours, four passes driving the surviving
discriminants 1.54×10⁹ → 0); GRH appears only in their runtime
guarantee, not in the verification logic. A second-axis check
(arXiv record, title search, a CMS Winter 2025 talk abstract)
confirms the paper, the constant 1/5 and the range; there is no
v2 and no withdrawal. One non-load-bearing defect in LZZ
itself: their TeX line 297 prints the empty range
"4×10¹⁰ < q ≤ 10¹⁰" in a runtime remark (4×10⁵ plainly
intended).

## M3 — Credit honesty (B10, B12)

Credit is the strongest part of this paper. The title names the
source; the abstract closes with "The underlying ideas are those
of the OpenAI manuscript. The explicit constants, and the
presentation, are new."; §1.1 repeats "we claim no originality
for its ideas"; the acknowledgments repeat the attribution a
third time. The LZZ dependence is flagged twice, including the
Remark after §7: "a computation that we have not verified."

The LLM disclosure is specific, in §1.1 and again in the
acknowledgments: "The large language model Claude (Anthropic)
was used throughout the preparation of the paper. It produced a
report on the manuscript [OAI] together with an expanded draft
of the proof, which is the basis of the present text. It was
also used for drafting and revising portions of the text and of
the proofs, for working out the explicit constants, for
preparing the figure and the diagrams, for literature searches,
and for proof checking. The author has worked through every
line of the paper, has verified the mathematical arguments in
their entirety, and takes full responsibility for its content."
That is a model disclosure: the tool's role, the human's role,
and the responsibility line are all stated.

Two findings, both minor. (1) Banks writes (§1.1) that the
source proof "provides no numerical value for any constant."
The load-bearing reading is true (no δ₀ is extractable from the
source; its master constants are symbolic), but the literal
"any" is overbroad: the source's Lemma 6 does evaluate
c₀ = (4·97²)⁻¹ and C₀ = 192. A prose slip about the source, in
the direction of understating it; it touches no statement or
proof step of Banks's own. (2) Banks's "a computation of Lu,
Zaman, and Zhao" elides that LZZ import their bottom segment
(q ≤ 4×10⁵) from Platt (2016) rather than computing it; the
chain under V-B has two computational links, and a reader of
Banks alone would count one. Banks's own "we have not verified"
covers the dependence honestly; the elision is in the
attribution granularity, not in the dependence.

**Harvest correction (for the record):** the harvest entry for
this paper carried only the signal `single_author`. The paper's
Claude disclosure, which is not visible from the abstract the
harvest was built on, adds `disclosed_llm_help`; the corrected
fragility score is 2. The batch ranking is unchanged (Banks was
already #1).

## M4 — Fine-print inventory (Murray & van Oorschot)

Every assumption a reader of the headline inherits:

1. **The LZZ computation (V-B only).** c = δ₀ for q ≤ 10¹⁰
   rests on LZZ Theorem 1.1, hence on a single group's
   150,000-core-hour FLINT/Arb computation with public code but
   no published per-discriminant certificates, and on Platt
   (2016) beneath it. Unreplicated as of 2026-10-20. Banks
   states he has not verified it; neither has this audit.
2. **Classical explicit inputs.** The constants run through
   Rosser–Schoenfeld's explicit Mertens theorem in the form
   Banks states (the H ≥ 319 threshold is theirs) and through
   Davenport's partial-fraction formula. Both are taken as
   cited; the audit verified that Banks's *use* of them is
   faithful, and did not re-derive the 1962 explicit bounds
   from the original paper.
3. **The ring 𝒪 = ℤ[a,b].** Not necessarily the ring of
   integers of K. The determinant lives in 𝒪 by construction,
   which is all the divisibility argument uses; a reader who
   assumes 𝒪 = 𝒪_K imports more than the proof needs or uses.
4. **Range edges.** The first assertion needs q ≥ q₀ ≥ 9 for
   three separate reasons, all stated in the paper's own
   hypothesis remark: d ≠ 2, N ≥ H, and absorbing the bounded
   terms into L = log q (which is where q₀ = 10¹⁰, rather than
   the bare δ₀ inequality, is spent). Below q₀ nothing in
   §§2–7 applies; the all-q statement is B11's finiteness plus
   item 1, not the determinant argument.
5. **β range.** Everything is about real zeros β ∈ (0,1) of
   real (quadratic) characters. The headline says nothing about
   complex zeros or other characters, and the source's theorem
   is the same shape; no reader should carry the constant to
   GRH-type statements.
6. **Source status.** The OpenAI manuscript is an unrefereed
   corporate manuscript (no named authors, no acknowledgments,
   no AI-use statement in the PDF). Banks's paper is, at this
   point, its most careful public scrutiny; this audit audited
   Banks's scrutiny, and the third-party Lean rebuild of the
   source (GAP 2) reports no flaw in it.

## Receipt

- Banks arXiv:2610.15483v1: PDF
  `54891704515ba9d58ae60ce4c16f4b368a377a9732ca98e26172209fa0647d6f`;
  e-print `33616defcbd665865217183bb099f94c34b5e3f5514efd7ce5d37feb7fc44836`;
  `Effective_SZs.tex`
  `34a1586c6c285474c62d8d504f1a3077667a041c6bf507ad042cd5d6a86f2cfc`.
  Theorem 1.1 at tex lines ~170–185; second-assertion proof
  lines ~187–205 (LZZ quote at 195–200); §7 at lines 1362–1455;
  effectivity remark (δ₀ = 81/(5888 e^{3/2})) at ~1457–1492.
- Internal recomputation (B2): mpmath evaluation of C₁, C₂, H,
  ω, δ₀ and all §7 absorption inequalities; values in M2 and in
  `~/workspace/banks-recon/internal-check.md`, which also holds
  the B1–B12 evidence at check level.
- OpenAI manuscript: openai/math @
  `adc7f1241b42e322a6451854ab7e4b4c146bf78a`, PDF
  `fab9f6e84ece2a37d834b2c031d8eb14e81413d9f6270791e7b5468b295214ef`
  (9 pp; git blob hashes reproduce at the commit; the rebuild
  repo's vendored copy is the same blob), TeX
  `b011ba9c1f55ee2164292492c55e0c6d75c458eb30d4808808f9953823b8ded4`.
  Theorem 1 p. 1; contradiction close pp. 8–9; Lemma 6 constants
  at TeX line 549. Evidence: `openai-check.md`.
- LZZ arXiv:2602.03626v1: PDF
  `77388d40267e90684e02ec8e666a9d55b0ceb159fa6b5b9eea1faf3dd09b1a40`;
  e-print `0f369e2b6b3ba8c0329afc14693ece72781c043c942837ef79e907e71e74c8ab`;
  main TeX `0f5239418a9795ea5c75d972a5f9cff2379cb2a47e798376b2d4c8126ce23639`.
  Theorem 1.1 at TeX lines 70–76; Platt segment at line 261;
  code repo github.com/asif-z/landau-siegel-zero-tester @
  a783ffdfb (recorded, not run). Evidence: `lzz-check.md`.
- No CI runs were dispatched for this audit; no repository
  outside fragile-proof-audit was written; no author was
  contacted.

## Surviving GAPs (named, not silent)

1. The LZZ computation (and Platt 2016 beneath it) was not
   re-run or independently replicated here. V-B is a
   consumption verdict: the implication LZZ Thm 1.1 ⇒ c = δ₀ is
   verified; the computation itself is single-source. Closing
   path: re-run the public tester code on a sample of the
   discriminant range, or await an independent replication.
2. Neither Lean formalization of the source statement was built
   in this audit: OpenAI's own 306-file solution tree at
   adc7f12, and AolinHAN/landau-siegel-lean @ 919e60f (whose
   author records a build and a 406-theorem axiom audit, and
   reports no gap in the OpenAI argument). A build + `#print
   axioms` pass on either would upgrade the source argument's
   status from "scrutinized in prose" to kernel-checked; it
   would not change either verdict here, which are about
   Banks's paper and its consumption.
3. §3's interpolation proof was read end to end but not
   independently re-derived, and Rosser–Schoenfeld Theorem 6
   was consumed in the form Banks states it. Both are standard
   shapes (Laurent's interpolation determinant method; the 1962
   explicit Mertens), and no step read in either place
   contradicts its statement; a full re-derivation is the
   remaining depth this audit did not buy.

## Verdict lock

**Verdict: PASS.** Both scoped verdicts stand as stated under
`## Verdicts` above: V-A on the explicit theorem, V-B as a
consumption verdict on the Lu–Zaman–Zhao chain. The surviving
gaps named in the section above are qualifications on those
verdicts, not exceptions to them. (Section added 2026-10-23,
restyle only: the note previously carried its verdicts as the
scoped bullets under `## Verdicts` and had no closing verdict
line; no verdict, finding or wording above this section has
been changed.)
