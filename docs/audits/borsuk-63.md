# Audit note — Borsuk dimension 63 (Grinsztajn 2026)

**Date:** 2026-09-20  
**Artifact:** GitHub `maaxgrin/borsuk-63-counterexample`  
**Commit:** `cdcdbeac2e692b8641218c70ce9f414522e125e5`  
**Script sha256:** `c3144ffeb009c634eeaf2f0eb45c70ef4eeeb779f55e2d8ffd4446b0ba4d9673`  
**PDF sha256:** `d6c39e45399362e080aee3ea6a99e82152f7e0f8c6963cc9a815ef8337527734`  
**Instrument:** `scripts/gates/borsuk63.py` → `results/borsuk63_gate_meta.json`  
**Registered in `check.py`:** no

## Verdict (route, not theorem)

Borsuk’s conjecture is already known false in high dimension. This pin
replays the 2026 **dimension-63** certificate. A PASS of the instrument
means the author’s finite reconstruction of \(G_2(4)\) checks out as
printed; it is not a campaign kill of a live proof.

## What was run

`python incoming/borsuk-63/verify_borsuk63.py` (stdlib only). Observed:

- 273 projective points; 65 isotropic / 208 nonisotropic; 416 vertices
- degrees 100; 20800 edges; \(\lambda=36\), \(\mu=20\)
- \(|B|=96\), \(|C|=320\); \(B_i\) sizes \(32,32,32\)
- K5 witness `[0, 122, 126, 130, 134]`; `has K6 full False`; `has K5 on NbC False`
- terminal line: `all exact verification checks passed`

No 321×63 coordinate dump is in the repo. DIMACS certificates live under
`certificates/` (graph on 416 vertices of \(G_2(4)\), not Euclidean
coordinates). The Gemini MD’s numpy clique gate was **not** implemented.

Sage verifier was **not** run (campaign stack excludes Sage).

## Discrimination (deferred)

Not executed this pass. A later control would replay the same checks on
Jenrich–Brouwer dimension-64 data and confirm they do not claim 63.

## Do not claim

- That this campaign discovered the counterexample.
- That Lean formalized the 321-point embedding.
- That Borsuk fails in every dimension \(\ge 63\) beyond what the author
  proves (the script checks this construction).
