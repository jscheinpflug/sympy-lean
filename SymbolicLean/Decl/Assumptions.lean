import Lean.Data.Json

namespace SymbolicLean

open Lean

inductive Assumption where
  | positive
  | nonnegative
  | nonzero
  | integer
  | rational
  | real
  | complex
  | finite
  | invertible
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

inductive Polarity where
  | affirm
  | deny
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

structure AssumptionFact where
  assumption : Assumption
  polarity : Polarity := .affirm
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

end SymbolicLean
