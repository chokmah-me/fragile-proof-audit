/-
  ST-1 to ST-5 statement probes for the Aaronson-Ambainis audit
  (fragile-proof-audit, claim aaronson-ambainis-psi-20261106,
  artifact @ 2a6ceaef872ae993708950f951989134084b851a).

  This file is added by the forge workflow
  (.github/workflows/aaronson-ambainis-forge.yml) into its build
  checkout; it is not part of the artifact. It imports the built
  library and runs strictly after the library build and the
  comparator have succeeded (harvest-loop M1 statement tests:
  probes record PASS / FAIL per theorem and never upgrade a
  verdict).

  Method, per the M1 add-on: obligations are discharged by
  applying the pinned theorems (or the pinned statement
  projections, where a lemma takes the statement as its
  hypothesis `h`), never by re-typing a theorem's hypotheses.
  The two computation lemmas `variance01_X0` / `variancePM_X0`
  state the variance formulas of the statements at the witness
  instances; each is tied to the pinned statement by a rewrite
  at the application site inside `st1_printed` / `st1_explicit`
  / `st1_pm` (a wrong transcription would fail those rewrites).
  ST-4 works by the add-on's own instruction for that probe:
  the theorem is restated on the junk instance, and `st4_tie`
  kernel-checks that the restated hypothesis is accepted as
  the domain of the pinned theorem's application there.

  Every probe lemma is axiom-audited at the end of the file.
-/
import AaronsonAmbainis.Main

open AaronsonAmbainis

namespace AAProbes

/-- Sum over the two points of `Fin 1 → Bool`, as the constant functions. -/
lemma univ_fin1_bool : (Finset.univ : Finset (Fin 1 → Bool))
    = {fun _ => false, fun _ => true} := by decide

lemma sum_fin1_bool (F : (Fin 1 → Bool) → ℝ) :
    ∑ X : Fin 1 → Bool, F X = F (fun _ => false) + F (fun _ => true) := by
  rw [univ_fin1_bool, Finset.sum_pair]
  intro h
  simpa using congrFun h 0

/-- Evaluation of the coordinate polynomial `X 0` at a `{0,1}` point. -/
lemma eval01_X0 (X : Fin 1 → Bool) :
    MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1))
      = if X 0 then 1 else 0 := by
  rw [MvPolynomial.eval_X]

/-- Evaluation of the coordinate polynomial `X 0` at a `{-1,1}` point. -/
lemma evalPM_X0 (X : Fin 1 → Bool) :
    MvPolynomial.eval (fun i => if X i then (1 : ℝ) else -1) (MvPolynomial.X (0 : Fin 1))
      = if X 0 then 1 else -1 := by
  rw [MvPolynomial.eval_X]

lemma hdeg_X0 : (MvPolynomial.X (0 : Fin 1) : MvPolynomial (Fin 1) ℝ).totalDegree ≤ 1 := by
  rw [MvPolynomial.totalDegree_X]

lemma hrange01_X0 : ∀ X : Fin 1 → Bool,
    0 ≤ MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1)) ∧
      MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1)) ≤ 1 := by
  intro X
  rw [eval01_X0]
  by_cases h : X 0 <;> simp [h]

lemma hrangePM_X0 : ∀ X : Fin 1 → Bool,
    |MvPolynomial.eval (fun i => if X i then (1 : ℝ) else -1) (MvPolynomial.X (0 : Fin 1))| ≤ 1 := by
  intro X
  rw [evalPM_X0]
  by_cases h : X 0 <;> simp [h]

/-- The variance expression of `PrintedConjecture` at `p = X 0`, `N = 1` is exactly `1/4`
(the maximum variance of a `[0,1]`-valued function). -/
lemma variance01_X0 :
    (∑ X : Fin 1 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1))
        - (∑ Y : Fin 1 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (MvPolynomial.X (0 : Fin 1))) / 2 ^ 1) ^ 2) / 2 ^ 1 = 1 / 4 := by
  simp only [sum_fin1_bool, eval01_X0]
  norm_num

/-- The influence expression of `PrintedConjecture` at `p = X 0`, `N = 1`, `i = 0`
is exactly `1` (the maximum). -/
lemma influence01_X0 :
    (∑ X : Fin 1 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1))
        - MvPolynomial.eval
            (fun k => if Function.update X 0 (!X 0) k then (1 : ℝ) else 0)
            (MvPolynomial.X (0 : Fin 1))) ^ 2) / 2 ^ 1 = 1 := by
  simp only [sum_fin1_bool, eval01_X0]
  norm_num

/-- The variance expression of `ExplicitBoundPM` at `p = X 0`, `n = 1` is exactly `1`. -/
lemma variancePM_X0 :
    (∑ X : Fin 1 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else -1) (MvPolynomial.X (0 : Fin 1))
        - (∑ Y : Fin 1 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else -1)
              (MvPolynomial.X (0 : Fin 1))) / 2 ^ 1) ^ 2) / 2 ^ 1 = 1 := by
  simp only [sum_fin1_bool, evalPM_X0]
  norm_num

/-- The influence expression of `ExplicitBoundPM` at `p = X 0`, `n = 1`, `i = 0`
is exactly `1`. -/
lemma influencePM_X0 :
    (∑ X : Fin 1 → Bool,
      ((MvPolynomial.eval (fun i => if X i then (1 : ℝ) else -1) (MvPolynomial.X (0 : Fin 1))
        - MvPolynomial.eval
            (fun k => if Function.update X 0 (!X 0) k then (1 : ℝ) else -1)
            (MvPolynomial.X (0 : Fin 1))) / 2) ^ 2) / 2 ^ 1 = 1 := by
  simp only [sum_fin1_bool, evalPM_X0]
  norm_num

/-- ST-1(a)+ST-2 for `PrintedConjecture`: the witness instance `N=1, d=1, p = X 0,
eps = 1/4` satisfies the hypotheses (degree and range directly; variance by
`variance01_X0`, tied by the rewrite at the application), and the theorem's
conclusion at the unique index is the true bound `(1/4)^7 ≤ 1`, the computed
influence there being `1` by `influence01_X0` (tied the same way). The witness
is non-degenerate: `p` is nonconstant, the variance `1/4` and the influence `1`
are the maxima for the class. -/
lemma st1_printed (h : PrintedConjecture) :
    (0 : ℝ) < (1 / 4 / 1) ^ 7 ∧ (1 / 4 / 1 : ℝ) ^ 7 ≤ 1 := by
  obtain ⟨i, hi⟩ := h 1 1 (MvPolynomial.X 0) hdeg_X0 hrange01_X0 (1 / 4) (by norm_num)
    (ge_of_eq variance01_X0)
  have hi0 : i = 0 := Subsingleton.elim i 0
  subst hi0
  rw [influence01_X0] at hi
  exact ⟨by norm_num, by simpa using hi⟩

/-- ST-1(b) escaping for the `{0,1}` statements: at `eps = 1/2` the variance
hypothesis fails for the same witness polynomial (its variance is `1/4 < 1/2`),
so the hypotheses are not content-free. -/
lemma st1_escape01 :
    ¬ (∑ X : Fin 1 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (MvPolynomial.X (0 : Fin 1))
        - (∑ Y : Fin 1 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (MvPolynomial.X (0 : Fin 1))) / 2 ^ 1) ^ 2) / 2 ^ 1 ≥ 1 / 2 := by
  rw [variance01_X0]
  norm_num

/-- The explicit bound of `ExplicitBound` at `eps = 1/4`, `d = 1` lies in `(0, 1]`. -/
lemma explicit_bound_range :
    0 < 8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 := by
  have hsqrt : Real.sqrt 15 ≤ 4 := by
    have h16 : Real.sqrt (16 : ℝ) = 4 := by
      rw [show (16 : ℝ) = 4 ^ 2 by norm_num]
      exact Real.sqrt_sq (by norm_num)
    calc Real.sqrt 15 ≤ Real.sqrt 16 := Real.sqrt_le_sqrt (by norm_num)
    _ = 4 := h16
  have hpi : (3 : ℝ) < Real.pi := Real.pi_gt_three
  have hrpow_pos : (0 : ℝ) < (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) :=
    Real.rpow_pos_of_pos (by norm_num) _
  have hrpow_le : (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) ≤ 1 :=
    Real.rpow_le_one (by norm_num) (by norm_num) (by norm_num)
  have hpi2 : (9 : ℝ) ≤ Real.pi ^ 2 := by nlinarith [hpi]
  have hpi4 : (81 : ℝ) ≤ Real.pi ^ 4 := by nlinarith [hpi2, Real.pi_pos]
  have hfac : 8 * Real.sqrt 15 / (125 * Real.pi ^ 4) ≤ 1 := by
    rw [div_le_one (by positivity : (0 : ℝ) < 125 * Real.pi ^ 4)]
    have h8 : 8 * Real.sqrt 15 ≤ 32 := by linarith [hsqrt]
    linarith [h8, hpi4]
  constructor
  · positivity
  · have h16 : (1 : ℝ) ^ 6 = 1 := by norm_num
    rw [h16, div_one]
    exact mul_le_one₀ hfac (by positivity) hrpow_le

/-- ST-1(a)+ST-2 for `ExplicitBound`: same witness instance; the conclusion's
bound is the number of `explicit_bound_range`, and the computed influence `1`
dominates it. -/
lemma st1_explicit (h : ExplicitBound) :
    0 < 8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 := by
  obtain ⟨i, hi⟩ := h 1 1 (MvPolynomial.X 0) hdeg_X0 hrange01_X0 (1 / 4) (by norm_num)
    (ge_of_eq variance01_X0)
  have hi0 : i = 0 := Subsingleton.elim i 0
  subst hi0
  rw [influence01_X0] at hi
  exact ⟨explicit_bound_range.1, by simpa using hi⟩

/-- The bound of `ExplicitBoundPM` at `eps = 1`, `d = 1` lies in `(0, 1]`. -/
lemma pm_bound_range :
    0 < Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 := by
  have hsqrt : Real.sqrt 15 ≤ 4 := by
    have h16 : Real.sqrt (16 : ℝ) = 4 := by
      rw [show (16 : ℝ) = 4 ^ 2 by norm_num]
      exact Real.sqrt_sq (by norm_num)
    calc Real.sqrt 15 ≤ Real.sqrt 16 := Real.sqrt_le_sqrt (by norm_num)
    _ = 4 := h16
  have hpi : (3 : ℝ) < Real.pi := Real.pi_gt_three
  have hpi2 : (9 : ℝ) ≤ Real.pi ^ 2 := by nlinarith [hpi]
  have hpi4 : (81 : ℝ) ≤ Real.pi ^ 4 := by nlinarith [hpi2, Real.pi_pos]
  have hfac : Real.sqrt 15 / (500 * Real.pi ^ 4) ≤ 1 := by
    rw [div_le_one (by positivity : (0 : ℝ) < 500 * Real.pi ^ 4)]
    linarith [hsqrt, hpi4]
  rw [Real.one_rpow]
  constructor
  · positivity
  · have h16 : (1 : ℝ) ^ 6 = 1 := by norm_num
    rw [h16, div_one]
    exact mul_le_one₀ hfac (by positivity) (by norm_num)

/-- ST-1(a)+ST-2 for `ExplicitBoundPM`: witness instance `n=1, d=1, p = X 0,
eps = 1` (variance exactly `1`), conclusion bound in `(0,1]`, computed
influence `1`. -/
lemma st1_pm (h : ExplicitBoundPM) :
    0 < Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 := by
  obtain ⟨i, hi⟩ := h 1 1 (MvPolynomial.X 0) hdeg_X0 hrangePM_X0 1 (by norm_num)
    (ge_of_eq variancePM_X0)
  have hi0 : i = 0 := Subsingleton.elim i 0
  subst hi0
  rw [influencePM_X0] at hi
  exact ⟨pm_bound_range.1, by simpa using hi⟩

/-- ST-1(b) escaping for `ExplicitBoundPM`: at `eps = 2` the variance hypothesis
fails for the same witness (its variance is `1 < 2`). -/
lemma st1_escapePM :
    ¬ (∑ X : Fin 1 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else -1) (MvPolynomial.X (0 : Fin 1))
        - (∑ Y : Fin 1 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else -1)
              (MvPolynomial.X (0 : Fin 1))) / 2 ^ 1) ^ 2) / 2 ^ 1 ≥ 2 := by
  rw [variancePM_X0]
  norm_num

/-- Range of the ST-5 witness function (the coordinate function on `{0,1}^1`). -/
lemma fbs_range : ∀ x : Fin 1 → Bool,
    0 ≤ (if x 0 then (1 : ℝ) else 0) ∧ (if x 0 then (1 : ℝ) else 0) ≤ 1 := by
  intro x
  by_cases h : x 0 <;> simp [h]

/-- Polynomial representability of the ST-5 witness function, by `X 0`. -/
lemma fbs_rep : ∃ p : MvPolynomial (Fin 1) ℝ, p.totalDegree ≤ 1 ∧
    ∀ x : Fin 1 → Bool, (if x 0 then (1 : ℝ) else 0)
      = MvPolynomial.eval (fun i => if x i then (1 : ℝ) else 0) p := by
  refine ⟨MvPolynomial.X 0, hdeg_X0, fun x => ?_⟩
  rw [MvPolynomial.eval_X]

/-- ST-1 on the antecedent predicate `FbsDegreeBound` at `n=1, d=1` for the
coordinate function: constant weights `c = 1` satisfy both weight conditions,
so the predicate's body is satisfiable at a non-degenerate instance (the
function is nonconstant; `n=1` is the smallest case the predicate admits).
This does not prove `FbsDegreeBound`; it shows the antecedent is not vacuous.
Under ST-5 the antecedent remains unproved (it is Agarwal-Ben-David
Theorem 1.7, formalized nowhere in the artifact). -/
lemma fbs_witness :
    ∃ c : (Fin 1 → Bool) → Fin 1 → ℝ,
      (∀ x y : Fin 1 → Bool,
        ∑ i ∈ Finset.univ.filter (fun i => x i ≠ y i), c x i ≥
          |(if x 0 then (1 : ℝ) else 0) - (if y 0 then (1 : ℝ) else 0)|) ∧
      (∀ x : Fin 1 → Bool, ∑ i, c x i ≤ Real.pi ^ 2 / 4 * (1 : ℝ) ^ 2) := by
  refine ⟨fun _ _ => 1, ?_, ?_⟩
  · intro x y
    rw [Finset.sum_filter, Fin.sum_univ_one]
    by_cases hx : x 0 <;> by_cases hy : y 0 <;> simp [hx, hy]
  · intro x
    rw [Fin.sum_univ_one]
    nlinarith [Real.pi_gt_three]

/-- Tie: the pinned predicate `FbsDegreeBound` accepts the witness function's
range and representability proofs at `n=1, d=1`, so `fbs_range` / `fbs_rep`
are about the pinned statement (kernel-checked through this application). -/
lemma fbs_tie (h : FbsDegreeBound) : True := by
  have key := h 1 1 le_rfl le_rfl (fun x => if x 0 then (1 : ℝ) else 0) fbs_range fbs_rep
  trivial

/-- The variance expression of `PrintedConjecture` at `p = 0`, `N = 0` is exactly `0`. -/
lemma variance00 :
    (∑ X : Fin 0 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ)
        - (∑ Y : Fin 0 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (0 : MvPolynomial (Fin 0) ℝ)) / 2 ^ 0) ^ 2) / 2 ^ 0 = 0 := by
  simp

lemma hdeg00 : (0 : MvPolynomial (Fin 0) ℝ).totalDegree ≤ 0 := by
  rw [MvPolynomial.totalDegree_zero]

lemma hrange00 : ∀ X : Fin 0 → Bool,
    0 ≤ MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ) ∧
      MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ) ≤ 1 := by
  intro X
  simp

/-- ST-4 boundary: at the junk instance `p = 0, N = 0` of `PrintedConjecture`,
the variance hypothesis (here at `eps = 1`) is false, since the variance
computes to `0`: the statement is vacuous exactly where the source statement
is (a constant polynomial has variance `0 < eps`). The junk values in the
conclusion at `d = 0` (`(eps/0)^7 = 0`, division by `0^6`) are unreachable
behind this hypothesis. -/
lemma st4_boundary
    (ha : (∑ X : Fin 0 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ)
        - (∑ Y : Fin 0 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (0 : MvPolynomial (Fin 0) ℝ)) / 2 ^ 0) ^ 2) / 2 ^ 0 ≥ 1) : False := by
  rw [variance00] at ha
  norm_num at ha

/-- Tie: the restated hypothesis of `st4_boundary` is accepted as the domain of
the pinned theorem's application at the same instance (kernel defeq check);
the conclusion's existential over `Fin 0` is then empty. -/
lemma st4_tie (h : PrintedConjecture)
    (ha : (∑ X : Fin 0 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ)
        - (∑ Y : Fin 0 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (0 : MvPolynomial (Fin 0) ℝ)) / 2 ^ 0) ^ 2) / 2 ^ 0 ≥ 1) : False := by
  have key := h 0 0 0 hdeg00 hrange00 1 (by norm_num)
  obtain ⟨i, -⟩ := key ha
  exact absurd i.isLt (Nat.not_lt_zero _)

/-- Forge glue: the probes applied to the pinned theorems themselves. -/
theorem st1_printed_main :
    (0 : ℝ) < (1 / 4 / 1) ^ 7 ∧ (1 / 4 / 1 : ℝ) ^ 7 ≤ 1 :=
  st1_printed AaronsonAmbainis.aaronson_ambainis

theorem st1_explicit_main :
    0 < 8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      8 * Real.sqrt 15 / (125 * Real.pi ^ 4) * (1 / 4 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 :=
  st1_explicit AaronsonAmbainis.aaronson_ambainis_explicit

theorem st1_pm_main :
    0 < Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ∧
      Real.sqrt 15 / (500 * Real.pi ^ 4) * (1 : ℝ) ^ ((5 : ℝ) / 2) / (1 : ℝ) ^ 6 ≤ 1 :=
  st1_pm AaronsonAmbainis.aaronson_ambainis_pm

theorem st4_tie_main
    (ha : (∑ X : Fin 0 → Bool,
      (MvPolynomial.eval (fun i => if X i then (1 : ℝ) else 0) (0 : MvPolynomial (Fin 0) ℝ)
        - (∑ Y : Fin 0 → Bool,
            MvPolynomial.eval (fun i => if Y i then (1 : ℝ) else 0)
              (0 : MvPolynomial (Fin 0) ℝ)) / 2 ^ 0) ^ 2) / 2 ^ 0 ≥ 1) : False :=
  st4_tie AaronsonAmbainis.aaronson_ambainis ha

end AAProbes

-- Axiom audit of every probe lemma (M1 add-on: a probe proved with sorryAx or
-- an added axiom is a failed probe). Expected: exactly the standard three.
#print axioms AAProbes.variance01_X0
#print axioms AAProbes.influence01_X0
#print axioms AAProbes.variancePM_X0
#print axioms AAProbes.influencePM_X0
#print axioms AAProbes.variance00
#print axioms AAProbes.st1_printed
#print axioms AAProbes.st1_escape01
#print axioms AAProbes.explicit_bound_range
#print axioms AAProbes.st1_explicit
#print axioms AAProbes.pm_bound_range
#print axioms AAProbes.st1_pm
#print axioms AAProbes.st1_escapePM
#print axioms AAProbes.fbs_range
#print axioms AAProbes.fbs_rep
#print axioms AAProbes.fbs_witness
#print axioms AAProbes.fbs_tie
#print axioms AAProbes.st4_boundary
#print axioms AAProbes.st4_tie
#print axioms AAProbes.st1_printed_main
#print axioms AAProbes.st1_explicit_main
#print axioms AAProbes.st1_pm_main
#print axioms AAProbes.st4_tie_main
