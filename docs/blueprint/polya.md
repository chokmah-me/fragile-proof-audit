# Pólya's counterexample (1919→1958) — certificate canonization, not refutation

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` §4.4, harvest rank 9.
Ranking table: L(906150257) = +1 | F=6, Fr=7*, R=8 | est. effort 4–8 wk.
Verdict in report: **Canonize the certificate.**

Pólya's conjecture — L(n) = Σ_{k≤n} λ(k) ≤ 0 for all n ≥ 2, which would have
implied RH and the simplicity of all zeta zeros — was killed by Haselgrove
(1958, non-constructive), with the first explicit counterexample by Lehman
(1960, n = 906,180,359) and the smallest by Tanaka (1980, n = 906,150,257).
This directory canonizes Tanaka's smallest counterexample as a pinned,
independently re-verifiable artifact: a clean-room segmented λ-sieve
(`src/liouville_sieve.c`) recomputes L(n) over [2, 906150257] and emits chunk
certificates (`certs/`, SHA-256-pinned in `manifest.json`) proving
(a) L(n) ≤ 0 for 2 ≤ n < 906150257 and (b) L(906150257) = +1.
`src/verify_certs.py` checks (a) and (b) from the certs alone.

**Status (v1 kickoff, 2026-09-22/23):** sieve + chunk certs + manifest +
independent verifier landed and validated against published anchors
(L(10⁹) = −25216; first crossing 906150257; max 829 at 906316571).
Deferred: second independent implementation (fresh eyes, genuine
independence), full write-up, Lean checked-sieve slice (stretch goal).
This is a confirmation artifact in the Gomila mold — **not a BREAK**; the
23/23 verdict lock is untouched.
