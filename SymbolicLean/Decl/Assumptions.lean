namespace SymbolicLean

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
  deriving Repr, DecidableEq, BEq, Hashable

inductive Polarity where
  | affirm
  | deny
  deriving Repr, DecidableEq, BEq, Hashable

structure AssumptionFact where
  assumption : Assumption
  polarity : Polarity := .affirm
  deriving Repr, DecidableEq, BEq, Hashable

end SymbolicLean
