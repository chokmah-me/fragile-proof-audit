# Blueprint — Track D#1: Cohen's Conjecture 66 (Sophie Germain cyclic subadditivity)

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK — no Lean scaffold yet
**Sources:** Cohen, Conjecture 66 (heuristic, checked up to large N by the author, no structural proof) · refutation: Ibarra, J. A. (2026), "A counterexample to a subadditivity conjecture of Cohen for Sophie Germain cyclic numbers," arXiv:2607.09793 [math.NT]
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (Section 1, "Cohen's Subadditivity of Sophie Germain Cyclic Numbers")
**No local PDF pinned** — provenance here rests on a live arXiv abstract fetch (2026-09-20), not a pinned PDF under `incoming/`. Flagged, not hidden: see the control's `[1]` block.
**Attack type:** F (Counterexample Search)

## Claim

An integer `n` is *cyclic* iff `gcd(n, phi(n)) = 1`. `n` is *Sophie Germain
cyclic* iff both `n` and `2n+1` are cyclic. Let

```text
C_sigma(N) = #{ n in [1, N] : n is Sophie Germain cyclic }
```

Cohen's Conjecture 66: `C_sigma(m + n) <= C_sigma(m) + C_sigma(n)` for all
`1 <= m <= n` (subadditivity). Cohen checked this heuristically up to a large
bound without finding a structural failure.

## Load-bearing lemma chain

The implicit assumption that the density of integers whose prime
factorization keeps both `n` and `2n+1` coprime to their own totients decays
or stabilizes smoothly enough that no shifted interval of length `m` can ever
contain disproportionately more valid integers than the base interval — i.e.
no localized density spike defeats subadditivity.

**Break point:** at `m = 31`, `n = 3928` a density spike occurs:
`C_sigma(3959) = 697 > 696 = C_sigma(31) + C_sigma(3928)`.

## Numeric gate

`scripts/gates/cohen_subadditivity.py`

- Computes `C_sigma(31) = 10`, `C_sigma(3928) = 686`, `C_sigma(3959) = 697`
  from the `gcd(n, phi(n)) = 1` definition directly — not copied from the
  paper's stated numbers.
- Implementation-equivalence self-test: cross-checks `sympy.totient` against
  an independent trial-division totient on every integer up to `2*3959+1 =
  7919` before trusting either for the count (0 mismatches).
- Verdict: **BREAK**. Runtime ≈2.5s (dominated by sympy's totient calls, not
  the counting logic — the source's claimed 0.1s undersold the sympy path).
- Meta: `results/cohen_subadditivity_gate_meta.json`; registered in
  `scripts/gates/check.py` (`EXPECTED_VERDICT["cohen_subadditivity"] =
  "BREAK"`).

## Discrimination control

`scripts/controls/cohen_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction shape, same register bucket as
`suman_eq48`/`odd_zeta_1609`; not "ceremony" — an exact-equality read of this
target would have missed that a counting-logic bug, not just a totient
mismatch, could produce a false BREAK).

Four questions, per `docs/GATE-BEFORE-PROVE.md`:

1. **Transcription fidelity** — gate's definitions/witness match the
   live-fetched arXiv abstract on all 5 checked markers (cyclic definition,
   Sophie Germain definition, conjecture statement, `m,n` values, exact
   counterexample counts). `ok: True`.
2. **Machinery discrimination** — sampled 500 random `(m, n)` pairs,
   `1 <= m <= n <= 500`: **0 violations** found, while the known witness at
   `(31, 3928)` reproduces correctly. The gate does not fire on everything;
   the witness is a genuine anomaly, not an artifact of an always-BREAK
   check.
3. **Algebraic self-consistency** — re-asserts the gate's own dual-totient
   cross-check passed (delegated, not duplicated).
4. **Independent corroboration** — same abstract fetch as (1); no second
   independent source checked yet (no PDF pinned, no Lean witness file
   located to cross-read).

Verdict: **NO FALSE POSITIVE**.

## Formalizable slice

Not started. Candidate shape (per the corpus doc's suggested Lean statement,
unverified against any actual `cohen66.lean` — that file's existence is an
unverified claim in the corpus doc, not something this campaign has seen):

```lean
theorem cohen_conjecture_66_false :
    ∃ m n : ℕ, 1 ≤ m ∧ m ≤ n ∧ C_sigma (m + n) > C_sigma m + C_sigma n
```

Needs: `C_sigma` defined in Lean over `Nat.totient`/`Nat.gcd`, decidability of
the witness at `m=31, n=3928` via `decide`/`norm_num` (finite check, small
enough for kernel evaluation — the corpus doc's "instantaneous" claim is
itself unverified and should be gated before assuming it, per this
campaign's own discipline about AI-sourced runtime claims).

## Fill checklist

- [x] Numeric gate (`scripts/gates/cohen_subadditivity.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/cohen_break_control.py`, NO FALSE POSITIVE)
- [ ] Local PDF pin under `incoming/` for arXiv:2607.09793 (provenance currently rests on live fetch only)
- [ ] Lean scaffold (`FragileProofAudit/CohenSubadditivity/`)
- [ ] Audit note under `docs/audits/cohen-subadditivity.md`
