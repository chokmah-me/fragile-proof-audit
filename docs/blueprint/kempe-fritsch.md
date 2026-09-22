# Blueprint — Kempe's 1879 four color "proof" (Fritsch & Fritsch, via Gethner et al. 2009)

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` Section
4.2, harvest rank 6. Tier 2 "historical broken step, pinpoint job" — same
class as `tait_tutte`: the break is settled mathematics (Heawood 1890 /
de la Vallée Poussin 1896 identified the flaw in general; Fritsch & Fritsch
1998 gave a small explicit counterexample), and the campaign's contribution
is an independently computed, from-scratch verification of the witness.

## The claim

Alfred Kempe, 1879: every plane graph can be properly 4-colored, by an
inductive algorithm using "Kempe chain switches." At a degree-5 vertex `v`
whose five neighbors carry colors `G, R, G, B, Y` in cyclic order (two
`G`-neighbors separated by `R` on one side, by `B` and `Y` on the other —
"Configuration 2," Gadget 5₂ in the source paper below), Kempe's method
attempts two successive chain switches (a `G_aB`-switch, then a
`G_bY`-switch, or the reverse order) to free a color for `v`. Kempe
implicitly treated the order of these two switches as immaterial.

## The break

Percy Heawood (1890) and Charles de la Vallée Poussin (1896) independently
found the general flaw: the two switches can interfere with each other.
Rudolf and Gerda Fritsch (*The Four-Color Theorem*, Springer, 1998) gave
a small, explicit 9-vertex graph — the Fritsch graph, isomorphic to the
skeleton of the triaugmented triangular prism — on which one switch order
succeeds and the other tangles irrevocably.

## Primary source used

Ellen Gethner, Bopanna Kallichanda, Alexander S. Mentis, et al., **"How
false is Kempe's proof of the Four Color Theorem? Part II,"** *Involve*
2:3 (2009), <https://msp.org/involve/2009/2-3/involve-v2-n3-p01-p.pdf>.
Local pin: `incoming/kempe-fritsch-gethner-involve-2009.pdf`
(sha256 `5aee2bc4c64f0bb71272f797f2bb5705e59adaff9d77339e6208755cb237cc0c`).

This paper states Definitions 1–3 (Kempe chain, Kempe chain switch,
irrevocable Kempe chain tangle) verbatim and precisely — quoted in full in
`scripts/gates/kempe_fritsch.py`'s docstring — and proves **Theorem 4**
("Gadget 5₂ is order-dependent") by exhibiting exactly this scenario on the
Fritsch graph, illustrated in Figure 3. The pinned PDF's body text extracts
cleanly (via `pdfplumber`, not the WebFetch HTML converter, which mangled
it); **Figure 3 itself is a rendered diagram, not text** — its content
(the graph's edges, the pre-coloring, and the two switch sequences) was
read off a 300-DPI render of PDF page index 10 (page 258), not
reconstructed from memory or a secondary description. See "Transcription
record" below.

## Transcription record

**Graph** (9 vertices, 21 edges), traced from the drawn line segments in
Figure 3's top diagram:

```
9-6, 9-2, 9-3, 9-8, 9-7,
6-2, 6-1, 6-8,
3-2, 3-5, 3-7,
2-1, 2-5,
1-5, 1-8, 1-4,
5-4, 5-7,
4-8, 4-7,
8-7
```

Cross-check: this edge list's degree sequence is exactly three vertices of
degree 4 (`{6, 3, 4}`) and six of degree 5 (`{9, 8, 7, 2, 1, 5}`) — matching
the Fritsch graph's independently documented degree sequence (Wikipedia:
"3 × 3⁴ + 6 × 3⁵") and edge count (21) exactly. This agreement across two
independent sources (the figure's drawn edges vs. the graph's known
invariants) is the transcription's main self-check.

**Initial coloring** (Figure 3, top diagram; vertex 1 uncolored):
`9=R, 6=B, 3=Y, 2=G, 5=R, 4=G, 8=Y, 7=B`. Vertex 1's five neighbors
`{6, 2, 5, 4, 8}` carry colors `{B, G, R, G, Y}` — the Configuration 2
pattern (two `G`s, separated by `R` on one side via the edge 2–5–4, by `Y`
and `B` on the other via 4–8–…–6–2).

**Branch A** ("No Tangle," left path in Figure 3): switch 1 is a `G,Y`
Kempe chain switch on the component containing vertex 2 — read off the
figure as vertices 2 and 3 swapping colors (`2: G→Y`, `3: Y→G`), with the
switched edge 2–3 highlighted in purple. Switch 2 is a `G,B` switch on the
component containing vertex 3 — read off as vertices 3, 4, 7 swapping
(`3: G→B`, `4: G→B`, `7: B→G`), edges 3–7 and 4–7 highlighted. Result:
vertex 1's neighbors are now `{B, Y, R, B, Y}` — no `G` — vertex 1 is
colored `G` (drawn green in the figure's final panel).

**Branch B** ("Tangled," right path): switch 1 is a `G,B` switch on the
component containing vertex 4 — read off as vertices 4 and 7 swapping
(`4: G→B`, `7: B→G`), edge 4–7 highlighted. Switch 2 is a `G,Y` switch on
the component containing vertex 2 — read off as vertices 2, 3, 7, 8
swapping (`2: G→Y`, `3: Y→G`, `7: G→Y`, `8: Y→G`), edges 2–3 and 3–7 (and
implicitly 7–8) highlighted. Result: vertex 1's neighbors are now
`{B, Y, R, B, G}` — `G` has reappeared at vertex 8 — vertex 1 is marked
with an "X" (unresolvable) in the figure's final panel.

This exactly matches Definition 3's irrevocable-tangle criterion: "following
a `GY`-Kempe chain switch on K₂ causes [the original `Y`-neighbor] to be
recolored `G`."

## Gate

`scripts/gates/kempe_fritsch.py`. Implements Definitions 1–2 (Kempe chain =
maximal connected component in the graph restricted to two colors; Kempe
chain switch = swap those two colors on that component) as plain BFS graph
algorithms, applied to the transcribed graph and coloring above. Runs both
branches from the same starting coloring and checks: (a) the computed chain
components match the ones read off the figure exactly (`[2,3]`/`[3,4,7]`
for Branch A, `[4,7]`/`[2,3,7,8]` for Branch B); (b) properness is preserved
after every switch (a mathematical necessity for a genuine Kempe switch,
checked as a sanity invariant); (c) Branch A leaves no `G` among vertex 1's
neighbors while Branch B reintroduces one.

**Confirm** (route survives): both orders agree. **Break** (route refuted):
they disagree — Gadget 5₂ does not commute.

## Discrimination control

`scripts/controls/kempe_fritsch_break_control.py`. Two checks:

1. Independent (non-gate-code) re-verification that properness is preserved
   after every switch in both branches — an implementation-correctness
   check, since a buggy switch could fabricate an apparent tangle out of an
   already-improper coloring.
2. A matched near-miss: a bare 5-wheel graph (hub + 5-cycle rim, no extra
   chords) with the same Configuration-2 color pattern around the hub. Here
   the `G_a` and `G_b` Kempe chains are each a single isolated vertex (no
   chord connects them to anything else colored `G`/`B`/`Y`), so the same
   switch machinery, completely unmodified, must find both switch orders
   agree (no tangle). This confirms the Fritsch graph's genuine tangle comes
   from its extra long-range edges (3–7, 4–7, 7–8), not from the search
   itself being inherently order-sensitive.

Verdict: **NO FALSE POSITIVE**.

## Do not claim

- That this campaign discovered the counterexample (Fritsch & Fritsch,
  1998; Theorem 4 as stated is Gethner et al.'s, 2009).
- That this refutes the four color theorem — it is true (Appel–Haken 1976,
  formalized in Coq by Gonthier); Kempe's specific *method* is what fails.
- That Kempe–Kittell chains (the paper's proposed fix, Gadget Kittell) were
  gated — not attempted this session.
- No Lean scaffold attempted — mathlib's planar-graph coloring coverage
  was not surveyed; the corpus report's own estimate for this target is
  4–8 weeks, "planarity is the expensive part."
