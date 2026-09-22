# Workplan — FragileProofAudit

**Operator:** dyb / Chokmah LLC  
**Repo:** private — https://github.com/chokmah-me/fragile-proof-audit  
**Checkpoint:** 2026-09-21 — Track D#8 **`salez_youssef_logsobolev` gated +
controlled, verdict BREAK**. Per this session's own standing lesson (NCI's
corpus entry claimed a gate that turned out fabricated), fetched and read
the real paper first (Münch, Leipzig University, arXiv:2504.08055,
`incoming/salez-youssef-munch-2504.08055.pdf`, live-checked via WebFetch
before download) — this time the corpus doc's description held up: Münch
refutes the Salez-Youssef conjecture (`α_LSI ≥ c·K/log(d)` under an Ollivier
curvature lower bound `K`, for a universal `c`) with an explicit birth-death
chain family on `{1,...,3n}` with exact rational transition rates,
`κ ≥ 1/(4n²)` everywhere, and a capacitary upper bound on `α_LSI` that decays
like `1/(n³ log n)` — one power of `n` faster than `K/log d ~ 1/(n² log n)`,
so no fixed `c` survives `n → ∞`. Gate (`scripts/gates/salez_youssef_logsobolev.py`)
reproduces this exactly: `fractions.Fraction` transition probabilities,
`mpmath` 80-digit stationary distribution and capacity (magnitudes down to
`~1e-10937` at `n=3000`, far outside float64), exact-rational confirmation
that the curvature bound is met with **equality** at every `n` tested, and
confirmation that the ratio `R(n)/[K/log d]` is strictly decreasing across
seven `n` values spanning three orders of magnitude, dropping below `0.01` at
`n=3000` — the actual asymptotic mechanism, not a single snapshot.
Discrimination control (`scripts/controls/salez_youssef_break_control.py`)
verdict **NO FALSE POSITIVE**: ten transcription spot-checks against the
pinned PDF's Section 2 formulas all match, and — using the paper's own named
"this case satisfies the conjecture" example (constant curvature + log-concave
invariant measure) — the same ratio diagnostic correctly shows the ratio
*growing* (not vanishing) as `n` grows, confirming the machinery discriminates
rather than always finding a "violation." Registered in `scripts/gates/check.py`;
**verdict lock now 15/15**; no Lean scaffold (mathlib has no Ollivier
curvature / isocapacitary / log-Sobolev coverage — the corpus doc's own
ranking table already correctly flagged this as low tractability). Evidence:
`docs/blueprint/salez-youssef-logsobolev.md`. This closes out the corpus
doc's ranking table (all 8 rows now dispositioned: 6 BREAK, 1 SKIPPED/no
finite gate, this one BREAK) — **Track D has no further corpus-doc-ranked
candidates**; next session should check `corpus/fragile-formalizable-proofs-report.md`
and `corpus/historical-collapses-gemini-export.md` for unexploited targets,
or return to the Lamé/cyclotomic Lean thread (**Resume (A)** below).

Prior Track D checkpoint (2026-09-21): Track D#7 **NCI Conjecture
(arXiv:2608.27416) SKIPPED, no finite gate** (not a BREAK/PASS — a scope
decision). Went to gate the corpus doc's next-ranked target (NCI has a full
"Target Identifier" block, unlike Chung-Graham's ghost entry, so it looked
trustworthy). Fetched and read the real paper (Wilhelm, TU Ilmenau,
`incoming/nci-wilhelm-2608.27416.pdf`, live-checked via WebFetch first) and
found the corpus doc's claimed "Verifiable Gate / Counterexample: Python
script validating the non-existence of admissible sets..." does not exist in
the source — **fabricated**, not merely corrupted-by-image-transcription
like the prior three targets. The actual refutation (Theorem 8.1 / Corollary
8.2) is a first-moment (probabilistic-existence) argument: Lemma 7.2 proves
*some* marking `m` on `F_p²` (`p ≥ 10^5`) makes the lattice `P_{p,m}` admit
no winning dot-algebra tree, via a union-bound expectation `E_p < 1`, but
**exhibits no marking** — confirmed by the paper's own §9 Open Problems item
1, which states verbatim that even a small-`p` explicit counterexample is
unsolved. The only numerically checkable content in the paper (the
double-counting identities in `(7.1)`) is true of every finite point set
unconditionally — testing it would be exactly the check-that-cannot-fail
ceremony Governing discipline #7 forbids. No script to write that would
*reproduce* the paper's witness, because it has none. Filed under **Do not
reopen** alongside Joshi/IUT, Collatz, Goldbach "monitors" — no finite gate.
Evidence: `docs/blueprint/nci-conjecture.md`.

Prior Track D checkpoint (2026-09-21): Track D#6 **`chung_graham_spiro` gated +
controlled, verdict BREAK**. Cross-checked the "Chung-Graham Gap-Set" row
against the corpus doc's own Section headers first, per the resume-note flag
— found it is a **ghost entry**: Sections 1-3 cover exactly seven other
targets, each with a full "Target Identifier" block and a Works Cited
number; Chung-Graham has neither, appearing only in the final ranking table
with no arXiv ID, no claimed theorem, no citation, and an incomplete name
(the real conjecture is Chung-Graham-**Spiro**, J. Number Theory 210
(2020)). Located the actual refutation by live web search:
Mohsen Aliabadi (2026), arXiv:2609.04473, `9 ∈ U_4 \ D_4` at `l=4`
(`incoming/chung-graham-spiro-2609.04473.pdf`). Gate reproduces the witness
by two independent paths: a direct translation of the paper's own `(a,b,t)`
representation algorithm (Path A, validated by exact transcription match
against two independently-sized literal lists printed in the PDF, `D∩[2,17]`
and the full 54-element `D∩[2,113]`), and a from-scratch simulation of the
original slow-Fibonacci-walk definition (Path B, agrees with Path A on all
192 unambiguous integers checked in `[2,220]`; 27 excluded as genuine ties
this campaign's naive brute force can't resolve without the original 2020
paper's tie-breaking rule — reported openly, not hidden). Caught and fixed a
category-error bug during development (conflating "is 9 itself an
up-integer" with "is 9 a gap value in `U_4`" — different questions).
Discrimination control (`scripts/controls/chung_graham_break_control.py`)
verdict **NO FALSE POSITIVE**: the same machinery correctly reproduces the
paper's own *true* claims at `l=1,2`, and correctly finds no discrepancy at
the paper's own flagged-open `l=3` case. Registered in
`scripts/gates/check.py`; **verdict lock now 14/14**; no Lean scaffold yet.
Evidence: `docs/blueprint/chung-graham-spiro.md`.

Prior Track D checkpoint (2026-09-21): Track D#5 **`thakur_carlitz` gated + controlled,
verdict BREAK**. Thakur's 2015 conjecture (every Carlitz-Wieferich prime of
`F_q[T]` in odd characteristic has degree divisible by the characteristic
`p`) refuted at an explicit degree-5 prime over `F_{19^3}`
(`incoming/thakur-carlitz-2607.15305.pdf`, arXiv:2607.15305, D. Niedbala
Giraudin) — **another corpus-doc narrative unusable** (the explicit quintic
and field data were behind untranscribed inline images), so the gate was
built by fetching and reading the actual paper. A from-scratch pure-Python
finite-field engine (`scripts/harness/finite_field.py` — no
`galois`/Sage/PARI on this laptop) builds `F_{19^3}[T]/(P)`, confirms `P`
irreducible via the standard distinct-degree test, and confirms the
c-Wieferich condition `M_5(theta)=0` via two independently coded formulas
(the paper's nested form and the raw alternating-sum definition) that agree.
Discrimination control (`scripts/controls/thakur_break_control.py`) verdict
**NO FALSE POSITIVE**: the same engine correctly identifies two known
c-Wieferich primes at different `(degree, characteristic)` pairs
(`T^5+4T+1`/F_5, Bamunoba-Bergström's `T^6+T^4+T^3+T^2+2T+2`/F_3) as positive
controls, and reports 0 hits among 10 random irreducible quintics over F_19
as negative controls. Registered in `scripts/gates/check.py`; **verdict lock
now 13/13**; no Lean scaffold yet (likely blocked on mathlib Carlitz-module
coverage). Evidence: `docs/blueprint/thakur-carlitz.md`.

Prior Track D checkpoint (2026-09-21): Track D#4 **`tang_zhang_schatten` gated +
controlled, verdict BREAK**. The Tang-Zhang Schatten-norm conjecture
(a single formula `C^TZ_{p,m}` claimed sharp for all finite `p>1`) refuted
at `p=3/2, m=2` via a real PDF pin (`incoming/tang-zhang-2608.15558.pdf`,
arXiv:2608.15558) — **this target's corpus-doc narrative was unusable**
(numeric constants lost behind untranscribed inline-image placeholders),
so the gate was built by fetching and reading the actual paper instead.
Two independent computation paths (exact-`Fraction` Gram-matrix algebra,
and mpmath 60-digit direct matrix construction) agree to `1e-40` and both
reproduce the paper's exact witness `R ≈ 1.0364136587048904 > 207/200 >
C^TZ_{3/2,2} ≈ 1.0346539518514341`. Discrimination control
(`scripts/controls/tang_zhang_break_control.py`) verdict **NO FALSE
POSITIVE**: 5 000 random rank-one pairs at the same `(p,m)` show only
~1% exceed the conjectured constant (witness is near the true extremum,
not typical), and the same formula independently reduces to Tang-Zhang's
own *proven* `p=2` closed form for several `m`. Registered in
`scripts/gates/check.py`; **verdict lock now 12/12**; no Lean scaffold
yet (likely blocked on mathlib Schatten-norm coverage). Evidence:
`docs/blueprint/tang-zhang-schatten.md`.

Prior Track D checkpoint (2026-09-21): Track D#3 **`sarkozy_sum_product`
gated + controlled, verdict BREAK**. Sarkozy's mod-`p` sum-product
conjecture (`|A| >= c*p` implies `1 in A+A union A*A`) refuted
independently: exhaustive search over `Z/pZ` for `p in
{5,7,11,13,17,19}` (CI, `--deep` adds `23`) finds an explicit
size-`(p-1)/2` witness avoiding `1` in both sumset and productset for
**every** tested prime, without transcribing Tang's (arXiv:2603.29992)
actual construction — the corpus doc's own description of it is
internally inconsistent. Discrimination control
(`scripts/controls/sarkozy_break_control.py`) verdict **NO FALSE
POSITIVE**, with one honest caveat: item-4 independent corroboration
(plain quadratic residues as an unrelated witness family) came back
negative at every tested prime. Evidence:
`docs/blueprint/sarkozy-sum-product.md`.

Prior checkpoint (2026-09-20): Phase 3(i)#+b **`Gal(ℚ(ζ₂₃)/ℚ)` cyclic of order
22, VERIFIED** (`CyclotomicGalois.lean`, axiom-clean, 150 declarations). The
attempt to go further and pin the decomposition-group cardinality (`Nat.card
(stabilizer G P) = 11` via `Ideal.card_stabilizer_eq`) hit a genuine mathlib
instance-diamond wall — see **Blocked** below; not forced through. Phase
3(i)#+a **norm pin VERIFIED**: any prime of `𝓞(ℚ(ζ₂₃))` above `2` has `absNorm
= 2^11`, not `2` (`CyclotomicPrimeTwo.lean`). Phase 3(i)# `OKNeg23 ↪
𝓞(ℚ(ζ₂₃))` VERIFIED (ring embedding, injective, via `embedToRingOfIntegers`);
Phase 3(i)#a Gauss-sum embed `gauss23² = −23` in `ℚ(ζ₂₃)` VERIFIED; Phase
3(i)+++++ concrete ideal `(2, θ)` with `absNorm = 2` non-principal VERIFIED;
Phase 3(i)++++ `IsDedekindDomain OKNeg23` VERIFIED; Phase 2(d) odd-zeta
202601.1609 RE-BROKEN at Lemma 5.1; **audit-integrity pass landed 2026-09-20**
— verdict lock + discrimination controls; **all eight verdicts unchanged**,
but what several of them *mean* changed (see **Track B**). **Track B item 1
landed same day** — `lame_ideal_neg23` discrimination control built, NO FALSE
POSITIVE. **Track D opened 2026-09-21** — ingested
`corpus/live-fragile-proofs-2024-2026.md` (7 arXiv-verified candidate
targets from an AI deep-research export; distinct from the Gemini export,
all 7 IDs live-checked). Two targets gated + controlled same day:
`cohen_subadditivity` (BREAK) and `baste_domination` (BREAK, closed both
bounds independently including an exact branch-and-bound search this
campaign wrote for γ(G)≥16). A third, `sarkozy_sum_product`, landed
2026-09-21 (BREAK). A fourth, `tang_zhang_schatten`, also landed
2026-09-21 (BREAK, first Track D target to need a real PDF fetch since the
corpus doc's own text was unusable for it). A fifth, `thakur_carlitz`,
landed 2026-09-21 (BREAK, second Track D target needing a real PDF fetch —
same image-corruption failure mode as Tang-Zhang). A sixth,
`chung_graham_spiro`, also landed 2026-09-21 (BREAK) — worst provenance
failure yet: the corpus doc has no body section for this target at all (a
table-only ghost entry, no arXiv ID, incomplete name), so the refutation was
located by live web search instead of any corpus-doc lead. A seventh
candidate, NCI, was SKIPPED (no finite gate) the same day — its corpus entry
looked complete but claimed a "Verifiable Gate" fabricated relative to the
real paper, which is a pure first-moment existence proof with no witness
(see `docs/blueprint/nci-conjecture.md`). An eighth, `salez_youssef_logsobolev`,
landed 2026-09-21 (BREAK) — this one's corpus description held up against the
real paper. All seven landed BREAKs registered in `scripts/gates/check.py`;
none has a Lean scaffold yet (mathlib coverage gaps: cyclic-number/graph
theory targets are tractable in principle but not attempted; Ollivier
curvature/log-Sobolev has no mathlib coverage at all).

**Resume at any of:** *(A)* the decomposition-group identification needed to
finish the pushed-forward non-principal ideal in `𝓞(ℚ(ζ₂₃))` — `Gal(ℚ(ζ₂₃)/ℚ)`
is now pinned cyclic of order 22, but `Ideal.card_stabilizer_eq` is blocked on
an `Algebra ℤ Cyclotomic23` / `Algebra ℚ Cyclotomic23` instance diamond (see
**Blocked**), or proved h⁺, or per-claim Agoh–Giuga — *(B)* the 2(d) write-up
decision (Track B item 2) — *(C)* Track D: Cohen, Baste, Sárközy, Tang-Zhang, Thakur, Chung-Graham-Spiro,
and Salez-Youssef are now all gated + controlled (BREAK ×7); NCI is SKIPPED
(no finite gate — its "Target Identifier" block existed, unlike Chung-Graham's,
but its "Verifiable Gate" claim turned out to be fabricated, not just
image-corrupted). The corpus doc's own 8-row ranking table is now fully
dispositioned — no further candidates there. Next Track D session should
open `corpus/fragile-formalizable-proofs-report.md` and
`corpus/historical-collapses-gemini-export.md` for unexploited targets (apply
the same "fetch and read the real paper before trusting any gate claim"
discipline learned this session), or pivot back to *(A)*.
`docs/blueprint/cohen-subadditivity.md`, `docs/blueprint/baste-domination.md`,
`docs/blueprint/sarkozy-sum-product.md`, `docs/blueprint/tang-zhang-schatten.md`,
`docs/blueprint/thakur-carlitz.md`, `docs/blueprint/chung-graham-spiro.md`,
`docs/blueprint/nci-conjecture.md`, and `docs/blueprint/salez-youssef-logsobolev.md`
are the templates to follow — the middle four also demonstrate the fallback
when the corpus doc's own text is corrupted, entirely missing, or (NCI)
fabricated for a target: fetch and read the real paper instead (see their
**Local PDF pinned** lines; chung-graham-spiro's documents cross-checking the
corpus doc's Section headers before trusting a table row; nci-conjecture's
documents recognizing a claimed gate that doesn't exist in the source at
all, as opposed to merely being image-corrupted).

(2(d) write-up was declined — **worth revisiting**: after the false-positive
control it is the campaign's only sendable artifact. See Track B item 2.)

**Pin:** Lean / mathlib `v4.32.2` (same as `catalan-sun-lean`)  
**Compute:** laptop · Python (`mpmath`, `Fraction`, SymPy) · no Sage/Magma/cluster  
**Habit:** commit each phase when it lands (do not leave a dirty tree for the next session)

This file is the **executable resume checklist**. Full harvest ranking lives in
`corpus/fragile-formalizable-proofs-report.md`; identifier truth in
`corpus/harvest-addendum-analysis.md`.

---

## Resume here — after Phase 3(i)#a Gauss-sum embed

**3(i) Lamé 1847:** **DONE through 3(i)#** —
gate \(h^-_{23}=3\); Lean Premise/QuadraticWitness/Maillet Bareiss;
quadratic ideal gate + `no_norm_two_equation`;
`IdealPrincipal` + **`IsDedekindDomain OKNeg23`** + concrete
`P2 = (2, θ)` with `absNorm P2 = 2` and `¬ IsPrincipal P2`;
**`CyclotomicEmbed`**: `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ`;
**`CyclotomicIdeal`**: `embedToRingOfIntegers : OKNeg23 →+* 𝓞 (CyclotomicField
23 ℚ)`, injective — `OKNeg23 ↪ 𝓞(ℚ(ζ₂₃))` as a ring embedding (θ ↦
`(1+gauss23)/2`, same minimal polynomial `X²−X+6`; integrality transported
via `Module.Finite ℤ OKNeg23` / `map_isIntegral_int`).
Evidence: `FragileProofAudit/Lame/`,
`scripts/gates/lame_h23.py`, `scripts/gates/lame_ideal_neg23.py`,
`docs/audits/lame-1847.md`.

**3(h) Agoh–Giuga kit:** **DONE** — Python oracle PASS + Lean `Criteria`/`Oracle`
(`oracle_seven`).

**3(i)#+a Norm pin (2026-09-20):** **DONE** — before attempting the pushforward,
pinned what the target norm has to be. `ord₂ mod 23 = 11` (`2^11 = 2048 ≡ 1`),
so mathlib's `IsCyclotomicExtension.Rat.inertiaDeg_eq_of_not_dvd` +
`Ideal.absNorm_eq_pow_inertiaDeg'` give: **any** prime of `𝓞(ℚ(ζ₂₃))` lying
over `(2)` has absolute norm `2^11 = 2048`, never `2`. Confirms in Lean the
suspicion already in this file: `Ideal.map embedToRingOfIntegers P2` cannot
land on a norm-2 ideal. Axiom-clean (`propext`/`Classical.choice`/
`Quot.sound` only). Evidence: `FragileProofAudit/Lame/CyclotomicPrimeTwo.lean`.

**3(i)#+b Cyclic Galois group (2026-09-20):** **DONE** —
`Gal(ℚ(ζ₂₃)/ℚ)` is cyclic of order 22. `Cyclotomic23/ℚ` is Galois
(`IsCyclotomicExtension.isGalois`); `cyclotomic 23 ℚ` is irreducible
(`Polynomial.cyclotomic.irreducible_rat`), giving
`IsCyclotomicExtension.autEquivPow : Gal(Cyclotomic23/ℚ) ≃* (ZMod 23)ˣ`;
`(ZMod 23)ˣ` is cyclic (`ZMod.isCyclic_units_prime`, 23 prime), and cyclicity
transports along the `MulEquiv` (`isCyclic_of_surjective`); order 22 via
`Nat.card (ZMod 23)ˣ = (23).totient = 22`. Axiom-clean, 150 declarations.
Evidence: `FragileProofAudit/Lame/CyclotomicGalois.lean`.

**Next options:**

1. **Pushed-forward non-principal ideal in `𝓞(ℚ(ζ₂₃))`** — now that
   `embedToRingOfIntegers` exists, the target norm is pinned at `2^11`, and
   `Gal(ℚ(ζ₂₃)/ℚ)` is confirmed cyclic of order 22, the remaining gap is
   identification, not arithmetic: show `Ideal.map embedToRingOfIntegers P2`
   is *prime* (not just contained in one) and equals *the* prime above `(2)`
   fixed by `L23`. **Attempted 2026-09-20 and blocked** — see below. Informal
   argument stands: the decomposition group of a prime above 2 has order
   `ef = 11·1 = 11`, the unique order-11 subgroup of the cyclic group of
   order 22, whose fixed field is exactly `L23`; formalizing this needs a
   decomposition-group / fixed-field correspondence connecting `OKNeg23`'s
   coordinate presentation to the actual subfield fixed by that subgroup; or
   sidestep norms entirely and prove \(h^+_{23}=1\) directly.
2. **Per-claim Agoh–Giuga audit** — blueprint a concrete claimed proof against
   the kit; instantiate failing lemma at \(g=30\) or \(g=858\).
3. Optional: von Staudt–Clausen / Agoh–Bernoulli bridge (same kit, not blocking).

**Blocked (2026-09-20):** the decomposition-group cardinality step
(`Ideal.card_stabilizer_eq` from `Mathlib.NumberTheory.RamificationInertia.Galois`,
which would give `Nat.card (MulAction.stabilizer Gal(ℚ(ζ₂₃)/ℚ) P) = 11` for
`P` a prime over `(2)`) hit a genuine mathlib instance diamond, not a missing
lemma: `IsGaloisGroup.of_isFractionRing Gal(Cyclotomic23/ℚ) ℤ (𝓞 Cyclotomic23)
ℚ Cyclotomic23` needs `[IsScalarTower ℤ ℚ Cyclotomic23]`, which *is* available
standalone (`AddCommGroup.intIsScalarTower`, fully generic), but fails to
synthesize once `Algebra ℤ Cyclotomic23` has already been pinned to
`CyclotomicField.instAlgebra` (mathlib's `deriving instance Algebra A,
IsScalarTower A K for CyclotomicField n K` mechanism) while `Algebra ℚ
Cyclotomic23` gets independently pinned to `DivisionRing.toRatAlgebra` —
`trace.Meta.synthInstance` confirms the failure is exactly at
`IsScalarTower ℤ ℚ Cyclotomic23` after those two choices are locked in.
Forcing `Algebra ℚ Cyclotomic23 := CyclotomicField.algebra 23 ℚ` via `haveI`
did **not** fix it (still fails — the ambient ambiguity between the two
`Algebra ℚ` instances seems to be the actual cause, not merely which one is
picked). This is not a missing-lemma gap of the kind flagged in advance (the
group-theory "unique order-11 subgroup of a cyclic group of order 22" lemma
was never reached — the block is earlier, at the ring-theoretic instance
wiring for `IsGaloisGroup`). Not forced through; no file committed with a
`sorry`. A future session should either (a) hunt for the right
`letI`/`Algebra.compHom`-based override that makes all three of `Algebra ℤ
Cyclotomic23`, `Algebra ℚ Cyclotomic23`, `IsScalarTower ℤ ℚ Cyclotomic23`
mutually defeq-consistent for instance synthesis, or (b) sidestep
`Ideal.card_stabilizer_eq` entirely and go for `h^+_{23}=1` directly.

flt-regular as a lake dependency is separately blocked — upstream toolchain is
`leanprover/lean4:v4.34.*` while this campaign pins `v4.32.2` (match
`catalan-sun-lean`). Do not bump the pin casually.

Do **not** claim the Agoh–Giuga conjecture. Do **not** confuse Kummer-regular
(\(23\nmid h\)) with UFD (\(h=1\)). Do **not** claim Lean proved
`classNumber (CyclotomicField 23 ℚ) = 3` — Bareiss owns \(h^-\); \(h^+\) stays cited.

---

## Track B — audit integrity (the non-Lean thread)

**Landed 2026-09-20** — commits `f399b26`, `3f8a78f`, `73782e0`, `5752140`.

- **Verdict lock** (`scripts/gates/check.py`) — all eight gates pinned in
  `EXPECTED_VERDICT`; drift in *either* direction fails the run. Gates still
  exit 0 on a BREAK by design (a BREAK is a finding, not a build failure); the
  lock is what notices a flip. Changing a pin is a deliberate act and belongs
  in the same commit as the re-audit.
- **Discrimination control is now doctrine** — `docs/GATE-BEFORE-PROVE.md`
  protocol step 3, with a register of which gates require one.
- **`scripts/controls/`** — instruments, not gates: no campaign verdict, never
  registered in `check.py`.
- Forced UTF-8 on gate subprocess IO and runner stdio. `lame_h23` and
  `lame_ideal_neg23` had been exiting 1 under a cp1252 console *after* writing a
  correct PASS, making `verify.ps1` red for pure code-page reasons.

**Net result: no verdict changed.** All three PASSes and both BREAKs stand.

### What the audit altered

| target | change |
|---|---|
| **2(g) PDN1** | Real defect, in the *gate*. α=2 rested on 1 and 2 integers and α=3 was untested — **81 data points total**. Added a mod-arithmetic path (sparse Euler/Jacobi + Kronecker substitution) self-tested against the exact dense oracle. CI now **6 747** points reaching α=3 in ~7 s; `--deep` gives **33 746** with α=3 on all four families. All hold. |
| **2(e) ES** | PASS *reinterpreted*. Matched control: coverage carries **no** information — every perturbed congruence covers *more* primes than the real one — but `egyptian3` separates **100 % / exactly 0 %**. The gate certifies **Theorems 4 and 7** (the implication), not Conjecture 1 (the existential). The paper never claimed to prove ESC; its abstract conjectures the covering. |
| **2(f) RR** | `nmax` circularity tested directly: raising it by 3 never moves `Z`, and the largest *contributing* ‖n‖ is 4–6 against a cutoff of 11–14. Degree push — (3,8) 12→**22** (past Frobenius 13), (3,7) 15→26, (3,5) 24→34 — all MATCH. |
| **1(b) Suman** | False-positive control clear. The search has no discriminating power on its own; the verdict rests entirely on the `k = 0` endpoint, verified verbatim in the PDF, reinforced by (49) being stated with **no** mention of ζ(5), and matched to Chen et al. |
| **2(d) odd-zeta** | False-positive control clear, and **upgraded**: the BREAK is an **infimum**, not a sample. For λ ≥ 0.5 the minimum over the whole domain is at the boundary, `g = 1+q = e^λ` exactly (148.413 = e⁵ … 442414 = e¹³). The instrument is shown to discriminate — it *finds* admissible `q` for λ < 0.458. |
| **`es_cover` odd-k** | Had gated the verdict on five branches that are tautologies in `k`. Now gates the failable scope invariant (every hard residue ≡ 1 mod 8); failure is `ABORT_SCOPE`, not `BREAK`. |

### Resume here (Track B), in order

1. ~~`lame_ideal_neg23` discrimination control~~ — **DONE 2026-09-20**,
   `scripts/controls/lame_ideal_control.py`. Confirms the search finds real
   solutions (`32 → (±3, ±1)`, `24 → (±1, ±1)`, `4 → (±2, 0)`); reproduces
   `norm_equation_solutions` against a brute force at 10x `b_bound` for seven
   targets (no truncation); shows the parity filter accepts at target=32 (not
   just vacuously true at target=8). Verdict: NO FALSE POSITIVE. Not
   registered in `check.py` — instrument, not a gate, per doctrine.

2. **2(d) write-up decision — revisit.** After the false-positive control this
   is the campaign's **only sendable artifact**: a 2026 preprint with no
   published refutation, a BREAK that is now an infimum result, survivor of both
   a retraction cycle and a control. Contrast 1(b) — Chen et al.
   (arXiv:2411.16774v3) already published that objection, so it is internal
   calibration, not an output.

3. **ES corpus question — open.** Does the 100 %/0 % separation belong in
   `corpus/` as a *positive* finding about Lopez's Theorems 4 and 7, rather than
   filed as a non-event because nothing died? Partial evidence gathered:
   Theorem 4 is an **iff** with a real constructive proof (`4duv = p+u+v` ⟹
   `u = (p+v)/(4dv−1)`, natural iff `4dv−1 | p+v`), *not* a one-line identity —
   which makes the framing more defensible than assumed. **Theorem 7 not yet
   read.** Note the campaign has no slot for "verified, no defect found"
   outputs, so `corpus/` is selection-biased toward kills.

4. **Type G on the PASSes.** ES is **vacuous** — the paper claims no proof, so
   there is no argument to find a gap in. Real remaining targets: PDN1's
   induction and RR's Ore step. All three notes now say `Type G not attempted`.
   Scope before starting; a pass escalates, never force a kill.

5. **Operator-only deep runs** (not CI): `python scripts/gates/pdn1.py --deep`
   (~105 s, 33 746 points, α=3 everywhere); RR `(3,8)` beyond `N=22` (23 s at
   22, cost grows fast).

---

## Track C — historical Type F pins (not resume)

**Landed 2026-09-20** from the Gemini “historical collapses” export
(`corpus/historical-collapses-gemini-export.md`, trust: lead). These do
**not** change the resume line above and are **not** in `EXPECTED_VERDICT`.

| Pin | Clone SHA | What was run | Lock |
|---|---|---|---|
| Quantum Hedetniemi arXiv:2609.20690 | `95c0ac05e9b7ea50b827ec491661eed2ed0147b4` | author Python certificates PASS; `axiom_audit.py` 382 files, no `sorry`/`axiom`; kernel `UNKNOWN` (their Lean 4.19.0) | off |
| Borsuk-63 Grinsztajn | `cdcdbeac2e692b8641218c70ce9f414522e125e5` | `scripts/gates/borsuk63.py` wraps author `verify_borsuk63.py` | off |

Do **not** promote either into the eight-gate lock. Do **not** bump the
campaign Lean pin to 4.19.0 to compile Zeiss. Operator commands:

```powershell
python scripts/gates/borsuk63.py
python incoming/quantum-hedetniemi/numerics/check_base_graph.py
python scripts/forge/axiom_audit.py incoming/quantum-hedetniemi --json-out results/hedetniemi_q_audit_meta.json
```

---

## Commands on resume

```powershell
cd C:\Users\Elke Shayna\Documents\00Dev\fragile-proof-audit
git pull
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

Expect: harness 6/6, prior gates as before, `giuga_oracle` PASS, `lame_h23`
PASS, `lame_ideal_neg23` PASS, `cohen_subadditivity` BREAK,
`baste_domination` BREAK, `sarkozy_sum_product` BREAK,
`tang_zhang_schatten` BREAK, `thakur_carlitz` BREAK, `chung_graham_spiro`
BREAK, `salez_youssef_logsobolev` BREAK, **verdict lock 15/15 ok**, lake + forge VERIFIED
(includes `Lame.IdealWitness` + `Lame.IdealPrincipal` + `Lame.DedekindField` +
`Lame.IdealNormTwo` + `Lame.CyclotomicEmbed` + `Lame.CyclotomicIdeal` +
`Lame.CyclotomicPrimeTwo` + `Lame.CyclotomicGalois`; axiom-clean, 150
declarations).

Controls are **not** run by `verify.ps1` — they are operator instruments:

```powershell
python scripts/controls/es_cover_control.py 10000   # ~3 s
python scripts/controls/break_control.py            # ~7 s
python scripts/controls/lame_ideal_control.py       # <1 s
python scripts/gates/borsuk63.py                    # Track C; not in the 8-lock
```

Both exit 0. `break_control` needs the pinned PDFs under `incoming/`
(gitignored); without them its transcription and corroboration checks report
`unavailable` rather than passing silently.

**3(i) landing:** gate `76521e6`; Premise/QuadraticWitness `9ae01da`; Maillet
Bareiss `7a8da40`; IdealWitness `9e7d8f2`; IdealPrincipal `4444ea9`;
Dedekind `c36aa9a`; IdealNormTwo `bc2bd06`; CyclotomicEmbed follows.

---

## Do not reopen

| Item | Why |
|---|---|
| Invent a Chen beta kernel for 202601.1609 | Gate of a formula the paper did not write |
| Treat `g(α)<0` as `‖Λ_m‖→0` | Different object |
| Fall back to Kim because odd-zeta failed | 2(d) BREAK is a valid outcome |
| Full Kim Tendsto Lean | Compressed appendix only |
| Claude’s Suman snippet `1 ≤ k ≤ 0` | Empty range; real range is `0 ≤ k ≤ d_n` |
| Jana–Karmakar | Audited clean (630+96); Pochhammer negative-index is mandatory |
| `catalan-sun-lean` | Own reference campaign; reuse pin, do not re-attack |
| Force kills on 2(e)–2(g) PASSes | Pass escalates; Ore/notebooks are capability-limited, not BREAKs |
| Joshi/IUT, Collatz, Goldbach “monitors” | No finite gate |
| NCI Conjecture (arXiv:2608.27416) | No finite gate — refutation is a first-moment existence argument with no exhibited witness, confirmed unsolved by the author's own §9 Open Problems; corpus doc's "Verifiable Gate" claim is fabricated, see `docs/blueprint/nci-conjecture.md` |
| Fake Mathematica / RISC / Magma replays | Prefer blocked notes over invented cofactors |
| Unmatched negative controls | The first ES control varied the congruence **and** the search breadth at once; its “weakly discriminating” answer had to be withdrawn. Prove search equivalence before concluding |
| Suman base case as a “false positive” | The paper does derive `a=2b`/`a=b` itself, but (49) is stated with **no** ζ(5), so the base case owes an *algebraic* claim. Chen et al. concur. Settled 2026-09-20 |
| Re-promoting `es_cover`’s odd-k identity branches | Tautologies in `k`; documentation only, never a verdict |
| Discrimination controls on `rr_qexpand` / `pdn1` / `giuga_oracle` / `lame_h23` | Ceremony — exact equality or divisibility; see the register in `GATE-BEFORE-PROVE.md` |

---

## Done (do not redo)

| Phase | Outcome | Evidence |
|---|---|---|
| **0** | Pin, harness, CI, forge | `README.md`, `results/lean_verify_meta.json` |
| **1(a)** γ | **G** — statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ | `docs/audits/gamma-aejonanonymous.md` |
| **1(b)** Suman ζ(5) | **B** — Eq. (48) at `n=1` has `a=2b`, `a=b` under `0 ≤ k ≤ d_1` | `docs/audits/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean` |
| **2(d)** odd-zeta 202601.1609 | **BREAK (corrected 2026-09-20)** — Lemma 5.1 never supplies admissible `(q,α,δ)`: `g(α*)>0` for every `q>e^λ−1` at `λ=2n+3`, `n=1..5`, sampled 300 orders of magnitude; superseded prior "`Λ_m` unevaluable" claim (that was false, PDF now pinned) | `docs/audits/odd-zeta-202601.md`, `scripts/gates/odd_zeta_1609.py`, `incoming/odd-zeta-202601/` (gitignored, sha256 in gate meta) |
| **2(e)** Erdős–Straus 2404.01508 | **PASS (escalate)** — certifies **Theorems 4/7**, not Conjecture 1: matched control shows coverage carries no information, `egyptian3` separates 100 %/0 %; no Lean kill | `docs/audits/es-covering.md`, `scripts/gates/es_cover.py` |
| **2(f)** RR / HJO 2608.05480+15219 | **PASS** — \(Z=P\) + Lemma 12; OreReduce (34) **capability-limited** | `docs/audits/rr-qexpand.md`, `scripts/gates/rr_qexpand.py` |
| **2(g)** PDN1 2503.00004 | **PASS** — GF + Thm 1.1/1.2 + (3.13) through **α=3**, 6 747 points in CI / 33 746 at `--deep` (was 81); notebooks **capability-limited** | `docs/audits/pdn1.md`, `scripts/gates/pdn1.py`, `incoming/pdn1/` |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `GiugaOnFactors`/`KorseltOnFactors`/`oracle_seven` | `docs/audits/agoh-giuga.md`, `scripts/gates/giuga_oracle.py`, `FragileProofAudit/AgohGiuga/` |
| **3(i)** Lamé 1847 | **PASS** — through 3(i)#a: Bareiss + ideal + Dedekind + concrete `(2,θ)` + Gauss-sum `√−23` in `ℚ(ζ₂₃)` | `docs/audits/lame-1847.md`, `FragileProofAudit/Lame/` |
| **Criterion module** | Apéry-shaped `irrational_of_integer_forms_tendsto_zero` | `FragileProofAudit/IrrationalityCriterion.lean` |

**Audited 2026-09-20** — every row above re-tested for false negatives (the
PASSes) or false positives (the BREAKs). **No verdict changed.** See **Track B**
for what the audit altered about their meaning and support.

---

## Optional appendix (not a blocker) — compressed Kim

**Only if** you specifically want Type F on a known corpse.

- Source: arXiv:1105.0730 · Zudilin / OEIS A013663
- Stub: `docs/blueprint/kim-zeta5.md`
- Quote ε-inequality after eq. (3.3); gate `n_k ∈ {10,100,1000}`, `N=1`
- One-page audit. **No Tendsto** unless the table is surprising
- Does not gate 3(h)

---

## After 3(i)++++ IsDedekindDomain OKNeg23

| ID | Target | First milestone |
|---|---|---|
| 3(i)++++ | Dedekind instance | **DONE** — `IsDedekindDomain OKNeg23` via integral closure |
| 3(i)+++++ | Concrete ideal | **DONE** — `P2 = (2, θ)`, `absNorm = 2`, `¬ IsPrincipal` |
| 3(i)#a | Gauss-sum embed | **DONE** — `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ` |
| 3(i)# | Cyclotomic embedding | **DONE** — `embedToRingOfIntegers : OKNeg23 →+* 𝓞(ℚ(ζ₂₃))`, injective |
| 3(i)#+a | Norm pin for primes above 2 | **DONE** — any prime over `(2)` in `𝓞(ℚ(ζ₂₃))` has `absNorm = 2^11`, via `ord₂ mod 23 = 11` |
| 3(i)#+b | `Gal(ℚ(ζ₂₃)/ℚ)` cyclic order 22 | **DONE** — via `autEquivPow ≃* (ZMod 23)ˣ` + `ZMod.isCyclic_units_prime` |
| 3(i)#+ | Pushed-forward ideal / classNumber | **BLOCKED 2026-09-20** on an `Algebra ℤ`/`Algebra ℚ` instance diamond for `Cyclotomic23` inside `Ideal.card_stabilizer_eq` (see **Blocked**, above); needs `Ideal.map embedToRingOfIntegers P2` prime + decomposition-group identification with the norm-`2^11` prime, `¬ Ideal.IsPrincipal`, or proved `h^+` |
| 3(j) | Sun batch 2603.29973 | After HypergeometricEval exists |
| 2(d) done | 202601.1609 PDF | **Pinned**; Lemma 5.1 BREAK landed, false-positive control clear, now an **infimum** result — write-up **decision to revisit** (Track B item 2) |
| 3(h)+ | Per-claim Agoh–Giuga | Concrete claimed proof vs kit at \(g=30\) / \(858\) |

---

## Governing discipline (do not drop)

1. Gates refute **routes**, not theorems. Notes: lemma · instance · false instance.
2. Audit the auditor. Ship harness with every failed gate. “Pith” / AI = lead until gated.
3. A **pass** escalates — never force a kill.
4. Gate before prove (`docs/GATE-BEFORE-PROVE.md`).
5. Negative-index Pochhammer is mandatory (`scripts/harness/pochhammer.py`).
6. **Commit as you go** — each phase lands with a git commit before the session ends.
7. **A check that cannot fail is not evidence.** Run the discrimination control
   where `docs/GATE-BEFORE-PROVE.md` requires one, and never gate a verdict on a
   tautology. Pin every verdict in `EXPECTED_VERDICT`.
