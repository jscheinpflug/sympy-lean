import Lean.Data.Json

namespace SymbolicLean

open Lean

inductive Truth where
  | true_
  | false_
  | unknown
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

inductive RelKind where
  | eq
  | ne
  | lt
  | le
  | gt
  | ge
  | mem
  | subset
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

end SymbolicLean
