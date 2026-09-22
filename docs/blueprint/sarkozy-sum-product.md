# Blueprint — Track D#3: Sarkozy's sum-product conjecture (mod p)

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK — no Lean scaffold yet
**Sources:** Sarkozy (conjecture, folklore/pre-2026, no local PDF pinned) · refutation: Tang, Q. (2026), "A counterexample to a conjecture of Sarkozy on sums and products modulo a prime," arXiv:2603.29992 [math.NT]
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (Section 1, "Sarkozy's Modulo a Prime Sum-Product Conjecture")
**No local PDF pinned** for either the original conjecture or Tang's refutation — provenance here rests on the corpus doc's paraphrase, which is itself internally inconsistent about the exact construction (its own "Verifiable Gate" bullet contains a self-contradicting "Wait, if ... that fails" hedge). Flagged, not hidden: the gate does not transcribe Tang's construction at all.
**Attack type:** F (Counterexample Search) / G

## Claim

Sarkozy's conjecture: there exist constants `c > 0` and `C` such that for
every prime `p`, any set `A subset Z/pZ` with `|A| >= c*p` must satisfy
`1 in (A+A) union (A*A)`.

Tang's refutation (2026): no such positive constant `c` can exist — the
sharp threshold is exactly `1/2`. For every odd prime `p` there is a set `A`
of exact size `(p-1)/2` with `1 notin (A+A) union (A*A)`.

Corpus's own formalizable slice:

```lean
theorem sarkozy_conjecture_false :
    forall p >= 5, Prime p ->
    exists A : Finset (ZMod p), A.card = (p - 1) / 2 /\
        (1 : ZMod p) notin (A + A) union (A * A)
```

## Load-bearing lemma chain

The implicit assumption that a fixed density threshold `c < 1/2` is
sufficient: that the combinatorial expansion of `A+A` combined with the
multiplicative mixing of `A*A` always fills the missing residue class `1`
once `|A|` exceeds *any* fixed fraction of `p`. The refutation shows this
fails right up to density `1/2` — there is no room below the trivial
pigeonhole bound for a nontrivial threshold to live.

**Break point:** for every odd prime `p` tested (5 through 19, exhaustively;
23 under `--deep`), an explicit set of size `(p-1)/2` avoiding `1` in both
`A+A` and `A*A` was found by brute-force search.

## Numeric gate

`scripts/gates/sarkozy_sum_product.py`

- For each prime `p` in `{5, 7, 11, 13, 17, 19}` (CI) / `{..., 23}`
  (`--deep`), exhaustively enumerates **every** size-`(p-1)/2` subset of
  `Z/pZ` and tests `1 notin (A+A) union (A*A)` directly from the
  definition — not copied from any transcription of Tang's construction.
- Implementation-equivalence self-test: every subset is checked by two
  independent code paths (`avoids_one`, a pairwise early-exit loop, and
  `avoids_one_via_sets`, a set-comprehension rebuild) before either is
  trusted; both agreed on all tested primes.
- Witness counts found (not just existence): `p=5`→1, `p=7`→2, `p=11`→2,
  `p=13`→4, `p=17`→4, `p=19`→8 (out of `C(p,(p-1)/2)` total subsets each).
- Verdict: **BREAK**. CI runtime ≈2.6s (dominated by `p=19`'s 92 378
  subsets); `--deep` adds `p=23` (1.4M subsets, +3.7s) — well over the
  corpus table's claimed 0.05s, which described a single constructive
  witness check, not this campaign's independent exhaustive-search
  re-derivation.
- Meta: `results/sarkozy_sum_product_gate_meta.json`; registered in
  `scripts/gates/check.py` (`EXPECTED_VERDICT["sarkozy_sum_product"] =
  "BREAK"`).

## Discrimination control

`scripts/controls/sarkozy_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction shape, same register bucket as
`cohen_subadditivity`/`baste_domination`; exact-equality alone would have
missed whether the exhaustive search could ever decline to report a
witness).

Four questions, per `docs/GATE-BEFORE-PROVE.md`:

1. **Transcription fidelity** — gate's lemma/instance matches the corpus
   doc's statement of the conjecture, the refutation citation, and the
   formalizable slice, read directly from the repo file (not a live
   fetch). `ok: True`. Does **not** check any claimed construction, since
   the gate doesn't use one.
2. **Machinery discrimination** — the full set `A = Z/pZ` correctly fails
   `avoids_one` for every tested prime (trivially, `1` is in the sumset of
   everything); random size-`(p-1)/2` subsets avoid `1` only rarely
   (0–3 out of 40 trials per prime) and random oversized subsets
   (`(p-1)/2 + 2`) never do, confirming the positive rate is
   density-sensitive rather than tautological. Verdict: not a check that
   fires on every input.
3. **Algebraic self-consistency** — re-asserts the gate's own dual
   `avoids_one` cross-check passed on every tested prime (delegated, not
   duplicated).
4. **Independent corroboration** — tested quadratic residues mod `p` as an
   unrelated, hand-derivable candidate family (not Tang's actual
   construction, and not the gate's own search code path). **Result:
   negative** — the plain quadratic-residue set does *not* avoid `1` at
   any tested prime. This does not invalidate the gate (which is
   search-based, not QR-based, and the exhaustive enumeration is a
   complete check, not a heuristic), but it means independent
   corroboration here rests on (1)+(3) only, not a second construction.
   Flagged honestly in the control's own output, not smoothed over.

Verdict: **NO FALSE POSITIVE** (with the item-4 caveat recorded above).

## Formalizable slice

Not started. Candidate shape (per the corpus doc's suggested Lean
statement — unverified against any actual Lean file, since none is
referenced anywhere in the corpus doc for this target):

```lean
theorem sarkozy_conjecture_false :
    ∀ p ≥ 5, Prime p →
    ∃ A : Finset (ZMod p), A.card = (p - 1) / 2 ∧
        (1 : ZMod p) ∉ (A + A) ∪ (A * A)
```

Two possible routes:

- **Decide-based, single prime**: instantiate at a fixed small `p` (e.g.
  `p = 5`, witness `A = {0, 2}`) and discharge by `decide`/`native_decide`
  avoidance — `decide` only, since `native_decide` is banned by this
  campaign's Lean discipline (see `docs/GATE-BEFORE-PROVE.md`). Finite,
  small enough for kernel evaluation, but proves only one instance, not
  the `∀ p` statement.
- **General route**: needs an actual construction of `A` as a function of
  `p` (this gate deliberately avoided reconstructing Tang's — see
  discrimination-control item 4) with a provable size and avoidance
  property. Substantially harder; not attempted.

## Fill checklist

- [x] Numeric gate (`scripts/gates/sarkozy_sum_product.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/sarkozy_break_control.py`, NO FALSE POSITIVE)
- [ ] Local PDF pin under `incoming/` for arXiv:2603.29992 (provenance currently rests on the corpus doc's paraphrase only)
- [ ] Lean scaffold (`FragileProofAudit/SarkozySumProduct/`)
- [ ] Audit note under `docs/audits/sarkozy-sum-product.md`
