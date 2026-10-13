# Audit note — truly subquadratic 3SUM / truly subcubic APSP, Lean formalization (arXiv:2610.06783, 2026-10-13)

**Claim artifact:** Josh Alman, Virginia Vassilevska Williams, *Truly
Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse
Lopsided Graphs* (arXiv:2610.06783v1, announced 2026-10-05), and its
companion Lean 4 formalization in `anthropics/formal-math` (`3sum-apsp/`),
whose five headline claims are stated in the self-contained
`EndStatement.lean` (139 lines, imports nothing, proves nothing).
**Harvest item:** `three-sum-apsp-subquadratic` (weekly scan 2026-10-12,
issue #5, recon rank 3, fragility 2, top signal
`formal_subset_of_claim`).
**Campaign objects:** `incoming/three-sum-apsp-subquadratic/PIN.md`.
**Repo pin:** `anthropics/formal-math` @
`e1a4e6508154ea59f030480661590a9fe3018011` (verified still `main` HEAD
2026-10-13); Lean/Mathlib `v4.33.1`. Full hash table in `PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-13`. An independent adversarial re-derivation from the primary
sources (paper TeX + pinned `EndStatement.lean`) was run before this
note was written: no refutations; two wording qualifications, both
adopted below.

**Scope of this audit:** M1 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## Verdict: M1 PASS

Each of the five `EndStatement` claims states what the paper's
Theorem 19 / Theorem 22 / Corollary 39 (zero-weight case) state, as
printed. Every definitional deviation found is a strengthening or an
exact encoding, never a weakening. The formal-subset gap is real but
is exactly the gap the authors disclose (below).

| # | Formal claim | Paper statement | Match |
|---|---|---|---|
| 1 | `Theorem_19`: Exact Triangle in `O(n^(3−ε_T))`, `ε_T = 0.0017` | Thm 19 (`03-reduction.tex`, thm:zwt): `O(n^(3−ε′) log n) ≤ O(n^(3−ε_T))`, `ε′ = 0.00175` | exact; the `5×10⁻⁵` exponent gap absorbs `log n` |
| 2 | `Theorem_22_3SUM`: `O(n^1.9992)` | Thm 22 (thm:3sumapsp): `n^(2−ε′/2+o(1)) ≤ O(n^1.9992)`; sharp value `1.999125` | exact as printed; gap `7.5×10⁻⁵` absorbs `o(1)` |
| 3 | `Theorem_22_MinPlus`: `O(n^2.99942)` | Thm 22: `Õ(n^(3−ε′/3)) ≤ O(n^2.99942)`; sharp value `2.9994166…` | exact as printed; gap `3.3×10⁻⁶` absorbs log factors |
| 4 | `Theorem_22_APSP`: `O(n^2.99942)` | Thm 22, same bound, directed graphs, no negative cycles | exact as printed |
| 5 | `Corollary_39_ZeroWeight`: `∀ k ≥ 3, O(n^(k−ε_T⌊k/3⌋))` | Cor 39 (`05-other.tex`, cor:kclique), zero-weight case | exact; `(k/3 : Nat)` is floor division |

The abstract's rounder APSP bound `O(n^2.9995)` is *weaker* than the
formalized `2.99942` — the formalization states the stronger
Theorem 22 numeral, not a silently dropped one. The five claims are
also exactly the list in the paper's own appendix paragraph on Lean
certification — no more, no fewer.

## The shared definitions (where M1 usually fails)

- **`BigO T r`**: `∃ K, ∀ n ≥ 2, T n ^ r.den ≤ K * n ^ r.num.toNat`.
  This is standard `O(n^r)` with *no* log slack (`T ≤ K^(1/r.den) · n^r`);
  legitimate here only because each paper bound carries the exponent
  gaps tabulated above. All five exponents are positive rationals, so
  `r.num.toNat` is exact (e.g. `1.9992 = 2499/1250`).
- **`SolvedInTime`**: `∀ κ : Nat, ∃ program P, slope b, bound T`,
  correct on every instance whose input entries satisfy
  `|a| ≤ n^κ`, at every word size `W ≥ b·(⌊log₂ n⌋+1)`, for *all* `n`.
  Against the paper's "for every constant `ν` (Thm 19: `ν ≥ 1`), word
  RAM with `O(log n)`-bit words" this is a **strengthening, not an
  equivalence**: a real `ν` is covered by `κ = ⌈ν⌉`, correctness at the
  smallest admissible `W` is included, and small `n` are not carved
  out. (Adversarial qualification adopted: do not call this
  "equivalent".)
- **`SolvedBy`**: `n` in cell 0, input after it, outputs read from the
  cells immediately after the input (offset `1 + |input|` — no
  overlap); verdict must satisfy `verdict = true ↔ yes`, which for the
  two output problems (default `yes = True`) correctly forces accept.
- **Exact Triangle**: three `n × n` weight functions, `yes` iff
  `∃ a b c, wAB a b + wBC b c + wAC a c = 0` — the paper's
  `S(a,b,c) = 0` on a complete tripartite graph, `n` per part.
- **3SUM**: `∃ i j k`, pairwise distinct *positions*, `x i + x j + x k = 0`
  — the standard reading of the paper's "three of them sum to 0"
  (`01-intro.tex`).
- **(min,+)-product**: output entry is characterised as a value that
  is attained at some `k` and is `≤` every `A i k + B k j` — exactly
  `min_k`, with no `min` operator needed.
- **APSP**: instances are `w : Fin n → Fin n → Option Int` under the
  subtype promise `∀ i d, Path w i i d → 0 ≤ d` — every closed walk
  has nonnegative weight, which is exactly "no negative cycles" (a
  negative closed walk decomposes into simple cycles, one negative).
  Output per pair: flag 1 with a least-weight path, or flag 0 with no
  path. Exactly APSP with unreachable pairs flagged.
- **Zero-weight k-clique**: input carries all `k²` part-pair blocks;
  the decision sum ranges over `i < j` only and counts each unordered
  part-pair **exactly once** (verified by enumeration:
  `C(k,2)` terms), i.e. the total clique edge weight.

Machine generosity is disclosed by the authors (`docs/MACHINE.md`:
unit-cost word multiplication, zero-initialised unbounded cells, slope
`b` chosen after `κ`, four further points) with the claim that none
changes an exponent; that claim is part of M2, not tested here.

## M2 — Argument correspondence: NOT FULLY AUDITED (qualified)

Structural scan only. The library's sections mirror the paper's, the
proofs are stated to follow the paper's algorithms "but not in every
detail" (authors' README, departures itemised in `docs/MACHINE.md`
and `docs/REMARKS.md`). Two source-fidelity caveats are documented by
the authors themselves: the `[VW13]`/`[VW18]` reduction programs are
the formalization's own constructions, **not compared with the
constructions in those papers**; and Theorems 17 and 21 are not
stated about programs in their printed form (program versions are
proved instead). So the cited-reduction steps should be read as
*re-proved*, not *source-faithful*. The paper appendix's sentence
"all lemmas and prior results that these statements rely on are also
formalized there" is rosier than that caveat. None of this touches
M1: the five statements themselves assume no cited result. A full M2
verdict requires reading the proofs, which this pick did not do.
Text scan (not a build): no `sorry`/`axiom` in
`EndStatement.lean`/`PaperStatements.lean`, none in `ThreeSumApsp/`
or `Solution/`; the deliberate `sorry`s live in `Challenge/`, outside
the solutions' import closure.

## M3 — Credit honesty: PASS (scoping), receipt GAP (verification)

The scoping is unusually honest, in both the README ("What is not
proved", "What a reader must trust") and `docs/REMARKS.md`. Not among
the five claims, and disclosed as not proved for any machine: the
real-input Las Vegas results (Thm 35, the real half of Thm 2, Cor 38,
Lemma 37 — so the abstract's "we also refute the real-valued
versions" rests on prose, not Lean), §5.1 running times (Thm 33
occurs only as a hypothesis; Thm 34), the matrix-multiplication
exponents (`ω, α, μ` undefined), the refuted hypotheses themselves
(only running times are stated), search versions, and running-time
sentences inside proofs. Corollary 39's min/max versions are not in
`EndStatement` but **are** stated about programs in
`PaperStatements.lean` (`Corollary_39_min_max`). Corollary 40's
vdBNS reading is stated for arbitrary exponents satisfying named
lower bounds — flagged by the authors, outside the five claims.

## Receipt

- `incoming/three-sum-apsp-subquadratic/PIN.md` — paper tarball,
  repo tarball, and key-file SHA-256s as tabulated there.
- **GAP (explicit):** no independent forge build and no Comparator
  run were performed in this audit — M1 is a statement audit, and
  compilation is never its acceptance criterion. The claim that the
  library *proves* the five statements therefore rests, for now, on
  the authors' `scripts/check.sh` description; their README likewise
  records no Comparator run. Closing this GAP is a separate,
  build-bearing pick (Comparator at tag `v4.33.0`, toolchain
  `v4.33.1`, configurations pinned in `PIN.md`; permitted axioms
  `propext`, `Quot.sound`, `Classical.choice`, nanoda enabled).

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1 verify/audit
of a harvest claim: **M1 PASS** — the formalized five say what the
paper prints, with strengthenings only; **M2 qualified** (reduction
steps re-proved, not source-compared; full argument audit not done);
**M3 PASS** on scoping honesty, with the build/Comparator receipt
recorded as a GAP above.
