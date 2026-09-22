/-
Ported from Quanyu Tang's public formalization accompanying
"A counterexample to a conjecture of Sárközy on sums and products modulo
a prime" (arXiv:2603.29992v2), Section 3, formalized with the Aristotle
theorem prover (Harmonic) plus human review by Wouter van Doorn.

Source: https://github.com/QuanyuTang/Lean-files/blob/main/UPNT65.lean
sha256 of the fetched source (before this campaign's port edits):
802ac3b0a09b6c1178bf643f7dd843fcf42c71d08bff66630982e7e7a51b7be9
Fetched: 2026-09-22. Original environment: leanprover/lean4:v4.28.0,
mathlib commit 8f9d9cff6bd728b17a24e163c9402775d9e6a365. This campaign
pins leanprover/lean4:v4.32.2 (lean-toolchain) -- ported verbatim except
for changes noted inline where the newer mathlib required them.

This proves the FULL content of scripts/gates/sarkozy_sum_product.py's
already-locked BREAK: Sárközy's Conjecture 65/1.1 is false, with the exact
threshold 1/2 (Tang's Theorem 2.2 / Corollary 2.3 / Remark 2.4), not merely
the specific finite-prime witnesses the Python gate spot-checks.
-/
import Mathlib

open scoped Pointwise
open Finset ZMod Fintype

noncomputable section

namespace FragileProofAudit.Sarkozy

variable {p : ℕ} [hp : Fact (Nat.Prime p)]

-- `private` dropped from the upstream source: this campaign's axiom-audit
-- tool resolves declarations by fully-qualified name and cannot see through
-- Lean 4's private-declaration name mangling (confirmed 2026-09-22 -- the
-- forge reported this one declaration CAPABILITY_LIMITED until this change).
lemma prime : Nat.Prime p := hp.out

/-! ## Proposition 2.1 -/

theorem sumset_covers (A : Finset (ZMod p)) (hA : p < A.card * 2) :
    ∀ x : ZMod p, ∃ a ∈ A, ∃ b ∈ A, a + b = x := by
  intro x
  by_contra h_contra
  push Not at h_contra
  set B : Finset (ZMod p) := Finset.image (fun a => x - a) A
  have h_disjoint : Disjoint A B :=
    Finset.disjoint_left.mpr fun a ha hb => by
      obtain ⟨b, hb', rfl⟩ := Finset.mem_image.mp hb
      exact h_contra _ ha _ hb' (by ring)
  have h_union : A.card + B.card ≤ p := by
    rw [← Finset.card_union_of_disjoint h_disjoint]
    exact le_trans (Finset.card_le_univ _) (by norm_num)
  rw [Finset.card_image_of_injective _ sub_right_injective] at h_union
  linarith

theorem sumset_eq_univ (A : Finset (ZMod p)) (hA : p < A.card * 2) :
    A + A = Finset.univ := by
  ext x; simp only [Finset.mem_add, mem_univ, iff_true]
  obtain ⟨a, ha, b, hb, hab⟩ := sumset_covers A hA x
  exact ⟨a, ha, b, hb, hab⟩

/-! ## Theorem 2.2 -/

def avoidsOne (A : Finset (ZMod p)) : Prop :=
  (∀ a ∈ A, ∀ b ∈ A, a + b ≠ (1 : ZMod p)) ∧
  (∀ a ∈ A, ∀ b ∈ A, a * b ≠ (1 : ZMod p))

/-! ### Group action -/

def s_map (x : ZMod p) : ZMod p := 1 - x
def t_map (x : ZMod p) : ZMod p := x⁻¹
def st_map (x : ZMod p) : ZMod p := 1 - x⁻¹
def ts_map (x : ZMod p) : ZMod p := (1 - x)⁻¹
def sts_map (x : ZMod p) : ZMod p := x * (x - 1)⁻¹

def orb (x : ZMod p) : Finset (ZMod p) :=
  {x, s_map x, t_map x, st_map x, ts_map x, sts_map x}

lemma s_map_involutive : Function.Involutive (s_map (p := p)) :=
  fun x => by unfold s_map; ring

lemma t_map_involutive : Function.Involutive (t_map (p := p)) :=
  fun x => inv_inv x

/-! ### Orbit preservation -/

lemma orb_s_subset (x : ZMod p) : orb (s_map x) ⊆ orb x := by
  simp +decide [ orb, s_map, t_map, st_map, ts_map, sts_map ];
  grind +ring

lemma orb_t_subset (x : ZMod p) : orb (t_map x) ⊆ orb x := by
  grind +locals

lemma orb_eq_of_s_map (x : ZMod p) : orb (s_map x) = orb x := by
  apply Finset.Subset.antisymm (orb_s_subset x)
  have h := orb_s_subset (s_map x)
  rwa [show s_map (s_map x) = x from s_map_involutive x] at h

lemma orb_eq_of_t_map (x : ZMod p) : orb (t_map x) = orb x := by
  apply Finset.Subset.antisymm (orb_t_subset x)
  have h := orb_t_subset (t_map x)
  rwa [show t_map (t_map x) = x from t_map_involutive x] at h

lemma orb_eq_of_mem {x y : ZMod p} (hy : y ∈ orb x) : orb y = orb x := by
  revert hy;
  simp +decide [ orb ];
  simp +decide [ s_map, t_map, st_map, ts_map, sts_map, Finset.ext_iff ];
  rintro ( rfl | rfl | rfl | rfl | rfl | rfl ) a <;> ring_nf <;> norm_num;
  · grind;
  · grind;
  · grind;
  · grind;
  · grind +splitImp

/-! ### Adjacency implies same orbit -/

lemma s_map_mem_orb (x : ZMod p) : s_map x ∈ orb x := by
  simp [orb]

lemma t_map_mem_orb (x : ZMod p) : t_map x ∈ orb x := by
  simp [orb]

lemma sum_adj_mem_orb {a b : ZMod p} (h : a + b = 1) : b ∈ orb a := by
  convert s_map_mem_orb a using 1;
  exact eq_sub_of_add_eq' h

lemma prod_adj_mem_orb {a b : ZMod p} (h : a * b = 1) : b ∈ orb a := by
  by_cases ha : a = 0;
  · aesop;
  · exact Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_self _ _ ) ) |> fun x => by rw [ show b = a⁻¹ by simp [ eq_inv_of_mul_eq_one_left h ] ] ; exact x;

/-! ### Cross-orbit safety -/

lemma cross_orbit_safe {a b : ZMod p}
    (hdisj : Disjoint (orb a) (orb b)) {a' b' : ZMod p}
    (ha : a' ∈ orb a) (hb : b' ∈ orb b) :
    a' + b' ≠ 1 ∧ a' * b' ≠ 1 := by
  constructor
  · intro h
    have hb_orb : b' ∈ orb a' := sum_adj_mem_orb h
    have hb_orb' : b' ∈ orb a := by rwa [orb_eq_of_mem ha] at hb_orb
    exact Finset.disjoint_left.mp hdisj hb_orb' hb
  · intro h
    have hb_orb : b' ∈ orb a' := prod_adj_mem_orb h
    have hb_orb' : b' ∈ orb a := by rwa [orb_eq_of_mem ha] at hb_orb
    exact Finset.disjoint_left.mp hdisj hb_orb' hb

/-! ### Orbit classification -/

lemma five_distinct (hp5 : 5 ≤ p) :
    ({0, 1, -1, (2 : ZMod p)⁻¹, 2} : Finset (ZMod p)).card = 5 := by
  rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] <;> norm_num;
  · rw [ inv_eq_one_div, div_eq_iff ] <;> norm_num;
    · intro h; rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases h <;> contradiction;
    · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
  · rw [ inv_eq_one_div, eq_div_iff ] <;> norm_num;
    · norm_num [ neg_eq_iff_add_eq_zero ];
      erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
    · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
  · norm_num [ eq_neg_iff_add_eq_zero ];
    rcases p with ( _ | _ | _ | _ | _ | p ) <;> norm_cast;
    erw [ ZMod.natCast_eq_zero_iff ];
    exact ⟨ Nat.not_dvd_of_pos_of_lt ( by norm_num ) ( by linarith ), by rintro ⟨ ⟩, by rintro ⟨ ⟩ ⟩;
  · erw [ eq_comm, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith )

lemma orbit_card_six (x : ZMod p)
    (hx0 : x ≠ 0) (hx1 : x ≠ 1) (hxn1 : x ≠ -1)
    (hxh : x ≠ (2 : ZMod p)⁻¹) (hx2 : x ≠ 2)
    (hpoly : x ^ 2 - x + 1 ≠ 0) :
    (orb x).card = 6 := by
  unfold orb;
  rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] <;> simp +decide [ *, s_map, t_map, st_map, ts_map, sts_map ];
  · grind;
  · grind;
  · grind;
  · grind;
  · grind

/-! ### Per-orbit independence -/

lemma zero_indep : avoidsOne ({0} : Finset (ZMod p)) := by
  constructor <;> simp +decide

lemma two_indep (hp5 : 5 ≤ p) : avoidsOne ({2} : Finset (ZMod p)) := by
  constructor <;> norm_num;
  · rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> norm_num [ Fin.ext_iff, ZMod ] at *;
    · decide +revert;
    · rintro ⟨ ⟩;
  · rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> norm_num [ Fin.ext_iff, ZMod ] at *;
    · decide +revert;
    · rintro ⟨ ⟩

lemma root_indep {u : ZMod p} (hu : u ^ 2 - u + 1 = 0) (hp5 : 5 ≤ p) :
    avoidsOne ({u} : Finset (ZMod p)) := by
  constructor <;> intro a b <;> simp_all +decide;
  · intro h;
    grind +suggestions;
  · by_contra h_contra
    have h_u_one : u = 2 := by
      grind
    subst h_u_one
    norm_num at *; (
    rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases hu <;> contradiction;);

lemma triple_indep {x : ZMod p}
    (hx0 : x ≠ 0) (hx1 : x ≠ 1) (hxn1 : x ≠ -1)
    (hxh : x ≠ (2 : ZMod p)⁻¹) (hx2 : x ≠ 2) :
    avoidsOne ({x, ts_map x, st_map x} : Finset (ZMod p)) := by
  constructor;
  · simp +decide [ ts_map, st_map ];
    grind;
  · simp +zetaDelta at *;
    refine' ⟨ _, _, _ ⟩;
    · grind +locals;
    · unfold ts_map st_map;
      grind;
    · unfold st_map ts_map;
      grind

/-! ### Additional orbit lemmas -/

lemma orb_mem_self (x : ZMod p) : x ∈ orb x := by
  simp [orb]

lemma orb_eq_or_disjoint (x y : ZMod p) :
    orb x = orb y ∨ Disjoint (orb x) (orb y) := by
  by_contra! h_inter;
  obtain ⟨z, hzx, hzy⟩ : ∃ z, z ∈ orb x ∧ z ∈ orb y := by
    exact Finset.not_disjoint_iff.mp h_inter.2;
  exact h_inter.1 ( orb_eq_of_mem hzx ▸ orb_eq_of_mem hzy ▸ rfl )

lemma triple_subset_orb (x : ZMod p) :
    ({x, ts_map x, st_map x} : Finset (ZMod p)) ⊆ orb x := by
  simp +decide [ Finset.subset_iff, orb ]

lemma avoidsOne_union {A B : Finset (ZMod p)} {a b : ZMod p}
    (hA : avoidsOne A) (hB : avoidsOne B)
    (hAo : A ⊆ orb a) (hBo : B ⊆ orb b)
    (hdisj : Disjoint (orb a) (orb b)) :
    avoidsOne (A ∪ B) := by
  refine ⟨ ?_, ?_ ⟩ <;> intro c hc c' hc';
  · rcases Finset.mem_union.1 hc with ( hc | hc ) <;> rcases Finset.mem_union.1 hc' with ( hc' | hc' ) <;> simp_all +decide [ avoidsOne ];
    · have := cross_orbit_safe hdisj ( hAo hc ) ( hBo hc' ) ; aesop;
    · exact cross_orbit_safe hdisj ( hAo hc' ) ( hBo hc ) |>.1 |> fun h => by rwa [ add_comm ] ;
  · simp +zetaDelta at *;
    rcases hc with ( hc | hc ) <;> rcases hc' with ( hc' | hc' );
    · exact hA.2 _ hc _ hc';
    · exact cross_orbit_safe hdisj ( hAo hc ) ( hBo hc' ) |>.2;
    · have hc_orb : c ∈ orb b := hBo hc
      have hc'_orb : c' ∈ orb a := hAo hc';
      have := cross_orbit_safe hdisj.symm hc_orb hc'_orb; (
      exact this.2);
    · exact hB.2 _ hc _ hc'

/-! ### Orbit-closed and choose function -/

lemma orbit_of_mem_image {O : Finset (ZMod p)}
    (hO : O ∈ (Finset.univ : Finset (ZMod p)).image orb) :
    ∃ x, O = orb x := by
  obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hO
  exact ⟨x, rfl⟩

noncomputable def choose_indep (O : Finset (ZMod p)) : Finset (ZMod p) :=
  if (0 : ZMod p) ∈ O then {0}
  else if (2 : ZMod p) ∈ O then {2}
  else if h : ∃ u ∈ O, u ^ 2 - u + 1 = 0 then {h.choose}
  else
    if hne : O.Nonempty then
      let x := hne.choose
      {x, ts_map x, st_map x}
    else ∅

lemma choose_indep_subset {O : Finset (ZMod p)} (hO : ∃ x, O = orb x) :
    choose_indep O ⊆ O := by
  unfold choose_indep;
  split_ifs <;> simp_all +decide [ Finset.subset_iff ];
  · exact Exists.choose_spec ‹∃ u ∈ O, u ^ 2 - u + 1 = 0› |>.1;
  · have h_orb : ∀ x ∈ O, ts_map x ∈ O ∧ st_map x ∈ O := by
      obtain ⟨ x, rfl ⟩ := hO;
      intros y hy; exact ⟨ by
        rw [ ← orb_eq_of_mem hy ];
        exact Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_self _ _ ) ) ) ), by
        rw [ ← orb_eq_of_mem hy ];
        exact Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_of_mem ( Finset.mem_insert_self _ _ ) ) ) ⟩;
    exact ⟨ Exists.choose_spec ‹_›, h_orb _ ( Exists.choose_spec ‹_› ) ⟩

set_option maxHeartbeats 400000 in
lemma choose_indep_avoidsOne (hp5 : 5 ≤ p) {O : Finset (ZMod p)} (hO : ∃ x, O = orb x) :
    avoidsOne (choose_indep O) := by
  unfold choose_indep;
  split_ifs;
  · exact zero_indep;
  · exact two_indep hp5;
  · exact root_indep ( Classical.choose_spec ‹∃ u ∈ O, u ^ 2 - u + 1 = 0› |>.2 ) hp5;
  · rename_i h₁ h₂ h₃ h₄;
    convert triple_indep _ _ _ _ _ ;
    all_goals have := h₄.choose_spec; simp_all +decide [ Finset.ext_iff, orb ];
    · exact fun h => h₁ <| h ▸ this;
    · grind +locals;
    · intro h; have := h₃ _ this; simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ] ;
      grind +splitImp;
    · contrapose! h₂; have := hO.choose_spec ( 2⁻¹ ) ; simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ] ;
      grind;
    · exact fun h => h₂ <| h ▸ this;
  · exact ⟨ by tauto, by tauto ⟩

set_option maxHeartbeats 800000 in
lemma choose_indep_card (hp5 : 5 ≤ p) {O : Finset (ZMod p)} (hO : ∃ x, O = orb x) :
    2 * (choose_indep O).card + (if O.card = 3 then 1 else 0) = O.card := by
  cases' hO with x hx;
  by_cases h0 : 0 ∈ orb x <;> by_cases h2 : 2 ∈ orb x;
  · have h_orb_eq_orb0 : orb x = orb 0 := by
      rw [ ← orb_eq_of_mem h0 ];
    grind +locals;
  · unfold choose_indep;
    split_ifs <;> simp_all +decide;
    unfold orb at *;
    unfold s_map t_map st_map ts_map sts_map at *;
    by_cases hx : x = 0 <;> by_cases hx' : x = 1 <;> simp_all +decide;
    grind;
  · have h_orbit_2 : orb x = orb 2 := by
      rw [ ← orb_eq_of_mem h2 ];
    have h_orbit_2_elements : orb 2 = {2, -1, (2 : ZMod p)⁻¹} := by
      unfold orb;
      unfold s_map t_map st_map ts_map sts_map;
      grind +revert;
    have h_distinct : (2 : ZMod p) ≠ -1 ∧ (2 : ZMod p) ≠ (2 : ZMod p)⁻¹ ∧ (-1 : ZMod p) ≠ (2 : ZMod p)⁻¹ := by
      refine' ⟨ _, _, _ ⟩;
      · rw [ Ne.eq_def, eq_neg_iff_add_eq_zero ];
        norm_num;
        erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
      · rw [ Ne.eq_def, inv_eq_one_div, eq_div_iff ] <;> norm_num;
        · intro h; rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases h <;> contradiction;
        · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
      · rw [ Ne.eq_def, inv_eq_one_div, eq_div_iff ] <;> norm_num;
        · rw [ neg_eq_iff_add_eq_zero ] ; norm_num;
          erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
        · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
    unfold choose_indep; simp_all +decide ;
  · by_cases hroot : ∃ u ∈ orb x, u ^ 2 - u + 1 = 0;
    · have h_orbit_size : ∀ u : ZMod p, u ∈ orb x → u ^ 2 - u + 1 = 0 → orb u = {u, 1 - u} := by
        grind +locals;
      obtain ⟨ u, hu, hu' ⟩ := hroot;
      have h_orbit_size : orb x = {u, 1 - u} := by
        rw [ ← h_orbit_size u hu hu', orb_eq_of_mem hu ];
      have h_distinct : u ≠ 1 - u := by
        grind +locals;
      unfold choose_indep; aesop;
    · have h_card_triple : (choose_indep O).card = 3 := by
        unfold choose_indep;
        split_ifs <;> simp_all +decide;
        · grind +revert;
        · rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] <;> simp +decide [ * ];
          · unfold ts_map st_map;
            rw [ inv_eq_one_div, div_eq_iff ];
            · grind;
            · have := Exists.choose_spec ( Finset.card_pos.mp ( Finset.card_pos.mpr ‹_› ) );
              simp_all +decide [ sub_eq_iff_eq_add, orb ];
              rcases this with ( h | h | h | h | h | h ) <;> simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
              · grind;
              · grind +ring;
              · aesop;
              · grind;
              · grind;
          · grind +locals;
        · simp_all +decide [ orb ];
      have h_card_orbit : (orb x).card = 6 := by
        apply orbit_card_six x;
        all_goals contrapose! hroot; simp_all +decide [ orb ];
        · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
        · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
          norm_num at *;
        · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
      aesop

/-! ### Main theorem -/

set_option maxHeartbeats 1600000 in
theorem exists_large_avoiding_set (hp5 : 5 ≤ p) :
    ∃ A : Finset (ZMod p), A.card = (p - 1) / 2 ∧ avoidsOne A := by
  refine ⟨ Finset.biUnion ( Finset.image orb ( Finset.univ : Finset ( ZMod p ) ) ) ( choose_indep ), ?_, ?_ ⟩;
  · rw [ Finset.card_biUnion ];
    · have h_count_orbits : ∑ O ∈ Finset.image orb (Finset.univ : Finset (ZMod p)), (if O.card = 3 then 1 else 0) = 1 := by
        rw [ Finset.sum_eq_single ( orb 2 ) ];
        · simp +decide [ orb ];
          unfold s_map t_map st_map ts_map sts_map;
          rw [ Finset.card_eq_three ];
          refine' ⟨ 2, 1 - 2, 2⁻¹, _, _, _, _ ⟩ <;> norm_num;
          · rw [ eq_neg_iff_add_eq_zero ] ; norm_num;
            erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
          · rw [ inv_eq_one_div, eq_div_iff ] <;> norm_num;
            · intro h; rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases h <;> contradiction;
            · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
          · rw [ inv_eq_one_div, eq_div_iff ] <;> norm_num;
            · rw [ neg_eq_iff_add_eq_zero ] ; norm_num;
              erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
            · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
          · grind +qlia;
        · intro b hb hb'; split_ifs <;> simp_all +decide ;
          obtain ⟨ x, rfl ⟩ := hb;
          have h_cases : x = 0 ∨ x = 1 ∨ x = -1 ∨ x = (2 : ZMod p)⁻¹ ∨ x = 2 ∨ x ^ 2 - x + 1 = 0 := by
            contrapose! hb';
            exact absurd ‹#(orb x) = 3› ( by rw [ orbit_card_six x hb'.1 hb'.2.1 hb'.2.2.1 hb'.2.2.2.1 hb'.2.2.2.2.1 hb'.2.2.2.2.2 ] ; decide );
          rcases h_cases with ( rfl | rfl | rfl | rfl | rfl | h_cases ) <;> simp_all +decide [ orb ];
          · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
          · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
          · simp_all +decide [ s_map, t_map, st_map, ts_map, sts_map ];
            grind;
          · unfold s_map t_map st_map ts_map sts_map at * ; simp_all +decide;
            grind;
          · grind +locals;
        · exact fun h => False.elim <| h <| Finset.mem_image_of_mem _ <| Finset.mem_univ _;
      have h_sum_card : ∑ O ∈ Finset.image orb (Finset.univ : Finset (ZMod p)), O.card = p := by
        rw [ ← Finset.card_biUnion ];
        · convert Finset.card_univ;
          all_goals try infer_instance;
          · ext x; simp [orb];
          · rw [ ZMod.card ];
        · intros O hO O' hO' hOO';
          obtain ⟨ x, hx, rfl ⟩ := Finset.mem_image.mp hO; obtain ⟨ x', hx', rfl ⟩ := Finset.mem_image.mp hO'; simp_all +decide [ Finset.disjoint_left ] ;
          exact fun y hy hy' => hOO' <| orb_eq_of_mem hy ▸ orb_eq_of_mem hy' ▸ rfl;
      have h_sum_card : ∑ O ∈ Finset.image orb (Finset.univ : Finset (ZMod p)), (2 * (choose_indep O).card + (if O.card = 3 then 1 else 0)) = p := by
        rw [ Finset.sum_congr rfl fun x hx => choose_indep_card hp5 <| orbit_of_mem_image hx, h_sum_card ];
      simp_all +decide [ Finset.sum_add_distrib];
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( Nat.sub_eq_of_eq_add <| by rw [ ← Finset.mul_sum _ _ _ ] at *; linarith ) );
    · intros O hO O' hO' hne;
      obtain ⟨ x, hx, rfl ⟩ := Finset.mem_image.mp hO; obtain ⟨ x', hx', rfl ⟩ := Finset.mem_image.mp hO'; simp +decide [ *, Finset.disjoint_left ] ;
      have := orb_eq_or_disjoint x x'; simp_all +decide [ Finset.disjoint_left ] ;
      exact fun a ha hb => this ( choose_indep_subset ( orbit_of_mem_image ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) ) ha ) ( choose_indep_subset ( orbit_of_mem_image ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) ) hb );
  · simp_all +decide [ avoidsOne ];
    constructor <;> intro a x hx b y hy;
    · by_cases hxy : orb x = orb y;
      · have := choose_indep_avoidsOne hp5 ( show ∃ z, orb y = orb z from ⟨ y, rfl ⟩ );
        exact this.1 _ ( hxy ▸ hx ) _ hy;
      · have hdisj : Disjoint (orb x) (orb y) := by
          exact Or.resolve_left ( orb_eq_or_disjoint x y ) hxy;
        exact cross_orbit_safe hdisj ( choose_indep_subset ( orbit_of_mem_image ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) |> fun h => by aesop ) hx ) ( choose_indep_subset ( orbit_of_mem_image ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) |> fun h => by aesop ) hy ) |>.1;
    · by_cases h : orb x = orb y;
      · have := choose_indep_avoidsOne hp5 ( show ∃ z, orb y = orb z from ⟨ y, rfl ⟩ );
        exact this.2 a ( by aesop ) b ( by aesop );
      · have h_disjoint : Disjoint (orb x) (orb y) := by
          exact Classical.not_not.1 fun h' => h <| by have := orb_eq_or_disjoint x y; tauto;
        exact cross_orbit_safe h_disjoint ( choose_indep_subset ( ⟨ x, rfl ⟩ ) hx ) ( choose_indep_subset ( ⟨ y, rfl ⟩ ) hy ) |>.2

/-! ## Corollary 2.3: Sárközy's Conjecture 65 is false -/

lemma avoidsOne_card_le (hp5 : 5 ≤ p) (A : Finset (ZMod p)) (hA : avoidsOne A) :
    A.card ≤ (p - 1) / 2 := by
      by_contra h_contra
      have h_sumset : A + A = Finset.univ := by
        apply sumset_eq_univ;
        linarith [ Nat.div_mul_cancel ( show 2 ∣ p - 1 from even_iff_two_dvd.mp ( hp.1.even_sub_one <| by linarith ) ), Nat.sub_add_cancel hp.1.pos ];
      simp_all +decide [ Finset.ext_iff ];
      obtain ⟨ a, b, ha, hb, hab ⟩ := Finset.mem_add.mp ( h_sumset 1 );
      exact hA.1 a b ha hb hab

/-- Remark 2.4: the exact extremal value is `(p - 1) / 2`. -/
theorem exact_extremal_value (hp5 : 5 ≤ p) :
    IsGreatest {n | ∃ A : Finset (ZMod p), A.card = n ∧ avoidsOne A} ((p - 1) / 2) := by
  constructor
  · exact exists_large_avoiding_set hp5
  · intro n ⟨A, hAn, hA⟩
    rw [← hAn]
    exact avoidsOne_card_le hp5 A hA

/-- Corollary 2.3: Sárközy's Conjecture 65/1.1 is false. For every `c > 0` and
`p₀ : ℕ`, there exists a prime `p > p₀` and a set `A ⊆ 𝔽_p` with
`|A| > (1/2 - c) * p` such that `1 ∉ A + A` and `1 ∉ A * A`. -/
theorem sarkozy_conjecture_false :
    ∀ (c : ℝ) (_ : 0 < c) (p₀ : ℕ),
    ∃ (p : ℕ) (_ : Fact (Nat.Prime p)),
      p₀ < p ∧
      ∃ A : Finset (ZMod p),
        (A.card : ℝ) > (1/2 - c) * p ∧ avoidsOne A := by
          intro c hc₁;
          have h_exists_A : ∀ (p : ℕ) (_ : Fact (Nat.Prime p)) (hp : 5 ≤ p), ∃ A : Finset (ZMod p), A.card = (p - 1) / 2 ∧ avoidsOne A := by
            intro p x hp; exact exists_large_avoiding_set hp;
          intro p₀
          obtain ⟨p, hp⟩ : ∃ p : ℕ, Fact (Nat.Prime p) ∧ p₀ < p ∧ 5 ≤ p ∧ (p - 1) / 2 > (1 / 2 - c) * p := by
            obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_infinite_primes ( p₀ + 5 + ⌈ ( c ) ⁻¹ * 2⌉₊ + 1 );
            refine' ⟨ p, ⟨ hp₂ ⟩, by linarith, by linarith, _ ⟩;
            nlinarith [ Nat.le_ceil ( c⁻¹ * 2 ), mul_inv_cancel₀ hc₁.ne', show ( p : ℝ ) ≥ p₀ + 5 + ⌈c⁻¹ * 2⌉₊ + 1 by exact_mod_cast hp₁ ];
          obtain ⟨ A, hA₁, hA₂ ⟩ := h_exists_A p hp.1 hp.2.2.1;
          refine' ⟨ p, hp.1, hp.2.1, A, _, hA₂ ⟩;
          rcases Nat.even_or_odd' p with ⟨ k, rfl | rfl ⟩ <;> norm_num at *;
          · exact absurd ( hp.1.1.eq_two_or_odd ) ( by omega );
          · grind

/-- Combined statement: the sharp threshold is exactly `1/2`. -/
theorem sarkozy_threshold_sharp (hp5 : 5 ≤ p) :
    (∀ A : Finset (ZMod p), p < A.card * 2 → A + A = Finset.univ) ∧
    (∃ A : Finset (ZMod p), A.card = (p - 1) / 2 ∧ avoidsOne A) :=
  ⟨sumset_eq_univ, exists_large_avoiding_set hp5⟩

#print axioms sarkozy_threshold_sharp
#print axioms exact_extremal_value
#print axioms sarkozy_conjecture_false

end FragileProofAudit.Sarkozy

end
