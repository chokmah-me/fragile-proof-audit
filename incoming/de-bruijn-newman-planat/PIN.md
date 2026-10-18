# Input pin — de Bruijn–Newman constant, classical-strip comparison (arXiv:2610.18214)

Pinned 2026-10-18 for the October 16 harvest (issue #6, card 4,
fragility 1, signals `single_author`). Queue position set by the user
2026-10-16 ("once and only when this is finished do the de Bruijn",
after the class-number close-gaps) and confirmed 2026-10-18. Scope of
the pick: **M1–M4 statement-fidelity audit plus a replay of the
author's certificate lanes** — the verdict lock is not touched. There
is no Lean artifact in this target; the certificate is a Python
pipeline with exact-rational auditors, shipped as arXiv ancillary
files.

- Paper: Michel Planat, *A certified classical-strip comparison for
  the de Bruijn-Newman constant*, arXiv:2610.18214v1, math.NT
  (11M26, 30D15, 65G30), 19 pages, submitted 2026-10-13, CC-BY 4.0.
  No journal publication; no peer-review file exists (confirmed
  2026-10-17). Headline (thm:main): **conditional** on premises
  (A1)–(A3),
  Λ ≤ 148611789321711/10^15 = 0.148611789321711 < 0.148612.
  - PDF: `arXiv-2610.18214v1.pdf`
    `bd90329ebb99772f2e6449b382903ff87cc6677bb5f4582295bd58f92d3ab6a8`
  - E-print tarball: `arXiv-2610.18214-eprint.tar.gz`
    `4599b663fe3c0913b78c445834b93ff2721e33e819601185a43bb88dd226ed5b`
    (both retrieved 2026-10-17 from arxiv.org, ID verified at the
    abs page; working copies in `~/workspace/dbn-planat-sources/`,
    not committed).
- Certificate bundle (the author's SI, `anc/` in the e-print, 63
  files): `anc/certificate/` holds `verify.py` + `code/` (12 Python
  checkers), `inputs/` (directed 192/256-bit enclosures, source
  JSONs), `histories/` (comparison result/audit JSONs), `receipts/`
  (19 JSON receipts), `NUMERICAL_RESULT.json`, `README.md`, and
  `SHA256SUMS.json` (54 manifest entries). `anc/derivative_pilot/`
  is a separate pilot, not part of thm:main.
- Packaging note (found at replay, 2026-10-18): as shipped, 8
  manifest entries name `.json.gz` files that are absent; the same
  8 payloads ship decompressed as `.json`. Deterministic re-gzip
  (mtime 0, no stored filename) of the shipped payloads reproduces
  all 8 manifest SHA-256s and byte counts exactly, after which the
  manifest verifies 54/54. Content integrity intact; `verify.py`
  does not run out of the box until the repair is applied.
- Replay environment: this VM, Python 3.12.3, standard library only
  for both lanes run (`verify.py --receipt`, `verify.py
  --regenerate`). The native FLINT/Arb tail regeneration lane was
  not run (see the audit note's Receipt GAPs).
- Related, not part of the claim: the same author's companion
  paper arXiv:2609.37164 (endpoints Λ ≤ 0.149344833997286 and
  Λ < 0.157371218, a different route); the audit baseline is the
  user's Gomila Λ ≤ 0.1787854 PASS of 2026-09-23
  (`~/workspace/dbn-lambda-audit/`).
