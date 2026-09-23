# Related-work research memo — replay audits of published mathematical claims

*Research memo for the methods-paper related-work section. Saved 2026-09-23.
This is source material, NOT the section draft. Do not copy verbatim into the paper
without re-checking each citation against the primary source.*

Each line below: 2–4 key citations (authors, venue, year) + why it matters for
situating the paper — especially where the literature already does something like
replay auditing, and where this paper differs. A "Verification" note per line
distinguishes what was checked against a primary source from what came second-hand.

---

## 1. Polymath15 on the de Bruijn–Newman constant (Λ ≤ 0.22)

- **D. H. J. Polymath, "Effective approximation of heat flow evolution of the
  Riemann ξ function, and a new upper bound for the de Bruijn–Newman constant",
  arXiv:1904.12438 (Apr 2019); published Research in the Mathematical Sciences 6
  (2019), paper 31.** The paper proves several effective (fully explicit-error)
  estimates on H_t(x+iy) and combines them with numerical computations to get
  Λ ≤ 0.22 unconditionally, plus stronger bounds conditional on further numerical
  verification of RH. Its Table 1 is the key artifact: a conversion table from
  "RH verified to height H" into a Λ upper bound.
- **T. Tao, Polymath15 proposal and eleven working threads, terrytao.wordpress.com
  (Jan 2018 – 2019); project wiki at michaelnielsen.org/polymath.** The public
  record of a massively collaborative computational-analytic project: the
  methodology, parameter choices, and numerical work were developed in the open.

**Why relevant.** This is the closest existing precedent for what the paper calls
a replay audit's *target*: a published, computer-assisted bound whose decisive
content is a computation (effective estimates + numerics), and whose verification
story is "the estimates are proved, the numerics were run by the authors." The
paper differs in posture: Polymath15 *produced* the computation; the replay-audit
campaign *re-executes someone else's* under a hostile prior. Note also the
structural point the paper should make: Polymath15's Table 1 is exactly the kind
of artifact a replay audit would target — a table whose entries depend on someone
else's RH-verification computation — and Platt–Trudgian's corollary below shows
the bound improving precisely when that external computation is re-run harder.

**Verification.** Citation details (title, arXiv ID, journal, paper 31) verified
against the arXiv abstract page for 1904.12438. The Table-1 description is
confirmed by the abstract and by Platt–Trudgian §3.4 (see line 2). Finer
methodological claims (interval arithmetic use, zero-tracking) are from
secondary summaries, not the PDF.

---

## 2. Platt–Trudgian 2020 (Λ ≤ 0.2)

- **D. J. Platt and T. S. Trudgian, "The Riemann hypothesis is true up to
  3·10¹²", arXiv:2004.09765 (Apr 2020); Bull. Lond. Math. Soc. 53 (2021).**
  The paper's main result is the verified RH height H = 3,000,175,332,800.
  Its §3.4 ("The de Bruijn–Newman constant") notes that the second row of
  Polymath15's Table 1 gives Λ ≤ 0.2 as soon as H > 2.51·10¹² is shown, and
  states this as **Corollary 2: Λ ≤ 0.2**. The authors add that the next table
  entry (requiring H slightly above 10¹³) would give Λ < 0.19, which their H
  does not reach: "We have not pursued this."

**Why relevant.** This is the cleanest real-world example of the paper's thesis
that computational claims compose: a Λ bound is only as strong as someone
else's RH-verification computation, and improving the bound meant re-running
the underlying computation at larger scale (NCI/Gadi machine hours acknowledged
in the paper). It also models the honest-boundary behavior the paper advocates:
the authors state exactly which table entry they reach and which they do not.
The replay-audit campaign's Gomila case study sits directly in this lineage
(Polymath15 method → Platt–Trudgian height → a claimed 0.1787854 instantiation),
so this citation does double duty: related work *and* the case study's provenance.

**Verification.** The Corollary 2 / Table 1 / "We have not pursued this" material
was verified against the arXiv PDF text itself. The journal venue/year (Bull.
Lond. Math. Soc. 53 (2021)) is from secondary sources (Wikipedia, zeta-lab
notes) — confirm against the published version before citing.

---

## 3. Lean's mathlib review process as a verification institution

- **leanprover-community, "Pull Request Review Guide",
  leanprover-community.github.io/templates/contribute/pr-review.md (living
  document).** The official guide for reviewing mathlib PRs. Key structural
  facts: anyone in the community may *review* a PR, but only maintainers may
  *merge*; there is a recognized "mathlib reviewer" tier whose approving reviews
  get merged faster. Reviews are expected to cover style, documentation,
  declaration placement, library integration (API generality, simp/ext tagging,
  no instance diamonds), and duplication — i.e., everything *except* logical
  correctness, which the kernel already guarantees.
- **leanprover-community, "How to contribute to mathlib",
  leanprover-community.github.io/templates/contribute/index.md.** Notes the
  scale of the institution: 2600+ open PRs (as of mid-2026), a public review
  queue/dashboard, and explicit guidance that contributors should find their own
  reviewers.

**Why relevant.** This is the strongest existing *institution* for the thing the
paper says is missing — except that it verifies a different object. Mathlib
review is post-kernel human review of formalized proofs: the machine checks
correctness, humans check fitness (naming, generality, placement,
faithfulness to the intended statement). The paper's replay audits do the
mirror image: for *informal* computational proofs, there is no kernel, so the
audit must supply both the correctness check (re-running the computation) and
the fitness check (is this the claim the paper actually makes?). Citing mathlib
lets the paper say precisely what it is *not* proposing (another formal library
with a review queue) and what gap remains (computational claims in ordinary
published prose have no kernel and no review queue).

**Verification.** Could NOT open the guide page directly (fetch failed); the
description above is from search-result snippets of the official pages. Re-verify
against the live pages before citing specifics like the 2600-PR figure.

---

## 4. Journal of Formalized Reasoning / certified-programs literature

- **Journal of Formalized Reasoning (J. Formaliz. Reason.), ISSN 1972-5787,
  est. 2009, Univ. of Bologna / AlmaDL, peer-reviewed open access.** Scope:
  "significant, automated or semi-automated formalization efforts in any area,"
  with emphasis on *proof techniques and methodologies* and their impact on the
  formalization process; explicitly "an effort will be made to ensure that the
  'experimental data' backing formalisation papers will remain accessible."
- **R. Rieu et al., "A Why3 proof of GMP algorithms", J. Formaliz. Reason.**
  (representative article, doi:10.6092/issn.1972-5787/9730). A certified-programs
  instance: a comprehensive arbitrary-precision integer arithmetic library
  (GMP algorithms: Toom–Cook, division, square root) verified in Why3 down to
  an efficient C implementation, covering functional correctness, memory safety,
  and absence of arithmetic overflow — i.e., the computation and its
  verification delivered as one artifact.

**Why relevant.** JFR is the archival venue whose *stated* mission overlaps the
paper's: methodology of formalization, reusable techniques, accessible
experimental data. Two differences to draw: (1) JFR publishes *constructions*
(formalizations the authors built); the replay-audit paper publishes
*re-executions of other people's constructions* with adversarial dispositions —
a genre JFR's scope does not obviously cover. (2) The certified-programs line
(Why3/GMP) shows what "the computation and its proof arrive together" looks
like when done by the original authors; the replay campaign exists because, in
ordinary published mathematics, they usually do not. Caveat for the paper:
one secondary source describes JFR as effectively defunct (nothing after
Vol. 13, Dec 2020) — verify before characterizing the venue's current status.

**Verification.** Journal scope/ISSN/publisher verified against Wikipedia and
jfr.unibo.it/about (via snippets). The "effectively defunct" claim is
second-hand (a GitHub publication-routes doc) — treat as unverified.

---

## 5. Proof-repair literature

- **T. Ringer, R. Porter, N. Yazdani, J. Leo, D. Grossman, "Proof Repair across
  Type Equivalences", Proc. PLDI 2021 (arXiv:2010.00774).** Introduces
  *proof repair*: algorithms and tools that fix formal proofs in response to
  breaking changes (here, changes in types), via proof-term transformation +
  transport across equivalences, implemented in the PUMPKIN Pi Coq plugin and
  demonstrated on eight case studies.
- **C. Viola, M. Fan, T. Ringer, "Proof Repair across Quotient Type
  Equivalences", Proc. ACM Program. Lang. 9, OOPSLA2, Article 386 (Oct 2025).**
  Extends the line to quotient types in Cubical Agda/Rocq; its introduction
  states the field's premise plainly: writing and *rewriting* proofs is
  ubiquitous, "challenging to deal with even for experts," and repair aims to
  automate the fixing.

**Why relevant.** This is the literature on what happens *after* a formal proof
breaks — the closest analogue to the paper's GAP disposition ("the route is
damaged but repairable"). The contrast is instructive: proof repair assumes a
proof assistant, a precise breakage (type change), and a repaired artifact that
the kernel re-checks. The paper's GAPs are prose verdicts about informal
arguments with no kernel to confirm the repair — which is exactly why the
reviewer-facing version of this paper needs an evidentiary standard for GAPs
that the proof-repair literature gets for free from the type checker. Cite it
as the formal-methods cousin that shows what "repairable" means when
verification is mechanized, to throw the informal case into relief.

**Verification.** Both citations verified against arXiv/publisher pages
(abstracts, venues, DOIs as shown in search results).

---

## 6. Adversarial verification / audit framings from cryptography and security

- **Code4rena competitive audits (2021–; winding down 2026 per TradingView/
  The Block reporting).** Independent researchers ("wardens") compete for a
  fixed prize pool to find vulnerabilities in a code snapshot; leaderboard
  rankings; 700+ public reports. The institutionalized form of "many hostile
  strangers read the artifact before it ships."
- **Sherlock audit contests.** Documented pipeline: scope setup → senior
  (lead watson) review pass → global researcher push → multi-stage judging
  (deduplication, severity correction) → fix review by the senior reviewer.
  The judging + fix-review stages are the analogue of the paper's controls and
  verdict-lock discipline.
- **NCC Group cryptographic reviews (e.g., Olm/Megolm 2016; Filecoin
  Bellman/BLS 2020; Go x/crypto/ssh 2025–26).** The professional-services
  version: manual source inspection + test execution against a pinned commit,
  findings with severity/impact/exploitability, public reports. The go-x/crypto
  report's "Project Information" block (exact commit hash, consultant-days,
  method, scope) is a model for the artifact-pinning the paper demands of
  itself.

**Why relevant.** This is the "hostile witness" analogue the paper's §8 reaches
for, and it is real — but it lives in *industry practice*, not in a single
citable theory paper. The paper should cite the practice (contests + judging +
fix review) as the existence proof that adversarial scrutiny can be
institutionalized, then mark the difference: security audits judge code against
a threat model, while replay audits judge a *proof* against its own claims —
and a BREAK must name the lemma and the false instance, not just a severity.
Do not oversell: none of these sources theorize adversarial verification; they
do it.

**Verification.** Code4rena/Sherlock mechanics from their docs and secondary
summaries; the Code4rena wind-down from a TradingView/Reuters-style news
snippet — second-hand, and volatile. NCC report formats from the reports'
own text via search snippets. No single academic "adversarial audit theory"
paper was found — flagged below as the thin line.

---

## 7. Post-publication review mechanisms

- **PubPeer (est. 2012).** Anonymous post-publication commenting platform;
  documented as a whistleblowing venue whose threads have led to corrections
  and retractions (Retraction Watch coverage).
- **J.-L. Ortega and L. Delgado-Quirós, "How do journals deal with problematic
  articles", El Profesional de la Información (2023),
  doi:10.3145/epi.2023.ene.18.** Of 17,244 PubPeer-commented articles, only
  21.5% of those deserving an editorial notice (honest errors, methodological
  flaws, fraud, manipulation) were ever corrected by the journal. I.e.,
  post-publication scrutiny *finds* problems at scale but the formal
  correction machinery largely does not act on them.
- **Polymath-style collaboration (Tao's Polymath15 proposal, Jan 2018; eleven
  working threads; public wiki).** The constructive side of post-publication
  scrutiny: an open, massively collaborative re-derivation whose working
  papers are the threads themselves.

**Why relevant.** The Ortega result is the paper's best quantitative friend:
it shows that the existing post-publication layer detects but does not
*dispose* — findings sit in comment threads without verdicts, which is exactly
the gap a disposition taxonomy (BREAK/GAP/PASS/SKIP with a lock) is designed
to fill. The paper's move from "someone commented" to "a gate fired and the
lock recorded it" is the differentiator to stress. Polymath15 belongs here
too, as the positive case: open collaborative verification that actually
shipped a published result.

**Verification.** Ortega & Delgado-Quirós citation (journal, year, DOI, the
17,244 / 21.5% figures) verified against the article page snippet. PubPeer
launch/anonymous-commenting from Wikipedia. Polymath15 threads from Tao's
blog tag pages (secondary summaries).

---

## 8. Terence Tao's writing on machine-checked / computer-assisted proofs

- **T. Tao, "Machine-Assisted Proof", Simons Foundation lecture (Feb 19, 2025).**
  Survey from the four-color theorem's 5,000-graph computation (noted as
  error-prone, revised several times) through proof assistants as languages
  that "generate proof certificates," enabling large-scale collaboration;
  the forward-looking claim is that the synthesis of AI tools with proof
  assistants is where the gap closes.
- **T. Tao, "Machine assisted proof" summary of views, Notices of the AMS
  (Jan 2025), via teorth.github.io living summary.** The load-bearing idea:
  "verification is the filter that makes an unreliable tool useful" —
  "in math, we can completely check and verify outputs, and this really
  filters out a lot of the rubbish"; and the caution: "I would caution
  against using AI tools without the ability to independently verify their
  output."
- **T. Tao, ICM 2026 lecture "Mathematics after proof scarcity" (via
  abdgafartunde.github.io summary, Aug 2026 — second-hand).** The pipeline
  argument: problem → proof generation → *verification* → exposition →
  acceptance → digestion → canonical theory. Even a fully machine-verified
  150-page proof is not a solved problem for the discipline until it is
  exposited, accepted, and digested. Directly relevant to the paper's
  limitations section: replay audits verify, they do not digest.

**Why relevant.** Tao is the highest-status voice saying the paper's two
central things: (1) computation in proofs needs independent verification, and
cheap verifiability is what makes powerful tools safe; (2) verification is
necessary but not sufficient for mathematical knowledge — which bounds the
paper's claims honestly (a PASS is not an endorsement of importance, a BREAK
is not a contribution to the field). The ICM pipeline also gives the paper a
respectable frame for "where replay audits sit": they are the verification
stage, industrialized, for proofs whose verification stage was skipped.

**Verification.** Simons lecture content from a published transcript
(josherich.me); the Notices quotes via Tao's own living summary page
(teorth.github.io) — treat quote wording as second-hand until checked against
the Notices piece. The ICM 2026 lecture is via a third-party blog summary
only — do not cite claims about it without the primary source.

---

## Strongest citations (for the section)

1. **D. H. J. Polymath, arXiv:1904.12438 / Res. Math. Sci. 6 (2019), paper 31**
   — the computational-methodology precedent and the Table-1 artifact.
2. **Platt & Trudgian, arXiv:2004.09765 / Bull. Lond. Math. Soc. 53 (2021),
   Cor. 2** — verified from the PDF; computation-composes-honestly exemplar.
3. **Ortega & Delgado-Quirós, EPI (2023), doi:10.3145/epi.2023.ene.18**
   — the 21.5% figure that motivates dispositions over comments.
4. **Ringer et al., PLDI 2021 (proof repair)** — the mechanized cousin of GAP;
   sharpens what "repairable" means with vs. without a kernel.
5. **mathlib PR Review Guide (leanprover-community)** — the existing
   verification institution; mirror-image contrast (kernel + human fitness
   review vs. no kernel at all).

## Thin lines / not found

- **No academic "adversarial verification theory" paper.** The crypto-audit
  analogue (line 6) is industry practice (Code4rena, Sherlock, NCC reports),
  not a theorized literature. If the section wants a scholarly anchor for
  "hostile scrutiny as method," it will need the economics-of-bug-bounty
  literature or the SoK systematization papers — not researched here.
- **mathlib review guide details** could not be verified against the live page
  (fetch failed); currently sourced from search snippets.
- **Tao ICM 2026** is third-party summary only; several Tao quotes are via his
  living-summary page rather than the primary venues.
- **JFR's current status** (active vs. defunct after Vol. 13/2020) is
  second-hand; verify before characterizing.
- **Platt–Trudgian journal venue/year** from secondary sources; confirm
  against the published Bull. LMS version.
