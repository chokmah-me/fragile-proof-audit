# Gomila's Λ ≤ 0.1787854 (2026) — audit, not refutation

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` §3.5, harvest rank 8.
Ranking table: Λ ≤ 0.1787854 | F=5, Fr=5, R=9 | est. effort 3–6 wk.
Verdict in report: **Verify/audit — not a refutation play.**

This is the *inverse* of a fragile proof: a claim explicitly structured as
finite, independently checkable gates. The campaign deliverable is a
confirmation artifact, not a kill. Any failure found (a row that will not
parse under fail-closed rules, an interval that straddles) is a finding,
not an indictment — per the corpus: "fragility is not guilt."

## The claim (verbatim from the corpus entry)

In August 2026, Jude Gomila announced a computer-assisted proof lowering the
de Bruijn–Newman constant's ceiling from 0.2 (Platt–Trudgian, 2020) to
exactly 129/800 + 87677/5,000,000 = **0.1787854**, instantiating Polymath 15's
Theorem 1.2 at an exact rational parameter row, supported by ~3.15 million
machine-checked interval certificates plus an 883-prism barrier argument.

Exact parameter row:

```
X   = 6,000,000,185,827
t₀  = 129/800          = 0.16125
ŷ₀² = 87677/2,500,000  = 0.0350708
Λ  ≤ t₀ + y₀²/2
   = 129/800 + 87677/5,000,000
   = 893927/5,000,000
   = 0.1787854   (exact rational; final arithmetic is exact, not floating-point)
```

Stakes: RH ⟺ Λ ≤ 0 (proved equivalence); Rodgers–Tao (2018) proved Λ ≥ 0, so
the truth is confined to [0, 0.1787854]. Provenance per the corpus: Dan Romik
named as independent reviewer; audit trail hash-pinned.

## Source links

- Announcement / full walkthrough (the "paper"; no arXiv version):
  https://www.judegomila.com/posts/riemann-lambda-0.1787854
  (Jude Gomila, Aug 19, 2026 — "A new ceiling for Λ: the de Bruijn–Newman
  constant is at most 0.1787854")
- Public audit repository (certificates, checkers, replays, review record;
  repo self-describes the proof as "Not yet peer reviewed"):
  https://github.com/judegomila/dbn-lambda-01787854-candidate-audit

## Pinned provenance (recorded 2026-09-22)

Audit-repo HEAD at pin time:
`a74738deb6d5e0f76887cb36901da08b68dca705`
(2026-08-21, "Add the Aristotle-formalized complete lemma layer under
lean/aristotle (#29)").

The repo's `SHA256SUMS` pins the full tree. The 15 sealed window shards
(`certificates/`, filename pattern `p<mollifier primes>_<N start>_<N end>.log.gz`):

```
d9a66e7904bcb258f008197fc1d70b9e7dab578cc55350cb829605a8271907db  certificates/p235711_690988_690995.log.gz
d3103aec577d4d500b5713dd0b1aada109602849d1fa31805db6c2f08053e719  certificates/p235711_690996_691500.log.gz
d602a19441b3f668cda7130d1001034a5b6fcf86bb80b045e2f8b749469e5fca  certificates/p235711_691501_697000.log.gz
4dcadd8b8de0e6bd419455421b37fa26a4ecfc4e3ac8765af1ce85b70fd8d95b  certificates/p235711_697001_728999.log.gz
fe89eb942ccb5a4b7e7b6ba91dcb93b8be45d82784eb2e366e67e0766bf8ab85  certificates/p2357_729000_818999.log.gz
6b7371b7c2953c8fb96225531607ac878f2eab402242b5f44f22760d803c2e85  certificates/p235_819000_1027999.log.gz
adefc4bbebdd55c57e795d186e2063b183a7eb34a0ba3fd3dc770b01e7c2e585  certificates/p23_1028000_1030000.log.gz
f217b53e6e02a805e8ffbfc2b3ffec98a0902625fe75e286cb5f88362f760f67  certificates/p23_1030001_1050000.log.gz
9a55421582f9e8751e85f18a93b83dfebca4f16996a24cc15d2ad0130a0afc5e  certificates/p23_1050001_1100000.log.gz
6880b739d3d3446a332f6fa1b939033168a426151c174aeff48c06f0dc3c0198  certificates/p23_1100001_1300000.log.gz
de8618e213152bff26db51b12aa167ba693a17bdf52a9e60aadf28d1024b7295  certificates/p23_1300001_1700000.log.gz
8e97159496ead5e4f8e0697c44ca7a0e754c294e6f6122486a508f70939242c5  certificates/p23_1700001_2200000.log.gz
a5573508d1b24e4fd74d8ff30c9f5065f39921b4fc4eec7a7cd63976bf769751  certificates/p23_2200001_2800000.log.gz
1ec7f34e7ce51c8e618f2cb136a27fc90bba78f9da5b66fff513413d2b6db124  certificates/p23_2800001_3300000.log.gz
fdd2fc6e9dbe69d3edfa69b91e9298d53eba5c860bda6a9d1d3c20d5f77798a3  certificates/p23_3300001_3840000.log.gz
```

Mollifier legs: {2,3,5,7,11} for N=690988..728999 (4 shards);
{2,3,5,7} for N=729000..818999; {2,3,5} for N=819000..1027999;
{2,3} for N=1028000..3840000 (9 shards).
Related pins from the same `SHA256SUMS`:

```
266c1e6b6bc9330f471f0874fc89f9b64eaac1b320cddedfd197ef3c028e295a  WINDOW_FREEZE_THEOREM.md
7cfff3e01b592907f3abc14497a51ab221bee82877d21b7f8f66b7273d1e14d4  verifiers/verify_window_freeze.py
0d40f9b8137f83fcfd7c6546e333d23acac052fa7ca3822f4d7d3075c62e66d8  verifiers/verify_prop410_arb.c
```

## Certificate inventory

1. **3,149,013 window rows** (N=690988..3840000): one certified strict
   interval-arithmetic inequality per Riemann–Siegel window
   W_N=[x_N, x_{N+1}), x_N=4π(N²−t₀/16), proving |f_{t₀}| ≥ 7.91366×10⁻⁷
   against certified total error E_max ≤ 2.33495×10⁻⁷ (nonvanishing with a
   3.4× cushion). Prop 4.10 certified by standalone FLINT/Arb
   `verifiers/verify_prop410_arb.c` at 256 and 512 bits, run as prerequisite
   P17 of the 40-gate fail-closed assembly.
2. **883-prism barrier certificate**: closed time prisms over
   R=[X,X+1]+i[0.1809,1], 0≤t≤t₀, winding number 0 in each (argument
   principle); minimum certified margin 0.5198; 7,688 stored Taylor
   coefficient components (tail bounded by 1.96×10⁻²²); 54 strict fail-closed
   parser checks; replayed on Linux/FLINT 3.0.1 and macOS/FLINT 3.6.0 with
   identical verdicts on all 883 prisms.
3. **Tail lemma** (N≥3840000): contraction D<0.999721 ⟹ |f|≥1.734×10⁻⁴;
   single Arb run at 256 & 512 bits plus a separate Python interval
   implementation; finite and tail lanes overlap on the complete window
   N=3840000.

Every artifact is SHA-256 pinned and re-attested by the repo's `verify.sh`.
Independent review: Dan Romik (re-proved every analytic lemma; wrote two
journal-grade manuscripts plus seven standalone verification programs).
Four-agent adversarial AI review panel (July 2026): no fatal or
bound-invalidating defect; fixed one real gap (the Dini transfer was not
wired into the assembly gate). Full from-source recompute matched
line-for-line (all 7,688 coefficients, 883 prisms, 3,149,013 rows).

## Window Freeze theorem (summary)

`WINDOW_FREEZE_THEOREM.md` (see pin above) is the elementary,
unconditional lemma that turns the scan from numerics into proof. At
t₀=129/800, y₀²=87677/2,500,000, y_max²=271/400 (=1−2t₀), with
q_N=N²−t₀/16, x_N=4πq_N, W_N=[x_N,x_{N+1}): for every integer
690988≤N≤3840000, every x∈W_N, every y∈[y₀,y_max):

- G(x,y) ≤ G_N(y),  with G(x,y)=e^{y/50}(x/4π)^{-y/2}  (frozen = upper bound)
- K(x,y) ≤ K_N(y),  with K(x,y)=t₀y/2(x−6)         (frozen = upper bound)
- Σ(x,y) ≥ Σ_N(y),  with Σ(x,y)=(1+y)/2 + (t₀/4)log(x/4π) − (t₀/2x²)(1−3y+4y(1+y)/x²)₊
  (frozen = lower bound)

where the frozen values are evaluated at the window's closed left
endpoint x_N — exactly the conservative directions the producer consumes.
Proof idea: ∂_xG=−yG/2x<0, ∂_xK=−t₀y/2(x−6)²<0; Σ is strictly increasing
in x (log term strictly increasing; the x⁻²·h₊ correction nonincreasing),
including across the kink h=0. Site coverage: x_{690988}<x_*<x_{690989}
with certified margins x_*−x_{690988}>5377393.9878 and
x_{690989}−x_*>11989041.1746 (exact rational Machin-series bounds for π,
exact integer-square-root brackets, independent 400-bit interval
evaluation); windows tile [x_*,x_{3840001}) with no gaps or double
assignments. Boundary convention is fail-closed: x_{N+1} belongs to
W_{N+1}, where all three frozen bounds reset in the safer direction.
The repo's `verifiers/verify_window_freeze.py` checks A1–C11 (row count
B7: NMID−N0+1 = 3,149,013 exact; leg-endpoint consecutivity B8).

## Sample check (2026-09-22) — VERIFIED PASS

Smallest shard: `certificates/p235711_690988_690995.log.gz`
(first {2,3,5,7,11} leg). Filename encodes N=690988..690995 —
8 expected rows. Downloaded from the audit repo at the pinned commit
above; published SHA-256 pin:
`d9a66e7904bcb258f008197fc1d70b9e7dab578cc55350cb829605a8271907db`.

Row-content verification completed (2026-09-22, shell session against the
audit repo at the pinned commit
`a74738deb6d5e0f76887cb36901da08b68dca705`):

- SHA-256 of the downloaded shard matches the published pin exactly.
- Ran the audit repo's own fail-closed parser
  (`verifiers/verify_finite_and_binding.py` `parse_file`).
- **8 rows; N=690988..690995 exactly contiguous** — count matches the
  filename's encoded range.
- UNCERT=0 — no uncertain records.
- 3 runs with TIMING counts matching run rows.
- TBOX = the leg's expected singleton box 16125/100000 (= t₀).
- Every row matches the spec `N <n> L12 <floor> GT089 [01]`.
- Minimum stored floor = 791366/10^12 = 7.91366e-7 at N=690988 — exactly
  the p235711 leg's pinned minimum; this shard holds the leg's argmin,
  the decisive margin floor of the whole finite scan.

**No anomalies. Sample check PASSES (8/8 rows).**

## Full finite replay (2026-09-22) — VERIFIED PASS

Run on a fresh download of all 15 shards at pinned audit-repo commit
`a74738deb6d5e0f76887cb36901da08b68dca705`, using the repo's own
`verifiers/verify_finite_and_binding.py` (Python 3.12.3 + mpmath 1.2.1,
220-bit interval arithmetic), exit code 0.

- **15/15 shard SHA-256 checksums** match the repo's `SHA256SUMS` pins.
- **leg p235711** ({2,3,5,7,11}): 4 files, 12 runs, N=690988..728999,
  38,012 rows, min floor 0.000000791366 @690988, UNCERT=0.
- **leg p2357** ({2,3,5,7}): 1 file, 1 run, N=729000..818999,
  90,000 rows, min 0.000315112459 @729000, UNCERT=0.
- **leg p235** ({2,3,5}): 1 file, 1 run, N=819000..1027999,
  209,000 rows, min 0.000305788807 @819000, UNCERT=0.
- **leg p23** ({2,3}): 9 files, 9 runs, N=1028000..3840000,
  2,812,001 rows, min 0.000309285478 @1028000, UNCERT=0.
- **Global**: 3,149,013 rows, N=690988..3840000, gaps=0, overlaps=0,
  UNCERT=0.
- **Error budget** 12/12 gates: eAB ≤ 2.057023688667e-12,
  eC0 ≤ 2.33492848188649183e-7, Emax ≤ 2.33494905212337849e-7
  (within the claimed 2.33495e-7).
- **Normalizer/corr monotonicity** 6/6 gates:
  Xi_ub = −1.363112154757640042 < 0.
- **Binding floor** = 7.91366e-7 − 2.33494905212337849e-7
  = 5.57871094787e-7 > 0.

**RESULT PASS: full finite Triangle weld B=893927/5000000 rows=3149013.**

This is an **audit confirmation, not a BREAK** — explicitly **not** on the
23/23 verdict lock.

## Dini y-transfer (2026-09-22) — VERIFIED PASS

Fresh fetch of `logs/` at pinned audit-repo commit
`a74738deb6d5e0f76887cb36901da08b68dca705` (Python 3.12.3).
**9/9 log SHA-256 checksums** match the repo's `SHA256SUMS` pins:
`triangle_y_dini_180` / `triangle_y_dini_256`,
`triangle_normalizer_corr_180` / `triangle_normalizer_corr_256`,
`triangle_y_monotonicity_independent_head_120` /
`triangle_y_monotonicity_independent_tail_120`,
`p11_triangle_tail_cells_independent`,
`tail_1787854_160` / `tail_1787854_256`.

`verifiers/verify_triangle_y_dini_logs.py` — **RESULT PASS**: 4/4 legs at
both 180- and 256-bit precision; worst ratio_ub = 0.99999860767275095 < 1
(slack 1.39232724905e-6); both precisions bit-identical on the worst
ratio; fixed-domain Arb Dini source present with fail-closed gates. The
worst (thinnest-margin) leg is P=235711, N=690988..728999 — the same leg
that holds the finite scan's argmin floor.

`verifiers/verify_stored_logs.py` — **RESULT PASS**: Dini logs (four legs
+ strict ratio), normalizer/corr gates, independent corrected Python
monotonicity head/tail, independent P11 cell decomposition, and
`tail_1787854` 93/93 at both 160 and 256.

**Platt–Trudgian margin independently confirmed**:
3,000,175,332,800 − 6,000,000,185,827/2 = 175,239,886.5, exactly as
claimed.

Primary-source provenance (confirmed): T_PT = 3,000,175,332,800 is
Theorem 1 of Platt–Trudgian proper (arXiv:2004.09765, *Bull. LMS* 53
(2021), 792–797: "true up to height 3 000 175 332 800 ... the lowest
12,363,153,437,138 non-trivial zeroes"), independently corroborated by a
separate Lean formalization project's audit doc citing the identical exact
height. The X/2 reading of criterion hypothesis (i) is confirmed by the
repo's own CANDIDATE_PARAMETERS.md ("required zeta height X/2 =
3000000092913.5") and PROOF_NOTE.md (3.1)–(3.3), plus the cross-check that
the abstract's rounded 3×10¹² falls short of X/2 by exactly 92,913.5
(consistent only with the X/2 requirement).

Meaning: the y-transfer extending the y₀ floors across the full y-band is
sealed — gate (ii) is now fully closed, including the transfer step the
author's adversarial panel had flagged as a real gap.

## Barrier replay (2026-09-22) — VERIFIED PASS

Fresh clone of the audit repo at pinned commit
`a74738deb6d5e0f76887cb36901da08b68dca705`; read-only replay scope (no
producer rebuild), per the audit plan. Environment: Linux, Python 3.12.3
+ mpmath 1.2.1, gcc, FLINT 3.0.1 (libflint-dev, the repo Dockerfile's
reference version).

- **5/5 sealed barrier certificate SHA-256 checksums** match the repo's
  `SHA256SUMS` pins: `barrier_target_closed.log` (Linux/FLINT 3.0.1),
  `barrier_target_closed_macos_arm64_flint36.log`,
  `storedsum_taylor_tail.log`, `storedsum_provenance.log`,
  `uniform_error_256.log`.
- `verifiers/verify_barrier_binding.py` on the sealed log —
  **RESULT: ALL PASS, exit code 0**: 54/54 checks, 0 failures; prism
  cover E5 parses 883/883 lines, consecutive identifiers, every prism
  quantity passes its sign/type gate. Conclusion: H_t is zero-free on
  the complete closed slab [X,X+1] × [0.1809,1] × [0,0.16125].
- `verifiers/verify_prop410_arb.c` compiled clean against FLINT 3.0.1
  and run at both precisions — **31/31 checks PASS at 256 bits**
  (exit 0) and **31/31 checks PASS at 512 bits** (exit 0): exact
  candidate identity t₀+y₀²/2 = 893927/5000000, t-box, y₀² identity,
  floor-vs-budget, all domain gates, and the directed Arb error-budget
  bounds, with no stored numerical certificate read.

**RESULT PASS: 883-prism barrier certificate + Prop 4.10 Arb error
budget at 256 & 512 bits.** Gate (iii) of the Triangle weld is now
closed on this audit's evidence. Still an audit confirmation, not a
BREAK; not on the 23/23 verdict lock.

## Tail replay (2026-09-22) — VERIFIED PASS

Fresh clone of the audit repo at pinned commit
`a74738deb6d5e0f76887cb36901da08b68dca705`; read-only scope. Same
environment as the barrier replay (Linux, Python 3.12.3 + mpmath 1.2.1,
gcc, FLINT 3.0.1).

- **5/5 sealed tail certificate SHA-256 checksums** match the repo's
  `SHA256SUMS` pins: `logs/tail_1787854_160.log`,
  `logs/tail_1787854_256.log`, `logs/tail_arb_256.log`,
  `logs/tail_arb_512.log`, `logs/p11_triangle_tail_cells_independent.log`.
- `verifiers/verify_tail_arb.c` compiled clean against FLINT 3.0.1 and
  run fresh at both precisions — **36/36 checks PASS at 256 bits**
  (exit 0) and **36/36 checks PASS at 512 bits** (exit 0), including the
  decisive contraction gate D < 1 (N ≥ N1 = 3840000, M = 153814).
- `verifiers/verify_tail_arb_logs.py` on the sealed logs —
  **RESULT PASS, exit 0**: 36/36, D < 1, flow > error, certified margin
  > 0.000173520937333783227135809831470514 (i.e. |f| ≥ 1.734×10⁻⁴
  holds with margin).
- Independent Python interval tail verifiers —
  `verify_tail_1787854_160.py` **ALL PASS** (exit 0, 35.4 s) and
  `verify_tail_1787854_256.py` **ALL PASS** (exit 0, 40.0 s).

**RESULT PASS: tail lemma (N≥3840000 contraction ⟹ |f|≥1.734×10⁻⁴).**
The finite and tail lanes overlap on the complete window N=3840000, so
the weld is continuous. All four Gomila audit lanes — finite, Dini
y-transfer, barrier, tail — now replayed PASS on this audit's evidence.
Audit confirmation, not a BREAK; not on the 23/23 verdict lock.

## Audit plan (verify/audit, not refutation)

1. ~~Shard row check + full finite replay~~ — **DONE 2026-09-22**: sample
   shard 8/8 rows PASS; full replay of all 15 shards
   **3,149,013/3,149,013 rows PASS** (see above).
2. ~~Sample wider strata~~ — **DONE 2026-09-22** via the full replay (all
   15 shards, all four mollifier legs).
3. ~~Dini y-transfer (y₀ floors → full y-band)~~ — **DONE 2026-09-22**:
   9/9 log checksums PASS; `verify_triangle_y_dini_logs.py` PASS (4/4
   legs, worst ratio_ub 0.99999860767275095 < 1);
   `verify_stored_logs.py` PASS; Platt–Trudgian margin confirmed
   (see above).
4. ~~Barrier + tail replay~~ — **DONE 2026-09-22**: barrier 5/5
   checksums PASS, `verify_barrier_binding.py` PASS (54/54, 883/883,
   exit 0), `verify_prop410_arb.c` PASS at 256+512 bits (31/31 each);
   tail 5/5 checksums PASS, `verify_tail_arb.c` PASS at 256+512 bits
   (36/36 each, D<1), `verify_tail_arb_logs.py` PASS (margin
   >1.7352e-4), Python tail verifiers ALL PASS at 160+256 bits.
   All four Gomila lanes now replayed PASS.
5. State the three gate lemmas (verified height, final-time clearance,
   barrier) in Lean against the campaign's axiom-clean forge; cross-reference
   Gomila's own `lean/aristotle` (seven Lean 4 projects, 223 theorems,
   axioms ⊆ {propext, Classical.choice, Quot.sound}) — state natively,
   do not import their aristotlelib setup.
6. Discipline: a clean pass confirms the audit trail (valuable — a
   machine-checked confirmation of a live bound). A failed row is a
   finding about the certificate chain, never an indictment of the
   claimant.

## Do not claim

- Do not claim this audits Gomila's proof in full — the finite lane is
  fully replayed and PASS, but the barrier and tail legs are not yet
  replayed; this file is a blueprint, not a verdict.
- Do not claim the corpus description was wrong — the key identifiers
  cross-checked (rank 8, 3,149,013 rows, 883 prisms, 0.1787854, Romik,
  hash-pinned) even though the corpus doc was downgraded on math
  descriptions elsewhere.
- Do not treat "Not yet peer reviewed" as a defect — the campaign audits;
  it does not referee.
- Do not bump the campaign Lean pin to run Gomila's `lean/aristotle`
  projects (aristotlelib, separate toolchain) — state the lemmas natively.
