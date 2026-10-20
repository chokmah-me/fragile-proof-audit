# Audit note — Frei–Sofos–Widmer, quasi-Riemann hypothesis applications to class groups and small generators (arXiv:2610.18491v2, 2026-10-14)

**Claim artifact:** Christopher Frei, Efthymios Sofos, Martin Widmer,
*Some applications of the quasi-Riemann hypothesis to class groups and
small generators of number fields* (arXiv:2610.18491v2). The paper
proves an effective Chebotarev theorem conditional on QRH(δ) and
applies it to the Ellenberg–Venkatesh ℓ-torsion bound, an averaged
ℓ-torsion theorem, least split primes, and small generators. The
abstract (main.tex line 144) says the authors "make unconditional the
Ellenberg–Venkatesh bounds" via recent quasi-Riemann preprints. The
paper's own theorems are all stated **conditionally** on QRH(δ), and
§1 (line 155) carries the authors' disclaimer, verbatim: "As we, the
authors of the present note, have currently not verified the arguments
in these preprints, we prefer to state all of our results conditionally
on QRH(δ) for some δ∈(0,1/2]."
**Harvest item:** queued by the user 2026-10-18 from the weekly
harvest; recon 2026-10-19; audit dispatched 2026-10-20.
**Campaign objects:** `incoming/frei-sofos-widmer/PIN.md`.
**Pinned sources:** paper PDF sha256 `2432308e…036f`, e-print tarball
`02a69908…c8ba7cf`, `main.tex` `7e8aed18…2aef` (full hashes in PIN);
working copies and per-check evidence in `~/workspace/fsw-recon/`
(`RECON.md`, `AUDIT-BRIEF.md`, `audit-work/paper-math.md`,
`audit-work/lean.md`, `audit-work/citations.md`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run date
`2026-10-20` · harness pin via `scripts/harness_pin.py` (agent Muse
(Meta), model Muse Spark 1.3, skills dir mtime
2026-10-09T20:02:43Z). The paths that could carry or kill this claim
were enumerated before the audit (AUDIT-BRIEF.md checks A1–A12, from
RECON.md §5 plus an adversarial pass). A DEEPEN pre-verdict pass (the
standing companion prompt for harvest audits) was run on the draft
verdicts before they were finalized; it changed two framings (the
region-inclusion point in M1, the stated grounds for V-B) and no
verdict.

**Scope of this audit:** M1 statement fidelity, M2 argument
correspondence at fidelity grade, M3 credit honesty, M4 fine-print
inventory, for two claim objects kept separate throughout: **V-A**, the
QRH(δ)-conditional theorems the authors prove, and **V-B**, the
unconditional instantiation the abstract asserts. Deliberately out of
scope: independent re-derivation of the Chebotarev proof, and
re-verification of the consumed preprints themselves (V-B checks the
consumption, not the cited proofs). No author contact.

## Verdicts

- **V-A (conditional core): PARTIAL.** The conditional argument checks
  out where this audit can check it (A7 substitution fidelity, A9,
  A12), with two named statement-surface defects: the pointwise
  corollary is printed without the exceptional set its proof requires
  (M2), and one density value the averages discussion needs is
  asserted without a citation (M2).
- **V-B (unconditional instantiation): PARTIAL.** The consumption
  mechanics are exact (A8, A11, and the cited statements say what the
  paper needs), but the headline instantiation for the E–V bound is
  never performed in the body of the paper, and at the cited region
  δ = 1/6000 the instantiated bound has no effective content at any
  realistic discriminant (A6, numbers in M2). The chain also rests
  entirely on preprints the authors state they have not verified;
  that dependence is disclosed, and this audit does not re-verify
  them by design.
- **A3 (Lean build and `#print axioms`): GAP.** The artifact's
  statements diff clean and its tree is textually free of every known
  escape (M1), but no build was run: the pinned toolchain
  v4.35.0-rc3 is not installed on this VM and the project is 5,528
  files on an hourly-rebooting host. The closing recipe is in the
  Receipt block. This GAP caps the artifact's support at textual
  grade; it does not change either verdict above, because both
  verdicts are about the paper and its consumption.

## The claim and its citation topology (A10)

Two verdict objects. V-A: thrm:generaldelta (effective Chebotarev
under QRH(δ)), cor:GRH_bound_pointwise (the E–V bound under QRH(δ)),
thm:l_tor_averages, cor:Rupp1 (small generators under QRH(δ)). V-B:
the same results with δ instantiated by citation.

| Citation | Region claimed | Used at (main.tex) | Load-bearing? |
|---|---|---|---|
| hexagon:2610.00200v1 (Cureton–Thorner) | QRH(1/6000), all Dedekind ζ, hence all finite-order Hecke L | line 155 (attribution); line 347 ("thus making it unconditional") | YES, the whole V-B headline |
| OAI1112 (OpenAI, *The Quasi-Riemann Hypothesis*) | QRH(1/12), Dirichlet L + finite-order Hecke L of Q(√−3) | line 288 (cubic E–V bound via Heath-Brown Thm 5); line 155 (intro) | YES for the cubic case |
| OAI78 (OpenAI) | QRH(1/8), Dirichlet L + Hecke of Q(√−3) | line 155 only | No, intro context |
| OAIartin (OpenAI, Thm 1.2) | QRH(10⁻⁶), Hecke of cyclotomic fields containing μ₁₂ | line 155 only | No, intro context (it is an input to Cureton–Thorner, not consumed by FSW directly) |

One refinement of the recon's topology, found by this audit: the
line-347 sentence ("Here we replace this assumption by QRH(δ), thus
making it unconditional by \cite{hexagon:2610.00200v1}") sits in
§1.3, the small-generators subsection, and discharges **cor:Rupp1**.
There is no instantiation sentence for the E–V headline anywhere in
the body: a search for "unconditional" returns the abstract (line
144), line 347, and one unrelated use in §2 (line 448).
cor:GRH_bound_pointwise (line 281) is stated purely conditionally.
V-B for the headline therefore rests on the abstract plus the
line-155 prose attribution alone.

## M1 — Statement fidelity (A1, A2, A10)

**A1, the Lean theorem vs Hexagon v2 Theorem 1.1: match.** Hexagon v2
Theorem 1.1 (ct-v2.txt line 253): "If K is any number field, then
ζ_K(s) ≠ 0 when Re s > 31/32 and s ≠ 1." The Lean solution theorem
(`DedekindZetaSolution.lean`, `main`) quantifies over an arbitrary
number field K with no discriminant or degree bound, asserts
nonvanishing for `31/32 < s.re` with the hypothesis `s ≠ 1`, and has
no exceptional-zero carve-out; the paper has none either. The one
encoding difference is the standard one: Lean exhibits a continuation
`f`, differentiable on ℂ∖{1} and agreeing with
`NumberField.dedekindZeta K s` for Re s > 1, and asserts nonvanishing
of `f`; the paper speaks of ζ_K via its continuation. The Hecke side
matches the same way (the paper's "wherever it is holomorphic" is the
Lean guard `(s ≠ 1 ∨ ¬ χ.IsPrincipal)`). **Relevance to V-B:** the
formalized region Re s > 31/32 is strictly wider than the region FSW
consume (Re s > 1 − 1/6000), so the formalized statement implies the
consumed one by inclusion, at statement level. Support by inclusion
is not the same as a formalization of the consumed paper (see A4).

**A2, two-path rule: pass.** The challenge file
(`Challenge/DedekindZetaChallenge.lean`) and the solution module
state both theorems (`main`, `heckeCorollary`) identically,
character for character after whitespace normalization; the
supporting definitions (`RayClassCharacter`, `IsPrincipal`) also diff
identical between the challenge copy and the library copy the
solution resolves against. The README's "formalized result" quotes
the 31/32 region, i.e. the solution's actual statement, not a
stronger phrasing. One harmless nuance: the README's Theorem 1.1
sentence omits the `s ≠ 1` qualifier; at s = 1, ζ_K has a pole, not a
zero, so nothing is overstated.

**A3-textual, dependency-cone hygiene: clean.** Ripgrep over all
5,528 `.lean` files at the pin, vendor included: `sorry` exactly 2
hits, both the by-design challenge proof slots; `admit`, `axiom`
declarations, `addDecl`, `skipKernelTC`, `native_decide`,
`ofReduceBool`, `trustCompiler`, `sorryAx`, and `set_option … trust`
all zero. The closing chain was traced by reading:
`Solution.main` → `DedekindZetaZeroFree.dedekindZeta_ne_zero`
(Main.lean:14) → `Quantitative.dedekindZeta_ne_zero`
(DedekindZetaNonvanishing.lean:13), where the proof is a real proof
(cyclotomic-12 descent, closing on
`dedekindZeta_zeroFree_of_abelian_extension`). Textual absence cannot
see axioms entering through compiled dependencies; that is what the
unrun build (GAP, above) would settle.

**A10:** the topology table above is verified line by line against
main.tex. The paper itself confines OAI78 and OAIartin to intro
context; only the abstract's "breakthroughs of OpenAI and
Cureton–Thorner" phrasing invites a stronger reading. The kill path
fires against downstream summaries, not against the paper.

## M2 — Argument correspondence (A6, A7, A8, A9, A12)

**A7, the E–V substitution: fidelity holds.** E–V's Lemma 2.3 needs
M prime ideals of K of norm at most N(d_{L/K})^{η−ε},
η = 1/(2ℓ(d−1)), splitting completely in L. FSW substitute their
QRH(δ)-Chebotarev corollary (thrm:generaldelta, lines 194–206): error
term c₁·(#C/#G)·x^{1−δ}·log(Δ_L^{1/δ} x^{n_L}) with c₁ absolute and
effectively computable. The power saving x^{−δ} holds for every fixed
δ > 0, the relative-error computation is written out in the splitting
corollary's proof (lines 516–537), and the consumption (proof of
cor:GRH_bound_pointwise, lines 571–586) computes M ≍ Δ_L^{η−2ε}
legitimately, with ε absorbing the log factor. The weaker error term
costs nothing in the exponent. This check fails only through A6's
effectivity door.

**A6, effectivity at the cited region δ = 1/6000: the kill path
fires.** The splitting corollary (lines 221–226) delivers its primes
only for x ≥ c(δ)·(log Δ_L)^{1/δ}·(log log Δ_L)^{2/δ}. The constant
c(δ) is given no form anywhere in the paper; its proof (line 537) is
pure existence ("Taking c(δ) sufficiently large … we can make the
last expression arbitrarily small"). Setting c(δ) = 1, a best case the
paper does not supply, and solving 6000·ln t + 12000·ln ln t = ηt for
t = ln Δ gives the discriminant size at which the threshold first
drops below Δ^η, i.e. the first size at which the prime supply the
E–V step needs can exist at all:

| ℓ | d | η | crossover log₁₀ Δ |
|---|---|---|---|
| 2 | 3 | 0.1250 | 395,225 |
| 2 | 6 | 0.0500 | 1,045,923 |
| 5 | 3 | 0.0500 | 1,606,958 |
| 5 | 6 | 0.0200 | 2,757,773 |

(Full 16-cell grid in `audit-work/paper-math.md`.) In the most
favorable case the crossover is a discriminant with roughly 400,000
decimal digits. Real discriminants have log₁₀ Δ in the single or
double digits. The instantiated theorem is not false; it is an
asymptotic statement and the crossover is finite. But at the cited
region its effective content is nil, and both corrections available
(a true c(1/6000) > 1, and the threshold applied to the normal
closure's discriminant, an O_{n_L}(1) multiple in the log) push the
crossover further out, so the table is a strict best case. At
δ = 31/32 the same computation collapses to trivial sizes, but
31/32 is not the region v2 of the paper cites (A11 confirms v2 still
cites hexagon v1).

**The exceptional set.** The pointwise proof (lines 578–581) applies
the bound "for all but O_{δ,K,n_L,ℓ,ε}(1) extensions L of K of degree
d". The count's δ-dependence is acknowledged in the subscript and
never quantified anywhere in the paper (the word "exceptional"
occurs only at lines 581, 583, 612). Mechanically the exceptions are
the extensions whose Δ_L is too small for the threshold inequality;
at δ = 1/6000 "too small" extends to discriminants of some 10⁵
digits, so the carve-out swallows every family a reader would name.
What keeps the printed corollary true is the standard device of
absorbing finitely many fields into the implied constant.

**Statement/proof mismatch (a V-A defect).** cor:GRH_bound_pointwise
as stated (lines 281–287) has no exceptional set; it asserts the
bound for every L/K satisfying QRH(δ). Its proof (line 583) proceeds
only "For non-exceptional L", and the absorption argument is never
written in that proof. The paper does write the argument in the
Ruppert proof (lines 653–654), so the gap is presentational, not
mathematical, and one sentence would close it. As printed, a central
corollary's statement does not match its proof.

**A8, the cubic case: consumption exact, one presentation defect.**
The reduction is Heath-Brown's Theorem 5 (arXiv:2412.07701v2, the
{CT} environment at hb.tex line 268; printed numbering confirmed in
the PDF). Its hypothesis is a zero-free disc |s−1| ≤ ϑ/log|Δ_K| for
a **single Dirichlet** L-function L(s,χ) (χ cubic for cyclic K,
quadratic for non-cyclic K), with ϑ ≥ C₁(ℓ,ε), one real zero allowed
in the quadratic case; the conclusion is h_ℓ(K) ≪
|Δ_K|^{1/2 − 1/(4ℓ) + ε}, which matches FSW's exponent at d = 3
exactly (1/2 − 1/(2ℓ(d−1))). The word "Hecke" occurs 0 times in
Heath-Brown's paper; his Theorem 5 does not need a Hecke L region
over Q(√−3). What FSW attribute to OAI1112 is nevertheless its
actual statement: OAI1112 Theorem 1.1 gives no zeros for Re s >
11/12 for every finite-order Hecke L-function over Q(√−3), "thus
every Dirichlet L-function" included. A half-plane at 11/12 supplies
Heath-Brown's disc once log|Δ_K| > 12ϑ, with room to spare. The
defect: line 288 cites `\cite{OAI1112,OAI1112}`, the same key twice,
so the sentence's "either of" has one distinct referent as printed
(present in both FSW versions). Both plausible intended keys (the
other is presumably OAI78 at QRH(1/8)) would suffice mathematically;
the printed one does, so the math is unaffected.

**A9, the averaged theorem: the briefed kill path cannot fire; one
reduced finding.** thm:l_tor_averages (lines 297–302) has **no**
density hypotheses: its only hypotheses are fixed degree d over a
fixed K and QRH(δ) for each member's normal closure; the family
density ρ enters through the implied constant (via α_S). The
ρ, C₁, C₂ conditions live in the comparison paragraph that follows
(line 303), not in the theorem. The live findings: (i) the one
density value the paper needs, ρ = 1 for D₄ quartic extensions, is
asserted in one clause with no citation and no derivation (lines
311–312; the count #S(x) ≍ x is standard, but the paper does not
cite it); (ii) the abstract's "arbitrary families" is accurate for
the statement, but the improvement over trivial summation is
density-gated (the theorem improves for r = 1 exactly when ρ > 1/2 +
1/(2ℓ(d−1)), line 311), a caveat the abstract does not mention.

**A12, small generators: split exhaustive, δ-dependence
unquantified.** cor:Rupp1 (lines 349–352) has no case split; its
proof (§3, lines 644–654) is uniform over all fields given QRH(δ)
for the normal closure, applying the splitting corollary at
x = 2Δ_L^{1/2} and feeding the resulting split prime to
Vaaler–Widmer's Theorem 4.1. The prose trichotomy the brief named
(abelian / real-embedding / totally-complex-Galois) is the
pre-existing state of Ruppert's question (lines 341–347) and is
exhaustive; the new argument alone covers all fields. The constant
C_{n,δ} depends on δ through exactly one channel, the threshold
c_{n,δ} (line 648), which is the same unquantified c(δ) as A6; at
δ = 1/6000 the "sufficiently large" regime again begins past
~10⁵-digit discriminants. The corollary promises only the existence
of C_{n,δ}, so nothing is overclaimed in its statement.

## M3 — Credit honesty (A4, A10 framing, the declaration)

**A4, widening provenance, paper side.** Cureton–Thorner v1
(33 pp) states Theorem 1.1 with the region Re s > 1 − 1/6000; the
constant came from keeping the full margin of the cited OpenAI
proof, the smallest entry in its Table 1 being the theta-side saving
1/6000 (v1 §13.2). V2 (36 pp) is **not** the same proof at a better
constant: the 15-section architecture and the OpenAI μ₁₂ input are
unchanged, but v2 states in its own §2 that "the sharper detector
and enlarged Euler domains are proved in Sections 11 and 12", and
§13 redoes the contour comparison with new scales (direct range to
Z^{1/5}, exceptional range to Z^{3301/10000}, segments moved to
Re ξ = 0.8801), concluding "these changes improve the width from
1/6000 to 1/32" (ct-v2.txt lines 508, 2757, 2781–2794).

**A4, repo side.** AxiomMath/DedekindZetaZeroFree has four commits,
all by Dean Cureton, no merges, no PR references. Commit `201bc40`
(2026-10-13, "improve zero-free bound to 31/32") changed 167 files
(+34,147 lines, new Poisson sieve machinery in
`ZeroDetection/Smoothing/Poisson/*` and siblings) and moved the
formalized constant from 5999/6000 (the repo previously formalized
the Hexagon **v1** region) to 31/32 in the Challenge, the Solution,
Main, the README, and formalization.yaml. The README at the pin
still links `https://hexagonmath.org/2610.00200v1` (line 5) while
the code formalizes the v2 region; the 201bc40 README diff touched
only the displayed bound, not the link. Review status in-repo is
self-declared: formalization.yaml (line 154) records
`status: "agent-reviewed"`. No human review artifact is in the repo.
Single-author, single-commit widening of a load-bearing constant is
the QCryptLean squashed-history pattern; it is recorded here as
provenance, not as a defect in the mathematics.

**Framing.** FSW's abstract credits "breakthroughs of OpenAI and
Cureton–Thorner" jointly; the consumption (A10 table) is narrower:
Hexagon v1 carries the headline, OAI1112 carries the cubic case,
and OAI78/OAIartin are context. The paper's §1 prose is accurate
about this; the abstract is broader than the body. On the FSW side,
credit practice between versions improved: v2 added a missing
prior-work attribution (Pierce, for ℓ = 3, n_L = 2) that v1 lacked
(A11 record below).

**The declaration.** End of §1 (line 357), a subsection titled "AI
use declaration", verbatim: "No artificial intelligence tools were
used in this work." Recorded as stated. No public-source check of
this sentence is possible, and none is implied.

## M4 — Fine-print inventory (Murray & van Oorschot)

Every assumption a reader of the headline inherits:

1. **QRH(δ) hypotheses, per theorem.** thrm:generaldelta assumes
   QRH(δ) for ζ_L of the normal closure in play; cor:GRH_bound_pointwise
   and thm:l_tor_averages assume it per field (for averages, per
   member's normal closure); cor:Rupp1 assumes it for ζ of the normal
   closure over ℚ. None of these is discharged inside the paper.
2. **The unverified-preprint dependency.** V-B discharges item 1 by
   citing hexagon:2610.00200v1 and OAI1112, preprints whose arguments
   the authors state they have not verified (line 155). The audit
   consumed them as cited, by design; their own correctness is not
   a finding of this note in either direction.
3. **The exceptional-extensions carve-out.** The pointwise bound is
   proved for all but O_{δ,K,n_L,ℓ,ε}(1) extensions, with the
   count's δ-dependence unquantified (M2). At δ = 1/6000 the
   carve-out covers every discriminant below ~10⁵ digits.
4. **Effectivity constants.** c₁ in the Chebotarev error term is
   absolute and effectively computable; the threshold constant c(δ)
   is neither given a form nor claimed effective, and C_{n,δ} in
   cor:Rupp1 inherits it whole. The v2 text also widens one implied
   constant's declared dependencies to (d, K, δ) (line 612, A11).
5. **Per-family density.** The averaged theorem's improvement (not
   its statement) needs family density ρ above a threshold
   (line 311); the one named value, ρ = 1 for D₄ quartics, is
   uncited in the paper.
6. **Artifact fine print.** The Lean support for the consumed
   region is by inclusion from a stronger formalized statement
   (M1), at textual grade only (A3 GAP), in a repo whose review
   status is self-declared "agent-reviewed" and whose README links
   the superseded v1 paper.

## A11 record — FSW v1 → v2 delta

Diff of `main.tex` v1 (tarball sha256 `50e1d13a…f4dd`) against the
pinned v2: 6 changed lines, no theorem, corollary, proposition, or
lemma statement differs, no hypothesis changed, theorem-environment
count identical (8 in each), lines 155, 288, 347 byte-identical.
The changes: (a) line 275, one prior-work attribution added (Pierce,
ℓ = 3 and n_L = 2; exactly two new `.bbl` entries); (b) line 321,
one phrase dropped; (c) line 323, typo fix; (d) line 343, the numeral
in "effective constant C ≥ 20" dropped, in FSW's *description of
Widmer's cited result*, not in an FSW statement; (e) line 577, typo
fix; (f) line 612, inside the proof adapting Koymans–Thorner, an
implied constant's declared dependencies widened from δ to
(d, K, δ); the threshold at that step is unchanged. The recon's
structural claims describe v2's mathematics.

## Receipt

- FSW v2 PDF `2432308ec3ec4586985365a10403a7b06ed6d524d36544ba1dad2f7f63cc036f`;
  e-print tarball `02a69908c488c0a3baf5a6dc4e35036d441885f6edaabab843f970279c8ba7cf`;
  `main.tex` `7e8aed18c8e3d0f90f2666505bd7d411c7935170acf984670118fcafdf592aef`;
  `main.bbl` `c4f130b98eceb2583c911be0a564000987dbd79d3962b876e15a95eae3256d55`.
- FSW v1 e-print tarball `50e1d13adaf557e9b242a453be3a1fe4f04d5d83acaf6f0e052780651c45f4dd`
  (retrieved 2026-10-20 from arxiv.org/e-print/2610.18491v1).
- Cureton–Thorner v1 PDF `ae3ec63272056714c81c6a56ac860c76885a384d9569cbf6ca45cd4cb9433d09`;
  v2 PDF `46cc2c2ac941a7c702b61641ff30f6a3fa9e88d273559aa014c278b08ab1d126`.
  Theorem 1.1 quoted from ct-v1.txt line 155 and ct-v2.txt line 253.
- Heath-Brown arXiv:2412.07701v2: e-print
  `7d253fa68b3ca5f3d36ae921b5e5f8a5dbffcf9218f0511f37f127c9e11d8ca0`,
  PDF `9875f3d053a27430e85f59de70249db8f0154fe54549596985934561c8acf896`;
  Theorem 5 = {CT} environment, hb.tex line 268, hypothesis and
  conclusion quoted in M2; "Hecke" count in hb.tex: 0 (grep).
- OAI1112 PDF `f919b57829b178c8e60e7c17b018cf773e7907cf642ef5a3347d8a826e8dbf18`;
  Theorem 1.1 at oai1112-paper2.txt lines 54–56.
- Lean repo pin `09afbb4ce6570c1615d58509dc197fc9f0956b7d`
  (`git rev-parse HEAD`; tree clean, `git status --porcelain`
  empty); toolchain file `leanprover/lean4:v4.35.0-rc3`; Mathlib rev
  `0493595ecd5da8ef14742febab99728f98e948e8` (lake-manifest.json).
  A2 diff: whitespace-normalized string comparison of both theorem
  signatures in Challenge vs Solution, identical. A3-textual:
  ripgrep counts over 5,528 files (sorry 2, both in Challenge; all
  other escape patterns 0). A4-repo: `git log` (4 commits),
  `git show --stat 201bc40` (167 files, +34,147).
- A6 numeric check: bisection on 6000·ln t + 12000·ln ln t = ηt,
  t = ln Δ, c(δ) = 1, spot root re-checked by direct substitution
  (residual < 1 in 113,755); script and full grid in
  `~/workspace/fsw-recon/audit-work/paper-math.md`.
- **A3 GAP, closing recipe:** install the pinned toolchain
  (`elan toolchain install leanprover/lean4:v4.35.0-rc3`), then in
  the repo at `09afbb4`: `lake exe cache get`, `lake build`, and
  `lake env lean` on a scratch file with `#print axioms` for
  `DedekindZetaZeroFree.dedekindZeta_ne_zero` and the Solution
  module's `main` and `heckeCorollary` (or the README's comparator
  run, `lake comparator --config comparator.json`). Expected cost:
  multi-hour on this VM class, reboot-interrupted and resumable via
  `.lake`; a BPF-free, disk-room host (the Dell runner class) is the
  cheaper lane. Until then the README's "only the three standard
  axioms" sentence is the repo's claim, not this audit's receipt.
- No CI runs were dispatched for this audit; no repository outside
  fragile-proof-audit was written; no author was contacted.

## Surviving GAPs (named, not silent)

1. A3: no build, no `#print axioms` receipt for the Lean artifact
   (recipe above).
2. The consumed preprints (hexagon:2610.00200v1, OAI1112, and the
   OpenAI inputs behind them) were not re-verified; V-B is a
   consumption verdict only.
3. c(δ) and the exceptional count's δ-dependence are unquantified
   in the paper itself; A6's numbers are the best case c(δ) = 1.
4. OAI78's own PDF was not fetched; its QRH(1/8) region is recorded
   from FSW's line 155 and bibliography only. It is intro context
   for FSW and load-bearing nowhere in this audit's verdicts.

## Correction (2026-10-20, later the same day)

In M2 (A6), the sentence "At δ = 31/32 the same computation collapses
to trivial sizes" is wrong in two ways. First, the parametrization:
QRH(δ) means no zeros with Re s > 1 − δ, so the Hexagon v2 region
Re s > 31/32 corresponds to **δ = 1/32**, not 31/32. Second, the
number: at δ = 1/32, η = 1/8, c = 1, the crossover recomputes to
log₁₀ Δ ≈ 1,359, i.e. a discriminant of roughly 1,400 digits. That
is far below the cited region's 395,225 and far above trivial. The
qualitative point the sentence carried stands (the widened region is
much more effective than the cited one, and it is still not the
region the paper cites); the label and the word "trivial" do not.
The recomputation is by `scripts/harvest-loop/qrh_effectivity_screen.py`
(added to this repo the same day), which reproduces this note's A6
grid to within 0.5 log₁₀ units on all 16 cells; control values at
η = 1/8, c = 1: δ = 1/2 → 56 digits, δ = 1/12 → 451 digits,
δ = 1/32 → 1,359 digits, δ = 1/6000 → 395,225 digits.
