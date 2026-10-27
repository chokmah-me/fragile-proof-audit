# Audit note — Brualdi–Solheid completion (Stevanović, arXiv:2610.34905)

**Claim artifact:** Dragan Stevanović, *The maximum
spectral radius of connected graphs with prescribed order
and size* (arXiv:2610.34905v1, 2026-10-26): completes the
Brualdi–Solheid (1986) classification for every feasible
(n, e) — the extremal connected graph is the dense
candidate D_{n,e} or the star candidate V_{n,e}, no other
graph is extremal even at ties, and in the range n ≤ e+1
(where V_{n,e} does not exist) D_{n,e} alone wins. The
final D-versus-V comparison is Damnjanović's Propositions
4.1–4.2, cited and not reproved. The machine-carried part
is a set of exact polynomial and Sturm certificates for
the three comparison families (J), (K1), (K2) and the
virtual-star inequality, shipped as the arXiv ancillary
archive (master v35).
**Harvest item:** fresh harvest 2026-10-27
(`incoming/harvests/2026-10-27.md`, CLAIM
maximum-spectral-radius-connected-graphs-order-size,
recon fragility 3, third in the ranked queue, issue #12);
picked at the user's tap 2026-10-27.
**Campaign objects:** `incoming/brualdi-solheid-spectral-radius/PIN.md`.
**Pinned sources:** paper PDF sha256
`eb8c8dd628e619cec0f964ff711c32e371c3b0224b7dc53c22071860a7c874e4`;
arXiv source tarball (manuscript + ancillary) sha256
`e8562ecf485e8a59cd1a3e43fcc339daec0d64bd13e9896cd15118e0c9e1ab45`;
all 43 ancillary files plus the manuscript verified
against the archive's own `anc/SHA256SUMS.txt` (43/43).
There is no separate code repository; the reserved
Zenodo DOI 10.5281/zenodo.23650385 is stated unpublished,
so the arXiv ancillary is the only public copy. Evidence
in `~/workspace/brualdi-solheid-recon/` (`EVIDENCE.md`,
`my_checks.py`, `DEEPEN.md`, run logs `run-*.log`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-27` · harness pin via
`scripts/harness_pin.py`. Recon ran Grandmaster's Methods
(the standing harvest pairing: the paper's dependency
map, the proof-to-code map, and the archive README's
stated boundaries read before anything was run); the
pre-verdict deepening was a DEEPEN challenge pass (below).

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-27T22:58:13Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## Verdicts

- **V-A (certificate suite replay): PASS.** The archive's
  complete fast Python runner exits 0 with its documented
  marker, and its output reproduces the authors' supplied
  complete run log line for line (0 differing lines after
  timing normalization): analytic identities, templates,
  the omega transcription check, (K2), (J), (K1) region
  and split certificates (all 21 interior and all 21
  strict-face (MA) polynomials), the virtual-star
  certificate (four cones; 1,766 exact Sturm exclusions
  for 4 ≤ e ≤ 1769), and the three exact ties all pass.
- **V-B (independent spot recomputation): PASS.** The
  auditor's own code, built from the paper's definitions:
  the three ties verify exactly (ρ(D) = ρ(V) = 9, 8, 9 at
  (n, e) = (80, 6), (60, 10), (68, 21), from equitable
  quotient matrices constructed for the purpose), ω_e at
  those e equals 80, 60, 68 by an exact gcd check against
  eqs. (1)–(2), and 7 of the 1,766 virtual-star Sturm
  exclusions (e = 4, 5, 17, 100, 500, 1000, 1769) re-verify
  with an auditor-written Sturm implementation (0 roots
  in the excluded interval, positive endpoint value).
- **Scope (not a GAP in the audited claim):** the
  certificates are the machine-carried leg of the paper,
  exactly as its dependency map draws it. The Bellman
  induction, dense-core domination, the compression and
  strict-exclusion arguments, and Damnjanović's
  Propositions 4.1–4.2 are analytic (the last is cited
  published work), read for M1–M4 and not reproved; the
  theorem as a whole is not machine-checked, and this
  note does not claim it is. The verdict lock is not
  touched.

## M1 — statement fidelity

The proof-to-code map's obligation table matches the
paper's Section 6 and Appendix A boundaries line by line:
each certificate script is tied to the (J), (K1), (K2), or
virtual-star obligation it discharges, and the rows the
map marks analytic (Bellman transfer identities are
checked as formulas, the recursion itself is analytic;
first-part bound and strict exclusion "no new script
obligation"; Damnjanović row "transcription and
illustrations, not a proof of Damnjanović's
propositions") are the same rows the paper's dependency
table marks analytic or cited. The threshold objects in
the code are the paper's: Ψ_e and ω_e of eqs. (1)–(2)
(cross-checked by the archive's own transcription check
and by the auditor's independent transcription in V-B,
where the e=6 case factors by hand as
Ψ_6 = 24x(x−9)(x+1), giving ψ = 9 and ω_6 = 80 exactly),
and the walk-function numerator/denominator pair
(nR, DenR) is the paper's W_{R_e} for R_e = K_{k+1} minus
a K_{1,f} star, the same graph as the paper's definition
(K_k plus a vertex joined to t = k−f clique vertices).

## M2 — what the certificates establish

Given the analytic frame (threshold reduction of
Brualdi–Solheid, the Bellman recursion on cores, dense-
core domination, the fractional complete-split bound),
the remaining parameter-uniform obligations are sign and
root-exclusion statements about explicit rational
polynomials. The certificates discharge them exactly:
positive-coefficient cones for the uniform ranges
((K1)(a), (K1)(MC), (K1)(MA) interior and strict face,
virtual-star k ≥ 60), rational Sturm exclusions for the
finite ranges (virtual-star 4 ≤ e ≤ 1769, the ten
(J) derivative-norm checks), exact small-case checks
(38 in (J)), and rational identities throughout. No
numerical sampling is used to deduce an all-parameter
statement; the exploratory scripts are explicitly
diagnostic and are not run by the proof runners.

## M3 — credit honesty

The claim is Stevanović's (sole author). Damnjanović's
contribution is credited in the paper's abstract, its
dependency map, and the archive README as the source of
the final comparison (Propositions 4.1–4.2 of [7]) and of
the prior resolution for 4 ≤ e ≤ 130; this note follows
that attribution. The Python and Sage legs are described
by the archive itself as two implementations of one
certificate design, "not separate mathematical proofs";
no new full Sage log exists for v35 (SageMath was absent
from the packaging environment), and the Sage notebook in
the archive is labeled historical (SageMath 10.9, previous
release). This note credits one replayed implementation,
not two.

## M4 — fine-print assumption inventory

- `templates_check.py` imports numpy, which the
  archive's `requirements.txt` does not declare (it pins
  only sympy==1.14.0 and mpmath==1.3.0). The first replay
  attempt died on the import in seconds; with numpy
  2.5.4 installed, the suite passes in full. An
  install-instruction defect in the archive, recorded
  here; it does not touch any certificate.
- The SymPy alternative runner (`run_proof_only.sh`,
  designated by the README as an alternative construction
  of the same obligations) was run as corroboration:
  scripts 1–8 completed (including the full virtual-star
  certificate), and its strict-face cross-check passed
  the Bernstein identity recheck and faces B_0, B_1, B_2
  (3 of 21) before two VM reboots killed successive
  attempts; the script is ~2h of symbolic expansion and
  does not fit this VM's ~2h reboot cycle in one process.
  The strict-face obligation itself is discharged in
  full by the pure-Python implementation inside the
  completed fast runner (all 21 faces, RESULT: PASS
  strict (MA) on the face t = k−1). The SymPy strict-face
  tally is therefore reported as partial corroboration,
  not as a suite result.
- Environment deltas from the stated setup: Python
  3.12.3 here vs 3.13.5 stated; SymPy and mpmath exact
  pins. All outputs match the supplied log, so the delta
  is immaterial to the replay.
- The reserved Zenodo deposit (10.5281/zenodo.23650385)
  is unpublished at audit time; if it later appears with
  different bytes, this note's pins are the arXiv ones.
- The (K2) family is "mostly analytic" per the paper's
  own table; its script checks rational identities and
  exceptional cases only. Counted as such in V-A.

## DEEPEN — pre-verdict pass

Run 2026-10-27 (full text in
`~/workspace/brualdi-solheid-recon/DEEPEN.md`), after the
replay and the auditor's checks. Alternatives considered:
V-A PARTIAL until all 21 SymPy strict faces land
(rejected: the obligation is discharged by the completed
proof-complete runner; the SymPy script is the archive's
own designated alternative construction of it, and its
3 landed faces pass), PASS_WITH_GAPS over the analytic
remainder (rejected: the remainder is the paper's stated
design, with the comparison leg cited published work; the
harvest pattern fences paper-math remainders in the scope
lines), BREAK over the undeclared numpy dependency
(rejected: an install defect, repaired by one package,
after which every output matches the authors' log).
Nothing in the pass moved a verdict.

## Receipt

- Replay host: this VM (2 vCPU), 2026-10-27. Evidence
  index: `~/workspace/brualdi-solheid-recon/EVIDENCE.md`
  (sha256 of every run log below). Package
  integrity first: `sha256sum -c SHA256SUMS.txt` from
  `anc/`, 43/43 OK.
- Attempt 1 of the fast runner died in ~6 s:
  `ModuleNotFoundError: numpy` in templates_check.py
  (see M4). With numpy 2.5.4 added to the venv (SymPy
  1.14.0, mpmath 1.3.0 per requirements), attempt 2:
  `sh run_proof_only_fast.sh`, exit 0, 17m16s, final line
  `PASS: all v35 Python exact checks (pure-Python strict
  boundary)`. Diff against the supplied
  `documentation/logs/python_v35_complete_fast.log`
  (supplied exit file: 0): 0 differing lines after
  normalizing per-line timing annotations.
- SymPy runner `sh run_proof_only.sh`: scripts 1–8
  completed in the first attempt (analytic identities
  through vstar, RESULT (V*) present); strict-face
  cross-check progress B_0, B_1, B_2 OK plus the Bernstein
  identity recheck across two attempts, each killed by
  a runtime restart at ~20 min; reported as partial
  corroboration per M4, not rerun to completion.
- Auditor's checks (`my_checks.py`, exit 0): ties and
  omega per V-B (first version of the omega test wrongly
  required the identity at every root of Ψ_e rather than
  the largest; corrected to a gcd-at-the-largest-root
  test and rerun clean — an auditor bug, recorded here);
  own-Sturm vstar sample e ∈ {4, 5, 17, 100, 500, 1000,
  1769}: 0 roots in (ell, hi] and numV(hi) > 0 each time,
  with ell and hi recomputed by the auditor's own
  bisection/Sturm code.

Closing verdict: PASS. The 32-gate verdict lock is
untouched (17 BREAK / 15 PASS).

**Verdict: PASS**
