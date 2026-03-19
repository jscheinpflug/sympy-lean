namespace SymbolicLean

inductive Dim where
  | static : Nat → Dim
  | dyn : Lean.Name → Dim
  deriving Repr, DecidableEq, BEq, Hashable

end SymbolicLean
