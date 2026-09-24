# Audit note — NLA-MI32 Heidary "Upper comparison for Latała–Świątkowski inequality" — Type-A replay: PASS; Type-G verification-credit scan: no discrepancy (catalog vindicated)

**Target:** harvest 2026-09-24, Card 6 (`nla-mi32`), fragility 3.
**Paper:** Diar Heidary, "MI-32: a proof through parity counts and positive walk polynomials" (research checkpoint 2026-09-13–14; "complete proof draft; independent analytic reviews, six bounded exact suites, and the joint integrity audit passed. These are research reviews, not journal peer review or a formal proof-assistant certification.").
**Pins:** paper draft `docs/source/MI32_solution.md` (6043 bytes, SHA-256 `fc2a01f6215d4d1e0e96095ae990ad4208e8126b0091ee0103edbf2918469073`) at `DiarHaidary/Spectral-norms-of-independent-entries-with-regular-moment-growth@762bd5ec5050a96f5e6ba3926b6cda4816fcd4b0`; catalog `ajt60gaibb/OpenProblemsInNLA@0689db001ddc4c54f2652ed4b13b753637fef700`. (The catalog `references/heidary-mi32-latala-2026-09-19/proof.pdf` URL from the task brief returns **404**; the paper draft lives in the author's tree, which is also the harvest record's paper URL.)
**Date:** 2026-09-24. **Scope:** Type-A numeric replay of the headline upper bound on witnesses + exact replay of the load-bearing fourth-moment lemma; Type-G scan of the Palomar-registration credit. No Lean build attempted (canonical verification evidence is published and reviewed below).

**Verdicts: Type-A PASS. Type-G NO DISCREPANCY.** The quantitative headline replays on the witness family, the analytic engine's key lemma replays exactly, and the apparent catalog/tree contradiction on Palomar registration resolves in the catalog's favor against registry ground truth.

## The claim

For real n×n X with independent mean-zero entries, all absolute moments finite, and ||X_ij||_{2r} ≤ α||X_ij||_r (r ≥ 1):

> c_α{M(X)+D(X)} ≤ E||X|| ≤ C_α{M(X)+D(X)}.

M(X) = max row std + max column std; D(X) = max_{1≤k≤n} min_{|I|≤k} sup_{||s||₂,||t||₂≤1} ||Σ_{i,j∉I} X_ij s_i t_j||_{log(k+1)} with one shared deterministic deletion set I on both axes and the subunit order log 2 at k=1. "The new contribution is the upper bound. The lower bound is the established Theorem 4.1 of Latala--Swiatkowski." The Lean export is `MI32.main_upper : ∀ α ≥ 1, ∃ C > 0, UpperBoundAt α C` — an existential constant.

## Type-A: headline on Rademacher witnesses + lemma replay (PASS)

`scripts/gates/nla_mi32.py` (stdlib `Fraction` for all rational parts; mpmath at 80 dps for the sharpness probe):

- **S1 — headline, exact route:** for n ∈ {2,3,4}, all 2^{n²} sign patterns enumerated. Each pattern has ||X||_F² = n², so E||X||_F² = n² exactly. By Jensen (documented analytic step), (E||X||₂)² ≤ E||X||_F² = n². Fair signs give M(X) = 2√n exactly (row/col sums of squares = n), and n² ≤ 4n = M(X)² for n ≤ 4 (exact integer check). D(X) ≥ 0. Hence E||X||₂ ≤ 1·(M(X)+D(X)): the headline holds with C = 1 on the witness family — the tree's own `RegularWitness.lean` exhibits this fair-sign family as regular at α = 1.
- **S2 — constant sharpness:** r_n = E||X||₂/M(X) = 0.6036, 0.6866, 0.7406 at n = 2,3,4; max 0.7406 ≤ 0.8 (C = 1 with 0.2 margin). The constant is not tight on Rademacher — the ratio grows slowly with n.
- **S3 — fourth-moment lemma, exact:** the proof's engine (`MI32.raw_positive_polynomial_fourth_moment`: E[(ΣP_a²)²] ≤ 9^d·α^{8d}·(E[ΣP_a²])² for nonnegative-coefficient degree-≤d polynomials). With Z = 1, α = 1 and 40 seeded random vector polynomials (m = 4..8 vars, dim 1..3, degree 1..3, seed 20260924): S4·2^m ≤ 9^d·S2² holds exactly on all 40, worst ratio 0.247.

Discrimination control: **NO FALSE POSITIVE** — (a) tightened headline constant C* = 0.7 is rejected (observed max r_n = 0.7406 > 0.7); (b) tightened lemma constant 2.98 (4th-power form) is rejected on the linear form F = Σ_{i=1}^{201} x_i, where the exact ratio is 3−2/201 = 2.9900… > 2.98 while the true constant 9 passes; (c) the unperturbed path passes, so the instrument is not always-reject. (Receipt: `results/nla_mi32_control_meta.json`.)

## Type-G: the Palomar contradiction resolves for the catalog (no discrepancy)

This card carried the sharpest Type-G flag of the batch: the tree page and the catalog directly contradict each other on Palomar registration.

- **Tree** (`DiarHaidary@762bd5e`): README — "**It is not registered with Palomar.** A submission has been made; its AI editorial review returned requested changes… Comparator and NanoDa cannot run on this Windows host… Registration has not been requested, no human peer review of the mathematics has taken place, and no novelty or priority claim is made." `verification/status.json` (checked 2026-09-14T13:55Z): comparator "not_run", nanoda "not_run", registration "not_requested".
- **Catalog** (`ajt60gaibb@0689db0`): `RESOLVED.md` — "registered as Palomar entry PALOMAR-2026-09-14-000006, version 1… Palomar's Linux Comparator, NanoDa and sandboxed kernel run 34852526384 accepted the frozen statement… trust level high… editorial review outcome neutral." `matrix-inequalities-and-norms/MI-32/README.md` — "Lean verified — 2026-09-14", same entry/run claims.
- **Registry ground truth** (`data.palomar-registry.org`, fetched 2026-09-24): entry PALOMAR-2026-09-14-000006 exists — status "registered", trust "high", source commit `762bd5e` (the exact pinned commit), published 2026-09-14T15:41:11Z; verification block cites run_id 34852526384, comparator `57567492`, nanoda `68d5ca9d`, mechanical report hash; editorial review outcome "neutral" (reviewer codex:gpt-5.6-sol).

**Resolution:** the catalog is vindicated; the tree page is stale. The tree's status.json was frozen at 13:55Z, Palomar's review ran at 14:38Z, and registration published at 15:41Z — the README's disclaimer was true when written and false ~2h later. Not fabrication; a freeze-time artifact. (Receipt: `results/nla_mi32_typeg_meta.json`.)

Two caveats stay in the record: (1) Palomar's own review warning — "The informal account materially misidentifies the exact-logarithmic LocalLogMoment theorem as a step in the selected proof. Describe it as an unused companion corollary" — a documented formalization-vs-informal-account mismatch, review still "neutral". (2) The harvest signals (`anonymous_or_unaffiliated`, `disclosed_llm_help`, `ai_only_review`) are disclosed on both sides and confirmed, not hidden.

Sorry census: 113 Lean files (95 under `MI32/`); 2 `sorry` mentions in `Challenge.lean` (1 actual — the intentional Challenge hole — plus its documenting comment); 0 in `Solution.lean`, all 95 `MI32/` modules, and `FullTargetAudit.lean`; no `axiom`/`admit`/`native_decide` in project sources (the one "admit" grep hit is the English word in a comment). Toolchain `leanprover/lean4:v4.33.0`, mathlib pin `db584cd6`.

Gates refute routes, not theorems — and here no route dies. The headline's quantitative content replays, its engine lemma replays exactly, and the verification credit checks out.
