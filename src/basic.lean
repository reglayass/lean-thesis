universe u

inductive btree (α : Type u)
| empty {} : btree
| leaf (k : nat) (a : α) : btree
| node (l : btree) (k : nat) (a : α) (r : btree) : btree

namespace btree
variables {α : Type u}

def empty_tree : btree α := btree.empty

def lookup (x : nat) : btree α → option α
| btree.empty := none
| (btree.leaf k a) := if x = k then a else none
| (btree.node l k a r) := 
  if x < k then lookup l 
  else if x > k then lookup r 
  else a

def bound (x : nat) : btree α → bool
| btree.empty := ff
| (btree.leaf k a) := if x = k then tt else ff
| (btree.node l k a r) :=
  if x < k then bound l
  else if x > k then bound r
  else tt

def insert (x : nat) (a : α) : btree α → btree α
| btree.empty := btree.node btree.empty x a btree.empty
| (btree.leaf k a') :=
  if x < k then btree.node (btree.leaf x a) k a' btree.empty 
  else if x > k then btree.node btree.empty k a' (btree.leaf x a)
  else btree.leaf x a
| (btree.node l k a' r) :=
  if x < k then btree.node (insert l) k a' r
  else if x > k then btree.node l k a' (insert r)
  else btree.node l x a r

section ordering

def forall_keys (p : nat → nat → Prop) : nat → btree α → Prop
| x btree.empty := tt
| x (btree.leaf k a) := (p x k) -- idk if this is right
| x (btree.node l k a r) := 
  forall_keys x l ∧ (p x k) ∧ forall_keys x r

def ordered : btree α → Prop
| btree.empty := tt 
| (btree.leaf k a) := tt -- idk if this is right
| (btree.node l k a r) := 
  ordered l ∧ ordered r ∧ (forall_keys (>) k l) ∧ (forall_keys (<) k r)

end ordering

-- section balancing

-- def height : btree α → nat
-- | btree.empty := 0
-- | (btree.node l k a r) :=
--   1 + (max (height l) (height r))

-- def outLeft : btree α → bool
-- | btree.empty := ff
-- | (btree.node l k a r) :=
--   match l with
--   | btree.empty := ff
--   | (btree.node ll lk la lr) := 
--     (height ll ≥ height lr) ∧ (height ll ≤ height lr + 1) ∧ 
--     (height lr ≥ height r) ∧ (height ll = height r + 1)
--   end

-- def outRight : btree α → bool
-- | btree.empty := ff
-- | (btree.node l k a r) :=
--   match r with
--   | btree.empty := ff
--   | (btree.node rl rk ra rr) :=
--     (height rl ≤ height rr) ∧ (height rl ≤ height rr + 1) ∧
--     (height rr ≥ height l) ∧ (height l + 1 = height rr)
--   end

-- def easyR : btree α → btree α
-- | btree.empty := btree.empty
-- | (btree.node l k a r) :=
--   match l with
--     | btree.empty := (btree.node l k a r)
--     | (btree.node ll lk la lr) := (btree.node ll lk la (btree.node lr k a r))
--   end

-- def easyL : btree α → btree α
-- | btree.empty := btree.empty
-- | (btree.node l k a r) :=
--   match r with
--   | btree.empty := (btree.node l k a r)
--   | (btree.node rl rk ra rr) := (btree.node (btree.node l k a rl) rk ra rr)
--   end

-- end balancing

end btree