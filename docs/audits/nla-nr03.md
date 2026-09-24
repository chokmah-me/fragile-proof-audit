# Audit note — NLA-NR03 Holden 127-term nonnegative factorization of C7 — Type-E replay: PASS; Type-G verification-credit scan: GAP

**Target:** harvest 2026-09-24, Card 2 (`nla-nr03`), fragility 4.
**Paper:** Sidney Holden, "The quadratic correlation matrix need not have full nonnegative rank: A counterexample to NR-03 and an explicit factorization for every size", September 2026, Flatiron Institute (Center for Computational Biology).
**Pins:** `incoming/nla-nr03-holden.pdf` (345,135 bytes, 6 pages, SHA-256 `249a1c630d2442be22456cc7eaf12f02c80439c00ea08508663cb0742563db02`); certificate `incoming/nla-nr03-factors_n7.json` (207,141 bytes, SHA-256 `fa515775f9c77e5dfe85109125d3f730c4b36684894730096247cd67fcc60bb9`, byte-identical to the git blob at the pinned commit); code tree sgstepaniants/OpenProblemsInNLA at `f664d07e82aaa60bc9c78dd1946e763168c5c530`; catalog ajt60gaibb/OpenProblemsInNLA at `0689db001ddc4c54f2652ed4b13b753637fef700`.
**Date:** 2026-09-24. **Scope:** Type-E exact replay of the load-bearing certificate + Type-G scan of the Lean-verification credit. No Lean build attempted (nothing to build against — see below).

**Verdicts: Type-E PASS. Type-G GAP** (catalog verification credit, not the proof route). The mathematical claim — rank₊(C7) ≤ 127 via explicit exact factorization — is sound. What fails is RESOLVED.md's "Lean verified" credit for it.

## The claim

NR-03 asks whether rank₊(C_n) = 2ⁿ for every n ≥ 3, where C_n(a,b) = (1 − |a ∩ b|)². Holden proves rank₊(C_n) ≤ 2ⁿ⁻¹ + C(n,1) + C(n,2) + C(n,4), hence "rank₊(C7) ≤ 64 + 7 + 21 + 35 = 127 < 128". The paper is explicit about what it does *not* claim: "It does not assert that the exact nonnegative rank of C7 is 127, or that 7 is the smallest counterexample dimension."

## Type-E: the certificate verifies (PASS)

`scripts/gates/nla_nr03.py` replays the paper's own construction-independent check (Appendix A), re-derived — the target matrix is rebuilt from the mask definition C7(a,b) = (1−popcount(a&b))², never copied from the certificate:

- metadata n = 7, r = 127; W is 128×127, V is 127×128, 128 denominators
- every entry of W, V a nonnegative int; denominators positive ints ⊆ {1,4,9,16,25,36}; W entries ⊆ {0,1,2}; V entries ≤ 36 — all matching the paper's stated ranges
- **integer path:** Σ_k W[a][k]·V[k][b] == d[b]·C7(a,b) for all 16,384 entries — 0 bad
- **rational path:** H = V·diag(d)⁻¹ as exact `Fraction`s; W·H == C7 over all 16,384 entries — 0 bad
- corroboration: rebuilt C7 has exactly 5,103 zero and 11,281 positive entries, matching the paper's stated split (5,103 = 7·3⁶, verified combinatorially in-gate)
- exactly 127 atoms (64 complementary pairs + 7 singletons + 21 pairs + 35 four-sets, per the paper's ordering)

Discrimination control (`scripts/controls/nla_nr03_control.py`): **NO FALSE POSITIVE** — single-entry perturbations of W, V, and one denominator are each rejected via the exact-product check (matched: everything else fixed); the unperturbed certificate passes the same path; the target is rebuilt from the definition.

## Type-G: the "Lean verified" credit does not survive its own sources (GAP)

Three pinned sources, mutually contradictory on exactly one point:

1. **Catalog** (`RESOLVED.md` at `0689db0`, NR-03 section): "**Lean verified — 2026-09-13.** ... The [immutable ten-export Lean proof](.../tree/f664d07.../NR-03/lean) ... The canonical Linux Comparator/default-kernel verification ... and sandbox/rejection controls **passed**."
2. **Tree page** (`NR-03/lean/README.md` at the *exact commit the catalog links*, `f664d07`): "This is a **source-only candidate: it has not yet passed the authoritative Linux LeanCert/default-kernel/Comparator harness** or independent final proof reviews. ... That conditional result **does not establish** the complete graph, the ten public exports, or a Comparator/default-kernel pass. **It does not add to the Lean-verified count** or change the existing Solved status."
3. **Paper** (pinned PDF): "This is informal AI-agent review, not external human peer review or formal verification. **No Lean verification was performed.**"

The `sorry` scan is consistent with the tree page's honest self-description, not the catalog's credit: 60 Lean files; `sorry` appears only in `Challenge.lean` (10×, by design as the Comparator boundary); `Solution.lean` has none; no `axiom`, `admit`, or `native_decide` tokens anywhere. Zero sorrys in an unverified source tree is not verification.

Note the catalog even contradicts itself in the same section: two paragraphs above the "Lean verified" block it writes "no external human peer review, **formal verification** or historical novelty certification **is claimed**" — for the informal audit — then appends the "Lean verified" block. The appended block is marked up as an HTML-commented insertion (`<!-- nr03-lean-verification -->`), i.e. grafted onto the record after the paper's own "No Lean verification was performed."

## Distinguishing GAP from BREAK

Per doctrine, gates refute routes, not theorems. No lemma of the paper's proof route was falsified — the Type-E gate PASSES, so this is not BREAK in any case. It is GAP: the catalog's verification-credit claim for NR-03 is genuinely defective (it asserts a canonical verification pass that the linked tree page explicitly disavows at the linked commit), while the underlying mathematics is untouched. The route that dies is "trust RESOLVED.md's Lean-verified credit for NR-03."

**Theorem untouched.** rank₊(C7) ≤ 127 stands on the verified exact certificate. The 25-gate verdict lock is untouched; `nla_nr03` registers as a new 26th gate with verdict PASS.

## Scope and limits

- The GitHub Actions run 34785341662 cited by RESOLVED.md was not independently inspected (no browser in this audit). The tree page at the linked commit already characterizes the Linux diagnostic as bridge-only (six lightweight modules) and disavows it as establishing the complete graph, the ten exports, or a Comparator pass; a human click-through could confirm what that run actually checked. This does not affect the finding, which rests on the tree page's own words.
- ~~No Lean build was attempted~~ — superseded 2026-09-24: a full `lake build` was run (see "Verification run 2026-09-24" below).
- The audit pins the certificate at the tree commit `f664d07`; later commits on either repo are out of scope.

## Verification run 2026-09-24 (build)

At the user's direction the candidate tree was put through a real Lean build to settle the GAP above.

- Tree: `sgstepaniants/OpenProblemsInNLA@f664d07`, subtree `nonnegative-and-positive-factorizations/NR-03/lean`. The subtree **does** pin its toolchain: `leanprover/lean4:v4.33.1` (harvest recon's repo-level "not pinned" was wrong here too). Deps: leancert @ `621a43d` → mathlib @ `0df444a` (v4.33.1) + 8 others at exact revs; 8,690 mathlib oleans via `lake exe cache get`.
- **`lake build` (default target `Solution`): EXIT 0, 0 errors, wall time 25m15s.**
- 10/10 public exports elaborate; every `#print axioms` = exactly `[propext, Classical.choice, Quot.sound]`; all 10 `#assert_trust kernel` passed.
- Sorry census: `Challenge.lean` 10 (by design, Comparator boundary); `Solution.lean` 0; all 58 NLA modules 0; no `axiom`/`admit`/`native_decide` in project sources.
- Comparator name match: Challenge's 10 contract names = comparator.json's 10 theorem names = Solution's 10 verified exports (identical).

**One honest qualifier:** the pinned tree does not build *unmodified*. The canonical run 34783909558 died at `Rank.lean:40:4` (a `mod_cast` elaboration error); a one-line cast repair was needed, after which the full graph builds cleanly. So the tree page's "pending" self-description remains the accurate one for the pinned artifact — the catalog's "passed" credit is still premature as written — but the GAP closes upward in substance: the proof genuinely verifies with a trivial fix, standard axioms only.

Caveats: `lake build` was run, not the repo's `tools/lean/verify.sh` harness (outside the sparse checkout) — sandbox/rejection controls and kernel-control cases were not executed; the Comparator's core checks (name inventory, permitted-axiom audit, sorry scan) were replicated manually. The leancert dependency contains sorrys in its own test/example files; none leak into any export's axiom set. Full logs and report: `~/workspace/nr03-lean-verify/REPORT.md` (outside this repo).
