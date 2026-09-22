# NCI (Non-Cancelling Intersections) Conjecture — SKIPPED, no finite gate

**Target Identifier (corpus doc):** NCI Conjecture, 2026 Refutation, arXiv:2608.27416
**Verdict: NOT GATEABLE — scope decision, no computational verdict recorded.**

## What the corpus doc claims

`corpus/live-fragile-proofs-2024-2026.md` §"The Non-Cancelling Intersections
(NCI) Conjecture" gives a full Target Identifier block (unlike the
Chung-Graham-Spiro ghost entry) and asserts:

> **Verifiable Gate / Counterexample**: Python script validating the
> non-existence of admissible sets between sizes [image82] and [image83] in
> the specified marked plane configuration.

The ranking table (row 7) simultaneously flags this same target as
"Formalization Tractability: Low (Dot-Algebra Trees)" and "Python/CPU Gate
Runtime: N/A (Symbolic logic bound)" — an internal contradiction: one place
in the same document claims a runnable Python gate exists, another says N/A.

## What the actual paper says

Fetched and read the real paper: Hermann Wilhelm, "Refutation of the
Non-Cancelling Intersections Conjecture," arXiv:2608.27416v2 (31 Aug 2026,
`incoming/nci-wilhelm-2608.27416.pdf`, TU Ilmenau). Confirmed live on arXiv
via WebFetch abstract check before download.

The paper's actual structure:

- **Theorem 8.1 / Corollary 8.2** (the refutation): for every prime `p ≥
  10^5` there is a marking `m` (an assignment of `w = ⌈√(2p)⌉+1` marked
  points to each of the `p²+p` lines of `F_p²`) such that the lattice
  `P_{p,m}` admits no winning dot-algebra tree — hence the family of sets
  `{S_{a_{i,j}}}` has no non-cancelling-intersections representation, and the
  NCI conjecture is false.
- **Lemma 7.2**, the step that actually produces the marking `m`, is a
  **first-moment (probabilistic existence) argument**: choose `m` uniformly
  at random per line, bound `Pr[T admissible]` by a union bound over short
  traces (Lemma 7.1's Cauchy-Schwarz counting bound), sum over all candidate
  sizes `2p ≤ |T| ≤ 4p` to get an expected admissible-set count `E_p < 1` for
  `p > 600`, and conclude *some* marking works because a non-negative
  integer-valued random variable with expectation `< 1` must sometimes be 0.
  **No marking is exhibited.** Nothing in the paper specifies which of the
  `(C(p, w))^{p²+p}` candidate markings actually has the property.
- **Remark 8.3**: even naming the smallest prime the theorem literally covers
  (`p = 100003`) only pins down that the resulting lattice has `< 1.1×10^15`
  elements — "far from a lattice one would want to write down."
- **§9 Open Problems, item 1, verbatim**: *"Explicit counterexamples and
  lower bounds. The proof of Theorem 8.1 is still a first-moment argument and
  produces no explicit marking. What is the smallest lattice on which no
  winning da-tree exists? Exhaustive search on `P_{p,m}` for small `p` is now
  conceivable."*

The author is explicit, in his own words, that constructing even one small
explicit instance is unsolved research, not a solved-and-omitted detail.

## Why this doesn't get a gate

This campaign's discipline (`docs/GATE-BEFORE-PROVE.md`, Governing discipline
§4/§7) requires a computable, executable witness reproducing the refutation —
the load-bearing lemma has to cash out in something a script can check in
under 60 seconds. Here:

- The only numerically checkable content is the algebraic double-counting
  identities `(7.1)` (`Σ j_ℓ = |T|(p+1)`, `Σ C(j_ℓ,2) = C(|T|,2)`) — these
  are true of *every* finite point set in *every* affine plane, unconditionally.
  Testing them would be exactly the kind of check-that-cannot-fail ceremony
  Governing discipline #7 forbids.
- Lemma 7.1's Cauchy-Schwarz bound and Lemma 7.2's union-bound arithmetic are
  correct algebra (checked by hand against the PDF, not by code) — there is
  no numeric constant here in the shape of prior Type-A targets (contrast
  Tang-Zhang, where an explicit real number was checkable to 60 digits).
- The one object that would make a genuine Type-F gate — an explicit `(p, m)`
  pair with no admissible set of size in `[2p, 4p]` — does not exist yet
  anywhere in the literature, by the refuting author's own admission. Building
  one from scratch is an open research problem in extremal combinatorics
  (plane geometry incidence bounds over `F_p`), not a "reproduce the paper's
  own witness" gate. It is out of proportion to what this campaign spends per
  target, and would not be *reproducing* anything — it would be *originating*
  a new result the source paper doesn't contain.

## Verdict

**SKIPPED — no finite gate.** Not a BREAK of the refutation (nothing found
suggests Theorem 8.1 or its proof is wrong) and not a PASS in the campaign's
sense (there is nothing checkable to pass). This joins the "no finite gate"
class alongside Joshi/IUT, Collatz, and Goldbach "monitors" in
`docs/WORKPLAN.md`'s **Do not reopen** table. The corpus doc's claimed
"Verifiable Gate" for this target should be treated as **fabricated** —
neither the cited paper nor its predecessor (Wilhelm, arXiv:2608.19414,
the left-linear-tree paper referenced as `[2]`) contains a runnable
counterexample script; both are pure existence proofs.

**Local PDF pinned:** `incoming/nci-wilhelm-2608.27416.pdf` (gitignored),
fetched directly from arXiv, live-checked via WebFetch before download.

**Do not reopen** unless: (a) someone publishes an explicit small-`p`
counterexample (the paper's own Open Problem 1), making a Type-F gate
possible, or (b) the task is redefined as *originating* new research (running
our own exhaustive/heuristic search for a small explicit marking) rather than
*auditing* an existing one — a different kind of campaign activity.
