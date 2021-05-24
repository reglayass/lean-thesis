universe u

inductive btree (α : Type u)
| empty {} : btree
| node (l : btree) (k : nat) (a : α) (r : btree) : btree

namespace btree
variables {α : Type u}

def empty_tree : btree α := btree.empty

def lookup (x : nat) : btree α → option α
| btree.empty := none
| (btree.node l k a r) := 
  if x < k then lookup l 
  else if x > k then lookup r 
  else a

def bound (x : nat) : btree α → bool
| btree.empty := ff
| (btree.node l k a r) :=
  x = k ∨ bound l ∨ bound r

def insert (x : nat) (a : α) : btree α → btree α
| btree.empty := btree.node btree.empty x a btree.empty
| (btree.node l k a' r) :=
  if x < k then btree.node (insert l) k a' r
  else if x > k then btree.node l k a' (insert r)
  else btree.node l x a r

def forall_keys (p : nat → nat → Prop) : btree α → nat → Prop
| btree.empty x := tt
| (btree.node l k a r) x := 
  forall_keys l x ∧ (p x k) ∧ forall_keys r x

def ordered : btree α → Prop
| btree.empty := tt 
| (btree.node l k a r) := 
  ordered l ∧ ordered r ∧ (forall_keys (>) l k) ∧ (forall_keys (<) r k)

def height : btree α → nat
| btree.empty := 0
| (btree.node l k a r) :=
  1 + (max (height l) (height r))

def balanced : btree α → bool
| btree.empty := tt
| (btree.node l k a r) :=
  if height l ≥ height r then height l ≤ height r + 1
  else height r ≤ height l + 1

def outLeft : btree α → bool
| btree.empty := ff
| (btree.node l k a r) :=
  match l with
  | btree.empty := ff
  | (btree.node ll lk la lr) := 
    (height ll ≥ height lr) ∧ (height ll ≤ height lr + 1) ∧ 
    (height lr ≥ height r) ∧ (height r + 1 = height ll)
  end

def outRight : btree α → bool
| btree.empty := ff
| (btree.node l k a r) :=
  match r with
  | btree.empty := ff
  | (btree.node rl rk ra rr) :=
    (height rr ≥ height rl) ∧ (height rr ≤ height rl + 1) ∧ 
    (height rl ≤ height l) ∧ (height l + 1 = height rr)
  end

def easyR : btree α → btree α
| btree.empty := btree.empty
| (btree.node (btree.node ll lk la lr) k a r) := btree.node ll lk la (btree.node lr k a r)
| (btree.node l k a r) := btree.node l k a r

def easyL : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k a (btree.node rl rk ra rr)) := (btree.node (btree.node l k a rl) rk ra rr)
| (btree.node l k a r) := btree.node l k a r

def rotR : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k a r) :=
  match l with
  | btree.empty := (btree.node l k a r)
  | (btree.node ll lk la lr) := 
    if height ll < height lr then easyR (btree.node (easyL l) k a r)
    else easyR (btree.node l k a r)
  end

def rotL : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k a r) :=
  match r with 
  | btree.empty := (btree.node l k a r)
  | (btree.node rl rk ra rr) :=
    if height rr < height rl then easyL (btree.node l k a (easyR r))
    else easyL (btree.node l k a r)
  end

def balance : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k a r) :=
  if outLeft (btree.node l k a r) then rotR (btree.node (balance l) k a r)
  else if outRight (btree.node l k a r) then rotL (btree.node l k a (balance r))
  else btree.node l k a r

def insert_balanced (x : nat) (v : α) : btree α → btree α
| btree.empty := btree.node btree.empty x v btree.empty
| (btree.node l k a r) :=
  let nl := insert_balanced l in
  let nr := insert_balanced r in
  if x < k then 
    if height nl > height r + 1 then rotR (btree.node nl k a r)
    else btree.node nl k a r
  else if x > k then 
    if height nr > height l + 1 then rotL (btree.node l k a nr)
    else btree.node l k a nr
  else btree.node l x v r

def shrink : btree α → option (nat × α × btree α)
| btree.empty := none
| (btree.node l k v r) :=
  match shrink r with
  | none := (k, v, l)
  | some (x, a, sh) := 
    if height l > height sh + 1 then (x, a, rotR (btree.node sh k v l))
    else (x, a, (btree.node sh k v l))
  end

def delRoot : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k v r) :=
  match shrink l with
  | none := r
  | some (x, a, sh) :=
    if height r > height sh + 1 then rotL (btree.node sh x a r)
    else btree.node sh x a r
  end

def delete (x : nat) : btree α → btree α
| btree.empty := btree.empty
| (btree.node l k a r) := 
  let dl := delete l in
  let dr := delete r in
  if x = k then delRoot (btree.node l k a r)
  else if x < k then 
    if height r > height dl + 1 then rotL (btree.node dl k a r)
    else btree.node dl k a r
  else if height l > height dr + 1 then rotR (btree.node l k a dr)
  else (btree.node l k a dr)

end btree