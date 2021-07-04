import definitions
import rotations
import forall_keys
import tactic.linarith
import tactic.omega
set_option pp.generalized_field_notation false

universe u

namespace insertion_balanced_lemmas
open btree
open rotation_lemmas
open forall_keys_lemmas

variables {α : Type u}

lemma forall_insert_balanced (k x : nat) (t : btree α) (a : α) (p : nat → nat → Prop) (h : p x k) :
  forall_keys p x t → forall_keys p x (insert_balanced k a t) :=
begin
  intro h₁,
  induction t,
  case empty {
    unfold forall_keys,
    intros k' h₂,
    simp [insert_balanced, bound] at h₂,
    subst h₂,
    exact h,
  },
  case node : tl tk ta tr ihl ihr {
    unfold forall_keys at ihl ihr h₁,
    simp only [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁], 
      by_cases c₂ : (height (insert_balanced k a tl) > height tr + 1),
      { simp only [if_pos c₂], 
        apply forall_rotate_right,
        apply forall_keys_intro,
        unfold forall_keys,
        repeat { split },
        { apply ihl,
          intros k' h₂,
          apply h₁,
          simp [bound],
          tauto,
        },
        { apply h₁, 
          simp [bound],
        },
        { intros k' h₂, 
          apply h₁,
          simp [bound],
          tauto,
        },
      },
      { simp only [if_neg c₂], 
        apply forall_keys_intro,
        unfold forall_keys,
        repeat { split },
        { apply ihl, 
          intros k' h₂,
          apply h₁,
          simp [bound],
          tauto,
        },
        { apply h₁, 
          simp [bound],
        },
        { intros k' h₂, 
          apply h₁,
          simp [bound],
          tauto,
        },
      },
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height (insert_balanced k a tr) > height tl + 1),
        { simp only [if_pos c₃], 
          apply forall_rotate_left,
          apply forall_keys_intro,
          unfold forall_keys,
          repeat { split },
          { intros k' h₂, 
            apply h₁,
            simp [bound],
            tauto,
          },
          { apply h₁, 
            simp [bound],
          },
          { apply ihr, 
            intros k' h₂,
            apply h₁,
            simp [bound],
            tauto,
          },
        },
        { simp only [if_neg c₃],
          apply forall_keys_intro,
          unfold forall_keys,
          repeat { split },
          { intros k' h₂, 
            apply h₁,
            simp [bound],
            tauto,
          },
          { apply h₁, 
            simp [bound],
          },
          { apply ihr,
            intros k' h₂,
            apply h₁,
            simp [bound],
            tauto,
          }, 
        },
      },
      { simp only [if_neg c₂], 
        have h : k = tk := by linarith,
        unfold forall_keys,
        intros k' h₂,
        apply h₁,
        rw h at h₂,
        exact h₂,
      },
    },
  },
end

lemma insert_ordered (t : btree α) (k : nat) (v : α) :
  ordered t → ordered (insert_balanced k v t) :=
begin
  intro h₁,
  induction t,
  case empty {
    simp [insert_balanced, ordered, forall_keys],
    split,
    { intros k' h₂, 
      simp [bound] at h₂,
      contradiction,
    },
    { intros k' h₂, 
      simp [bound] at h₂,
      contradiction,
    },
  },
  case node : tl tk ta tr ihl ihr {
    simp only [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁], 
      by_cases c₂ : (height (insert_balanced k v tl) > height tr + 1),
      { simp only [if_pos c₂], 
        apply rotate_right_ordered,
        rw ordered at h₁ ⊢,
        cases_matching* (_ ∧ _),
        repeat { split }; try { assumption },
        { apply ihl, assumption, },
        { apply forall_insert_balanced,
          { sorry },
          { assumption },
        },
      },
      { simp only [if_neg c₂],
        rw ordered at h₁ ⊢,
        cases_matching* (_ ∧ _),
        repeat { split }; try { assumption },
        { apply ihl, assumption, },
        { apply forall_insert_balanced, 
          { sorry },
          { assumption, },
        }
      },
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height (insert_balanced k v tr) > height tl + 1),
        { simp only [if_pos c₃], 
          apply rotate_left_ordered,
          rw ordered at h₁ ⊢,
          cases_matching* (_ ∧ _),
          repeat { split }; try { assumption },
          { apply ihr, assumption, },
          { apply forall_insert_balanced,
            { sorry },
            { assumption, },
          }
        },
        { simp only [if_neg c₃], 
          rw ordered at h₁ ⊢,
          cases_matching* (_ ∧ _),
          repeat { split }; try { assumption },
          { apply ihr, assumption, },
          { apply forall_insert_balanced, 
            { sorry },
            { assumption, },
          },
        },
      },
      { simp only [if_neg c₂], 
        have h : k = tk := by linarith,
        subst h,
        exact h₁,
      },
    },
  },
end

lemma insert_balanced_bound (t : btree α) (k : nat) (v : α) :
  bound k (insert_balanced k v t) :=
begin
  induction t,
  case empty {
    simp [insert_balanced, bound],
  },
  case node : tl tk ta tr ihl ihr {
    simp [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁], 
      by_cases c₂ : (height tr + 1 < height (insert_balanced k v tl)),
      { simp only [if_pos c₂], 
        apply rotate_right_keys,
        simp [bound],
        tauto,
      },
      { simp only [if_neg c₂], 
        simp [bound],
        tauto,
      },
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (tk < k),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height tl + 1 < height (insert_balanced k v tr)),
        { simp only [if_pos c₃], 
          apply rotate_left_keys,
          simp [bound],
          tauto,
        },
        { simp only [if_neg c₃], 
          simp [bound],
          tauto,
        },
      },
      { simp [if_neg c₂, bound], },
    },
  },
end

lemma insert_balanced_diff_bound (t : btree α) (k x : nat) (v : α) :
  bound x t → bound x (insert_balanced k v t) :=
begin
  intro h₁,
  induction t,
  case empty {
    simp [insert_balanced, bound],
    simp [bound] at h₁,
    contradiction,
  },
  case node : tl tk ta tr ihl ihr {
    simp only [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁], 
      by_cases c₂ : (height (insert_balanced k v tl) > height tr + 1),
      { simp only [if_pos c₂], 
        apply rotate_right_keys,
        simp [bound],
        simp [bound] at h₁,
        tauto,
      },
      { simp only [if_neg c₂], 
        simp [bound],
        simp [bound] at h₁,
        tauto,
      },
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height (insert_balanced k v tr) > height tl + 1),
        { simp only [if_pos c₃], 
          apply rotate_left_keys,
          simp [bound],
          simp [bound] at h₁,
          tauto,
        },
        { simp only [if_neg c₃],
          simp [bound],
          simp [bound] at h₁,
          tauto,
        },
      },
      { simp only [if_neg c₂], 
        simp [bound],
        simp [bound] at h₁,
        have h : k = tk := by linarith,
        subst h,
        exact h₁,
      },
    },
  },
end

lemma insert_balanced_nbound (t : btree α) (k x : nat) (v : α) :
  (bound x t = ff ∧ x ≠ k) → bound x (insert_balanced k v t) = ff :=
begin
  intro h₁,
  induction t,
  case empty {
    simp [insert_balanced, bound],
    finish,
  },
  case node : tl tk ta tr ihl ihr {
    simp only [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁],
      by_cases c₂ : (height (insert_balanced k v tl) > height tr + 1),
      { simp only [if_pos c₂], 
        apply rotate_right_keys,
        simp [bound] at *,
        tauto,
      },
      { simp only [if_neg c₂],
        simp [bound] at *,
        tauto, 
      }, 
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (tk < k),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height (insert_balanced k v tr) > height tl + 1),
        { simp only [if_pos c₃],
          apply rotate_left_keys,
          simp [bound] at *,
          tauto, 
        },
        { simp only [if_neg c₃], 
          simp [bound] at *,
          tauto,
        },
      },
      { simp only [if_neg c₂], 
        simp [bound] at *,
        tauto,
      },
    },
  },
end

/- If you check the bound on a key just inserted into the tree, it will return true -/
lemma bound_insert_eq (k : nat) (t : btree α) (v : α) :
  bound k (insert_balanced k v t) = tt :=
begin
  induction t,
  case empty {
    simp [insert_balanced, bound],
  },
  case node : tl tk ta tr ihl ihr {
    simp only [insert_balanced],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁], 
      by_cases c₂ : (height (insert_balanced k v tl) > height tr + 1),
      { simp only [if_pos c₂], 
        apply rotate_right_keys,
        simp [bound],
        apply or.inr (or.inl ihl),
      },
      { simp [if_neg c₂, bound],
        apply or.inr (or.inl ihl),
      },
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp only [if_pos c₂], 
        by_cases c₃ : (height (insert_balanced k v tr) > height tl + 1),
        { simp only [if_pos c₃], 
          apply rotate_left_keys,
          simp [bound],
          apply or.inr (or.inr ihr),
        },
        { simp [if_neg c₃, bound],
          apply or.inr (or.inr ihr), 
        },
      },
      { simp [if_neg c₂, bound], },
    },
  },
end

end insertion_balanced_lemmas