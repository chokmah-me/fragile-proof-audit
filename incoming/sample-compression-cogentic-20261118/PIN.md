# PIN — sample-compression-cogentic (registered 2026-11-25)

Registered 2026-11-25 at the user's tap ("Register it on
the board as a claim (PIN)") on the 2026-11-24 triage.
This is a triage-level registration: the arXiv record and
the paper's own source were pinned and read at the source
level (record: ~/workspace/sample-compression-triage-2026-11-24/TRIAGE.md).
No forge, no build, no replay applies: the artifact is a
30-page prose proof with no code and no formalization.
What is registered is the claim, the pins, the disclosed
agent provenance, and the M1 seams a real audit would open
first. Board status: claim registered, statements pinned
at source, correctness UNJUDGED (no part of the proof was
re-derived in triage). Verdict lock untouched.

## Claim

Cai, Gupta, Jiang, Liaw, Mehta, Moran, Velegkas, Wang and
Warmuth, "Near-Quadratic Sample Compression for All VC
Classes" (arXiv:2611.25011v1, 18 Nov 2026): every binary
concept class of VC dimension d >= 1 admits a labeled
sample compression scheme of size k = O(d^2 log^2 d)
examples and b = O(d log^2 d) side-information bits (Main
Theorem, intro.tex). Presented as proving the weaker
Floyd-Warmuth conjecture (a bound polynomial in d); the
prior bound depending only on d was Moran and Yehudayoff's
exponential (2016). The strong O(d) conjecture remains
open, and the paper says so.

## Canonical artifact

arXiv:2611.25011v1 [cs.LG], submitted 18 Nov 2026.
PDF sha256
`07136190096dbaad8c5e8b8338fb5ad31acc31e10845a5e651dd7b2f111be9f2`;
source tarball sha256
`b525249e0005ad190cfc902f28fd8af816f959ba2c95d26ecfc8caa38188c849`.
30 pages, about 15,000 words of TeX. Sections: intro,
dichotomy (the core construction, 5,114w), mwu, entropy,
appendix, conclusion, AI disclosure. No code, no Lean, no
ancillary files.

## Provenance (disclosed by the authors, verified at source)

The paper carries a dedicated AI Disclosure section
(ai_disclosure.tex), read verbatim in triage: the proof
was obtained autonomously by the Cogentic multi-agent
orchestration (companion paper arXiv:2609.40324, same
group minus Moran and Warmuth) running on Gemini 4
Carbon. The agent was prompted with three tiers (Tier 1:
full resolution of the conjecture, perhaps up to
polylogarithmic factors; Tier 2: a polynomial bound;
Tier 3: a subexponential bound), with no hints or
suggested approaches. Total cost at current Gemini API
pricing: approximately $344. The bound improved in steps:
O~(d^16), O~(d^6), O~(d^3), O(d^2 log^3 d), then the
published O(d^2 log^2 d). The human authors simplified
the proof and improved the exposition afterward and state
that they take responsibility for the correctness of the
results. Two co-authors are central figures in the claim
itself: Warmuth co-posed the conjecture (Floyd-Warmuth
1995); Shay Moran co-authored the 2016 exponential bound
this result replaces.

## M1 seams (named at registration, none adjudicated)

1. Definition seam, the headline question. The scheme is
   a generalized (k, b) scheme: side information
   b = O(d log^2 d) grows with d, and most of the k
   retained examples are unlabeled anchor points; only
   O(d log d) retained examples are labeled (disclosed in
   the paper's intro and conclusion). Under the standard
   (k, b) framework this settles the weak conjecture as
   the paper states it; whether the community accepts
   growing side information plus mostly-unlabeled
   retention as "the" weak conjecture is a question about
   the statement, not the proof. Warmuth is both the
   definition's authority and an interested party.
2. Reconstruction is improper: the reconstructor outputs
   a weighted majority vote of concepts from the class,
   not necessarily a class member. Standard in this
   literature; the scheme is generalized throughout.
3. Finite-class reduction: the proof assumes the class
   finite, citing the Ben-David-Litman compactness
   theorem for sample compression, with infinite domains
   handled via that citation plus a remark. A checkable
   dependency, not a gap by itself.
4. Where the weight sits: the bound comes from the
   dichotomy/entropy construction of a terminating anchor
   set of size O(d^2 log^2 d); the MWU encoding lemma
   adds only O(d log d) labeled examples. If the proof
   breaks, it breaks in dichotomy.tex or in the
   exit-condition argument in entropy.tex.

## Community state at registration

v1 is six days old at registration. Search surfaced only
summary sites restating the abstract (ZICQ, Lacuna,
LodeHQ, Emergent Mind digest of 2026-11-24, which carried
the bound accurately but omitted the agent provenance).
No public verification, objection, or independent read
was found. A full audit would be a human-grade prose
proof read of about 15,000 words with the definition
seam settled first; it is a session of work, not a
dispatch, and no lane is assigned.
