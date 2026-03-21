import Lean.Data.Json

namespace SymbolicLean

open Lean

inductive Dim where
  | static : Nat → Dim
  | dyn : Lean.Name → Dim
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

end SymbolicLean
