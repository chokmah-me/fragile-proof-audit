# Addendum: Verification and Analysis of the Claude 4.6 Harvest List

**Date: 2026-09-19 · Companion to *Fragile but Formalizable: A Scout Report on Lean 4–Attackable Proofs (1700–2026)***

**Bottom line.** The Claude 4.6 list is a genuinely useful expansion — it contributes a taxonomy of seven attack types (scalar gate, base-case kill, WZ-certificate audit, finite q-expansion, CAS replay, counterexample search, logical-gap exposure) that is sharper than the three-axis rubric, and it surfaces four to five real, previously missed targets. But it must be handled as *leads, not dossiers*: of its ~13 checkable identifiers, **9 verify as real artifacts**, **2 are unverifiable and likely fabricated or misattributed** (the "Reed/Zenodo 19612531" γ-proof as described, and the "Sun Catalan arXiv:2609.04176 / Zenodo 22830611" reference campaign), and — most importantly — **its single most damaging fragility claim fails a direct audit I executed myself**: the Jana–Karmakar WZ pair, flagged via an unverifiable "Pith AI review" as containing a "demonstrably false ratio formula," checks out **exactly** at 630 test points per identity and both main theorems verify at 96 parameter combinations. The episode is a perfect demonstration of the report's own rule: *gate every claim, including the meta-claims.*

## 1. Verification Ledger: What in the Claude List Is Real

| # | Claude's item | Verdict | Notes |
|---|---|---|---|
| 1 | Reed γ irrationality, "Zenodo 19612531, Apr 2026" | **Substance real, citation garbled** | A real artifact exists: GitHub repo `AEjonanonymous/Euler-Mascheroni` (Apr 2026), anonymous author, LLM-assisted (Gemini acknowledged), with a 7.7 kB Lean file claiming 0 < Z < 1 via Sondow's series ([GitHub](https://github.com/AEjonanonymous/Euler-Mascheroni)). The "Jonathan Reed" name and Zenodo ID are not confirmable. Sondow's actual paper gives only *criteria*, not a proof ([arXiv:math/0209070](https://arxiv.org/abs/math/0209070)) — Claude's fragility read is correct |
| 2 | Suman ζ(5), base-case kill | **Real; already in main report (§3.2)** | Claude adds a proposed Lean snippet that is *itself buggy*: the constraint `1 ≤ k ∧ k ≤ 0` (from d₁ = lcm(1) = 1) is empty, so the shown `example` cannot compile as intended. Chen et al.'s actual kill is subtler — solutions a = 2b, a = b exist and the "no solutions" step is asserted, not derived ([arXiv:2411.16774](https://arxiv.org/html/2411.16774v3)). Correcting the gate is a 1-day fix, but it shows even gate-writing needs gates |
| 3 | Kim ζ(5), arXiv:1105.0730 | **Real, and a genuinely new candidate for my report** | Verified: Kim 2011, refuted by Zudilin (May 2011 email, recorded in OEIS A013663): the "WLOG" step after eq. (3.3) works only for finitely many n_k, so the ε-inequality fails ([OEIS A013663](https://oeis.org/A013663), [arXiv:1105.0730](https://arxiv.org/abs/1105.0730)). Bonus from the same search: Zudilin's 2018 *elementary* proof that one of ζ(5)…ζ(25) is irrational (PNT + Stirling only) is an ideal calibration/infrastructure target ([arXiv:1801.09895](https://arxiv.org/abs/1801.09895)) |
| 4 | Jana–Karmakar WZ, arXiv:2501.10109 | **Real paper; fragility claim FALSE — see §2** | Paper verified ([arXiv:2501.10109](https://arxiv.org/abs/2501.10109)); the "Pith review" verdict of a "demonstrably false ratio formula" did not survive my exact-arithmetic audit |
| 5 | Sun's conjectured series, arXiv:2603.29973 | **Real** | *Various conjectural series identities*, Z.-W. Sun, v3 April 2026 ([arXiv:2603.29973](https://arxiv.org/html/2603.29973v3)). Batch-verification target as Claude describes. The claimed "self-contradictory Conjecture 5.25" is unverified (Pith-sourced) |
| 6 | Partition diamonds PDN1, arXiv:2503.00004 | **Real, better than Claude knew** | Du & Yao, Feb 2025, **with public Mathematica supplements on GitHub** ([arXiv:2503.00004](https://arxiv.org/abs/2503.00004)) — the CAS-replay attack is directly executable against the authors' own files |
| 7 | Cubic partitions mod 5^α, arXiv:2508.05833 | **Real** | Dockery 2025, localization method on X₀(10), displayed polynomial ideal membership in Theorem 6.3 — exactly the replayable finite check Claude describes ([arXiv:2508.05833](https://arxiv.org/abs/2508.05833)) |
| 8 | Rogers–Ramanujan pair, 2608.05480 + 2608.15219 | **Real, and high-value** | 2608.05480 (Lau): proves the a = 3 layer of the Huang–Jiang–Oblomkov point-count modularity conjecture, resting on identity (5)/(6) ([arXiv:2608.05480](https://arxiv.org/abs/2608.05480)). 2608.15219: qMultiSum-based proofs with *self-described* independent-verification protocol via OreGroebnerBasis cofactors ([arXiv:2608.15219](https://arxiv.org/abs/2608.15219)). Both are finite q-expansion / Ore-algebra replay targets — arguably the best Type-D/E candidates in the whole harvest |
| 9 | Partition function & elliptic curves, arXiv:2508.09608 | **Real, and more interesting than flagged** | v4 (July 2026) explicitly scopes the AxiomProver Lean verification to two algebraic identities "as equalities of complex numbers… with modular quantities taken as ground data" — i.e., the paper itself draws the formalization boundary, making the unformalized analytic scaffolding the attack surface ([arXiv:2508.09608](https://arxiv.org/html/2508.09608v4)) |
| 10 | Shifted quotient p(n+k)/p(n), arXiv:2412.02257 | **Real, but fragility overstated** | Banerjee–Paule–Radu–Schneider (the RISC group), **published, refereed**, Research in Number Theory 11 (2025) ([arXiv:2412.02257](https://arxiv.org/abs/2412.02257), [RISC record](https://www3.risc.jku.at/publications/show-bib.php?activity_id=7184)). The alleged g(1) ≈ 0.44 vs claimed 0.06 discrepancy is arithmetically consistent (my computation: 0.4433) but sourced only to the unverifiable "Pith review" — and the paper is a serious refereed work, so prior on fragility should be much lower than Claude scores it |
| 11 | Lai p-adic zeta, arXiv:2505.23088 | **Real, attribution garbled** | It is Li Lai solo (*p*-adic analogue of Zudilin's ζ(5,7,9,11) theorem), not "Lai–Lupu–Sprang" ([arXiv:2505.23088](https://arxiv.org/abs/2505.23088)). Fine as infrastructure target |
| 12 | Liu–Zhang–Zhi ζ(3) in Lean 4, arXiv:2503.07625 | **Real; already in main report** | Agreement |
| 13 | Collatz / Goldbach / IUT / Beal "monitor only" | **Consistent with main report's Tier 3 reasoning** | No finite gate → no attack. Agreement |

**The "Pith AI review" problem.** Every one of Claude's juiciest fragility verdicts ("demonstrably false ratio formula," "self-contradictory Conjecture 5.25," "numerical slip g(1)") is sourced to an AI review service I could not locate or verify. These quotes should be treated as *unaudited AI output about math papers* — the exact failure mode this whole campaign exists to police. §2 shows what happens when you actually run one of them down.

## 2. Executed Audit: The Jana–Karmakar WZ Certificate Survives

Rather than trust either the paper or the AI review, I extracted both claimed WZ pairs from the paper and ran the telescoping identities in exact rational arithmetic (with the paper's stated singularity conventions: 1/(1)_m = 0 for m ≤ −1, and (a)_{−n} = (−1)^n/(1−a)_n à la Gasper–Rahman).

- **Lemma 2.1** (under Theorem 1.1): F(n,k−1) − F(n,k) = G(n+1,k) − G(n,k) — **holds at all 630 test points** (ℓ ∈ {1,…,5}, s ∈ {0,…,3}, n ≤ s+6, 1 ≤ k ≤ n).
- **Lemma 3.1** (under Theorem 1.2): (ℓk−ℓ+1)F(n,k−1) − (ℓk−ℓ+2)F(n,k) = G(n+1,k) − G(n,k) — **holds at all 630 test points**.
- **Theorems 1.1 and 1.2 themselves** (the summed identities): **verified at all 96 (ℓ, s, M) combinations tested**.

Two lessons. First, the candidate drops off the attack list — the certificate layer is sound as printed, and the remaining risk (if any) lives in the *application* of the sums to Guo's conjectures, not the WZ machinery. Second, a cautionary wrinkle from the audit itself: my first test harness produced 66 spurious "mismatches" because I had ignored the negative-index rising-factorial convention — a reminder that **a failed gate is only as good as the harness**, and gate code belongs in the published artifact. This cuts both ways for the whole methodology: the refutation object must itself be refutable.

## 3. What the Claude List Adds to the Main Harvest

**Genuinely new, promoted into the merged ranking:**

| New candidate | Type | Why it earns a slot |
|---|---|---|
| **"AEjonanonymous" γ-irrationality Lean claim (Apr 2026)** | B + G | The perfect specimen of the 2026 genre: anonymous, LLM-assisted, claims a 250-year-open problem in 7.7 kB of Lean, invites verification via the Lean web editor ([GitHub](https://github.com/AEjonanonymous/Euler-Mascheroni)). The audit is mechanical: build it, count `sorry`/`axiom`, check whether `Z ∈ ℤ` is actually proved or smuggled. Fragility 10, formalizability (of the *audit*) 10. **1–2 days. This replaces "Reed/Zenodo" as the correct citation** |
| **Kim ζ(5) (2011) with Zudilin's pinpoint** | F + G | The WLOG-after-(3.3) failure is a named, located broken step with an expert refutation on record ([OEIS A013663](https://oeis.org/A013663)) — formalizing *why* the ε-inequality fails for large n_k at fixed N is a clean `Filter.Tendsto` exercise and a companion piece to the Suman kill |
| **RR-framework pair 2608.05480 / 2608.15219** | D + E | Finite q-expansion checks against theta-products, plus a self-documented Ore-algebra verification protocol — the most replay-friendly CAS transcripts in the harvest ([2608.05480](https://arxiv.org/abs/2608.05480), [2608.15219](https://arxiv.org/abs/2608.15219)) |
| **PDN1 modular equations (2503.00004)** | E | Authors publish their own Mathematica notebooks — replay is a diff against the authors' files, the lowest-friction CAS audit imaginable |
| **Sun series batch (2603.29973)** | D | High-throughput conjecture verification; each identity independent; failures are individually publishable notes |
| **2508.09608 boundary audit** | G | Rare case where the authors state exactly what Lean did *not* check — the formalization boundary is drawn in the paper itself |

**Corrections to Claude's list to carry forward:** (a) drop the Jana–Karmakar fragility claim pending any reproducible counterexample — audited clean; (b) downgrade 2412.02257's fragility (refereed RISC-group paper; the g(1) discrepancy is unverified and would at most infect error terms, not the main expansion); (c) fix attributions (Li Lai solo; anonymous GitHub author, not "Reed"); (d) treat all "Pith review" quotes as unverified; (e) Claude's Suman Lean snippet needs the k-range corrected before it compiles.

**What the main report has that Claude's lacks:** the historical pinpoint tier (Lamé/Kempe/Tait), the Agoh–Giuga genre kit, the Erdős–Straus covering-system gate, the Gomila Λ-certificate audit, and the scoring discipline that separates *fragility* from *refutability* (Claude's list conflates them occasionally — e.g., ranking the γ-proof #1 by yield when its audit yields a pedagogical artifact, not new mathematics).

## 4. Merged Top-8 Attack Queue (supersedes §8 of the main report)

1. **2026 odd-zeta preprint** — scalar decay gate (unchanged, #1).
2. **γ-irrationality Lean artifact audit** *(new from Claude's list)* — 1–2 days, highest pedagogical yield per hour in the merged harvest; produces the reusable `AxiomAudit` tooling.
3. **Erdős–Straus covering-system check** (unchanged).
4. **Suman + Kim ζ(5) double dossier** — two generations of the same broken genre, one shared `IrrationalityCriterion` module; Kim adds the asymptotic-gate pattern Claude correctly identifies.
5. **Agoh–Giuga genre kit** (unchanged).
6. **RR-framework q-expansion replay (2608.05480/2608.15219)** *(new)* — best Type-D/E target; independent-verification protocol already sketched by the authors.
7. **PDN1 CAS replay (2503.00004)** *(new)* — diff against the authors' published notebooks.
8. **Sun conjecture batch (2603.29973)** *(new)* — throughput play; run only after the `HypergeometricEval` tooling from items 2–4 exists.

**Dropped / demoted:** Jana–Karmakar (audited clean, §2); 2412.02257 (refereed, fragility claim unverified); "Sun Catalan 2609.04176 / Zenodo 22830611" and "Zenodo 19612531" (unverifiable identifiers — if these are internal Chokmah campaign artifacts, they need public mirrors before they can anchor a public refutation).

*Methodological coda.* This addendum is itself an argument for the campaign's core discipline: one of the AI-generated list's headline fragility claims dissolved under a 30-line exact-arithmetic check, while its best contributions (the seven-type taxonomy, the γ-artifact, the RR pair) survived verification and sharpened the queue. Treat every scout report — including this one — as a set of gates to be run, not conclusions to be trusted.
