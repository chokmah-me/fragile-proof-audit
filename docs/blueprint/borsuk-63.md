# Blueprint — Track C: Borsuk dimension 63 (Grinsztajn 2026)

**Status:** pinned incoming artifact; **not** on the verdict lock  
**Genre:** Type F certificate of a known (2026) counterexample  
**Gate (instrument):** `scripts/gates/borsuk63.py` — wraps the author’s
`verify_borsuk63.py`; never registered in `check.py`  
**Source:** GitHub `maaxgrin/borsuk-63-counterexample`  
**Pin:** clone `cdcdbeac2e692b8641218c70ce9f414522e125e5`;
`verify_borsuk63.py` sha256
`c3144ffeb009c634eeaf2f0eb45c70ef4eeeb779f55e2d8ffd4446b0ba4d9673`;
proof-note PDF sha256
`d6c39e45399362e080aee3ea6a99e82152f7e0f8c6963cc9a815ef8337527734`

## Claim

Borsuk (1933): every bounded set in \(\mathbb{R}^n\) with at least two points
partitions into \(n+1\) subsets of strictly smaller diameter. False in high
dimension (Kahn–Kalai 1993). Previous smallest published failure: dimension 64
(Jenrich–Brouwer, from Bondarenko’s \(G_2(4)\)). Grinsztajn 2026: dimension 63,
321-point three-distance set, every smaller-diameter subset has size at most 5,
so at least 65 parts.

Duplicate arXiv:2608.12561 is **withdrawn**. Construction assisted by GPT-5.5 Pro.

## Load-bearing checks (author script, not the Gemini MD)

The MD’s “321×63 numpy distance matrix + 4.2 s clique” is **not** the published
verifier. `verify_borsuk63.py` reconstructs \(G_2(4)\) from \(\mathrm{PG}(2,16)\)
over \(\mathbb{F}_{16}\) and checks:

- strongly regular parameters \((416,100,36,20)\);
- partition \(V=B\sqcup C\), \(|B|=96\), \(|C|=320\);
- three 32-vertex components \(B_1,B_2,B_3\) of the induced graph on \(B\);
- degree data used for the dimension drop;
- clique obstructions (K5 witness; no K6; no K5 on \(N(b)\cap C\)).

Stdlib only (integer arithmetic and bitsets). Sage is optional and **not** used.

## Discrimination (not in this pass)

A later control would run the same checks on Bondarenko/Jenrich dimension-64
data and confirm they do not claim dimension 63. Not required to pin the
artifact.

## Non-goals

- Do not invent coordinates.
- Do not add Sage/numpy.
- Do not promote into `EXPECTED_VERDICT`.
