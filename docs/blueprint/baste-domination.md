# Blueprint — Track D#2: Baste-Furst-Henning-Mohr-Rautenbach domination inequality

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK (fully independent, no partial fallback needed) — no Lean scaffold yet
**Sources:** Baste, Furst, Henning, Mohr, Rautenbach (conjecture) · refutation: Afrasyab, K. (2026), "A 50-Vertex Cubic Counterexample to the Domination-versus-Edge-Domination Conjecture," arXiv:2609.10783 [math.CO]
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (Section 1, "The Baste-Furst-Henning Domination Inequality")
**No local PDF pinned** — provenance rests on a live arXiv HTML fetch (2026-09-20), not a pinned PDF under `incoming/`. Flagged, not hidden: see the control's `[1]` block.
**Attack type:** F (Counterexample Search)

## Claim

Every finite regular graph `G` of positive degree satisfies
`gamma(G) <= gamma_e(G)` (domination number ≤ edge domination number, where
`gamma_e(G)` is the minimum size of a maximal matching / edge dominating
set).

## Load-bearing lemma chain

The intuitive bound relating maximal matchings to vertex covers in regular
symmetric geometries — that a graph cannot need proportionally *more*
vertices to dominate than edges to edge-dominate, for regular graphs.

**Break point:** a specific 50-vertex cubic (3-regular) graph, built from a
15-variable / 20-clause SAT-gadget construction, has `gamma(G) = 16 > 15 =
gamma_e(G)`.

## Construction (re-derived, not copied from the corpus doc's narrative)

Transcribed from `arxiv.org/html/2609.10783` (live-fetched 2026-09-20):

- 15 variable-pair gadgets → 30 "literal" vertices `v_j-`, `v_j+`
  (`j = 1..15`), each pair joined by a **pair edge** `v_j- -- v_j+`.
- 20 "clause" vertices `c_1..c_20`, each joined to the 3 literal vertices
  named by its clause (`x_j` → `v_j+`, `not x_j` → `v_j-`).
- Vertex labeling: `v_j- = 2(j-1)`, `v_j+ = 2(j-1)+1`, `c_a = 29+a`.
- 50 vertices, 75 edges. 3-regular **by construction**, contingent on every
  signed literal occurring exactly twice across the 20 clauses — checked in
  the gate, not assumed (`transcription.every_signed_literal_occurs_twice`).

The 20 clauses (verbatim from the fetch, embedded in
`scripts/gates/baste_domination.py::CLAUSES`):

```text
C1=(x1,x9,~x11)    C2=(~x4,~x10,~x13)  C3=(x1,~x9,~x14)   C4=(x2,x6,x14)
C5=(~x5,~x6,x15)   C6=(x2,~x3,x15)     C7=(x3,x5,~x9)     C8=(~x6,~x12,~x15)
C9=(~x1,x5,~x11)   C10=(x4,~x7,~x15)   C11=(~x2,x8,~x12)  C12=(x3,x9,x11)
C13=(~x4,~x8,x10)  C14=(x7,~x8,x13)    C15=(x4,x7,~x13)   C16=(~x2,~x7,x14)
C17=(~x3,x11,~x14) C18=(x8,x10,x12)    C19=(~x10,x12,x13) C20=(~x1,~x5,x6)
```

## Numeric gate

`scripts/gates/baste_domination.py`

Closes both bounds independently, not by trusting the source's stated
conclusion:

- **γ_e(G) = 15**, closed both ways:
  - upper: the 15 "pair edges" form a valid, maximal matching (checked
    directly — no unmatched edge exists between two unmatched vertices).
  - lower: a **general** cubic-graph inequality — any maximal matching `M`
    must dominate all `m` edges, and each edge in a cubic graph is adjacent
    to ≤4 others, so `5|M| >= m` for *any* maximal matching, giving
    `|M| >= ceil(75/5) = 15`. This needs only 3-regularity, not this
    specific graph's structure, so it is not vulnerable to a construction
    transcription error the way a graph-specific argument would be.
- **γ(G) ≤ 16**: the source's explicit 16-vertex witness is checked to
  dominate all 50 vertices directly (not assumed).
- **γ(G) ≥ 16**: an **independent** exact branch-and-bound search (bitmask
  hitting-set DFS with a fractional lower-bound prune, NOT a
  re-implementation of the paper's `L(T)`/set-cover-recurrence argument)
  confirms no dominating set of size ≤15 exists. 8,856,929 nodes explored,
  ~12s, well inside a 45s budget — the search was written to report
  `INCONCLUSIVE` rather than a fabricated bound if the budget were exceeded;
  it was not.
- Verdict: **BREAK** (full, not `BREAK_PARTIAL`).
- Meta: `results/baste_domination_gate_meta.json`; registered in
  `scripts/gates/check.py`.

## Discrimination control

`scripts/controls/baste_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction; and specifically because this
gate's γ(G)≥16 claim rests on an exact-solver *this campaign wrote*, not on
re-running the paper's own argument — so "does the solver ever say yes" is
the sharpest possible false-positive question here).

1. **Transcription fidelity** — construction matches the live HTML fetch on
   6 checked markers (labeling formula, pair-edge count, signed-literal
   double-occurrence, edge-domination bound arithmetic, upper-witness size,
   clause-subset search scale). `ok: True`.
2. **Machinery discrimination** (the decisive check) — the same solver used
   on the target graph is run on 4 independent cases: K4 at budget=1
   (`gamma(K4)=1`, found=True), the Petersen graph at budget=3 (textbook
   `gamma=3`, found=True) *and* budget=2 (found=False — correctly declines
   below the true minimum), and the target graph itself at budget=16 (the
   source's own upper-bound witness — found=True, 103 nodes). All 4 match
   the expected outcome exactly: the solver both finds small dominating
   sets when they exist and correctly declines when they don't.
3. **Algebraic self-consistency** — the general cubic edge-domination bound
   formula (`ceil(edges/5)`), applied to K4 (6 edges), gives 2, matching K4's
   independently known minimum maximal matching size of 2.
4. Independent corroboration: same live HTML fetch as (1); no second source
   checked (no PDF pinned).

Verdict: **NO FALSE POSITIVE**.

Bug caught by writing the control: `exists_dominating_set_of_size_at_most`
originally hardcoded `n = NUM_VERTICES` (the 50-vertex target graph's own
constant) instead of `n = len(adj)`, so it crashed on every other graph the
control tried to pass it (`KeyError` on K4). Fixed before the control could
run at all — exactly the class of defect a solver-only self-test on the one
target graph would never have surfaced.

## Formalizable slice

Not started. A `gamma(G) > gamma_e(G)` witness over a `SimpleGraph (Fin 50)`
is large but finite/decidable in principle; likely the least tractable of
the Track D candidates so far (the corpus doc rates it "High" tractability
but that rating is unverified against any actual Lean attempt — this
campaign has not checked whether `decide`/`norm_num` handle a 50-vertex,
75-edge instance inside Lean's kernel budget).

```lean
theorem baste_domination_false :
    ∃ (G : SimpleGraph (Fin 50)), G.IsRegularOfDegree 3 ∧
      γ G > γ_e G
```

## Fill checklist

- [x] Numeric gate (`scripts/gates/baste_domination.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/baste_break_control.py`, NO FALSE POSITIVE)
- [ ] Local PDF pin under `incoming/` for arXiv:2609.10783 (provenance currently rests on live fetch only)
- [ ] Lean scaffold (`FragileProofAudit/BasteDomination/`)
- [ ] Audit note under `docs/audits/baste-domination.md`
