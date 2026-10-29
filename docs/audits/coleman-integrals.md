# Audit note — Coleman integration over finite extensions of Q_p (Cai–Keller, arXiv:2610.33970)

**Claim artifact:** Tianyi Cai and Timo Keller, *Explicit
Coleman integration over finite extensions of Q_p*
(arXiv:2610.33970). The paper extends the
Balakrishnan–Tuitman algorithm for Coleman integration to
arbitrary finite extensions K/Q_p, allowing ramification
and nontrivial residue degree, with explicit precision
bounds and a public Magma implementation (repository
TimoKellerMath/ColemanIntegralsLocalFields, single
squashed commit 683e080, MIT). Headline application: a
single-prime computation at p = 19 over the unramified
quadratic extension Q_19^2 recovers all 35 affine sporadic
quadratic divisors on C = X(s3,ns5) over F = Q(sqrt5),
12 in split residue classes and 23 in Frobenius-conjugate
classes; completeness of the list is proved in
Appendix A by symmetric Chabauty and a Mordell–Weil
sieve.
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
coleman-integrals-local-fields-cai-keller, recon
fragility 0, issue #12); picked at the user's tap
2026-10-29 as a scoped PARTIAL-ceiling audit (the
ceiling was set in advance: no Magma exists in the
auditor's environment, so the Coleman computation
itself is fenced — see the fence list).
**Campaign objects:** `incoming/coleman-integrals/PIN.md`.
**Pinned sources:** paper PDF sha256
92e50da2e055f8bf1e469b345e3fdc1645ef5a69f704e3daa7dd51b109a348e8;
arXiv source tarball sha256
be8fe8691c9a563aeb596a922975e749c90a54da2a8531672c945037272c1ccd;
repository tarball at the pinned commit sha256
9303ec563483fe1fe6e89c12e0dc40400ccebee35e51823b64dd72bb7e380718.
Evidence in `~/workspace/coleman-recon/` (`EVIDENCE.md`,
`farith.py`, `va_compare.py`, `vb_soundness.py`,
`vb_sigma.py`, `vb_model.py`, `vb_sieve.py`, `vb_jac.py`,
run logs, `ADJUDICATION.md`, `argon-deepen.md`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-29` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing); the pre-verdict deepening
was a DEEPEN challenge pass (Argon, below), run after the
first verification round and adjudicated point by point;
two of its hits produced the additional checks in
sections 4 and 5.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-29T12:32:29Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## 1. The audit object

C is the genus-3 curve X(s3,ns5) with the plane quartic
model of the paper's Eq. (quartic model) and of
`appendix-A-common.m`:

qaff(x,y) = y^4 − 2y^3x − y^2x^2 − 8y^3 − 2y^2x + 2yx^2
+ x^3 + 3y^2 + 3yx − 3x^2 − 2y + 3x − 1 over F = Q(s),
s^2 = 5.

The 35 divisors are Delta_i = P_i + P_i^{tau_i}, encoded
by the x-coordinate minimal polynomial mp_i in F[X]
(paper Table tab:sporadic-divisors; the list `mps` in
`appendix-A-common.m`) and by y = c0 + c1·x, the unique
root of qaff(alpha, Y) in F_i = F(alpha) for a root
alpha of mp_i. The involution sigma of the paper's
Proposition (Appendix A) is the projective map with
matrix MM = [[1,8,−8],[1,3,2],[−2,4,1]]; its quotient
is E = X(ns3,ns5), y^2 + y = x^3 + 1. The classification
statement is C^(2)(F) = K_2 ∪ phi^*(E(F)) with K_2 the
72 known divisors (36 sums Q_i + Q_j of the eight
F-rational points, D_infty, and the 35 Delta_i).

## 2. Consistency (V-A)

The repository's own Magma-free harness
`tests/check_logs.py` passes 69 ok / 0 failures on the
pinned tree. No committed log contains a Magma error
string. The 35 polynomials are identical as exact
elements of F[X] across four sources: the paper's
Table, the `mps` list in `appendix-A-common.m`
(index-by-index), the recovered set printed in
`example-8.4-single-prime.log`, and the numbered union
in `example-8.4-multiprime.log` (index-by-index).
`cspor_mp` in `appendix-A-common.m` equals mps[20]
(Delta_20 is the class c_spor of the sieve). The
single-prime log's own summary lines (35 of 35
recovered, no extras, 12 split / 23 conjugate) are the
claims tested in sections 3 and 4. A read of
`example-8.4-single-prime.m` confirms the published
list enters only in the final cross-check, after the
search: the recovery runs `quadratic_points_split`
over Coleman data built from the model, with vanishing
differentials computed from the points P1, P2, P3
(the first three F-rational points), and the search
statistics (35 genuine, 25 rational-pair, 307 spurious,
25 unrecognized, 44 rank-drop) are those of a sweep,
not of a lookup.

## 3. Soundness of the 35 divisors (PASS)

Exact arithmetic over F = Q(sqrt5) (auditor's own
`farith` implementation, cross-checked by an
independent sympy number-field computation):

- Every mp_i is a monic quadratic irreducible over F:
  its discriminant is a non-square in F (exact square
  test in Q(sqrt5)), for all 35. The set {mp_i} is
  stable under the conjugation s -> −s, and the 35
  polynomials are pairwise distinct. Irreducibility
  also excludes any Delta_i having an F-rational
  constituent point, so none of the 35 is a sum of
  two of the eight F-points or a double 2Q_i.
- The table's y is a point of C: substituting
  y = c0 + c1·x into qaff and reducing modulo mp_i
  over F gives the zero polynomial, for all 35.
- The table's y is the ONLY root of qaff(alpha, Y) in
  F(alpha): for w = u + v·alpha the system
  qaff(alpha, w) = 0 has exactly one solution
  (u, v) in F^2, namely (c0, c1) (lex Groebner basis
  over Q(sqrt5); the system has 16 solutions over the
  algebraic closure, the pairs of points over the two
  roots of mp_i, of which exactly one pair is
  F-rational). This is the paper's encoding claim,
  verbatim.
- The eight F-rational points Q_1..Q_8 of the
  Proposition satisfy the homogeneous model exactly.
  The line Z = 0 cuts out Y^2·(Y − (1+sqrt2)X)·
  (Y − (1−sqrt2)X), i.e. the divisor 2·(1:0:0) +
  D_infty with D_infty as stated; (1:0:0) = Q_4 is a
  smooth point of the model (the double factor is the
  tangency of the line Z = 0 there, not a singularity:
  the partial derivative dQ/dZ at (1:0:0) is 1).

## 4. Classification at 19 (PASS)

19 splits in F; the two places are s -> 9 and s -> 10
(mod 19). The example script takes its place as
`Decomposition(OF,19)[1]`, the first prime in Magma's
decomposition order, and tags a recovered divisor
split iff its discriminant is a unit at that place
and a square in the residue field (the script's own
criterion). The auditor recomputed the classification
from the divisors themselves, exactly mod 19: all
mp_i and all table coefficients c0, c1 are
19-integral at both places, every mp_i is monic (so
no degree drop and no constituent point at infinity
in the reduction), and for each divisor the reduced
points were computed and checked smooth on the model
mod 19. Result: at BOTH places the split is
12 split / 23 conjugate / 0 ramified; per divisor,
the place s -> 10 reproduces the log's printed tag
for all 35 divisors, while s -> 9 agrees on 19 of 35
(exactly the conjugates swap). The audit therefore
identifies the script's chosen place as s -> 10
(mod 19) in the pinned Magma version, and the log's
tags are the reduction types at that place. The
counts 12/23, which are what the paper claims, are
place-independent here. Separately, the quartic model
itself has good reduction at all nine sieve primes:
in each affine chart of P^2 the Jacobian system has
no solution over the algebraic closure of F_q
(Groebner basis over GF(q) is [1]), for
q in {19,29,31,41,59,61,71,79,89}.

## 5. Geometry tying the local data down (PASS)

Two checks bind the Appendix A local data to the
curve independently of Magma:

- The involution: qcoef o sigma = 625 · qcoef as
  polynomials (sigma preserves the model), sigma^2 =
  id, and sigma permutes the eight F-points exactly
  as (1 2)(3 4)(5 6)(7 8) — the pairing the
  Proposition states (sigma(Q_{2i−1}) = Q_{2i}). The
  four divisors the sieve loses, P1+P2, P3+P4,
  P5+P6, P7+P8, are therefore exactly the sigma-fibres
  phi^*(point), i.e. pullback divisors, which is why
  their loss is by construction and harmless: the
  sieve's task is only that nothing outside
  T_0 = K_2 ∪ phi^*(E(F)) survives it.
- Point counts: N_k = #C(F_{q^k}) for k = 1, 2, 3 was
  recomputed with python-flint (`vb_jac.py`) at the
  primes q in {19, 29, 31} (the count is a slow
  per-prime loop; the remaining six primes were still
  running when this note was filed, and the leg is a
  supporting binding, not a load-bearing one — the
  sieve replay of section 6 independently reproduces
  all nine |H_q| from the committed data). At each of
  the three completed primes N_1 and N_2 agree with
  the values recorded in the
  `appendix-A-localdata-<q>.log` files, the
  L-polynomial (Newton identities on N_1..N_3 plus the
  genus-3 functional equation) gives |J(F_q)| = L(1),
  and |H_q| divides L(1): q = 19: N = (22, 434, 6808),
  L(1) = 8400 = 5 x 1680; q = 29: N = (22, 912, 24094),
  L(1) = 19200 = 8 x 2400; q = 31: N = (42, 1090,
  29232), L(1) = 43680 = 14 x 3120. Hasse–Weil holds
  at all three primes, and #(A_q cap H_q^rob) never
  exceeds #C^(2)(F_q).

## 6. The sieve deduction from the committed local data (PASS)

`appendix-A-sieve.m` is pure finite-abelian-group
arithmetic over the nine `appendix-A-local-<q>.dat`
files: H_q = Z^3 / LocalRel_q with basis (t_10, z,
c_spor); A_q cap H_q^rob stored as tuples (doubled
class vector, type (a)/(b)/(c), tag, at-infinity,
pullback flag, description, class data); Y_q the
doubled non-pullback classes; W the CRT survivors in
Gamma/H, H = intersection of the kernels of
rho_q : Gamma -> H_q; step (vii) settles a class x
when some prime's fibre over x consists only of
type-(a) classes that are reductions of the 72 known
divisors. The auditor re-implemented the sieve from
scratch in Python (own Magma-literal parser, own HNF
group arithmetic), reading only the .dat files, and
reproduced EVERY number in `appendix-A-sieve.log`:

- per prime: |H_q| and its invariants, #(A_q cap
  H_q^rob), #pullback, #Y_q, ord(rho_q(c_spor)) —
  all nine rows exact;
- |J(C)(F)_tors| = 240 read off at q = 41 (the
  subgroup generated by the images of t_10 and z),
  matching the assertion in the sieve;
- sieve modulus M = 32760; 316 surviving (n, t)
  pairs; #W = 158 classes;
- #W_known = 58, #(W cap W_known) = 54; the 72 known
  divisors give 72 distinct residue classes at every
  prime; the lost set is exactly {P1+P2, P3+P4,
  P5+P6, P7+P8};
- the per-prime collision lists (diagonal reductions
  of known divisors that are not doubles 2Q_i) match
  exactly, with 8 doubles at every prime;
- step (vii): every fibre above a surviving class is
  of type (a) (158/158); settlement is 158/158 under
  the jet criterion with first witnesses
  {41: 138, 79: 20}, and 158/158 under the cited
  criterion read literally (multiplicities collected
  before reduction) with first witnesses
  {41: 130, 79: 28}; the full per-prime statistics
  table (settles / cited / max and mean fibre /
  unsettled / diagonal / colliding) matches to the
  printed digit, including mean fibre sizes;
- a single prime settles all of W at
  q in {79, 19, 29, 61} under the jet criterion and
  at q in {79, 19, 61} under the cited criterion.

So the deduction is verified in the following exact
sense: GIVEN the committed local data files, the
conclusion C^(2)(F) = T_0 follows by the stated
sieve, under both readings of the symmetric-Chabauty
criterion. The scope boundary is equally exact: the
replay takes the .dat files as its input. Their
generation — the enumeration of A_q over
C_q^(2)(F_q), the type (a)/(b)/(c) jet-rank
computations, H_q^rob, and the LocalKnown reduction
vectors, all computed by `appendix-A-localdata.m`
from the shared setup in `appendix-A-common.m` — is
a Magma computation and is fenced (section 7). The
basis (t_10, z, c_spor) and the base point D_0 are
common to all nine files by construction (one shared
setup file, one localdata script); a per-prime shift
of basis or base point is not a failure mode the
artifact's structure admits silently, but verifying
the reductions themselves is precisely the fenced
step. Within the replay, the data are heavily
over-determined: the nine H_q are independent
computations whose CRT intersection is nonempty in
exactly the pattern the geometry predicts (sections
5 and 6), and the LocalKnown vectors give 72 distinct
classes at every prime with the four sigma-fibres —
and no sporadic divisor — lost.

## 7. Fences (GAP by construction)

Not verified, and not verifiable in the auditor's
environment (no Magma license or binary; the
implementation is Magma-only and its logs are pinned
to V2.29-10):

- The Coleman integration itself: Example 8.4
  single-prime recovery over Q_19^2, the eight-prime
  sweep, and Examples 8.1–8.3; the package's
  Frobenius, cohomology and solver machinery; the
  precision bounds of Sections 6–7 as computations.
- The generation of the .dat local data
  (`appendix-A-localdata.m`): the enumeration of
  A_q, type (a)/(b)/(c) tags, H_q^rob, LocalKnown.
- The inputs from `appendix-A-generators.m` and
  `appendix-A-rank-E.m`: J(C)(F)_tors = [2, 120] of
  order 240, [J(C)(F) : Gamma] dividing 2,
  rk E(F) = 1. (The sieve is index-safe by design:
  the multiplier 2·iota_2 and H_q^rob make its
  conclusion independent of which of the two index
  values holds. The torsion order 240 is consistent
  with the replay's read-off at q = 41, section 6,
  and the rank of E enters only the pullback family's
  parametrization, not the sieve.)
- Siksek's symmetric Chabauty criterion (Box–
  Gajovic–Goodman, Thm 2.6) as mathematics: read for
  statement fidelity only. The artifact itself flags
  the one reading subtlety (jet criterion vs the
  cited criterion read literally, at colliding
  diagonal reductions) and settles W under both;
  the replay confirms both settlements.

## M1 — statement

The abstract's claims match the
artifact's contents: the extension to arbitrary
finite extensions with explicit precision bounds,
the single-prime recovery at 19 over Q_19^2, the
12/23 split, and completeness by Appendix A. The
paper states in the Example that 19 splits in F, so
the completion is F_v = Q_19 and the computation
runs over its unramified quadratic extension to
reach the Frobenius-conjugate classes; there is no
discrepancy between the headline phrasing and the
method.

## M2 — argument

The completeness argument is
the Appendix A proposition; its computational content
splits into the fenced local-data generation and the
verified sieve deduction, and the paper does not
present the search itself as part of the proof (the
sieve script states this explicitly).

## M3 — credit

The implementation is presented as an extension of
Balakrishnan–Tuitman's code, and the criterion is
cited to Siksek and to Box–Gajovic–Goodman; nothing
in the artifact overstates this.

## M4 — fine print

The load-bearing assumptions are (i) the correctness
of the Magma computations in the fence list,
(ii) the symmetric Chabauty criterion, and
(iii) the index-safety of the sieve, which the
artifact handles by construction rather than by
resolving [J(C)(F) : Gamma]. The single squashed
commit means the logs and .dat files carry no
generation history; provenance rests on the pinned
commit alone.

## 9. DEEPEN adjudication

The DEEPEN pass (Argon, contract-breaker brief)
returned five attacks; two were sustained in part
and produced new work, three were answered by
evidence already in hand or by the artifact's own
definitions:

- "(1:0:0) is a double point, so the model is
  singular and the smoothness claim is fabricated" —
  REJECTED. The double factor in the Z = 0 section
  is the tangency of the line Z = 0 at the smooth
  point (1:0:0) (dQ/dZ = 1 there); the model is a
  smooth plane quartic of genus 3, and the
  chart-by-chart Groebner check over GF(q) is
  correct as stated.
- "The classification test is not the log's
  classification" — REJECTED. The script defines
  the tag by the discriminant criterion at its
  chosen place (valuation 0 and residue-field
  square), which is the test the auditor ran; the
  ramified sub-case the attack constructs does not
  occur (0 of 35). The place-identification point
  is sustained as a reporting matter and is handled
  in section 4.
- "The sieve replay verifies only arithmetic" —
  SUSTAINED as naming and scope, rejected as a
  defect: the leg is named the sieve deduction from
  the committed local data, its scope boundary is
  stated in section 6, and the data are additionally
  bound to the geometry by section 5, which the
  attack itself proposed.
- "Basis/base-point coherence across primes is
  assumed" — SUSTAINED as a scope statement,
  recorded in section 6.
- "Missing checks" — the sigma-pairing and the
  point-count / Jacobian-order checks were run and
  pass (section 5); the distinctness of the 35 and
  their non-membership in the rational-point sums
  follow from section 3 (pairwise distinctness is
  now checked explicitly). Verifying LocalKnown
  vectors against the Jacobian group law mod q is
  part of the fenced local-data generation.

Disposition of the legs: the soundness of the
35 divisors and the auxiliary F-rational data
(section 3) passes, the 12/23 classification at 19
(section 4) passes, the geometric bindings of
section 5 pass, and the Appendix A sieve
deduction from the committed local data (section
6) passes. Behind the fence (section 7) sit the
Coleman integration itself, the generation of the
local data, and the generators/rank inputs. The paper's
headline — 35 genuine sporadic divisors, recovered
at the single prime 19, with the list complete —
is supported in every leg the auditor could replay
without Magma, and the ceiling is the one set when
the audit was scoped: the p-adic computation at the
center of the paper is exactly the leg no
Magma-free replay can reach.

**Verdict: PARTIAL** — every replayable leg supports
the headline; the center of the paper sits behind the
fence set at scoping.
