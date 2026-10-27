# Audit note — Chen, Schur number S(6) >= 537 (arXiv:2610.31362)

**Claim artifact:** Chen, *A new lower bound for the sixth Schur
number: S(6) >= 537* (arXiv:2610.31362), and its code,
github.com/jeffchen006/Schur-Number-6 @
`92a9d5f1336a5a064b2bfe6597d967f59191e365`. Headline: an explicit
partition of {1,...,537} into six sum-free sets, the first
improvement on S(6) since Fredricksen–Sweet 536 (2000), plus 131
pairwise inequivalent partitions and derived bounds.
**Harvest item:** weekly harvest 2026-10-26
(`incoming/harvests/2026-10-26.md`, CLAIM schur-number-6-537);
picked at the user's tap 2026-10-26 for the laptop lane.
**Campaign objects:** `incoming/schur-number-6-537/PIN.md`.
**Pinned sources:** repo PDF sha256 `e432c918…c25cf`;
certificate.col `5f950ad8…58315`; solutions537.txt
`fcae1cd5…1b6`; data/S8_n5372.txt `d0abd71d…6d24` (full hashes in
the PIN). Evidence in `~/workspace/schur-recon/`
(`RECON-BRIEF.md`, `independent_verify.py`,
`evidence-run-40431910885/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-26` · harness pin via
`scripts/harness_pin.py`. A Grandmaster's Methods pass ran at
recon; a DEEPEN pre-verdict pass ran before the verdict was
finalized (off-by-one indexing, ordered-pair symmetry of the
mod-538 condition, canonical-key soundness, and the S8
standalone-vs-template scope question; all resolved on evidence
below).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T01:22:52Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (certificates at the pin, independent verifier): PASS.**
  Forge run 40431910885, details below. The main certificate, all
  131 partitions, and the S8 certificate verify under a verifier
  written from the paper's definitions, sharing no code with the
  authors' checker.
- **V-B (statement fidelity, M1): PASS.** The printed Theorem 1
  partition is the certificate, class by class; the derived-bound
  arithmetic is exact.
- **Scope note (not a GAP in the claim):** the family-internal
  structure assertions (frame g membership, the C* first class,
  palindrome defects, the F5 special case) are verified only by
  the authors' own check.py, not by our verifier. The SAT search
  is not replayed; no DRAT-style proof is published, and none is
  needed for a lower bound carried by an explicit certificate.

## Receipt

- Forge workflow `schur-forge` at this repo's main `5005da9`
  (dispatch gate PASS 2026-10-27T01:18:43Z chained to the push),
  lane [self-hosted, laptop] (dell-laptop), dispatched
  2026-10-26 21:19 EDT, completed success in 35 s
  (2026-10-27T01:19:43Z → 01:20:18Z), all 11 steps success.
  Run: https://github.com/chokmah-me/fragile-proof-audit/actions/runs/40431910885
- Run verdict file: `verdict=PASS`. Pin asserted in-run:
  head_sha = pin = tip = `92a9d5f1…e365`, clone on first attempt.
  Runner clock skew 1 s. Authors' SHA256SUMS 21/21 OK in-run.
- Evidence artifact `schur-forge-evidence`, downloaded
  2026-10-27T01:21Z, zip sha256
  `a8c1dcf3083e963579c0ac4d52d6539cb299f348a88c62423a1ccd64d14c1ef2`
  (matches the digest shown on the run page); the embedded
  verifier inside the artifact is byte-identical to the recon
  copy (sha256 in the PIN).
- Same results reproduced independently on this VM before the
  forge was written: authors' check.py exit 0 in 9.5 s; our
  verifier INDEPENDENT: PASS in 8.6 s; in-run times 8 s and 8 s.

## M1 — statement fidelity

- Paper definition (Introduction): C is sum-free if there are no
  x, y in C, *not necessarily distinct*, with x+y in C; S(k) is
  the largest n for which {1,...,n} partitions into k sum-free
  sets. Our verifier implements exactly this (results.json states
  the same: `equal_summands_allowed: true`). No weak-Schur
  substitution.
- Theorem 1 (S(6) >= 537) is proved by listing six sets in
  `paper/partition_blocks.tex`. Mechanical comparison: the six
  printed sets, sizes 76/76/88/70/76/151 (total 537), equal the
  certificate.col classes class by class after the authors'
  renumbering (colors in order of least elements). The indexing
  question (could certificate.col be 0-based?) is closed by this
  match: both 1 and 537 occur in the printed sets, and a one-off
  shift would break the equality.
- Vacuity anchors: the main certificate check examines all
  143,916 splits x + (z−x) (= 537·536/2); the S8 check all
  14,426,506 (= 5372·5371/2). Both counts are asserted in the
  forge verdict, so an empty or truncated parse cannot PASS.
- Derived bounds (paper's proof, arithmetic rechecked):
  S(8) >= 10·537+2 = 5372; S(11) >= 380·537+148 = 204,208;
  S(13) >= 10·204,208+2 = 2,042,082; R_6(3) >= 537+2 = 539. All
  exact. The S(8) bound also carries the explicit certificate
  below.
- Proposition (families): each F1–F4 partition agrees with the
  example in at least 462 of 537 positions, i.e. differs in at
  most 75; the authors' checker reports the maximum difference
  as exactly 75. Consistent.

## M2 — argument route

- The claim's load-bearing object is the explicit certificate,
  and it is checked three ways: the authors' check.py (class-set
  formulation), our verifier (z-first split formulation, own
  parsers for all three artifact formats), and the printed paper
  partition (M1). The three agree.
- Mod-538 sum-freeness: forbidden pattern c(x) = c(y) =
  c((x+y) mod 538) with (x+y) mod 538 ≠ 0 (the excluded case maps
  to 0, outside the domain). The authors quantify y >= x, ours
  all ordered pairs; the condition is symmetric, so the checks
  are equivalent. All 131 partitions pass, as does the main
  certificate.
- Inequivalence: canonical keys (image under each of the 268
  units mod 538, colors relabeled by least element, minimum over
  the orbit) are 131 distinct values, which proves pairwise
  inequivalence under unit multiplication followed by color
  renaming. This matches the proposition's statement, including
  that color renaming alone is not the equivalence claimed.
- S8 scope: our verifier checks data/S8_n5372.txt as a
  standalone artifact (a 5372-char string over 1..8, all colors
  used, zero monochromatic triples), which is what S(8) >= 5372
  needs. The width-10 template provenance (Bengone et al.,
  Table II) is the authors' construction claim; their checker
  additionally asserts the file equals the template output. We
  record the provenance as author-checked, the validity as
  independently checked.
- Decoder caveat: the historical gen.py decoder can lose forced
  frame colors (decoder_caveat.py reproduces a frame violation),
  so a raw SAT model need not decode to a valid coloring. The
  shipped certificates do not ride on the decoder; they are
  validated directly. The caveat is provenance for how the
  search was run, disclosed by the authors themselves, and does
  not touch the certificates' validity.

## M3 — credit honesty

- Previous bounds are tabled with sources in the paper: S(6) 536
  and R_6(3) 538 to Fredricksen–Sweet (R_6(3) also with a second
  citation), S(8) 5362 and S(13) 2,038,282 to Bengone et al.,
  S(11) 203,828 to Ageron et al.; S(5) = 160 is credited to
  Heule's determination. The abstract names Fredricksen and
  Sweet (2000) for the improved bound.
- The 131 partitions are described in the paper, the README, and
  results.json as a search collection, explicitly not an
  enumeration; no impossibility at 538 is claimed anywhere.
  Claim language stays at lower bounds throughout.
- The SAT solver behind the search (Kissat, per the harvest
  recon of the generator) is part of the search provenance; the
  paper's own framing is a found partition, not a solver result,
  so no solver-credit gap arises for the claim itself.

## M4 — fine-print assumption inventory

- Convention: S(k) as maximum feasible interval length with
  x = y allowed. Under the alternative convention (partition of
  [1, n−1], or distinct summands only) the same artifact would
  support a differently numbered claim; the paper states its
  convention in the Introduction and results.json, and the
  Fredricksen–Sweet comparator uses the same one.
- The mod-538 and frame structure are properties of this
  search's outputs, not hypotheses of Theorem 1; Theorem 1 needs
  only the one partition, as the paper itself notes.
- Family-internal structure (frame g, C*, palindrome defects,
  the F5 rotated case) rides on the authors' checker alone; see
  the scope note in Verdicts. Nothing in the headline bounds
  depends on it.
- Artifact freshness: the pinned commit was also the repo tip at
  recon and at dispatch, so no tip-vs-pin divergence arose; the
  forge asserts the pin regardless.

## Verdict

PASS
