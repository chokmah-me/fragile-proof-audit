# Recon: FRK-UC — Demontis's claimed proof of Frankl's union-closed sets conjecture

**Status:** recon complete 2026-09-23. No gate code written. Nothing committed.
**Gate feasibility verdict: NOT-GATEABLE** (as a finite-search route refutation).
The defect is proof-logical (type-G logical gap), not a finitely falsifiable
false lemma — the dossier's hypothesized enumeration gate would PASS and miss it.

## Paper pin

- **arXiv:2405.03731v1** [math.CO], "The union-closed set conjecture is true",
  Roberto Demontis (robdemontis@gmail.com), submitted 6 May 2024.
- 8 pages, LaTeX/hyperref, no figures. PDF fetched 2026-09-23 from
  `http://arxiv.org/pdf/2405.03731`:
  `SHA-256 f7c748d33c8721841b7ffe8a77ee0de7c89f72a91dc4416a8c18d1a0137cf6c3`
  (104,779 bytes).
- Submission history shows **only v1**; not withdrawn. HTML version
  (`arxiv.org/html/2405.03731v1`) carries identical content.
- PDF text extraction (`pdftotext -layout`) is **clean and complete** — no
  lossy sections, all inline math readable, all lemma/theorem numbers recovered.
- **Dossier discrepancy (corroborates corpus/README.md "Finding targets. Not
  describing them."):** `corpus/Fragile-Route_Harvest_Dossier_II.md` Hit 2
  misattributes this paper to "S. Schäge" and describes an entropy-method
  argument. The actual paper is by **Roberto Demontis** and uses purely
  combinatorial machinery (basis/deletion sequences, "optimal sequences",
  "quasiminimal" elements). Do not trust the dossier's description.

## Lemma map (exact numbering, verbatim load-bearing statements)

Notation: `A = 2^[n] − {∅}`, `F ⊆ A` union-closed, `D = A − F` (deleted sets),
`F^i = {X ∈ F : i ∈ X}`, `D^i = {X ∈ D : i ∈ X}` (note: the paper overloads
`D_j` in Thm 4's proof to mean the first `j` deleted sets — see below).

- **Def 1** — basis: `B(F) = {X ∈ F | ∀Y, Z ∈ F − {X} : X ≠ Y ∪ Z}`.
- **Lemma 1** — "For all X ∈ F, not necessarily union-closed, we can always
  find a set T = {T1; …; Tr} ⊆ B(F), such that X = ∪T." (fine)
- **Def 2/3** — (union-closed) sequence from A to F by single deletions.
- **Lemma 2** — "Let F ⊆ A be a union-closed set, let B ∈ B(F), F − {B} is a
  union-closed set." (fine)
- **Lemma 3** — "Let F ⊆ A (F is not neccessarily union-closed) let
  Z ∈ F − B(F), then B(F) ⊆ B(F − {Z})." (fine)
- **Theorem 2** — "Let F ⊆ A be a union-closed set, then it exists a
  union-closed sequence from A to F." (fine; deletion of basis elements,
  Lemma 1+3 close the termination argument)
- **Lemma 4** — "For all j ∈ ∪A, F ∪ D^j is a union-closed set." (fine)
- **Def 4** — *ideal sequence*: all sets not containing `i` deleted first.
- **Lemma 5** — "For all union-closed sets F ⊆ A there is an ideal sequence
  from A to F." (fine; size-ordered deletion of `D^i`)
- **Def 5/6/7** — extension `E_X(Y)`; `X ∈ D` *vincolated* iff `F ∪ {X}` not
  union-closed (i.e. `∃Y ∈ F : X ∪ Y ∈ D`); *vincolated to Y*.
- **Theorem 3** — "Let F ⊆ A be a union-closed set, let D = A − F, then if
  each X ∈ D − D^i is vincolated, then it is possible to find an element
  Y ∈ D − D^i vincolated to a non-vincolated R ∈ D^i." (proof is shaky —
  maximality argument assumes `R = Y ∪ X ∈ D^i` strictly larger without
  ruling out `R = Y`; secondary, not the decisive break)
- **Def 8** — *optimal sequence for i*: ends `… −{X_{t−1}} −{X_t} = F` with
  `i ∈ X_t`, `i ∉ X_{t−1}`, prefix ideal to `F ∪ {X_t; X_{t−1}}`.
- **Lemma 6** — "If D^i ≠ D, it is always possible to build an optimal
  sequence for i on D." (two cases via Thm 3 / Lemma 5)
- **Def 9** — *quasiminimal*: "i is said quasiminimal on D for a set
  Y = {Y1; Y2} ⊂ F iff (1) i ∈ Y2, (2) i ∉ Y1, (3) i is minimal on D ∪ Y,
  (4) ∃ optimal sequence A_0…A_{t+2} from A to F − Y with
  A_{t+1} = A_t − {Y1}, A_{t+2} = A_{t+1} − {Y2}."
  **Note the domain: `Y ⊂ F`.**
- **Theorem 4** — "For all D, it exists i such that if it exists a set
  Y = {Y1; Y2} i quasiminimal on D for Y, then
  `2|(D ∪ Y)^i| ≤ |(D ∪ Y)| + 1`." ← **earliest fragile step**
- **Theorem 5** — "Let D = A − F and let j minimal on D, with |D| > 1.
  Then `2|D^j| ≤ |D| + 1`." ← **decisive step**
- **Theorem 1** (main) — "Let F ⊆ A be a union-closed set, we can find
  i ≤ n such that `|F| ≤ 2|F^i|`." Proof: `|F| = |A| − |D|
  = 2|A^i| − 1 − |D| ≤ 2|A^i| − 2|D^i| = 2|F^i|`, using Thm 5
  (`−1 − |D| ≤ −2|D^i| ⟺ 2|D^i| ≤ |D| + 1`). The final implication is
  sound arithmetic; cases `|D| ≤ 1` are unaddressed but hold trivially.

## The break: Theorem 4 → Theorem 5 inference is logically invalid

**Theorem 4's statement** is an ill-formed conditional: `∃i[(∃Y quasiminimal(i,D,Y)) → 2|(D∪Y)^i| ≤ …]`
with `Y` bound in the antecedent but free in the consequent.

**Theorem 4's proof, Case 1** (verbatim load-bearing sentences):
"Suppose that for some i that satisfy the theorem for Dt−1 … If we could
choose Y such that i quasiminimal on D for Y, we could do as follows. …
By definition i quasiminimal on Dt−1. Thus, by inductive hypothesys,
`2|(Dt−1 ∪ {Xt; Xt+1} ∪ Y)^i| ≤ |(D ∪ Y)| + 1`."
Four defects: (a) "i that satisfy the theorem" is meaningless for an
∃-statement; (b) the proof proceeds on the undischarged hypothesis
"If we could choose Y"; (c) "by definition i quasiminimal on Dt−1" is
false — quasiminimality is relative to an exhibited `Y ⊂ F`, none is
given; (d) the induction hypothesis yields `∃i'[antecedent → consequent]`,
not the inequality for *this* `i`. Case 2 is no better (it concludes
`|Dt| = 1` "proved at the inductive step" from a degenerate subcase, and
writes `2|(Dt ∪ {Y1; Xt+1} ∪ {Y2})^i| = 2|Dti| + 4` although Def 9(2)
requires `i ∉ Y1`).

**Theorem 5's proof** (verbatim): "By Theorem 4, it exists i, not necessarily
different from j, such that for the set {Xt; Xt+1} i quasiminimal on Dt−1
for {Xt; Xt+1} and `2|(Dt−1 ∪ {Xt; Xt+1})^i| ≤ |Dt−1 ∪ {Xt; Xt+1}| + 1`."
Two defects: (a) **quantifier confusion** — Theorem 4's `∃i[A(i) → B(i)]`
is upgraded to `∃i[A(i, Y₀) ∧ B(i)]` for the *specific* `Y₀ = {X_t, X_{t+1}}`,
which nothing provides (the optimal sequence is for `j`, and Theorem 4's
`i` carries no quasiminimality guarantee for this `Y₀`); (b) **type error
against Definition 9** — quasiminimality requires `Y = {Y1;Y2} ⊂ F`, but
`X_t, X_{t+1} ∈ D = A − F`. "Quasiminimal on D_{t−1} for {X_t; X_{t+1}}"
is ill-typed per the paper's own Definition 9. (The subsequent
`2|D^j| = 2|D^i|` step would be fine *if* `i` were minimal on `D` — both
minima coincide — but that `i` is never produced.)

No easy repair is visible: instantiating at `i := j` (which does satisfy
Def 9(1)–(3) for `Y₀`) still needs Theorem 4's implication for *all* `i`,
which is not what Theorem 4 states or proves. A repair would have to prove
a strictly stronger Theorem 4 — essentially as hard as Theorem 5 itself.

## Gate feasibility: NOT-GATEABLE (finite search cannot refute this route)

Theorem 5 *is* universal over families and finitely falsifiable, so the
dossier's hypothesized gate (enumerate union-closed families on small ground
sets, test `2|D^j| ≤ |D|+1` for minimal `j`) is buildable — but it would
**PASS and miss the real defect**:

- Throwaway probe (`/tmp/frkuc/probe_thm5.py`, not a gate, not committed):
  **all 61** union-closed families on n=3, **all 2480** on n=4, and 300,000
  sampled union-closed families on n=5 satisfy Theorem 5 with **zero
  violations**. (Enumeration cross-checked: n=2 gives 7 = all subsets of
  `A` except `{{1},{2}}`, as expected.)
- The defect is in the *inference* (quantifier confusion + Def-9 type
  error), which no finite family-enumeration can detect. A PASS on any
  enumeration says nothing about whether Theorem 4's proof establishes
  Theorem 5.

Correct instrument: a **type-G logical-gap pinpoint** — formalize Theorem 4's
statement and exhibit that its proof's Case 1 / Theorem 5's invocation does
not go through (the `∃i[A→B]` vs `∃i[A(Y₀)∧B]` confusion and the
`Y₀ ⊂ F` vs `Y₀ ⊂ D` mismatch). This refutes the *route*, not the theorem:
Theorem 5 may well be true (small cases support it), and Frankl's
conjecture itself is untouched by this finding.

## Public discussion / status

- No v2, no withdrawal; v1 (6 May 2024) is the only version.
- **No published rebuttal, no r/math announcement thread, no MathOverflow
  refutation located** (two web searches, 2026-09-23).
- Third-party status scout (txmy/ultra-mathematician, Jul 2026) lists the
  conjecture as `probably-open`, Demontis's paper as a "resolution claim,
  not accepted here as an established solution", noting Bouchard's 2025/2026
  minimum-counterexample program continues and "no independent acceptance
  path was located".
- The conjecture is therefore still treated as **open** by the community;
  this paper is an unaccepted claimed proof with a broken decisive inference.

## Recommended next step (if parent approves)

Write the type-G audit note (`docs/audits/frankl-uc-gap.md`): pin Theorem 4's
statement verbatim, exhibit the quantifier/type errors with the exact
quoted lines, and record disposition "proof GAP — route refuted, theorem
untouched". Optionally add the Theorem-5 enumeration as a *control-style*
script under `scripts/analysis/` documenting that the lemma statement
survives small cases (so the finding is precisely scoped to the inference).
Do **not** frame as BREAK: no counterexample to any lemma statement was found.
