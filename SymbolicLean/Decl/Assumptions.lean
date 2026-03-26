import Lean.Data.Json

namespace SymbolicLean

open Lean

inductive Assumption where
  | positive
  | negative
  | nonnegative
  | nonpositive
  | nonzero
  | zero
  | integer
  | rational
  | irrational
  | real
  | complex
  | imaginary
  | odd
  | even
  | finite
  | infinite
  | prime
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
