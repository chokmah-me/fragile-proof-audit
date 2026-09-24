/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import FragileProofAudit.QTSPP.DiagonalIdentity

/-!
# Identity (3.2): the concrete Koutschan operator (Milestone 3)

The explicit order-7 recurrence operator for the diagonal `d_n = B'(n,n)`,
received 2026-09-24 from Christoph Koutschan (re-run at our request).
Coefficient polynomials below are transcribed verbatim in the factored
form sent by the author: `L = Σ p_i(n) S_n^i`, signs as given.

Machine-checked properties of the transcribed operator (independent
sympy verification, see `~/workspace/qtspp/verify_operator.py`):
  * order 7, all eight coefficient polynomials of degree 24;
  * `(S_n − 1)` is a right factor: the signed coefficient sum is the
    zero polynomial (so the constant-1 sequence satisfies `L`);
  * leading coefficient `p_7(n) > 0` for all `n ≥ 0` (every factor has
    positive coefficients and is positive at 0);
  * odd `S_n`-powers share one degree-12 factor, even powers another.

What remains for the full identity: `hrec` (the ∂-finite substitution
output certifying that the diagonal satisfies `L`) and `hinit` (the seven
determinant evaluations `B'(k,k) = 1`). Both are recorded as explicit
hypotheses of `koutschan_diagonal_of_hrec_hinit` below.
-/

namespace FragileProofAudit.QTSPP

/-- The eight signed coefficient polynomials `p_7, …, p_0` of
    Koutschan's order-7 operator, in the factored form sent by the
    author. `koutschanP i n` is the coefficient of `S_n^i`. -/
def koutschanP : ℕ → ℕ → ℚ
  | 7, n => 256*(3+2*(n : ℚ))*(5+2*(n : ℚ))*(7+2*(n : ℚ))*(9+2*(n : ℚ))*(11+2*(n : ℚ))^2*(13+2*(n : ℚ))^2*(47376+77988*(n : ℚ)+43753*(n : ℚ)^2+10212*(n : ℚ)^3+851*(n : ℚ)^4)*(8551886500080+65607634187424*(n : ℚ)+203662728958644*(n : ℚ)^2+350432791445004*(n : ℚ)^3+378130590361145*(n : ℚ)^4+272136969467064*(n : ℚ)^5+134892553142380*(n : ℚ)^6+46670376822480*(n : ℚ)^7+11242193924478*(n : ℚ)^8+1846957944360*(n : ℚ)^9+197213905720*(n : ℚ)^10+12331694628*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 6, n => -256*(1+2*(n : ℚ))*(3+2*(n : ℚ))*(5+2*(n : ℚ))*(7+2*(n : ℚ))*(9+2*(n : ℚ))^2*(11+2*(n : ℚ))^2*(3780+17714*(n : ℚ)+18223*(n : ℚ)^2+6808*(n : ℚ)^3+851*(n : ℚ)^4)*(1473384570900480+5642158702989312*(n : ℚ)+9639427943490048*(n : ℚ)^2+9726122184947712*(n : ℚ)^3+6460991139551360*(n : ℚ)^4+2979516206794944*(n : ℚ)^5+978939764726152*(n : ℚ)^6+231104839410720*(n : ℚ)^7+38943731595873*(n : ℚ)^8+4572700562160*(n : ℚ)^9+355470653446*(n : ℚ)^10+16442259504*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 5, n => -48*(3+2*(n : ℚ))*(5+2*(n : ℚ))*(7+2*(n : ℚ))*(9+2*(n : ℚ))*(16+3*(n : ℚ))*(20+3*(n : ℚ))*(160643952+318071148*(n : ℚ)+241555483*(n : ℚ)^2+91888368*(n : ℚ)^3+18683956*(n : ℚ)^4+1940280*(n : ℚ)^5+80845*(n : ℚ)^6)*(8551886500080+65607634187424*(n : ℚ)+203662728958644*(n : ℚ)^2+350432791445004*(n : ℚ)^3+378130590361145*(n : ℚ)^4+272136969467064*(n : ℚ)^5+134892553142380*(n : ℚ)^6+46670376822480*(n : ℚ)^7+11242193924478*(n : ℚ)^8+1846957944360*(n : ℚ)^9+197213905720*(n : ℚ)^10+12331694628*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 4, n => 48*(1+2*(n : ℚ))*(3+2*(n : ℚ))*(5+2*(n : ℚ))*(7+2*(n : ℚ))*(13+3*(n : ℚ))*(17+3*(n : ℚ))*(9064440+45105792*(n : ℚ)+59803990*(n : ℚ)^2+34938444*(n : ℚ)^3+10195231*(n : ℚ)^4+1455210*(n : ℚ)^5+80845*(n : ℚ)^6)*(1473384570900480+5642158702989312*(n : ℚ)+9639427943490048*(n : ℚ)^2+9726122184947712*(n : ℚ)^3+6460991139551360*(n : ℚ)^4+2979516206794944*(n : ℚ)^5+978939764726152*(n : ℚ)^6+231104839410720*(n : ℚ)^7+38943731595873*(n : ℚ)^8+4572700562160*(n : ℚ)^9+355470653446*(n : ℚ)^10+16442259504*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 3, n => 9*(3+2*(n : ℚ))*(5+2*(n : ℚ))*(10+3*(n : ℚ))*(14+3*(n : ℚ))*(16+3*(n : ℚ))*(20+3*(n : ℚ))*(881435520+1741820880*(n : ℚ)+1324680500*(n : ℚ)^2+504933780*(n : ℚ)^3+102808739*(n : ℚ)^4+10681752*(n : ℚ)^5+445073*(n : ℚ)^6)*(8551886500080+65607634187424*(n : ℚ)+203662728958644*(n : ℚ)^2+350432791445004*(n : ℚ)^3+378130590361145*(n : ℚ)^4+272136969467064*(n : ℚ)^5+134892553142380*(n : ℚ)^6+46670376822480*(n : ℚ)^7+11242193924478*(n : ℚ)^8+1846957944360*(n : ℚ)^9+197213905720*(n : ℚ)^10+12331694628*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 2, n => -9*(1+2*(n : ℚ))*(3+2*(n : ℚ))*(7+3*(n : ℚ))*(11+3*(n : ℚ))*(13+3*(n : ℚ))*(17+3*(n : ℚ))*(51933420+246764586*(n : ℚ)+326590169*(n : ℚ)^2+191614884*(n : ℚ)^3+56076074*(n : ℚ)^4+8011314*(n : ℚ)^5+445073*(n : ℚ)^6)*(1473384570900480+5642158702989312*(n : ℚ)+9639427943490048*(n : ℚ)^2+9726122184947712*(n : ℚ)^3+6460991139551360*(n : ℚ)^4+2979516206794944*(n : ℚ)^5+978939764726152*(n : ℚ)^6+231104839410720*(n : ℚ)^7+38943731595873*(n : ℚ)^8+4572700562160*(n : ℚ)^9+355470653446*(n : ℚ)^10+16442259504*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 1, n => -81*(4+3*(n : ℚ))^2*(8+3*(n : ℚ))^2*(10+3*(n : ℚ))*(14+3*(n : ℚ))*(16+3*(n : ℚ))*(20+3*(n : ℚ))*(473676+402776*(n : ℚ)+125449*(n : ℚ)^2+17020*(n : ℚ)^3+851*(n : ℚ)^4)*(8551886500080+65607634187424*(n : ℚ)+203662728958644*(n : ℚ)^2+350432791445004*(n : ℚ)^3+378130590361145*(n : ℚ)^4+272136969467064*(n : ℚ)^5+134892553142380*(n : ℚ)^6+46670376822480*(n : ℚ)^7+11242193924478*(n : ℚ)^8+1846957944360*(n : ℚ)^9+197213905720*(n : ℚ)^10+12331694628*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | 0, n => 81*(1+3*(n : ℚ))^2*(5+3*(n : ℚ))^2*(7+3*(n : ℚ))*(11+3*(n : ℚ))*(13+3*(n : ℚ))*(17+3*(n : ℚ))*(180180+199534*(n : ℚ)+79495*(n : ℚ)^2+13616*(n : ℚ)^3+851*(n : ℚ)^4)*(1473384570900480+5642158702989312*(n : ℚ)+9639427943490048*(n : ℚ)^2+9726122184947712*(n : ℚ)^3+6460991139551360*(n : ℚ)^4+2979516206794944*(n : ℚ)^5+978939764726152*(n : ℚ)^6+231104839410720*(n : ℚ)^7+38943731595873*(n : ℚ)^8+4572700562160*(n : ℚ)^9+355470653446*(n : ℚ)^10+16442259504*(n : ℚ)^11+342547073*(n : ℚ)^12)
  | _, _ => 0

/-- Right-factor witness `Q = Σ_{j=0}^6 q_j S_n^j` with
    `L = Q · (S_n − 1)`: `q_j = Σ_{i=j+1..7} p_i`. -/
def koutschanQ : ℕ → ℕ → ℚ
  | 6, n => koutschanP 7 n
  | 5, n => koutschanP 6 n + koutschanP 7 n
  | 4, n => koutschanP 5 n + koutschanP 6 n + koutschanP 7 n
  | 3, n => koutschanP 4 n + koutschanP 5 n + koutschanP 6 n + koutschanP 7 n
  | 2, n => koutschanP 3 n + koutschanP 4 n + koutschanP 5 n + koutschanP 6 n + koutschanP 7 n
  | 1, n => koutschanP 2 n + koutschanP 3 n + koutschanP 4 n + koutschanP 5 n + koutschanP 6 n + koutschanP 7 n
  | 0, n => koutschanP 1 n + koutschanP 2 n + koutschanP 3 n + koutschanP 4 n + koutschanP 5 n + koutschanP 6 n + koutschanP 7 n
  | _, _ => 0

theorem koutschan_right_top (n : ℕ) :
    koutschanP 7 n = koutschanQ 6 n := by
  simp only [koutschanP, koutschanQ]

theorem koutschan_right_bot (n : ℕ) :
    koutschanP 0 n = -(koutschanQ 0 n) := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_1 (n : ℕ) :
    koutschanP 1 n = koutschanQ 0 n - koutschanQ 1 n := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_2 (n : ℕ) :
    koutschanP 2 n = koutschanQ 1 n - koutschanQ 2 n := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_3 (n : ℕ) :
    koutschanP 3 n = koutschanQ 2 n - koutschanQ 3 n := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_4 (n : ℕ) :
    koutschanP 4 n = koutschanQ 3 n - koutschanQ 4 n := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_5 (n : ℕ) :
    koutschanP 5 n = koutschanQ 4 n - koutschanQ 5 n := by
  simp only [koutschanP, koutschanQ]; ring

theorem koutschan_right_mid_6 (n : ℕ) :
    koutschanP 6 n = koutschanQ 5 n - koutschanQ 6 n := by
  simp only [koutschanP, koutschanQ]; ring

/-- The concrete certificate: Koutschan's operator with its
    `(S_n − 1)` right-factor witness. -/
def koutschanCertificate : DiagonalCertificate where
  p := koutschanP
  q := koutschanQ
  right_top := koutschan_right_top
  right_bot := koutschan_right_bot
  right_mid := by
    intro i hi n
    have hmem : i = 1 ∨ i = 2 ∨ i = 3 ∨ i = 4 ∨ i = 5 ∨ i = 6 := by
      rw [Finset.mem_Icc] at hi; omega
    rcases hmem with rfl | rfl | rfl | rfl | rfl | rfl
    · exact koutschan_right_mid_1 n
    · exact koutschan_right_mid_2 n
    · exact koutschan_right_mid_3 n
    · exact koutschan_right_mid_4 n
    · exact koutschan_right_mid_5 n
    · exact koutschan_right_mid_6 n

/-- Leading coefficient never vanishes on ℕ (all factors positive). -/
theorem koutschan_hlead (n : ℕ) : koutschanP 7 n ≠ 0 := by
  have hn : (0:ℚ) ≤ (n:ℚ) := Nat.cast_nonneg n
  simp only [koutschanP]
  exact ne_of_gt (by positivity)

/-- Identity (3.2) for the concrete operator, conditional on the two
    remaining computational inputs: the recurrence itself (`hrec`, the
    ∂-finite substitution output) and the seven initial values
    (`hinit`, determinant evaluations). -/
theorem koutschan_diagonal_of_hrec_hinit (d : ℕ → ℚ)
    (hrec : ∀ nn, ∑ i ∈ Finset.range (7 + 1), koutschanP i nn * d (nn + i) = 0)
    (hinit : ∀ i < 7, d i = 1) :
    d = fun _ => 1 :=
  diagonal_identity_of_certificate koutschanCertificate d
    koutschan_hlead hrec hinit

end FragileProofAudit.QTSPP
