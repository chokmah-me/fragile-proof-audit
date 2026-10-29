# PIN — Coleman integration over finite extensions of Q_p (arXiv:2610.33970)

Audit opened 2026-10-29 at the user's pick (harvest
2026-10-27, CLAIM coleman-integrals-local-fields-cai-keller,
fragility 0, ninth in the ranked queue, issue #12). Scope
set in advance at a PARTIAL ceiling (doability adjudication
2026-10-29): no Magma exists in the auditor's environment,
so the Coleman computation itself is fenced; the audit
covers the divisors' soundness, their classification at 19,
and the Appendix A sieve deduction from the committed
local data.

## Claim

Tianyi Cai and Timo Keller, *Explicit Coleman integration
over finite extensions of Q_p*. The paper extends the
Balakrishnan–Tuitman Coleman-integration algorithm to
arbitrary finite extensions of Q_p (ramification and
nontrivial residue degree) with explicit precision bounds,
with a public Magma implementation. Headline application:
a single-prime computation at p = 19 over the unramified
quadratic extension Q_19^2 recovers all 35 affine sporadic
quadratic divisors on C = X(s3,ns5) over F = Q(sqrt5)
(12 in split residue classes, 23 in Frobenius-conjugate
classes). Completeness of the list is proved in
Appendix A by symmetric Chabauty and a Mordell–Weil
sieve over nine split primes.

## Pins

- paper.pdf: sha256 92e50da2e055f8bf1e469b345e3fdc1645ef5a69f704e3daa7dd51b109a348e8
- arXiv source (ec-revised.tex): sha256 be8fe8691c9a563aeb596a922975e749c90a54da2a8531672c945037272c1ccd
- repo TimoKellerMath/ColemanIntegralsLocalFields @
  683e080bbb616f7904632343b3b355957ad55f6c (single squashed
  commit, MIT): tarball sha256
  9303ec563483fe1fe6e89c12e0dc40400ccebee35e51823b64dd72bb7e380718

Evidence in ~/workspace/coleman-recon/ (farith.py,
va_compare.py, vb_soundness.py, vb_sigma.py, vb_model.py,
vb_sieve.py, vb_jac.py and their logs).
