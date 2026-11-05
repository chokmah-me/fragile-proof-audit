# Audit note — Hibi–Li (2016) conjecture fully resolved, Lean formalization (arXiv:2610.40703v2, 2026-11-05)

**Verdict: PASS (conditional).** The pinned Lean artifact builds
cleanly from its pinned commit on the self-hosted runner, and the
author's 177-claim audit table reproduces byte-identically from
`#print axioms` (158 PROVED, 19 PROVED-FROM-CITED, no sorryAx, no
open or violation rows). The headline — Conjecture 1.1 resolved — is
proved in Lean **conditional on exactly one unrefereed-preprint
axiom**, `fourier_prop_5_2` (Fourier, Proposition 5.2,
arXiv:2609.23629v1), plus three published results. That condition is
disclosed by the author in the abstract, in the axiom file's header,
and in the generated audit table, and this audit verifies the
disclosure is accurate. The verdict is therefore PASS for the Lean
artifact as pinned, with the headline graded conditional, not
unconditional: the equality case stands or falls with Fourier
Proposition 5.2, which no referee has yet checked.

**Claim artifact:** Dave Goel, *The Hibi–Li (2016) conjecture is
fully resolved*, arXiv:2610.40703. v1 submitted 2026-10-28 (15
pages); **v2, 2026-11-02 (17 pages, 3 figures) is current** and is
the version pinned here. ID, title, author verified on the abs page
2026-11-05. Claim: for every finite poset P, the order polytope
O(P) has at most as many k-faces as the chain polytope C(P) for
every k, and equality for some 2 ≤ k ≤ n−1 forces unimodular
equivalence; equality for k = 1 fails (counterexample poset X).
**Harvest item:** `hibi-li-conjecture-lean` (weekly harvest
2026-11-02, recon Card 3, fragility 3: `single_author`,
`formal_subset_of_claim`).
**Campaign objects:** `incoming/hibi-li-conjecture-lean/` (paper
v2 PDF, v2 e-print tarball, `lean-v4.60/` full project tree,
`PIN.md`).

**Canonical artifact (recon adjudication, full detail in
`PIN.md`):** `david44hello/papers_supporting_materials`, tag
`hibi-li-2016-conjecture-v4.60` @
`a936b943f1ad442f46ac4e38c3e3dd11d0f33c55`, folder
`hibi-li-2016-conjecture/lean/` — a complete lake project (162
`.lean` files, toolchain `leanprover/lean4:v4.35.0`, Mathlib
`v4.35.0`, manifest rev
`56a005855ea17e0b0958f73ec801ae140b0a1679`), tree aggregate sha256
`45014f2cd959ff469306ffad3cab3a557c5fda92b9826f25473f12932fe61e87`.
Two harvest candidates dissolve on inspection: the
`davegoel/LeanProofs` single-file blob does not exist (user and repo
both 404), and Zenodo 23601975 is the concept DOI of the longer
"miscellanea" paper version whose files are a PDF plus Python
certificate programs — no Lean. The arXiv comments field names tags,
not a branch; repo `main` is a moving multi-paper tree and is not
canonical.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
skills `lean-proof-forge`, `computational-claim-gate` (recon) ·
run dates `2026-11-05`. The forge workflow
(`.github/workflows/hibi-li-forge.yml`) was written by the main
agent, adversarially reviewed, and passed the pre-dispatch gate
(K13/K14 lint of the file and the full 15-workflow corpus, FM4
import closure on the pinned tree) before dispatch. No script was
drafted by an outside model for this audit; the verification
workflow is the author's own `check.sh`/`audit.py` route plus an
independent `#print axioms` check written by the main agent.

## M1 — Statement fidelity: PASS (headline level, checked line by line)

The four headline declarations in
`HibiLi/Paper/Statements.lean` were read against the paper text
(`hibi_li_short_v4.70.tex`, the arXiv v2 text):

- `conj_1_1_resolved` (#175) states, in Hibi–Li's own published
  conventions (`orderPolytopeHL`, `chainPolytopeHL`,
  `UnimodEquivHL`): (a) f_i ≤ f'_i for 1 ≤ i ≤ n−1; (b) equality
  for 2 ≤ i ≤ n−1 forces unimodular equivalence; (c) the k = 1
  case fails, witnessed by X (`fNum ... 1` equal on X, X not
  unimodularly equivalent). This is the *resolved* form of
  Conjecture 1.1 (paper lines 77–87 state (b) for 1 ≤ i ≤ d−1;
  Theorem 1.2 then shows (b) is false at i = 1 and true for
  2 ≤ i ≤ n−1). The Lean statement encodes the resolution, not
  the naive conjecture. Correct.
- `thm_1_2` (#173, Theorem 1.2, paper lines 136–145): (a)
  inequality for every k; (b) iff for 2 ≤ k ≤ n−1; (c) f_1 equal
  [HLSS] with non-equivalence for any poset containing X. Matches
  conjunct for conjunct, plus a fifth conjunct (every Q containing
  X) that the paper's proof establishes.
- `thm_4_1` (#135, Theorem 4.1): `(gapPoly n).coeff k ≤ fNum
  (chainPolytope P) k − fNum (orderPolytope P) k` under `ContainsX
  P`, with `gapPoly n = X^2 * (1 + X)^(n − 3)` (`Defs/PaperDefs.lean`
  line 13) — exactly the paper's `t^2(1+t)^{n−3}` coefficientwise
  bound. `thm_4_1_binom` is the binomial-coefficient reading
  (`choose (n−3) (k−2)`), matching the paper's coefficient
  argument at Corollary 5.3.
- `cor_5_3` (#172, Corollary 5.3): `(f_k equal ↔ ¬ ContainsX P)
  ∧ (¬ ContainsX P ↔ UnimodEquiv ...)` — exactly the paper's
  three-way equivalence (i) ⇔ (ii) ⇔ (iii).

Caveat (line drift, not a mismatch): the paper text pinned here is
the author's internal v4.70, while the Lean and `AUDIT.md` key
their claim rows to v4.60 line numbers. Spot-checked drift is about
six lines (Theorem 4.1 sits at line 519 in v4.70 against 525–527 in
the AUDIT row; Corollary 5.3 at 804 against 810–815). The statements
themselves match; the line numbers in `AUDIT.md` refer to the
v4.60 text, not the submitted v4.70. Anyone re-checking M1 against
the arXiv v2 tex must allow for that shift.

## M2 — Argument (build reproduction): PASS

Two forge runs on the self-hosted desktop runner
(DESKTOP-7HDI2D1), both at the pinned workflow commit, both with
the target HEAD verified fail-closed before building:

- Run #1,
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42107077615
  (main@e8f0ef8, 20:55–21:19 UTC, 24m53s): build green (9,209
  jobs), `audit.py` regenerated `AUDIT.md` byte-identical to the
  pinned table, source scan clean. The run's overall conclusion was
  failure, caused by a bug in *this audit's* verification workflow:
  the independent check imported the root `HibiLi` module, which
  does not bring `HibiLi.Paper.Statements` into scope, so all eight
  `#print axioms` errored "Unknown constant". The target was never
  at fault. Fixed in the workflow (import
  `HibiLi.Paper.Statements`, plus a name-existence guard before
  running Lean), landed main@28ea21a, gate PASS.
- Run #2,
  https://github.com/chokmah-me/fragile-proof-audit/actions/runs/42114638844
  (main@28ea21a, 21:48–22:11 UTC, ~23m): **conclusion success,
  every step green.** Evidence artifact `hibi-li-forge-evidence`
  (id 13458285062, 34,135 bytes, sha256
  `162c95b136617cac6966b5600bc1cb28c89fbf32ff21b8661d1147784b580141`,
  downloaded and verified locally): `verdict.txt` reads `PASS`;
  `audit-py.log` reads "AUDIT: 177 claims. PROVED: 158,
  PROVED-FROM-CITED: 19."; the regenerated `AUDIT.md` is
  byte-identical to the pinned one; `TARGET_HEAD` is the pinned
  `a936b94`; Lean 4.35.0.

The independent `#print axioms` check (eight headline
declarations, read from `axioms.txt` in the artifact) returned
exactly the cited sets the `AUDIT.md` rows declare, each on top of
the standard three (`propext`, `Classical.choice`, `Quot.sound`):

- `prop_3_4`, `prop_3_7`, `fourier_thm_1_1`: + `fourier_prop_5_2`
- `thm_4_1`, `thm_4_1_binom`: + `fourier_prop_5_2`,
  `ziegler_face_figure`
- `cor_5_3`: + `fourier_prop_5_2`, `hibiLi_thm_2_1`,
  `ziegler_face_figure`
- `thm_1_2`: + all four cited axioms
- `conj_1_1_resolved` (headline): + `fourier_prop_5_2`,
  `hibiLi_thm_2_1`, `ziegler_face_figure`

No `sorryAx` anywhere in the artifact. The source scan (mirror of
the author's `check.sh` scanner) found zero `sorry` / `admit` /
`native_decide` / `implemented_by` / `unsafe` in the tree, and
`axiom` appears only under `HibiLi/Cited/`. The full 177-claim
table contains no PROVED-FROM-TEMP, OPEN, or VIOLATION rows
(158 + 19 = 177 exactly).

## M3 — Credit honesty: PASS, with the condition named

The author's disclosure is accurate and unusually complete. The
paper abstract says the equality case uses two results from
Fourier's preprint; the Lean tells the sharper story, and the
author tells it in three places (abstract, `Cited/Fourier.lean`
header, generated `AUDIT.md` Trust note): at v2.10 (arXiv v1) both
Fourier Lemma 4.1 and Proposition 5.2 were axioms (167 claims,
142 PROVED / 25 PROVED-FROM-CITED); by v4.60 the author had proved
Lemma 4.1 (`Proofs/Fourier41.lean`) and the CJK dual-graph lemma
(`Polytope/CJKProof.lean`), narrowing the unrefereed dependency to
the single Proposition 5.2. The harvest's "two results of a Fourier
preprint as axioms" was the v1 picture and is now imprecise; the
current picture is one axiom. `fourier_prop_5_2` appears in 12 of
the 177 AUDIT rows, including every headline row that matters
(Proposition 3.4, Proposition 3.7, Fourier Theorem 1.1, Lemma 4.2,
Theorem 4.1, Corollary 5.3, Theorem 1.2, the headline). No hidden
axiom was found: the four declared axioms are the complete set,
verified by two independent `#print axioms` passes (the author's
`audit.py` over all 177 claims, and this audit's eight headline
declarations).

## M4 — Fine-print assumption inventory

Load-bearing assumptions, all verified present in the pinned
source and in the reproduced axiom sets:

1. **`fourier_prop_5_2`** — G. Fourier, "The Hibi-Li
   face-number conjecture", arXiv:2609.23629**v1** (2026-09-20),
   Proposition 5.2 (relative transversality of the subdivisions S
   and T). **Unrefereed preprint.** The file header states it
   plainly: "The preprint is not yet refereed. Proposition 5.2 is
   taken as an AXIOM ... every claim whose AUDIT.md row lists it
   is conditional on it (in particular Theorem 4.1, Corollary 5.3
   and the headline)." This is the single load-bearing external
   input to the equality case. The Fourier v1-vs-v2 question
   was resolved the same day (follow-up section at the end of
   this note): the statement is unchanged in v2.
2. **`hibiLi_thm_2_1`** — Hibi–Li 2016, Theorem 2.1 (published,
   Math. Scand. 118 (2016)). Used for the unimodular-equivalence
   criterion (Theorem 2.2) and the k = 1 edge.
3. **`hlss_thm_2_1`** — Hibi–Li–Sahara–Shikama 2017, Theorem 2.1
   (published, Discrete Math. 340). Used only for the k = 1 edge
   counts (audit.py prints the HLSS users: `sec1_edges_agree`,
   `sec1_partb_false_k1`, `thm_1_2` — exactly the paper's stated
   use).
4. **`ziegler_face_figure`** — Ziegler, *Lectures on Polytopes*,
   Ch. 2 face figures (published book). The file candidly notes
   the "Proposition 2.4" numbering was not checked against the
   book. Minor provenance softness, no effect on the verdict.
5. Standard Lean axioms `propext`, `Classical.choice`,
   `Quot.sound` — present on every listing, as expected.

Not assumptions: Fourier Lemma 4.1 (proved), Fourier Theorem 1.1
and Proposition 6.1 (derived), CJK Lemma 2 (proved since v2.10).
No `HibiLi.Cited.Temp` placeholder namespace is used anywhere.

Minor artifact gaps (recorded, not verdict-changing):
- `scripts/audit.py` contains a comment referencing
  `scripts/kernel_replay.sh` ("makes the source newer than its
  olean, and scripts/kernel_replay.sh then refuses the run as
  stale"), but no such script ships in the v4.60 tree. The
  author's own tooling references a replay script that is not in
  the pinned artifact.
- The v4.60/v4.70 line drift noted under M1.

## Honest scope

This audit verifies the Lean artifact at the pinned tag and the
accuracy of its axiom disclosure. It does **not** verify Fourier
Proposition 5.2 itself (the unrefereed preprint's mathematics),
the paper's prose proofs, or the Python certificate programs in
the Zenodo miscellanea version (a different, longer paper). The
headline "fully resolved" is true in Lean modulo the one axiom;
whether it is true unconditionally is a question for Fourier's
preprint, not for this formalization.

## Results

- `results/hibi_li_forge_run1_evidence.zip` — run #1 artifact
  (35,780 bytes, sha256
  `d0cee135d657b44e3caf1d0397b1e0fe21b9cd295a426ef4b83332cdf637b453`,
  measured locally from the downloaded file),
  verdict FAIL on the harness import bug.
- `results/hibi_li_forge_run2_evidence.zip` — run #2 artifact
  (34,135 bytes, sha256
  `162c95b136617cac6966b5600bc1cb28c89fbf32ff21b8661d1147784b580141`),
  verdict PASS.
- `results/hibi_li_verdict.txt` — `PASS` (from run #2).
- `results/hibi_li_axioms.txt` — the eight headline `#print
  axioms` listings from run #2.
- `results/hibi_li_audit_regenerated.md` — the regenerated
  `AUDIT.md`, byte-identical to the pinned one.

## Follow-up (2026-11-05, same day): Fourier Prop 5.2, v1 vs v2

The open question in M4 item 1 is resolved. Both versions of
Fourier's preprint were pinned (`incoming/hibi-li-conjecture-lean/fourier/`:
v1 e-print tarball sha256
`239087f165ced37738ae8a7c8ee2b56aa4944717e45252855a598b235ae9d62a`,
v2 `51ffa26e62dc841d7579f55cb388cab0936dc090006deceeea2c3b951610d74e`)
and compared at the source level:

- **Numbering.** Theorem-like environments share one per-section
  counter in both versions. Section 5 runs Lemma 5.1 (clipping)
  then the relative-transversality proposition, so it is
  **Proposition 5.2 in v1 and in v2 alike**; section 5's structure
  is unchanged.
- **Statement.** Byte-identical in v1 and v2, and equal to the
  verbatim quote in `Cited/Fourier.lean`: "The subdivisions S and
  T determined by L and U are transverse relative to every face of
  B." The definition of relative transversality is likewise
  identical up to trailing whitespace.
- **Proof.** Same two-step proof in both; v2 tightens a few
  sentences editorially (normalized length 3,822 vs 3,734
  characters; the step-2 conormal-space passage is reworded, no
  step added or removed).
- **What v2 adds** is elsewhere: two new sections (~370 lines),
  a local comparison on the five-element star (§7) and marked
  monotonicity with strict inequalities (§8), including a theorem
  in §8.2 ("The equality case of the Hibi–Li conjecture") proving
  the equality statement for marked polytopes by a route that does
  not go through Proposition 5.2. That is the independent proof
  Goel's abstract refers to.

Effect on the verdict: none. Goel's Lean still takes Prop 5.2 as
an axiom and the axiom's statement is stable across the only two
versions of the preprint; the condition is now on the *current*
text of the preprint, not a superseded one. The proposition
remains unrefereed prose mathematics either way, and Fourier v2's
independent equality-case proof does not discharge Goel's axiom,
since Goel's formalization does not use it.
