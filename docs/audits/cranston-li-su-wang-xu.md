# Audit note — Cranston–Li–Su–Wang–Xu (2026) conjecture is true, Lean formalization (arXiv:2610.40863, 2026-11-06)

**Verdict: PASS.** The pinned Lean artifact builds cleanly from
its pinned tag on the self-hosted runner, and the author's
106-claim audit table reproduces byte-identically from `#print
axioms` (106 PROVED, 0 PROVED-FROM-CITED, no sorryAx, no axiom
declarations anywhere in the tree). The abstract's claim — all
results proved in Lean 4 "from Lean's standard axioms alone" — is
verified as stated: the five headline declarations depend on
exactly `propext`, `Classical.choice`, `Quot.sound`, and nothing
else. Unlike the same author's Hibi-Li formalization (audited
2026-11-05, PASS conditional on one unrefereed preprint axiom),
this artifact carries **no external input at all**: no `Cited/`
folder, no project axiom, no hypothesis-packing at statement
level. The condition that shaped the Hibi-Li verdict does not
arise here.

**Claim artifact:** Dave Goel, *The Cranston–Li–Su–Wang–Xu
(2026) conjecture is true*, arXiv:2610.40863, submitted
2026-10-29 (13 pages). ID, title, author verified on the abs
page 2026-11-05. The arXiv text is the SHORT paper (e-print
`p002_short.tex`); an expanded version is posted on Zenodo
(paper's reference [G]) and is a different text — see M1 scope.
Claim: for every finite abelian group A with |A| ≥ 4, any two
nowhere-zero A-flows on an all-even-degree graph are joined by a
chain of cycle changes through nowhere-zero flows (Theorem
2.3: every even graph is A-flow-connected), and likewise for
integer k-flows, k ≥ 4 (Theorem 8.1: every even graph is
k-flow-connected).
**Harvest item:** `cranston-li-su-wang-xu-lean` (harvest
2026-11-05, recon Card 10, fragility 1: `single_author`,
`pinned_toolchain`). **Pick:** chosen 2026-11-05 at the user's
tap after an Argon double-check of the harvest shortlist
overturned the fit ranking's #1 in this item's favor
(adjudication outside the repo:
`~/workspace/replaygate-harvest-argon-2026-11-05/ADJUDICATION.md`);
the pick's deciding question was whether any unproved input had
moved from an `axiom` declaration into a statement hypothesis
after the Hibi-Li audit. It had not (M1, M4).
**Campaign objects:** `incoming/cranston-li-su-wang-xu-2026-conjecture/`
(paper PDF, e-print tarball, `repo-v1.59/` pinned folder,
`PIN.md`).

**Canonical artifact (full detail in `PIN.md`):**
`david44hello/papers_supporting_materials`, tag
`cranston-li-su-wang-xu-2026-conjecture-v1.59` @
`7c03e0ba9a2c34e578472f477237a64d5c181e02`, folder
`cranston-li-su-wang-xu-2026-conjecture/lean/` — a complete lake
project (55 `.lean` files, library `EulerFlow`, toolchain
`leanprover/lean4:v4.35.0`, Mathlib `v4.35.0`, manifest rev
`56a005855ea17e0b0958f73ec801ae140b0a1679`). The arXiv comments
field names the tag; repo `main` is a moving multi-paper tree
and is not canonical.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
skills `lean-proof-forge` (forge pattern), harvest-loop M1–M4
standard · run dates `2026-11-05` (pin, recon read) and
`2026-11-06` (forge completion, this note). The forge workflow
(`.github/workflows/cranston-li-forge.yml`, deleted at this
close-out) was written by the main agent by adapting the
Hibi-Li forge, adversarially reviewed, passed the pre-dispatch
gate (K13/K14 + FM7) before dispatch, and its two source scans
were pre-run clean against the pinned tree on the VM. The
verification route is the author's own `audit.py` regeneration
plus an independent `#print axioms` check written by the main
agent. An Argon (google/gemini-4-argon) double-check of the
harvest ranking preceded the pick; it did not touch this
verdict, which rests only on the receipts below.

## M1 — Statement fidelity: PASS (headline and definitions, read line by line)

Headline declarations in `EulerFlow/Paper/Statements.lean`,
read against the short paper:

- `thm_2_3` (Theorem 2.3; short-paper Theorem `thm:all`, part
  (a) of the main theorem at tex l.81-87): `(A : Type)
  [AddCommGroup A] [Fintype A] (hA : 4 ≤ Fintype.card A)
  (G : MGraph V E) (hev : G.IsEven) : G.FlowConnected A` —
  exactly the paper's hypotheses (finite abelian group,
  |A| ≥ 4, every vertex of even degree), no others.
- `thm_2_4` (Theorem 2.4): the `ZMod m`, m ≥ 4 form, conclusion
  the step-graph preconnectedness with step values in
  {1, −1, 2, −2} — the paper's cyclic refinement.
- `thm_8_1` (Theorem 7.1 in the short paper's numbering,
  `thm:int`, tex l.579-584): `(hk : 4 ≤ k) (hev : G.IsEven) :
  G.KFlowConnected k` — part (b) of the main theorem.
- Supporting headlines `thm_2_2` and `prop_3_4` read the same
  way; no statement in the file carries a Prop-valued
  hypothesis structure, an extra side condition, or a
  `ClassicalInputs`-style package. The hypothesis-smuggling
  adaptation hypothesized at pick time is absent.

Definitions in `EulerFlow/Defs/Graph.lean`, read against the
short paper's Section 2 and Section 7 definitions:

- `MGraph` is a pair of functions `src, tgt : E → V`; loops
  and parallel edges are allowed, as the paper stipulates.
  `degree v` counts ends at v, a loop counting twice;
  `IsEven` is every degree even.
- `IsFlow` is the Kirchhoff condition (sum over edges leaving
  v equals sum over edges entering v, a loop in both sums);
  `IsNZFlow` adds f(e) ≠ 0 on every edge. `boundary` matches
  the paper's ∂x (entering minus leaving), and the table's
  `sec8_flow_iff_boundary` row is the paper's "x is a flow iff
  ∂x = 0".
- A step is `f' = f + t χ_Q` with t ≠ 0 (`stepGraph`);
  `flowGraph A` takes all non-zero step values, the paper's
  𝓕(G, A). `FlowConnected` is `Preconnected`, not Mathlib's
  `Connected` — deliberately, and correctly: the paper counts
  a flow graph with at most one vertex as connected (short
  tex, Section 7: "it counts as connected when it has at most
  one vertex", said of both flow graphs). The trivial cases
  are separately proved rows (`sec3_no_edge`: a graph with no
  edge has exactly one flow; `sec2_trivial_group` for |A| = 1).
- `Ik k = {x | 1 ≤ |x| ∧ |x| ≤ k - 1}` and `kFlowGraph`
  adjacency by λχ_Q, λ ≠ 0, match the paper's k-flow
  definition and 𝓕(G, k) verbatim.

Modeling notes (choices, not gaps): a directed cycle is a
cyclic list of darts with distinct edges and distinct tails —
the paper's "connected subgraph in which every vertex has
degree 2" rendered as a closed trail, the standard rendering;
the `Defs/` docstrings cite line numbers of the expanded
version (v0.30) while `Statements.lean`, `AUDIT.md`, and
`SHORT_MAP_v1.59.tsv` cite the short paper. SHORT_MAP spot
checks landed verbatim (Definition 2.1's loop parenthesis at
l.219; the Kirchhoff equation at l.205-209; Theorem 7.1's
statement at l.582 against the tex's l.579-584).

Scope direction: the 106-row table includes results the table
itself marks "not in the short paper (long paper v0.30 only)"
(e.g. rows 10, 48-51, 69-72) — the Lean proves **more** than
the arXiv text states, never less. M1 was mapped against the
short paper's claims only; the long-paper-only rows were not
checked against the Zenodo text.

## M2 — Argument (build reproduction): PASS

One forge run on the self-hosted desktop runner
(DESKTOP-7HDI2D1), target HEAD verified fail-closed before
building:

- Run #1,
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42148721865
  (main@5c80448; dispatched 2026-11-06 02:11 UTC; sat queued
  5h43m until the desktop runner came up, then ran 07:54-08:00
  UTC, forge job 6m05s): **conclusion success, every step
  green.** Gate job success (5s). Evidence artifact
  `cranston-li-forge-evidence` (id 13487380223, 36,601 bytes,
  sha256
  `918b78dd87c22b23b3010621d2cecea2fb053b55d66de803a862617ec3e725c9`,
  per the Actions API listing): `verdict.txt` reads `PASS`;
  `TARGET_HEAD` is the pinned `7c03e0ba`; Lean 4.35.0.
- Pin checks inside the run: 55 lean files (expected 55);
  sha256 OK on `AUDIT.md`, `EulerFlow/Paper/Statements.lean`,
  `EulerFlow.lean`. Mathlib cache: 9,030 files decompressed
  from the runner's cache, no download. Build: 9,102 jobs,
  green in 3m38s (warnings are linter-only; see minor gaps).
- `scripts/audit.py` regenerated `AUDIT.md` **byte-identical**
  to the pinned table: 106 claims, all PROVED.
- The independent `#print axioms` check returned, for all five
  headline declarations (`thm_2_3`, `thm_2_4`, `thm_8_1`,
  `thm_2_2`, `prop_3_4`), exactly `[propext, Classical.choice,
  Quot.sound]` — the standard three, in full, nothing else. No
  `sorryAx` anywhere.
- Source scans (mirror of the author's `check.sh` policy):
  zero `sorry` / `admit` / `native_decide` / `implemented_by` /
  `unsafe`, and zero `axiom` declarations anywhere in the tree
  — pre-run clean on the VM against the pinned tree and clean
  again inside the forge run.

## M3 — Credit honesty: PASS

The disclosure is accurate, and it is stronger than the same
author's Hibi-Li disclosure: there the abstract's "from
standard axioms" reading would have been wrong (19 cited rows,
one unrefereed axiom); here the abstract's "from Lean's
standard axioms alone" is exactly what two independent axiom
passes find. `AUDIT.md`'s Trust line ("there is NO
EulerFlow/Cited/ folder and no project axiom") is true of the
pinned tree. The table marks its own scope honestly, flagging
the long-paper-only rows as not in the short paper rather than
letting a reader assume the arXiv text contains them. No
hidden axiom, no undisclosed subset: the formalized set is a
superset of the short paper's results, disclosed as such.

## M4 — Fine-print assumption inventory

Load-bearing assumptions behind the headline:

1. The standard three Lean axioms (`propext`,
   `Classical.choice`, `Quot.sound`) — present on every
   listing, as expected. Nothing else. In particular **no
   published theorem enters as an axiom or as a hypothesis**:
   the contrast with the Hibi-Li artifact (four declared cited
   axioms) and with the hypothesis-package pattern seen
   elsewhere in this harvest window (explicit `ClassicalInputs`
   structures) is total.
2. The trusted base is Mathlib v4.35.0 at the pinned manifest
   rev, kernel-checked in the ordinary way. Residual if
   Mathlib fell: the claim would fall with it — the standard
   residual for every Lean audit in this repo, recorded for
   completeness.
3. Definition fidelity (M1) is the author's own rendering of
   the CLSWX graph model; the audit read the definitions
   against the paper and found them faithful, with the two
   modeling choices named in M1 (dart-list cycles;
   `Preconnected` per the paper's own convention). Residual:
   if the paper's "cycle" were read to admit a closed trail
   the dart-list model excludes, some lemma statements would
   shift meaning — no such case was found in the headline
   path.

Minor artifact gaps (recorded, not verdict-changing):
- `EulerFlow/Paper/Statements.lean` carries dead tactic code
  (build linter: line 259, `apply lem_6_1_proved <;>
  assumption` — the `assumption` never executes; line 265
  similar). Cosmetic; the statements are unaffected.
- The author's `scripts/kernel_replay.sh` (independent-kernel
  replay, author-stated about 20 minutes) ships in the pinned
  artifact but was **not** run by this audit; the verdict
  rests on the lake build, the author's `audit.py`, and the
  independent `#print axioms` pass. A kernel-replay run is
  available as a follow-up if ever wanted.
- `AUDIT_NOTES.md` and the long-paper line citations in
  `Defs/` docstrings refer to the expanded version (Zenodo),
  which was not pinned by this audit; only the short paper
  was.

## Honest scope

This audit verifies the Lean artifact at the pinned tag and
the accuracy of its axiom disclosure against the short paper
(arXiv:2610.40863). It does not verify the paper's prose
proofs, the expanded Zenodo version's additional results, or
the CLSWX (2026) paper being answered. Within that scope the
headline stands unconditional: the conjecture, as the short
paper states it, is proved in Lean from the standard axioms
alone.

## Results

- Forge run #1:
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42148721865
  — conclusion success, verdict PASS.
- Evidence artifact `cranston-li-forge-evidence` (Actions,
  id 13487380223, 36,601 bytes, sha256
  `918b78dd87c22b23b3010621d2cecea2fb053b55d66de803a862617ec3e725c9`,
  expires 2027-02-04).
