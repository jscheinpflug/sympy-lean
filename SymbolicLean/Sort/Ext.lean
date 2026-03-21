import Lean.Data.Json

namespace SymbolicLean

open Lean

inductive SymExt where
  | geometry
  | combinatorics
  | stats
  | physics
  | indexedTensors
  | codegen
  | numberTheory
  | other : Lean.Name → SymExt
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

end SymbolicLean
