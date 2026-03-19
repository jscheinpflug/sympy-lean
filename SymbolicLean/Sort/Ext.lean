namespace SymbolicLean

inductive SymExt where
  | geometry
  | combinatorics
  | stats
  | physics
  | indexedTensors
  | codegen
  | numberTheory
  | other : Lean.Name → SymExt
  deriving Repr, DecidableEq, BEq, Hashable

end SymbolicLean
