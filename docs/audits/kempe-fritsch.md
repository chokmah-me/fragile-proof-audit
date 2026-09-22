# Audit note — Kempe's 1879 four color "proof" (Fritsch & Fritsch, via Gethner et al. 2009)

**Claim artifact:** A. B. Kempe (1879), algorithm; R. & G. Fritsch (1998),
counterexample; Ellen Gethner et al. (2009), *Involve* 2:3, Theorem 4 —
formal statement and figure used for this gate.
**Campaign objects:** `docs/blueprint/kempe-fritsch.md`,
`scripts/gates/kempe_fritsch.py`,
`scripts/controls/kempe_fritsch_break_control.py`,
`results/kempe_fritsch_gate_meta.json`,
`incoming/kempe-fritsch-gethner-involve-2009.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Gadget 5₂'s two successive Kempe chain switches commute — the order does not affect whether Algorithm Kempe successfully colors the vertex |
| **Instance** | The Fritsch graph (9 vertices, 21 edges), the pinned pre-coloring, vertex 1 (degree 5, Configuration 2 neighbor pattern `G,R,G,B,Y`) |
| **False instance** | Switch order A (`(2,G,Y)` then `(3,G,B)`) succeeds; switch order B (`(4,G,B)` then `(2,G,Y)`) reintroduces `G` at vertex 8, tangling vertex 1 irrevocably |

**Verdict: BREAK.** This is settled 1890s/1998/2009 mathematics (Heawood,
de la Vallée Poussin, Fritsch & Fritsch, Gethner et al.), not new to the
campaign.

## What was gated

Tier 2 historical pinpoint job (`corpus/fragile-formalizable-proofs-report.md`
§4.2, harvest rank 6), same class as `tait_tutte` (rank 7, landed the prior
session). Unlike `tait_tutte`, whose witness graph and property (Hamiltonian
cycle existence) came from a well-documented library reference construction,
this target's decisive content — the exact graph, the exact 9-vertex
pre-coloring, and the exact two switch sequences — exists **only as a
rendered diagram** (Figure 3) inside the primary source PDF, not as
transcribable prose. Two earlier WebFetch attempts at this PDF returned
corrupted/unreadable binary content; the actual body text extracted cleanly
via `pdfplumber` (a proper PDF text library) once the file was saved
locally, but Figure 3 itself remained an image. Rendered that PDF page to a
300 DPI PNG and read the graph, coloring, and switch sequences directly off
it (multiple crops at increasing zoom); cross-checked the resulting
edge list against the graph's independently documented degree sequence
(3 vertices of degree 4, 6 of degree 5) before trusting it, per this
campaign's standing discipline against gating from an unverified
transcription.

- Structural check: 9 vertices, 21 edges, matching degree sequence.
- Initial-coloring check: proper on all 8 colored vertices; vertex 1's
  neighbor colors match the Configuration 2 pattern the paper's Gadget 5₂
  is defined for.
- Both branches: from-scratch BFS implementation of Definitions 1–2 (Kempe
  chain / Kempe chain switch, quoted verbatim in the gate's docstring)
  reproduces the exact chain components shown in the figure
  (`[2,3]`/`[3,4,7]` for Branch A, `[4,7]`/`[2,3,7,8]` for Branch B) and the
  exact outcome (no tangle / tangle).

## Discrimination control

`scripts/controls/kempe_fritsch_break_control.py`:

- Independently re-verifies properness is preserved after every switch in
  both branches (brute-force edge scan, not calling the gate's own
  properness check) — rules out a switch-implementation bug fabricating an
  apparent tangle from an already-broken coloring.
- Matched near-miss: the same Configuration 2 color pattern on a bare
  5-wheel graph (no chords beyond the rim cycle and hub spokes). There, the
  two Kempe chains are trivially isolated single vertices, and the same
  unmodified machinery correctly finds both switch orders agree — confirming
  the Fritsch graph's tangle is a genuine consequence of its extra
  long-range edges (3–7, 4–7, 7–8), not an artifact of the search being
  inherently order-sensitive.

Verdict: **NO FALSE POSITIVE**.

## Not done, on purpose

- Did not gate Gadget Kittell (the paper's proposed randomized fix using
  eight named Kempe–Kittell chains) — out of scope; Theorem 4 alone is the
  claim under test.
- Did not attempt Kempe's method on the Soifer graph (the smaller
  10-edge-fewer variant mentioned in the same literature) — a different,
  independent witness, not needed once Theorem 4's own witness verifies.
- No Lean scaffold attempted — mathlib's planar-graph coloring coverage was
  not surveyed this session; the corpus report's own effort estimate here
  is 4–8 weeks, "planarity is the expensive part."
