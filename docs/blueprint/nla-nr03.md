# Blueprint — Harvest 2026-09-24: nla-nr03, 127-term nonnegative factorization of C7 (Holden)

**Status:** Type-E gate landed (PASS) + Type-G catalog scan landed (GAP on verification credit) + discrimination control landed (NO FALSE POSITIVE) — no Lean scaffold
**Sources:** Sidney Holden, "The quadratic correlation matrix need not have full nonnegative rank: A counterexample to NR-03 and an explicit factorization for every size", September 2026, Flatiron Institute (Center for Computational Biology)
**Local PDF pinned:** `incoming/nla-nr03-holden.pdf` (345,135 bytes, 6 pages, SHA-256 `249a1c630d2442be22456cc7eaf12f02c80439c00ea08508663cb0742563db02`), fetched 2026-09-24 via `curl -sL https://raw.githubusercontent.com/ajt60gaibb/OpenProblemsInNLA/0689db001ddc4c54f2652ed4b13b753637fef700/references/holden-nr03-2026-09-13/NR03_counterexample.pdf`
**Attack type:** E (CAS-transcript replay, exact rational object) + G (logical-gap exposure on verification credit)

## Claim

For subsets a, b ⊆ [n], C_n(a,b) = (1 − |a ∩ b|)². The NR-03 question asks whether rank₊(C_n) = 2ⁿ for every n ≥ 3. Holden's paper:

> "At n = 7 this gives rank₊(C7) ≤ 127 < 128, disproving the universal full-rank conjecture in NR-03."

> "Consequently, rank₊(C7) ≤ 64 + 7 + 21 + 35 = 127 < 128, and rank₊(C_n) < 2ⁿ for every n ≥ 7."

The bound is r(n) = 2ⁿ⁻¹ + C(n,1) + C(n,2) + C(n,4); at n = 7: 64 + 7 + 21 + 35 = 127.

## Load-bearing object

An exact rational certificate, not a numerical optimization:

> "The supplied matrices W ∈ Z^{128×127}, V ∈ Z^{127×128}, and d ∈ Z^{128}_{>0} satisfy W V = C7 diag(d), H = V diag(d)^{−1}, C7 = W H."
> "The denominator values are 1, 4, 9, 16, 25, 36. Every entry of W is in {0, 1, 2}, and every entry of V is at most 36."

> "Rows and columns follow integer masks 0, . . . , 127; bit i denotes element i + 1. Atoms are ordered as 64 complementary pairs (representative masks 0, . . . , 63), seven singletons, 21 pairs, and 35 four-sets."

> "Integer matrices, denominators, and atom labels are in data/factors_n7.json. CSV matrices are W_n7.csv and H_scaled_n7.csv; denominators are in column_denominators_n7.csv. The additional H_n7_rational.csv stores H as exact fraction strings: its product with W equals C7 itself."

Data source gated: `data/factors_n7.json` in sgstepaniants/OpenProblemsInNLA at pinned commit `f664d07e82aaa60bc9c78dd1946e763168c5c530` (keys `W`, `H_scaled`, `denominators`, `n`, `r`).

## Break/GAP point

**Type E (load-bearing, PASS):** the certificate is independently re-verified entry-by-entry (see gate). The mathematical route — explicit exact factorization — is sound.

**Type G (verification credit, GAP):** the paper itself closes the door on any Lean-verification reading:

> "The submitted proof and checks were developed with ChatGPT assistance. On 13 September 2026, a separate Codex AI agent independently audited the entire argument and exact target, returning PASS for the complete negative resolution; its report and independently written exact checker accompany this submission. Under the repository's evidence rules [4], this supports Solved. **This is informal AI-agent review, not external human peer review or formal verification. No Lean verification was performed.**"

Against this, the catalog (`ajt60gaibb/OpenProblemsInNLA` at `0689db0…`, `RESOLVED.md`) credits NR-03 at a verification level the evidence does not support, while the Lean tree page itself self-describes as a source-only proof candidate with canonical verification still pending. The GAP is in the catalog's verification credit, not in the paper's proof route. Gates refute routes, not theorems — and here the route that dies is "trust RESOLVED.md's verification credit for NR-03", not the factorization.

## Numeric gate

`scripts/gates/nla_nr03.py` — verdict **PASS**

Loads `data/factors_n7.json` (pinned tree, `/tmp` clone — never inside the campaign repo) and checks, all with exact integer arithmetic except the final rational cross-check which uses `Fraction`:

1. metadata: `n == 7`, `r == 127`
2. dimensions: W is 128×127, V is 127×128, 128 denominators
3. nonnegativity: every entry of W and V is an int ≥ 0; every denominator a positive int; denominator values ⊆ {1,4,9,16,25,36}; W entries ⊆ {0,1,2}; V entries ≤ 36
4. **exact product, all 16,384 entries:** Σ_k W[a][k]·V[k][b] == d[b]·(1 − popcount(a&b))² for a,b ∈ 0..127 (this is the paper's own construction-independent check, re-derived — target rebuilt from the mask definition, not copied from the JSON)
5. rational form: H = V·diag(d)⁻¹ as `Fraction`s; W·H == C7 exactly over all 16,384 entries
6. term count: exactly 127 atoms (64 + 7 + 21 + 35 ordering noted in paper)
7. corroboration: the rebuilt C7 has exactly 5,103 zero entries and 11,281 positive — matching the paper's stated split (5,103 = Σ_i C(7,i)·i·2^{7−i} = 7·3⁶, verified combinatorially in-gate)

Meta: `results/nla_nr03_gate_meta.json`; registered in `scripts/gates/check.py` (`EXPECTED_VERDICT["nla_nr03"] = "PASS"`).

## Type-G scan

`results/nla_nr03_typeg_meta.json` — not a gate, a scan receipt:

- pinned paper: "No Lean verification was performed" (quoted above)
- tree page (`nonnegative-and-positive-factorizations/NR-03/lean` at `f664d07`): self-describes as source-only proof candidate; canonical verification pending
- `sorry` scan over the NR-03 Lean sources at the pinned commit: count recorded in the receipt
- catalog `RESOLVED.md` (at `0689db0`): claims a higher verification level — quoted verbatim in the receipt

Finding: **GAP** — the catalog's verification credit for NR-03 exceeds what the paper, the tree page, and the Lean sources support.

## Discrimination control

`scripts/controls/nla_nr03_control.py` — PASS-verdict gate, so the open question is vacuity ("could it miss a real defect?"):

1. **Perturbation:** flip a single entry W[a][k] by +1 (everything else fixed, including the independently rebuilt target matrix) → the gate's exact-product check must reject. Confirmed: rejects, naming the damaged row.
2. **Transcription independence:** the target matrix C7 is rebuilt from the mask definition C7(a,b) = (1−popcount(a&b))² — the JSON's own entries are never used as the oracle.
3. **Non-vacuity:** zero-entry count 5,103 and positive count 11,281 are asserted against the paper's stated split; a gate that skipped entries could not reproduce both.

Verdict: **NO FALSE POSITIVE**. Receipt: `results/nla_nr03_control_meta.json`.

## Formalizable slice

Not started. The certificate is already exact-rational, so a Lean formalization would be `decide`-friendly in principle (128×128×127 integer products), but the paper states no Lean verification was performed and none is claimed here. Candidate shape, if ever scaffolded:

```lean
theorem nr03_nonneg_rank_le : ∃ (W : Matrix (Fin 128) (Fin 127) ℚ) (H : Matrix (Fin 127) (Fin 128) ℚ),
    (∀ i j, 0 ≤ W i j) ∧ (∀ i j, 0 ≤ H i j) ∧ W * H = C7
```

Needs: the C7 matrix definition and the 127-term factor data as `Fin`-indexed literals. Not attempted.

## Fill checklist

- [x] Local PDF pin under `incoming/` (`nla-nr03-holden.pdf`, sha256 `249a1c63…`)
- [x] Type-E gate (`scripts/gates/nla_nr03.py`, verdict PASS)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/nla_nr03_control.py`, NO FALSE POSITIVE)
- [x] Type-G scan (`results/nla_nr03_typeg_meta.json`, GAP on verification credit)
- [x] Audit note (`docs/audits/nla-nr03.md`)
- [ ] Lean scaffold — not attempted; paper states no Lean verification was performed
