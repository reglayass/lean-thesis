import btree
import tactic.linarith
set_option pp.generalized_field_notation false

namespace ordered_lemmas
open btree_def

-- lemma forall_insert {α : Type} (l : btree α) (k k' : nat) (a : α) (p : nat → nat → Prop) (h : p k k') :
--   forall_keys p k' l → forall_keys p k' (insert k a l) :=
-- begin
--   intro h₁,
--   induction l,
--   case empty {
--     simp [btree_def.insert, forall_keys],
--     simp only [forall_keys] at h₁,
--     sorry 
--   },
--   case node : tl tk ta tr ihl ihr {
--     simp only [btree_def.insert],
--     by_cases c₁ : (k < tk),
--     { simp only [if_pos c₁], 
--       sorry
--     },
--     { simp only [if_neg c₁], 
--       by_cases c₂ : (k > tk),
--       { simp only [if_pos c₂], 
--         simp only [forall_keys],
--         simp only [forall_keys] at h₁,
--         apply and.intro,
--         { apply and.elim_left h₁ },
--         { apply and.intro, 
--           { apply and.elim_left (and.elim_right h₁) },
--           { sorry }
--         }
--       },
--       { simp only [if_neg c₂, forall_keys], 
--         simp only [forall_keys] at h₁,
--         apply and.intro,
--         {  },
--         { sorry }
--       }
--     }
--   }
-- end

lemma ordered_insert {α : Type} (t : btree α) (k : nat) (a : α) :
  ordered t → ordered (insert k a t) :=
begin
  intro h₁,
  induction t,
  case empty {
    simp only [btree_def.insert, ordered],
    apply and.intro,
    { simp },
    { apply and.intro,
      simp,
      apply and.intro,
      { simp [forall_keys] },
      { simp [forall_keys] }
    }
  },
  case node : tl tk ta tr ihl ihr {
    simp only [btree_def.insert],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁, ordered],
      apply and.intro,
      { apply ihl,
        simp [ordered] at h₁,
        apply and.elim_left h₁ 
      },
      { apply and.intro,
        { simp [ordered] at h₁,
          apply and.elim_left (and.elim_right h₁),
        },
        { apply and.intro, 
          { simp only [ordered] at h₁, 
            sorry
          },
          { simp only [ordered] at h₁,
            apply and.elim_right 
              (and.elim_right 
                (and.elim_right h₁)),
          }
        }
      }
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp [if_pos c₂, ordered],
        apply and.intro,
        { simp [ordered] at h₁, 
          apply and.elim_left h₁
        },
        { apply and.intro,
          { apply ihr, 
            simp [ordered] at h₁,
            apply and.elim_left (and.elim_right h₁),
          },
          { apply and.intro,
            { simp [ordered] at h₁,
              apply and.elim_left (and.elim_right (and.elim_right h₁)), 
            },
            { sorry }
          }
        } 
      },
      { simp only [if_neg c₂, ordered], 
        apply and.intro,
        { simp [ordered] at h₁, 
          apply and.elim_left h₁,
        },
        { apply and.intro,
          { simp [ordered] at h₁,
            apply and.elim_left (and.elim_right h₁), 
          },
          { apply and.intro,
            { sorry },
            { sorry } 
          } 
        }
      }
    }
  }
end

-- inversion lemmas!

lemma ordered_lookup {α : Type} (t : btree α) (k : nat) :
  ordered t → bound k t → ∃ (v: α), (lookup k t = some v) :=
begin
  intros h₁ h₂,
  induction t,
  case empty {
    simp only [lookup],
    simp [bound] at h₂,
    contradiction,
  },
  case node : tl tk ta tr ihl ihr {
    simp only [lookup],
    by_cases c₁ : (k < tk),
    { simp only [if_pos c₁],
      apply ihl,
      { simp only [ordered] at h₁, 
        apply and.elim_left h₁,
      },
      { simp only [bound, if_pos c₁] at h₂,
        exact h₂,
      }
    },
    { simp only [if_neg c₁], 
      by_cases c₂ : (k > tk),
      { simp only [if_pos c₂],
        apply ihr,
        { simp only [ordered] at h₁,
          apply and.elim_left (and.elim_right h₁),
        },
        { simp only [bound, if_neg c₁, if_pos c₂] at h₂,
          exact h₂,
        },
      },
      { simp only [if_neg c₂], 
        existsi ta,
        refl,
      }
    }
  }
end

end ordered_lemmas