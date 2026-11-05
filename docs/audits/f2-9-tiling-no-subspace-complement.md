# Audit note — F2^9 tiling with no subspace complement (arXiv:2610.42005, 2026-11-05)

**Claim artifact:** Samuel J. Ferguson and Joshua Iosevich, *Tiling
without a subspace complement: a sharp counterexample in dimension nine
over the field with two elements* (arXiv:2610.42005, submitted
2026-10-30; ID, title, and authors verified on the abs page
2026-11-05). Theorem (the explicit example): the 64-point set E in
F2^9 built from six 3-dimensional subspaces of F2^6 in eight layers
(Table 1, equations (2.3)-(2.4)) tiles by translation; its tiling
complements are exactly the 512 translates of T0 = C x {0}, none a
linear or affine subspace; its spectra are exactly the 64 sets
(C+a) x F2^3, one translation class each, eight containing zero in
each classification, every spectrum of Wiener norm 15/8. Headline
threshold: the subspace-complement property holds exactly for
d <= 8 (scoped out of this verdict, see Honest scope).
**Harvest item:** `f2-9-tiling-no-subspace-complement` (weekly
harvest 2026-11-02, recon Card 10, fragility 0).
**Campaign objects:** `incoming/f2-9-tiling-no-subspace-complement/`
(pinned PDF, e-print tarball, `paper.tex`, all five ancillary files,
`PIN.md`).

**Repo pin:** e-print tarball `arXiv-2610.42005-eprint.tar.gz`
`83a63ac99b5d342055c7d802f3e4063bf66cd2b5570c282ba73666b2bfd87579`;
paper PDF `71b9a592374017a13b8ed16dc8e27c7de254b52df1a344f132ec97450d1e2f97`;
`anc/example.json`
`6c98b0834efb902768b5d093770558ebbbb8246017779c6032815d7b2f50e60f`.
Full pin table in `PIN.md`
(`01d6df2093f35842f36f08672e3dcffc4452d4e2815596c35af9c21bc19aceca`).

**Intake discrepancy:** the harvest sweep recorded 15 ancillary
files (`README.md`, `verify_tilings.py`,
`verify_no_subspace_complement.py`, plus 10 more). The abs page and
the tarball both list exactly **5**: `README.txt`,
`comparison_data.json`, `example.json`, `verify_comparison.py`,
`verify_example.py`. No listed file is missing; the other 10 do not
exist and nothing was invented. Detail in `PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`computational-claim-gate` · run date `2026-11-05`. Independent gate
script drafted by `anthropic/claude-haiku-5.5` via OpenRouter
(effort medium, standing script-writing rule), adjudicated before
running (field-name fix `T0` -> `T`, tail rewrite onto the script's
own helpers, headline-count requires added; fixes listed in the
script header).

(M1/M2/M3 statement-fidelity checklist: N/A in one line — this is a
computational-replay gate, not a Lean formalization; the gated claim
is the explicit-example theorem exactly as stated in the paper. M4
is not N/A here because the headline threshold carries an external
input; it is inventoried under Honest scope.)

## Recon (Grandmaster's Methods pairing)

The authors' working method, from the paper itself: reduce
everything to one 8-point configuration C = {0, e1, ..., e6, j} in
H = F2^6, whose pair-sum set S (weights 0,1,2,5,6; |S| = 29) contains
no 3-dimensional subspace. Six 3-spaces of H with all nonzero points
in the complementary weight-3/4 set Z (|Z| = 35) are layered over
Y = F2^3 as (A0, A1, A2, D0, A3, D1, A0, D0), with every A_i meeting
every D_k only at 0. That forces the difference set to be exactly
E+E = ((Z u {0}) x {0}) u (H x (Y\{0})), |E+E| = 484, leaving only
28 possible nonzero differences for any complement. An edge/star
argument (Lemma Q) then classifies the 8-point sets Q with
Q+Q contained in S as translates of C, which settles complements
directly and, after a Fourier-support reduction, spectra as well.
No search is load-bearing in the paper's own proof of the
classifications; the shipped code checks the finite hypotheses and
exhausts the reduced finite problems.

## What was run

| Check | Result |
|---|---|
| Authors' `verify_example.py`, run exactly as shipped under the masked runner (`run-untrusted.sh`, never bare; author's instrument, not the verdict) | **exit 0, status PASS** — difference size 484, normalized complements 8, all complements 512, spectra 64 (8 normalized), Gram checks 65, Wiener norms {15/8}, 3-subspaces enumerated 788035, subspace complements 0. Also PASS under `python3 -O`. |
| Authors' `verify_comparison.py`, same route | **exit 0, status PASS** — both domains (theirs and Goyal's): 512 complements and 64 spectra each, identical complement and spectrum families, direction multiplicities [2,2,1,1,1,1] vs [2,1,1,1,1,1,1], no periodic complement, cross-fiber certificate checked. Also PASS under `-O`. |
| Independent gate, complements: direct enumeration of **all** C(28,7) = 1,184,040 normalized candidates (no clique search), difference criterion per candidate, then a full partition check (512 counts, all 1) on **every** resulting complement | **PASS** — normalized 8, distinct complements 512, partition passes 512/512, linear-subspace complements **0**, affine-subspace complements **0** |
| Independent gate, spectra (reduced problem): direct enumeration of all C(28,7) sets Q with Q+Q contained in S; naive-Walsh Gram check (W_E(l+l') = 0 for distinct l, l') on every candidate spectrum (C+a) x Y; Wiener norm by full 512-point Walsh transform | **PASS** — normalized Q 8, distinct Q translates 64, spectra passing Gram 64/64, Wiener norms {15/8} exactly |
| Independent gate, subspace census: independent RREF enumeration of **all** 3-dimensional subspaces of F2^9, count checked against the Gaussian binomial, each span tested against E+E | **PASS** — enumerated 788035 = ((511)(510)(508))/((7)(6)(4)), tiling subspaces **0** |
| Independent gate, Goyal cross-check vs `comparison_data.json`: same brute-force census on Goyal's E (transcribed by the authors from Goyal's repo snapshot `0df6158e...`) | **PASS** — \|D\| 484, normalized 8, complements 512, partition passes 512/512, complement family **identical** to the principal example's |
| Cross-route set equality: independent complement set vs authors' `verification_results.json` list; independent spectrum set vs authors' list | **PASS** — both sets equal element-for-element (512 and 64); all 512 complements are translates of T0 (one translation class) |
| Discrimination control: same partition instrument on a 6-dimensional subspace domain with the coordinate 3-subspace K as complement | **PASS** — K tiles (counts all 1); the instrument says yes to a subspace complement when one exists, so the 0 counts above are not vacuous |
| `example.json` vs the paper: layer bases and assignment read against Table 1 / equations (2.3)-(2.4) of `paper.tex`; E reconstructed from the bases by the authors' verifier | **PASS** — six bases and the (A0,A1,A2,D0,A3,D1,A0,D0) assignment match; reconstruction exact |

What the authors' verifiers actually check (read before running):
`verify_example.py` reconstructs E from the layer bases, verifies
C, S, Z, both union identities, the J-map annihilator identity, the
exact difference set, the T0 tiling by direct counts, the displayed
spectrum by exact integer Gram, an exhaustive clique enumeration of
normalized complements over the 28 allowed differences (expanded to
512 translates, each re-checked by direct tiling counts), the
reduced spectrum enumeration with Gram and Wiener checks on all 64,
the Walsh formula for C, and an RREF enumeration of all 788035
3-subspaces against the difference set. `verify_comparison.py`
repeats the domain, complement, and spectrum checks for both the
principal and Goyal domains and checks the cross-fiber certificate
and the direction-multiplicity invariant behind affine
inequivalence. Both are stdlib-only, deterministic, no cutoffs, no
network. Both declare the same proof dependency recorded below.

## Honest scope

- **Verdict covers the d=9 counterexample and its census only:**
  |E| = 64, tiling, exactly 512 complements, exactly 64 spectra,
  no subspace (indeed no affine) complement. The complement and
  subspace legs are fully computational in the independent route:
  the enumeration is over every normalized candidate, with no
  analytic reduction imported.
- **Spectrum completeness carries one analytic dependency, in both
  routes:** that every spectrum has the product form Q x F2^3 with
  Q+Q contained in S is the paper's Proposition (Fourier support
  contained in S x {0}, period lemma, annihilator union via the
  J map). The code exhausts the reduced problem that this argument
  leaves; all of its finite hypotheses (difference-set identity,
  annihilator union, W_C formula) were recomputed, and every one of
  the 64 resulting spectra was Gram-checked directly. This is the
  dependency the authors' own verifier declares in its output.
- **M4 fine-print inventory — the d <= 8 direction is external
  trust, cited not verified:** the positive direction for
  16-point tiles in dimension 8 rests on the authors' earlier
  theorem (their preprint's Theorem 1.1 / Lemma 6.5) via the
  classification of perfect binary codes of length 15. The paper
  gives elementary proofs for d <= 7 and for all other tile sizes
  in d = 8; only that one case is imported. If it fails: the d=9
  counterexample and census **survive**, the "precisely when
  d <= 8" threshold **weakens** to "fails for d >= 9, holds for
  d <= 7 and the replayed d=8 cases", and the product argument for
  d > 9 is unaffected. This audit did not replay the perfect-code
  classification and the verdict does not cover it.
- Further M4 items, all checked satisfiable by the instance itself:
  integer encoding `sum x_i 2^(i-1)`, addition = XOR (used
  consistently by paper, data, and both routes); spectrum defined
  via sign characters (the paper's example is spectral, so nothing
  here touches Fuglede's conjecture either way); Goyal data taken
  from the pinned snapshot named in `comparison_data.json` (the
  comparison leg inherits that transcription, which the authors'
  verifier checks internally; the principal verdict does not
  depend on it); no Lean formalization is under review (Goyal's
  separate Lean project was explicitly not replayed, as the
  ancillary README also states).
- Stdlib-only Python in both routes, no randomness, no seeds, no
  network after intake.

## Receipt

- `incoming/f2-9-tiling-no-subspace-complement/PIN.md`
  (`01d6df2093f35842f36f08672e3dcffc4452d4e2815596c35af9c21bc19aceca`)
- `results/f2_9_tiling_verify_meta.json`
  (`cf8393975102b2cf9d3f3b7842fa0c2c720782ef`)
- `results/f2_9_tiling_verify_out.txt` (independent gate, exit 0)
  (`2c0f6c8fbea7e7a6da5357cb3731bd6f89f478ca88b9c180d66e6e906b934849`)
- `results/f2_9_tiling_authors_out.txt` (both author verifiers,
  masked runner, exit 0)
  (`f8c1f9549be099aa722b2ded65c7f03e0f2fc573bc7d102ebc5ec594b2dd27c1`)
- `results/f2_9_tiling_authors_verification_results.json`
  (`15ce5e76d1f5a8fe1601d19b4d043620ee0e79fb4f7b9c880e4360e8e8873bcf`)
- `results/f2_9_tiling_authors_comparison_results.json`
  (`c805921c29fea57cb3d3ccead10fbe8a8bdbe14dc5bad8c36d3b9b3727a5297d`)
- Gate script: `scripts/gates/f2_9_tiling_independent.py`
  (`e7986eb02c6def29d70ceb2655bda90442271a9408e4d4d3d54acdb71933e524`)
- Declared verify commands (re-runnable):
  `run-untrusted.sh <workdir> python3 verify_example.py`;
  `run-untrusted.sh <workdir> python3 verify_comparison.py`;
  `python3 scripts/gates/f2_9_tiling_independent.py incoming/f2-9-tiling-no-subspace-complement/anc`

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone verify/audit
of a harvest claim. Standing on the evidence: **PASS** for the
d=9 counterexample and its census — two independent routes agree
to the element level on 512 complements and 64 spectra, and two
independent exhaustive enumerations agree that no subspace
complement exists. The d <= 8 boundary is cited, not verified, and
is outside this verdict.
