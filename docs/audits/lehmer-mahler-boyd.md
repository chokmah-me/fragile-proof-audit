# Audit note — Generalized Boyd dataset for the Lehmer barrier (arXiv:2610.30277)

**Claim artifact:** *Generalized Boyd constructions and the
Lehmer barrier at high degree* (arXiv:2610.30277). The
paper assembles a benchmark dataset of irreducible integer
polynomials of even degree d in [10, 2000] with Mahler
measure below Boyd's limit point alpha_1 = M(F(X,Y)) =
1.255433866266608745189..., F(X,Y) = X(X+1)Y^2 +
(X^2+X+1)Y + (X+1), improving six published records. The
only public artifact is the arXiv ancillary CSV
(`mahler_dataset_d10_2000.csv`, 996 rows); no search or
verifier code is public, so the audit is a dataset replay,
as the harvest card scoped it.
**Harvest item:** harvest 2026-10-26 (fragility 2);
picked at the user's tap 2026-10-28.
**Campaign objects:** `incoming/lehmer-mahler-boyd/PIN.md`.
**Pinned sources:** paper PDF sha256
7167d3ffff7307dfdc6154f95f4e5e2a3438df1567e8f20c9381f85a21af91e4;
arXiv source tarball (paper source + ancillary) sha256
2ff3857348ea4a2c7b12bbd3c4231640c6fa37e8bba774e30a89d5f9f39b4128.
Evidence in `~/workspace/lehmer-recon/` (`EVIDENCE.md`,
`parser.py`,
`va_checks.py`, `vb_flint.py` + `vb-results.log`,
`aberth128.py` + `aberth-results.log`, `escalate.py`,
`census.py` + `census.log`, `census_escalate.py` +
`census-escalated.log`, `miss_certify.py`,
`uc_exact.py` + `uc-exact.log`, `alpha1_grid.py`,
`R1710.txt`).
Tooling: python-flint 0.9.0 (FLINT exact factorisation,
Arb root balls at 128-bit precision), numpy 2.5.4.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-29` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing); the pre-verdict deepening
was a DEEPEN challenge pass (Argon), adjudicated point by
point before filing (section 8).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-29T12:50:44Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## M1 — statement

The claims under audit are the ones in
  the PIN: the dataset entries are irreducible with
  M < alpha_1; the Generalized Boyd (GB) quotient identity
  P = Q/Phi holds exactly with k = 0, a <= b, delta =
  2a+2b+k-d <= 14; GB holds 991 of the 995 degrees in
  [12, 2000] (99.6%); 85 literature matches and 6 strict
  improvements at d in {178, 188, 190, 202, 242, 250};
  and section 6's selection sentence: every entry "was
  selected by taking the minimum Mahler measure across
  our search methods, the one-parameter Boyd family, and
  the Generalized Boyd algorithm (together with published
  records for d <= 250)".

## M2 — argument

The dataset is the argument; the audit
  replays it entry by entry. The search pipeline that
  produced the GB tuples is not public and is fenced
  (section 7).

## M3 — credit

The 85/6 literature accounting is the
  authors' own columns replayed, not an independent
  literature search.

## M4 — fine print

Alpha_1's printed digits are the
  authors'; the auditor checked them independently
  (section 2). The one-parameter family of section 4 is
  Q_n(x) = x(x^3+1)x^{2n} - (x^4+x^2+1)x^n + (x^3+1),
  degree 2n+4, deflated by its full cyclotomic part.

## 2. The bound alpha_1 (PASS)

The torus integral for M(F(X,Y)) was evaluated on
trapezoid grids N = 512..8192 (`alpha1_grid.py`):
1.254740237937, 1.255204596124, 1.255353290334,
1.255397850366, 1.255420437722, converging upward to
alpha_1 = 1.25543 +- 0.00002. This is a gross-error
sanity check only (its error bar is a third of the
margin below); the comparisons in this note use the
printed constant alpha_1 = 1.255433866266608745189,
Boyd's value, consistent with the closed form
log alpha_1 = (5 sqrt(15) / (4 pi^2)) L(E_15, 2). The
largest dataset measure (1.255358262 at d = 1932) sits
7.56e-05 below the printed alpha_1, four orders of
magnitude above every measure uncertainty in section 4.

## 3. Structural replay of the CSV (PASS)

Exact integer arithmetic throughout (`va_checks.py`;
the parser's round-trip rendering was verified on all
996 polynomial strings before any check ran).

- Degrees are exactly the 996 even degrees in [10, 2000];
  every polynomial is monic, reciprocal, constant term +1.
- All 991 GB rows: Q(tuple)/Phi equals the stored
  polynomial exactly, with Phi read from the row's own
  cyclotomic_divisor column ("1" on 471 rows, a single
  Phi_m on 470, a product of two on 50). delta =
  2a+2b+k-d lies in [0, 14] on every row; k = 0 and
  a <= b on every row; s_0, s_1 in {+-1}. The stored
  quotient_expr matches Q/Phi (bare numerator when
  delta = 0).
- The five non-GB optima are exactly at d in {10, 12, 16,
  32, 164}, matching section 6.
- Literature columns: 91 rows carry literature_m; 85
  match the dataset value and 6 are strict improvements,
  at exactly d in {178, 188, 190, 202, 242, 250}.
- The d = 1000 footnote fraction in quotient_expr
  expands to exactly 537 terms and its value
  1.255130738 matches the row.
- gen_boyd_m is populated on exactly the 995 rows in
  [12, 2000] and equals mahler_measure on the GB rows;
  one_param_boyd_m is populated on 502 rows.

## 4. Irreducibility and measures (PASS)

- Irreducibility: FLINT exact factorisation over Z
  (`vb_flint.py`): all 996 dataset polynomials are
  irreducible (a single factor, exponent 1). The
  dataset's core claim holds exactly, with no reliance
  on the authors' Mathematica protocol.
- Measures, tight rows: Arb root balls at 128-bit
  precision give radius <= 1e-9 on 274 rows; all 274
  agree with the printed 9-decimal measures (max
  deviation 5.5e-10, median 2.4e-10, i.e. print rounding).
- Measures, wide rows: the remaining 722 rows have Arb
  radii up to 4.8e-3 because of root clusters near the
  unit circle (pairs ~1e-4 apart; the radius is stuck
  under precision increases, diagnosed at d = 1932).
  All 722 were escalated with Aberth iteration in
  float64 warm-started from the Arb midpoints
  (`aberth128.py`; final corrections ~1e-16), except
  d = 1998, which was computed independently in long
  double (`escalate.py`): both precisions give
  M = 1.255348397026 there, matching the printed value,
  and the float64 pipeline reproduced the tight rows to
  all 12 printed digits on validation. Result: every
  escalated measure agrees with the printed value to
  <= 5.9e-9 (707 of 745 Aberth rows inside the 5e-10
  print-rounding band; worst deviation 5.854e-9 at
  d = 818). No printed measure is wrong at any
  load-bearing digit, and every entry is certified
  M < alpha_1: the largest certified measure is
  1.255358262 at d = 1932, 7.56e-05 below alpha_1.

## 5. Unit-circle root fractions (defect, descriptive only)

The CSV's unit_circle_root_fraction column undercounts.
Two independent instruments agree on all 996 degrees:
tight Arb root balls (274 rows) and Aberth roots (745
rows; the split at d = 1962 shows a clean gap between
moduli 2.2e-16 and 2.13e-04 from the circle). Both give
the printed count at 908 degrees and exactly 4 more at
88 degrees — one reciprocal quadruple {r, r^-1,
conj(r), conj(r)^-1} on the circle that the authors'
count misses (e.g. d = 1962: 1694 vs 1690); no
discrepancy of any other size occurs. The pattern is
confirmed with exact arithmetic at sample degrees:
Descartes' rule of signs with Vincent bisection on the
trace polynomial R(y), x^-m P(x) = R(x + 1/x), counting
real roots in (-2, 2) over the integers (`uc_exact.py`)
gives exactly the printed count at the control degrees
d = 10, 12, 100, 500 and exactly printed + 4 at the
flagged degrees d = 186, 356, 430, 450, 488, 576, 582
(every flagged degree the exact count was run on). A full-range exact
count is beyond the audit's tools (python-flint
exposes no real-root isolation; symbolic Sturm does
not finish at degree ~1000), so the 88-degree figure
rests on the two float instruments in exact agreement
plus the exact spot checks. The column feeds no other
claim; the defect is recorded, not load-bearing.

## 6. The one-parameter census and the selection claim (BREAK)

The auditor enumerated the section 4 family exhaustively
(`census.py`: FLINT factorisation of Q_n for n = 3..1012;
996 values of n yield a single irreducible quotient of
even degree in [10, 2000], landing on 797 distinct
degrees, several degrees hit by more than one n). The
census family is the authors' family: the maximum
quotient measure over d >= 12 is 1.311999492455, matching
the paper's Table value 1.311999 for the one-parameter
family to all printed digits.

- The CSV's one_param_boyd_m column, where populated,
  is accurate: radius-aware comparison against the
  census (each printed value against every census
  quotient at that degree, tolerance = Arb radius +
  1e-9) gives 0 disagreements on 502 rows. But the
  column is populated at only 502 of the family's 797
  degrees; at 295 degrees where the family yields an
  irreducible quotient the column is empty.
- The paper's "504 even degrees" for the family is not
  reproduced under any natural reading: the full
  footprint is 797 degrees, the column's footprint 502.
  Filters tested against the census, none giving 504:
  n <= 998 (796 degrees), d <= 1500 (597), M < alpha_1
  (353), cyclotomic part nontrivial (797; in fact every
  quotient has deg Phi >= 2). The number is a
  bookkeeping artifact of the authors' evaluation
  pipeline; the direction is conservative (the family
  covers more than claimed).
- Missed selections. Four GB dataset rows are beaten
  by the family's own quotient at the same degree, each
  on an exact FLINT factorisation of Q_n. Certification
  of the measures is per degree: at d = 1710 and
  d = 1770 by Arb root balls directly (radii 6.57e-14
  and 6.7e-14); at d = 1434 and d = 1554 the quotients'
  Arb balls are wide and precision-independent (the
  d = 1554 ball radius is 5.840e-04 at 256, 512, and
  2048 bits alike — the cluster artifact of section 4),
  so those two rest on three agreeing instruments
  (`miss_certify.py`): float64 Aberth and long-double
  Aberth agree to 1.4e-14 and 1.7e-14 respectively, the
  Arb midpoints sit within 1.4e-7, and the gaps exceed
  the total cross-instrument spread by factors of
  about 1100 and 270:
  - d = 1710 (n = 854): family M = 1.255301935489 vs
    dataset record 1.255323937, gap 2.20e-05. The
    column prints the family's value (1.255301936) and
    the selection still did not take it.
  - d = 1434 (n = 718): family M = 1.255281572333 vs
    dataset record 1.255297571, gap 1.60e-05. Column
    empty at this degree.
  - d = 1554 (n = 778): family M = 1.255307071926 vs
    dataset record 1.255311770, gap 4.70e-06. Column
    empty at this degree.
  - d = 1770 (n = 884): family M = 1.255312107023 vs
    dataset record 1.255320620, gap 8.51e-06. Column
    empty at this degree.
  Section 6's minimum-selection sentence therefore
  fails at four degrees. Every wide-radius census row
  was escalated before concluding (396 rows,
  `census_escalate.py`, final corrections ~1e-16): the
  four misses above are all of them.
- Tie accounting. The family's true best-or-tied
  footprint is 33 degrees, not 19. The paper's 19
  (degrees where the CSV's one_param column equals the
  record) are all genuine and all confirmed exactly:
  7 are the same polynomial (census quotient identical
  to the dataset entry: d in {106, 226, 686, 746, 912,
  1194, 1212}) and 12 are exact ties under the sign
  symmetry (the census quotient is the dataset
  polynomial at -x, root-negation, hence exactly equal
  measure). A further 13 attainments are unrecorded,
  every one at a degree where the one_param column is
  empty: the three strict improvements at d in {1434,
  1554, 1770}, four same-polynomial ties at d in {696,
  1512, 1784, 1890}, and six sign-symmetry ties at d in
  {1272, 1424, 1484, 1544, 1604, 1936}. All 18
  sign-symmetry ties in the census were verified
  polynomial-by-polynomial (R(x) = P(-x) exactly).
  With d = 1710 (value recorded, selection not taken)
  the family attains or beats the dataset record at 33
  degrees.
- Restated bookkeeping: GB holds at most 987 of the
  995 degrees in [12, 2000] (99.2%, not 991 / 99.6%);
  the one-parameter family's best-or-tied count is 33,
  not 19. The headline existence claim is untouched:
  both the dataset entries and the four beating
  quotients are irreducible with M < alpha_1.

## 7. Fences (GAP)

- The search pipeline (section 3's ensemble and the GB
  solver that found the tuples) is not public; how the
  tuples were found is not audited. The audit verifies
  the dataset as given, entry by entry. In particular
  it does not re-run the GB parameter box (k = 0,
  a <= b, delta in [0, 14]) at any degree: whether an
  unpublished GB tuple beats the family quotient at
  the four missed degrees is part of the fenced
  pipeline. The BREAK is against section 6's selection
  sentence over the pool it names — the published
  entries, the one-parameter family, and the published
  GB entries.
- "Best known" against the world beyond the three
  families in the selection pool and the literature
  columns rests on the authors' leaderboard; the audit
  replayed the columns, it did not rebuild the
  leaderboard.
- The authors' section 3 verification protocol
  (deflation, Mathematica IrreduciblePolynomialQ,
  numpy.roots) was not replayed as such; it was replaced
  by exact FLINT factorisation and Arb/Aberth measures,
  which are independent of it and stronger on
  irreducibility.

## 8. DEEPEN adjudication

The DEEPEN pass (Argon, contract-breaker brief on the
draft conclusions; raw answer `argon-deepen.md`,
$0.0399) raised six attacks. Adjudication:

- "Float64 Aberth is an uncertified downgrade; the
  5.9e-9 deviation is 12 ULP at the printed precision."
  PARTIALLY SUSTAINED. Arb balls on these cluster
  polynomials do not shrink with precision (measured:
  the R_1554 radius is 5.840e-04 at 256, 512, and 2048
  bits), so ball certification is unavailable from that
  instrument at any precision, not merely untried. The
  audit's response: the two Aberth-dependent misses
  were re-certified on three instruments (section 6),
  and certification levels are now stated per degree.
  The 5.9e-9 worst deviation is the expected spread
  between two float64 root pipelines (the authors' own
  protocol is numpy.roots); it touches no load-bearing
  digit, the smallest margin in play being 4.70e-06.
  REJECTED as a verdict-changer.
- "The alpha_1 grid integral proves nothing."
  SUSTAINED as framing; section 2 now labels it a
  gross-error sanity check and rests the comparisons
  on the printed constant.
- "Reciprocity unchecked; Phi taken on trust from the
  string; literature columns merely compared."
  REJECTED on the first two: reciprocity is checked in
  section 3, and the Phi_m were constructed
  independently (Mobius inversion) before the identity
  Q/Phi = P was verified. The literature point is the
  M3 fence, already stated in section 1.
- "Value ties at 1e-9 between distinct irreducibles
  are not ties." SUSTAINED, and it improved the audit:
  all 18 such ties are exact, R(x) = P(-x), verified
  polynomial-by-polynomial (section 6).
- "The 504 footprint is an untested filter (try
  n <= 998, reducible discards)." REJECTED on the
  numbers: n <= 998 gives 796 degrees; the other
  filters are listed in section 6. The discard
  mechanism he proposes removes ~14 of 1010 values of
  n, not the ~300 the claim would need.
- "Count unit-circle roots exactly (Sturm on the
  trace polynomial); the GB box is auditable, the
  fence is misplaced." The first is SUSTAINED as the
  right instrument and was run exactly at sample
  degrees (section 5); the full-range exact count is
  recorded there as a tooling limit, not skipped
  silently. The second is REJECTED: re-running the
  authors' parameter-box search is the fenced pipeline
  itself; section 7 now says so explicitly.

Disposition of the legs: the dataset itself passes —
all 996 entries are irreducible, every printed measure
is confirmed (exactly on the tight rows, to <= 5.9e-9
on the escalated rows), every GB quotient identity is
exact, and the existence headline — irreducible
polynomials below alpha_1 at every even degree up to
2000 — stands. Section 6's minimum-selection claim
breaks at d = 1710, 1434, 1554, and 1770, and the
counts derived from it fall with it (991 of 995 /
99.6% becomes at most 987 / 99.2%; the family's
504-degree footprint and 19 best-or-tied records are
pipeline bookkeeping, not the family's true footprint
of 797 degrees and 33 best-or-tied). The search
pipeline and the external leaderboard are not public.
One descriptive defect: the unit-circle root fraction
column undercounts by one reciprocal quadruple at 88
degrees.

**Verdict: PARTIAL** — the dataset is verified in
full; the selection claim and its derived counts do
not survive the census.
