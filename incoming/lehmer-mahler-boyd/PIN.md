# PIN: Generalized Boyd construction / Lehmer high-degree barrier (arXiv:2610.30277)

Pinned 2026-10-28 (auditor's copies in ~/workspace/lehmer-recon/).

- paper.pdf: sha256 7167d3ffff7307dfdc6154f95f4e5e2a3438df1567e8f20c9381f85a21af91e4
- source.tar.gz (paper source + ancillary): sha256 2ff3857348ea4a2c7b12bbd3c4231640c6fa37e8bba774e30a89d5f9f39b4128
- Artifact under audit: src/anc/mahler_dataset_d10_2000.csv (2,337,908 bytes, 996 data rows),
  the arXiv ancillary dataset. No search/verifier code is public (per the 2026-10-26
  harvest recon); the audit is a dataset replay, as the harvest card scoped it.

## Claims under audit (from the paper)
- For every even d in [10, 2000] the dataset gives an irreducible integer polynomial
  with Mahler measure strictly below alpha_1 = M(F(X,Y)) = 1.255433866266608745189...,
  F(X,Y) = X(X+1)Y^2 + (X^2+X+1)Y + (X+1).
- Generalized Boyd family (five parameters (a,b,k,s_0,s_1), k = 0 and a <= b claimed
  across all records) holds 991 of the 995 degrees in [12, 2000] (99.6%, incl. all
  d >= 166); the remaining five optima are at d in {10, 12, 16, 32, 164}.
- For the 991 GB rows: P_d^*(x) = Q_{a,b,k,s_0,s_1}(x) / Phi(x) exactly, with
  Q = x^{a+k}(x^a+s_0)x^{2b} + s_1(x^{2a}+s_0 x^a+1)x^b + s_0(x^a+s_0),
  Phi the product of the cyclotomic factors of Q, deg Phi = delta = 2a+2b+k-d (<= 14
  per the appendix bound), and M(P) = M(Q) since M(Phi) = 1.
- In the literature-covered range the dataset matches 85 known optima and strictly
  improves 6 published values at d in {178, 188, 190, 202, 242, 250}.
- Max measure in the dataset: M = 1.255358262 at d = 1932 (margin 7.56e-5 below alpha_1).
- Authors' verification protocol (Sec. 3): deflate P(x^k) compositions, Mathematica
  IrreduciblePolynomialQ, numpy.roots Mahler measure. The search pipeline itself is
  not public and is out of scope; minimality ("best known") rests on the authors'
  leaderboard plus the published tables and is fenced accordingly.
