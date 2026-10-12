# Audit note — shuffle squares in smooth binary words (arXiv:2610.02262, 2026-10-12)

**Claim artifact:** Kory Kilpatrick, *Shuffle squares in smooth binary
words and the Kolakoski sequence* (arXiv:2610.02262, announced
2026-10-01). Theorem: every smooth binary tangram (both letters even
multiplicity) of length ≥ 18 is a shuffle square. Corollary: there are
**exactly 34** smooth tangrams that are not shuffle squares, all of
length ≤ 16. A finite FIFO certificate covers all positive smooth
tangrams at lengths 18, 20, …, 40. The paper discloses that GPT-5.6 Sol
and GPT-6-Astra "performed the mathematical research and proof
development, wrote and executed the computational code, and drafted and
revised the manuscript" under the author's supervision — the fragility-4
signal that motivated this audit.
**Harvest item:** `shuffle-squares-smooth-binary-words` (weekly scan
2026-10-12, issue #5, recon rank 1, fragility 4, top signal
`ai_generated`).
**Campaign objects:** `incoming/shuffle-squares-smooth-binary-words/`
(pinned e-print tarball, `paper.tex`, all five ancillary files,
`PIN.md`).

**Repo pin:** single pinned download `arXiv-2610.02262-eprint.tar.gz`
`07d3712334bd4daeed63133a01e0a011866807b56df719070211069735c1222e`
(retrieved 2026-10-12 from `https://arxiv.org/e-print/2610.02262`; the
tarball ships the ancillary `anc/` directory). Certificate
`smooth-even-base-certificate.json`
`d04eb188c2529a67ac5ee7161fe83940fe316b3ac54f7d42fbdd59be7936b42f`
(matches the hash printed in the paper §5, the README, and the author's
`SHA256SUMS`, whose four entries all verify). No listed file missing;
nothing invented. Full pin table in `PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`computational-claim-gate` · run date `2026-10-12`.

(M1/M2/M3 statement-fidelity checklist: N/A in one line — this is a
computational-replay gate, not a Lean formalization; the gated claim is
Corollary 1.2 + Proposition 2.1 exactly as stated in the paper.)

## What was run

| Check | Result |
|---|---|
| Author's declared verifier, run exactly as shipped (black box; author's instrument, not the verdict) | **exit 0, status PASS** — `smooth_words_regenerated 16146`, `smooth_tangrams_covered 4204`, `positive_controls_replayed 4170`, `exceptions_directly_exhausted 34` |
| Independent ceremony gate, claim 1: exception count — naive full enumeration of all 2ⁿ words (even n ≤ 16) from the paper's definitions of smooth / tangram / shuffle square; exact support-partition decision; exception set compared element-for-element with the author's 34-word table; per-length counts vs Table 1 | **PASS** — my count 34, sets match exactly; all 8 per-length (smooth, tangram, negative) triples match Table 1 |
| Independent ceremony gate, claim 2: lengths 18–40 certificate — bottom-up regeneration of all 16146 smooth words by induction on the finite derivative (structurally independent of the naive enumerator; cross-checked equal for n ≤ 16); exact coverage of the 4170 FIFO controls (no missing, no invented); every control replayed empty-to-empty | **PASS** — 16146 / 4204 regenerated; 4170/4170 controls valid and exactly covering the positive smooth tangrams |
| Discrimination control: same instrument, one definition flipped (odd Parikh instead of even) | **PASS** — 222 ≠ 34; the instrument is not tautological |
| `verify_claim_project.py` over both ceremony claims | **exit 0**, `status: "pass"`, both claims `ok: true` |

The two independent implementations (naive enumeration; bottom-up
derivative induction) agree on all smooth sets for n ≤ 16 and jointly
reproduce the author's full Table 1. The author's own 34-word table
(`smooth-even-exceptions.md` "By length" list) is byte-consistent with
the exception list inside the certificate JSON.

## Honest scope

- The infinite part of the proof (parity-return atom induction,
  Lemma 2.3's ten-atom classification) is prose mathematics and was
  **not** checked — this gate covers the computational claims only:
  the exact 34-exception count and the 18–40 finite certificate.
- The Kolakoski-prefix corollaries were not independently replayed.
- Shuffle-square status at lengths 18–40 is established via the
  certificate's FIFO controls (Lemma 1.4), replayed independently —
  not by exponential partition search (infeasible at n = 40).
- Counting convention: the empty word is smooth, a tangram, and a
  shuffle square by the paper's definitions, but the author's
  regeneration counts start at length 1; totals above are on nonempty
  words to match.
- Stdlib-only Python, no randomness, no seeds, no network after intake.

## Receipt

- `incoming/shuffle-squares-smooth-binary-words/PIN.md`
  (`2116f595b4f0e22ddae9c19c05ad88ecce8b1eaa9872119399eee83d1f7809de`)
- `results/shuffle_squares_verify_meta.json`
  (`c91550be62978be1b6336b6f26f4a639a5c7b3bac12fbeb766fba8ce232a9369`)
- `results/shuffle_squares_verify_out.txt`
  (`51d5e4bb7c887e2a5d5fee6e4339bab57019ace115b63f70495933fb0ba13e6f`)
- `results/shuffle_squares_verify_brief.md`
  (`83ebb30d8e149b67de899139b4979c657bc3b5f72fad92790e89c16899fb0108`)
- `results/shuffle_squares_control_receipt.md`
  (`a24081ab24e752e1cbb1aa30ae844b9ba556913c628be891d8043a9d83a05e96`)
- Gate scripts: `scripts/gates/shuffle_squares_independent.py`
  (`c1db5658…`), `scripts/gates/shuffle_squares_certificate_check.py`
  (`7af78aa2…`), `scripts/gates/shuffle_squares_control.py`
  (`09048499…`)
- Author's verifier output (exit 0): `/tmp/shuff/author_verifier_out.txt`
  (ephemeral; counters quoted in the table above)

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone verify/audit of a
harvest claim. Standing on the evidence: every checkable computational
claim confirmed — the "exactly 34" count reproduces element-for-element
from the paper's definitions alone, and the full 18–40 certificate
replays clean. No discrepancy found; no GAPs in intake. The AI-generation
fragility signal does not materialize in the finite computational core.
