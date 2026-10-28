# Audit note — Wang's planar D-coloring conjecture (Verma, arXiv:2610.33322)

**Claim artifact:** Harshit Verma, *A proof of Wang's
planar D-coloring conjecture* (arXiv:2610.33322v1).
A D-coloring is a proper edge-coloring in which every
diamond (K4 minus an edge) is rainbow. Wang's
conjecture: 9 colors for Δ = 4, 10 for Δ = 5, 2Δ−1 for
Δ ≥ 6. Hu–Kong–Wang proved Δ ≤ 5 and Δ ≥ 33 (cited).
This paper's main theorem: for every D ≥ 6, every
finite simple planar graph with Δ(G) ≤ D has a
D-coloring with at most 2D−1 colors, by discharging;
the case D = 6 is computer-assisted, and the computer
input is confined to two lemmas: generic certificates
(72 full-link templates: 59 greedy removal orders +
13 graph-polynomial coefficients) and one-spine
certificates (1,220 bases: 971 greedy + 249 CN).
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM Wang planar
D-coloring, recon fragility 1, issue #12); picked at
the user's tap 2026-10-28.
**Campaign objects:** `incoming/wang-d-coloring/PIN.md`.
**Pinned sources:** paper PDF sha256
2dc544abdc1d72a5cc3739d07636a9f1dd67a4e083d7493cf01f86fd90017a46;
arXiv source tarball (paper + ancillary) sha256
430e947e8eaa9f1b0e67976d5b40bb17e4bf5126a9502ab682aea4a00d2d3cc6.
Evidence in `~/workspace/wang-recon/` (`EVIDENCE.md`,
`my_checks.py`, run logs).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-28` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: a direct read of what the
statement architecture actually does); the pre-verdict
deepening was a DEEPEN challenge pass (below), run after
independent re-verification of the evidence.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-28T08:21:13Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## M1 — statement fidelity (read, not assumed)

- Main theorem (thm:main) and its corollary match the
  abstract's claim exactly, including that the Δ ≤ 5
  and Δ ≥ 33 cases are Hu–Kong–Wang's, not this paper's.
- The computer-assisted scope is stated in the paper
  itself: Lemmas (generic) and (one-spine). The
  generic count decomposes as the paper says: 9 sorted
  degree triples from {4,5,6} × 8 tip words = 72. The
  one-spine count 1,220 is the paper's enumeration
  (per triple, tip word, and spine choice, 2^r bases);
  the audit verifies the stored set has exactly 1,220
  duplicate-free keys, and tmpl.py independently
  prints the same two totals.
- Certificate semantics are the paper's own lemmas:
  greedy removal order valid iff each v_i has fewer
  than f(v_i) neighbours among the later vertices
  (lem:greedy); CN certificate = a nonzero coefficient
  of X^t in the graph polynomial of the conflict
  graph, sum t_i = |E(H)| (lem:cn). Both criteria were
  read from the text before any code was run.

## M2 — argument (the computer leg, verified twice)

- V-A: the ancillary suite replayed on the pinned
  tree (Python 3.12.3, standard library only).
  check_records.py: exit 0, failures: 0, certificate
  counts {generic 59 greedy + 13 CN; one-spine 971
  greedy + 249 CN}. It rebuilds every template from
  the Section 7 definitions and compares U, the
  conflict graph and f against every record, so the
  stored fields are pinned to the definitions.
  atcoef.py self-test: 77,784 coefficients against
  naive expansion, exit 0. fourwheel_d6_example.py:
  all Section 8 assertions true, exit 0. tmpl.py:
  72 generic templates, 1,220 one-spine bases.
- V-B: the auditor's own checker, from the raw
  records only (no tmpl.py import): key accounting
  duplicate-free (72 / 1,220; splits exact); all
  1,030 greedy orders re-verified against the
  lem:greedy criterion from the stored fields; all
  262 CN coefficients recomputed by the auditor's own
  sparse polynomial multiplication and equal to the
  stored values, all nonzero, sum t_i = |E| (total
  468.9s; slowest record 21.4s); the Section 8 graph
  rebuilt from its construction rule (18 vertices,
  48 edges, degrees 4–6) and both stored colorings
  checked against the D-coloring definition directly
  (proper; every K4 and every diamond rainbow): the
  11-coloring of G − v and the 10-coloring of G pass.

## M3 — credit honesty

- The paper credits Wang (conjecture), Hu–Kong–Wang
  (the settled ranges), Alon and Alon–Tarsi (the
  coefficient method), and Hall (the list lemma) in
  place. The ancillary README states plainly which
  files are the generation package and which were
  written independently from the paper (the template
  reconstruction and the Alon–Tarsi count), which is
  the disclosure the audit's two-leg design relies on.
  No priority overclaim found.

## M4 — fine print

- The verdict covers the computer-assisted leg and
  the claim's statement fidelity. The human
  discharging proof, for D ≥ 7 and for the D = 6
  reductions around the two lemmas, is fenced, not
  graded (the same scoping as the analytic remainder
  in the Brualdi–Solheid audit). A failure there would
  not be visible to this audit, and the note does not
  pretend otherwise.
- CN sign convention: flipping a factor (X_i − X_j)
  negates the whole graph polynomial, so a convention
  mismatch could flip every coefficient's sign; the
  lemma needs only nonzeroness. In fact the auditor's
  values agree with the stored ones exactly under the
  stored pair order, on all 262 records.
- The auditor's multiplication is slow (worst record
  21.4s) where the author's frontier DP is fast; the
  difference is engineering, not evidence: three of
  the author's methods, the atcoef self-test against
  naive expansion, and the auditor's fourth method all
  agree on every coefficient.
- The Section 8 example is a sharpness exhibit (the
  four-wheel reduction fails at D = 6 while G itself
  is 10-D-colorable); it is checked, but it carries no
  load in the main theorem beyond its stated role.

## DEEPEN pre-verdict pass

Run against the assembled case; nothing moved. Attacks
killed on facts: records encoding the wrong templates
(V-A rebuilds every template from the definitions and
compares the stored fields, 0 failures; V-B verifies
the certificates on those same fields with independent
code, so the records are pinned from both sides);
criterion drift (both greedy implementations check the
lemma's inequality as written, in two equivalent
formulations); coefficient convention games (nonzero
is sign-invariant, and the values match exactly
anyway); duplicate or missing bases (key sets asserted
duplicate-free at the paper's own counts); self-test
circularity in atcoef (its 77,784-coefficient test is
against naive expansion, a fifth method, and the
auditor's multiplication is a sixth data point on the
262 load-bearing coefficients).

**Verdict: PASS** — scoped to the computer-assisted
leg: all 72 generic and 1,220 one-spine certificates
at D = 6 are valid under the paper's own criteria,
verified by the author's Appendix A.3 suite replayed
(failures: 0) and by the auditor's independent checker
from the raw records (all 1,030 greedy orders, all
262 CN coefficients, the Section 8 example). The
human discharging proof around them is fenced, not
graded.
