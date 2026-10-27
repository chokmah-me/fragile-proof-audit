# Audit note — Improved lattice-packing bounds (Zubrilina, lattice-packing-bound)

**Claim artifact:** Nina Zubrilina, *Improved lattice-packing
bounds in small dimensions* (arXiv:2610.35830, 2026-10-26),
with its certificate repository
github.com/AstroNinja389/lattice-packing-bound: 83 exact
rational certificates (dimensions 9–91) for density upper
bounds from a modified Cohn–Elkies linear program (Theorem 1
of the paper), checked by four independent exact verifiers.
Headline: for 11 ≤ n ≤ 16 the bounds beat the rigorous
three-point bound of Cohn–de Laat–Salmon (n=16: 0.0187461206
vs 0.024995, a 25.00% gain); for 67 further dimensions they
lie below the published numerical Cohn–Elkies values.
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
improved-lattice-packing-bounds-small-dimensions, recon
fragility 5, head of the queue, issue #12); picked at the
user's tap 2026-10-27.
**Campaign objects:** `incoming/lattice-packing-bounds/PIN.md`.
**Pinned sources:** paper PDF sha256
`e26fc57262e32566ff1941659f910a68cfac2bea6c8a9182a4efc866d1df0d16`;
arXiv source tarball sha256
`76ca3f6b3ad52b0761caeb3d93194679eed02e7d33f44225b82216a6eaf6525e`
(the repo's `paper/main.tex` is byte-identical to it);
repo @ `340a0e93bb95942c2b1b80092be43149504970eb` (single
commit), codeload tarball sha256
`e3afc19993b8578a4d6be13b61dec51013dc4711622e0a2cd64da3a328c227a1`.
Evidence in `~/workspace/lattice-packing-recon/`
(`scalar_gate.py`, `cross_checks.py`, `DEEPEN.md`,
run logs `run-*.log`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-27` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: a full read of the paper,
the verification contract, and the certificate format
before anything was run); the pre-verdict deepening was a
DEEPEN challenge pass (below).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T21:00:04Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (certificate validity at the pin): PASS.** All
  four independent verifiers accept every applicable
  certificate on this VM (receipt below): Taylor 83/83,
  Bernstein 83/83, PARI root-counting 83/83, Descartes
  41/41 even dimensions. Given Theorem 1, the certificates
  therefore establish the claimed density and Hermite
  bounds exactly.
- **V-B (scalar claims): PASS.** The auditor's own
  implementation of the contract's budget arithmetic
  recomputes kappa, rho_+, and both decimal claims for all
  83 certificates, and every claim holds; the gains,
  improvement set, and smallest margins in the data and
  the paper recompute exactly.
- **Scope (not a GAP in the audited claim):** Theorem 1's
  proof is the paper's, read but not formalized; the
  verdict certifies the certificates given Theorem 1, as
  the Cohn–Kumar-style certificate presentation intends.
  For n ≥ 17 the comparison values are published
  *numerical* Cohn–Elkies estimates (Afkhami-Jeddi et
  al.), so improvements there are improvements over
  those printed numbers, not over rigorous bounds; the
  paper, README, and results data all label them so.
  Only 11 ≤ n ≤ 16 gains are over a rigorous published
  bound. The verdict lock is not touched.

## M1 — statement fidelity

The certificate contract implements the paper's Section 3
without drift. Read side by side: the three sign
conditions (q(t) > 0 on [0,∞);
Γ_b(1 + u + u²/2) − p(t) ≥ 0 on each bin with
u = (t−τ_b)/2, i.e. the paper's (t−τ_b)²/8 term;
p(t) < 0 beyond τ_M) are the paper's (eq:checks); the
weights R_b use the same 512-term truncated exponential
and backward maxima for b ≥ J; the caps B and A (with the
squared-variable U = (T+S−4)²/(4TS) = c_a² form and the
(n−1)(c′_a)² < 1 branch) are the paper's (eq:B)/(eq:A);
kappa is the paper's (eq:kappa) budget; the density and
Hermite claim equations, including odd-dimension squaring
against a Machin-formula rational pi lower bound (80-term
atan(1/5), 79-term atan(1/239)), are the paper's
(eq:claims) and its following paragraph. The n=16 headline
is the certificate's own claim (n016, K=81, density
0.0187461206) against the CDS three-point value 0.024995
printed in Table 1; the exact gain recomputes to the
printed 25.00%.

## M2 — what the certificates establish

Each certificate fixes rational Laguerre coefficients, a
rescaling τ_0, squared partition points, and bin heights
Γ_b. A verifier reconstructs p and q, proves the three
sign conditions exactly, rebuilds the weights, caps, and
budget in exact rational arithmetic, and tests the
certificate's decimal claims against the resulting ρ_+.
Four implementations do this by four different sign
methods (real-root counting in PARI, integer Taylor
bounds, Bernstein coefficients, Descartes' rule of signs)
sharing no code. The auditor's scalar gate is a fifth
implementation of the budget and claim half. The search
that produced the candidates (floating-point LP, run by
GPT-6 Astra per the paper) is not part of any leg: invalid
candidates would simply fail the sign tests.

## M3 — credit honesty

The claim is Zubrilina's (sole author). The paper's
Section 1 discloses in one line that "the numerical
exploration of the linear program was performed by GPT-6
Astra"; the repo README states the same division of labor
("The numerical search supplies candidates; it is not part
of the proof"). This note credits the result to the
paper and its certificates, and the search to the
disclosed model, matching the authors' own framing. Two
provenance facts are recorded without weight on the math:
the repo sits under a handle (AstroNinja389) that does not
match the author name, as a single commit created
2026-10-26; and its README states licence selection is
pending and no licence is granted by the checkout (this
audit only read and replayed it locally).

## M4 — fine-print assumption inventory

- The four verifiers and the auditor's gate share one
  specification (the repo's verification contract). The
  M1 read above is the fence: every contract formula was
  compared against the paper's equations. A shared
  misreading of the paper by the contract author and
  this auditor is the residual risk; more replay cannot
  remove it.
- Theorem 1 is consumed as a proved paper theorem. Its
  proof is short and fully printed (coset inner-product
  bound, the PSD trace argument for B(s), the projection
  argument for A(a,s), summation by parts), and it was
  read at recon; it is not machine-checked anywhere.
- Environment deltas from the authors' tested setup:
  Python 3.12.3 here vs 3.14.6 tested; PARI/GP 2.15.4
  (apt) vs 2.19.0 tested; python-flint exactly 0.9.0 as
  tested. All normalized verifier outputs matched the
  committed reference logs exactly, delta notwithstanding.
- Table 1's "best known lattice" column and the n=9, 10
  discussion (exact optimum in dimension 9, Mordell in
  10) are context, not claim objects; the certified
  bounds in 9 and 10 are not improvements over the
  strongest lattice bounds and the paper says so.
- The paper defines `\CertificateCount` as 82 and never
  uses the macro; the actual count is 83 in the manifest,
  the data, and the repo. Cosmetic only.
- Dimension 24 carries a certificate and sits outside
  the improvement set (README calls it a control near
  the known optimum); the 16 non-improvement certificates
  pass the same verifiers, which is what a control is for.

## DEEPEN — pre-verdict pass

Run 2026-10-27 (full text in
`~/workspace/lattice-packing-recon/DEEPEN.md`), after the
replay and the scalar gate. Alternatives considered: V-A
PARTIAL over the PARI version delta (rejected: one of
four legs, outputs matching the authors' references
exactly, the other legs and the scalar gate GP-free); GAP
on the n ≥ 17 improvement framing (rejected: the claim is
stated and labeled against numerical values, so certifying
the arithmetic against those printed values is the honest
grade, with the fence in the scope lines); one combined
verdict (rejected at the pick). Nothing in the pass moved
a verdict or added a finding.

## Receipt

- Replay host: this VM (2 vCPU), 2026-10-27. Driver:
  `verify/run.py` from the pin, `--jobs 4`, manifest
  sha256 validation and reference-log comparison on for
  every run (no `--no-reference`, no reference recording).
- Taylor: 83/83 PASS, exit 0, ~18 min. Bernstein: 83/83
  PASS, exit 0. PARI (gp 2.15.4, `-q -f` via the repo
  driver): 83/83 PASS, exit 0. Descartes (python-flint
  0.9.0): 41/41 even dimensions PASS, exit 0. The three
  latter runs chained in ~14 min total.
- Scalar gate (auditor's `scalar_gate.py`, exact Fraction
  arithmetic, own code): 83/83 certificates, density and
  Hermite claims both hold on every certificate,
  failures=0, exit 0, ~3.7 min. (First scalar run aborted
  after 34 OK / 0 FAIL on a Python int-to-str digit limit
  in the gate's own debug output; fixed and rerun clean —
  a harness bug, not a certificate event.)
- Cross-checks (auditor's `cross_checks.py`): certificate
  claims identical across certificates, manifest, and
  results.json on all 83; every `gain_percent_exact`
  recomputes from its row's decimals; improvement set ==
  [11–23, 25–40, 43–57, 62–75, 83–91] == 67 dimensions;
  four smallest gains n=62 (0.0117098%), n=91
  (0.0166780%), n=75 (0.0176948%), n=83 (0.0859357%),
  matching the README's exact fractions; all 69 rows of
  paper Table 1 match results.json (density exact,
  comparison to its printed rounding, gain to the table's
  rounding).
- Manifest integrity in-run: the driver validated every
  certificate's sha256 against the manifest before
  checking it (83/83, no mismatch); spot-pinned here,
  n016 certificate sha256
  `1d6f40a3ca0812758a696750a378dbbafb4dea3f97bdf43f114502aefa43f5b1`.

Closing verdict: PASS. The 32-gate verdict lock is
untouched (17 BREAK / 15 PASS).

**Verdict: PASS**
