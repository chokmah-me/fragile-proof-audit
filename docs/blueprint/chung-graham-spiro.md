# Blueprint — Track D#6: Chung-Graham-Spiro gap-set conjecture

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK — no Lean scaffold yet
**Sources:** Chung, F., Graham, R. L., Spiro, S. (2020), "Slow Fibonacci walks," J. Number Theory 210, 142–170 (conjecture) · refutation: Mohsen Aliabadi (2026), "A counterexample to the Chung-Graham-Spiro gap-set conjecture," arXiv:2609.04473
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (final ranking table, row 6, "Chung-Graham Gap-Set")
**Local PDF pinned:** `incoming/chung-graham-spiro-2609.04473.pdf` (sha256 `5e7d5c3deb2cf929f7f8075e851c966e587487f42d207606234e5449ea6dbc50`), fetched 2026-09-21 via `curl -sL https://arxiv.org/pdf/2609.04473`. **This target's provenance failure is worse than Tang-Zhang's or Thakur's.** Cross-check against the corpus doc's own Section headers (per the resume-note flag left in `docs/WORKPLAN.md`) found: Sections 1–3 cover exactly seven targets (Cohen, Baste, Sárközy, Tang-Zhang, Thakur, Salez-Youssef, NCI), each with a full "Target Identifier" block and a numbered Works Cited entry — **Chung-Graham has neither**. It appears *only* as a row in the final ranking table, with no arXiv ID, no claimed theorem, no failure mechanism, and no citation. The name itself is incomplete: the real conjecture is due to **Chung, Graham, and Spiro** (the corpus doc drops "Spiro" entirely). The actual paper was located by a live web search, not the corpus doc.
**Attack type:** F (explicit counterexample, finite witness + finite base case)

## Claim

Let `f_1=f_2=1`, `f_{k+2}=f_{k+1}+f_k` be the Fibonacci sequence. Every
integer `n>=2` has a unique "Chung-Graham-Spiro representation"
`n = a*f_t + b*f_{t-1}`, `t>=2`, `1<=a<=b<=f_t`. `n` is a *down-integer* if
`t` is even, an *up-integer* if `t` is odd; `D`, `U` (the increasing
sequences of each) partition the integers `>=2`. For `l>=1` the `l`-step gap
sets are `D_l = {d_{k+l}-d_k : k>=1}`, `U_l = {u_{k+l}-u_k : k>=1}`.
Chung-Graham-Spiro proved `D_1=U_1={1,2,3,5}` and `D_2=U_2={2,3,4,5,6,8,10}`
and conjectured **`D_l = U_l` for every `l>=1`**.

## Load-bearing lemma chain

The implicit extrapolation from two verified cases (`l=1,2`) to all `l`, with
no structural argument offered for why the agreement should persist as `l`
grows — a pattern this campaign has now seen twice (Thakur's conjecture
extrapolated from degrees 2–3; this one from `l=1,2`).

**Break point:** `l=4`, witness `9`. Within `[2,17]`,
`D∩[2,17]={2,5,7,9,10,12,13,15}`, `U∩[2,17]={3,4,6,8,11,14,16,17}`; the block
`8,11,14,16,17` is five consecutive up-integers with `17-8=9`, so `9∈U_4`.
The paper separately proves `9∉D_4`: a finite base case (Lemma 3.1, covering
all down-integers with representation parameter `t<8`, which lie in `[2,113]`
by the bound `M<=f_6 f_7=104`) plus two algebraic shift lemmas (forward
8-shift, backward 5-shift) that extend the non-existence to every larger `N`.
`l=3` is explicitly left open by the paper itself (Section 5): "our numerical
computations have not revealed any discrepancy... providing some
computational evidence that `D_3=U_3`."

## Numeric gate

`scripts/gates/chung_graham_spiro.py`

- **Path A**: a direct translation of the paper's own Appendix algorithm
  (brute-force search for the `(a,b,t)` representation) — not trusted
  blindly. Its output for `D∩[2,17]`, `U∩[2,17]`, and the full 54-element
  `D∩[2,113]` is checked against the paper's own literal printed lists
  (transcribed from the PDF), and matches **exactly** on all three.
- **Witness discovery**: the five-consecutive-up-integer block with span 9
  is found *programmatically* by scanning `U∩[2,17]` (not hardcoded), and
  equals `(8,11,14,16,17)` as claimed.
- **Base case reproduction**: `D∩[2,113]` contains no five-consecutive-block
  with span 9, matching Lemma 3.1.
- **Depth**: a second, independent-implementation "fast path"
  (`fast_cgs_representation`, using modular inverses instead of the paper's
  `O(f_t^2)` double loop) is self-tested against the brute-force path over
  `[2,1000]` (0 mismatches, ceremony-category implementation-equivalence
  check per `docs/GATE-BEFORE-PROVE.md`), then used to extend the
  no-span-9-down-block check to `N=50000` — far past the paper's own `N=113`
  base case, though still not a substitute for the algebraic shift-lemma
  argument that covers all `N` to infinity (not re-derived here).
- **Path B**: a from-scratch simulation of the *original* Chung-Graham-Spiro
  definition (slow Fibonacci walks — among all walks with `1<=a1<=a2<=n`
  reaching `n` exactly, take the one reaching latest; classify by whether
  the next term is `floor(phi*n)` or `ceil(phi*n)`), entirely independent of
  the `(a,b,t)` representation algorithm. Agrees with Path A on all 192
  unambiguous integers in `[2,220]` (27 excluded as genuine ties this naive
  brute force cannot resolve without a tie-breaking rule from the original
  2020 paper, which this campaign does not have — see caveat below); the
  witness block members `8,11,14,16,17` are all unambiguous and confirmed.
- Verdict: **BREAK**. Meta: `results/chung_graham_spiro_gate_meta.json`;
  registered in `scripts/gates/check.py`
  (`EXPECTED_VERDICT["chung_graham_spiro"] = "BREAK"`). Runtime ~4s.

**Known limitation, reported not hidden**: Path B's brute-force slow-walk
search has genuine tie-breaking ambiguity for some `n` (first hit: `n=35`,
where three walks tie for latest arrival and disagree on the next term).
This is very likely because the original Chung-Graham-Spiro paper (J.
Number Theory 210, 2020) defines "slow" with additional structure this
campaign did not fetch (only the citing refutation paper was pinned). Those
`n` are excluded from Path B's agreement claim rather than force-resolved —
consistent with "a check that cannot fail is not evidence": an
always-resolves classifier would be worse than an honest partial one. This
does not weaken the BREAK verdict, since Path A alone (validated by exact
transcription match against two independently-sized literal lists from the
PDF) already establishes the witness.

**Also caught in review**: an earlier draft of this gate mistakenly checked
whether the *integer* 9 classifies as up/down (`classify_walk(9)`) as if that
were equivalent to "9 is a gap value in `U_4`" — a category error (9 is in
fact a *down*-integer per both paths and the paper's own `D`-list; that fact
is unrelated to 9 appearing as a *difference* `u_{k+4}-u_k`). Fixed before
landing; the gate's witness check now correctly scans for five-consecutive
blocks in `U∩[2,17]`, not the classification of 9 itself.

## Discrimination control

`scripts/controls/chung_graham_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction shape).

1. **Matched claim (`l=1,2`)** — this campaign's own Path A machinery,
   over `N=5000`, reproduces the paper's own *true* claims exactly:
   `D_1=U_1={1,2,3,5}`, `D_2=U_2={2,3,4,5,6,8,10}`. If the search machinery
   had a bug that made it always report a gap-set mismatch, this would fail.
2. **Negative window (`l=3`)** — the paper's own Section 5 flags `l=3` as
   open, with no discrepancy found in their numerics. This campaign's own
   `D_3`/`U_3` computation over `N=5000` likewise finds `D_3=U_3` (no
   mismatch) — a matched negative control, not assumed.
3. **Path B depth** — 192/219 integers in `[2,220]` are unambiguous under
   the from-scratch slow-walk simulation, 0 disagreements with Path A among
   them, and the witness block `8,11,14,16,17` is confirmed unambiguous.
4. **Transcription** — `D∩[2,17]`, `U∩[2,17]`, and `D∩[2,113]` all match
   the pinned PDF's printed values exactly.

Verdict: **NO FALSE POSITIVE**.

## Formalizable slice

Not started. Candidate shape (fully finite and decidable in principle, given
the `(a,b,t)` representation criterion, `1<=a<=b<=f_t`, is elementary
Fibonacci-number arithmetic well within mathlib's reach):

```lean
theorem chung_graham_spiro_false :
    ∃ (D U : ℕ → ℕ), -- increasing enumerations of down/up integers
      (∀ n, IsDownInteger (D n) ↔ True) ∧
      (∀ n, IsUpInteger (U n) ↔ True) ∧
      (9 ∈ {U (k+4) - U k | k : ℕ}) ∧
      (9 ∉ {D (k+4) - D k | k : ℕ})
```

Needs: a Lean/mathlib formalization of the `(a,b,t)` representation
(existence/uniqueness) and the down/up-integer partition — likely absent
from mathlib v4.32.2 (not checked). The `9 ∈ U_4` half is fully finite and
`decide`-able in principle (five explicit integers, five explicit
representations). The `9 ∉ D_4` half needs either the full algebraic
shift-lemma argument (Lemmas 2.1–2.2 of the pinned PDF, an infinite
induction — substantial) or a from-mathlib decidability result bounding the
search, neither attempted. Comparable difficulty to Tang-Zhang/Thakur; not
attempted.

## Fill checklist

- [x] Numeric gate (`scripts/gates/chung_graham_spiro.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/chung_graham_break_control.py`, NO FALSE POSITIVE)
- [x] Local PDF pin under `incoming/` for arXiv:2609.04473
- [ ] Lean scaffold — likely blocked on mathlib CGS-representation coverage, not attempted
- [ ] Audit note under `docs/audits/chung-graham-spiro.md`
