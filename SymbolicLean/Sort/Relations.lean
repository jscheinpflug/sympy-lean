namespace SymbolicLean

inductive Truth where
  | true_
  | false_
  | unknown
  deriving Repr, DecidableEq, BEq, Hashable

inductive RelKind where
  | eq
  | ne
  | lt
  | le
  | gt
  | ge
  | mem
  | subset
  deriving Repr, DecidableEq, BEq, Hashable

end SymbolicLean
