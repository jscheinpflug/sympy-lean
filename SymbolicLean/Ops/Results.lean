import SymbolicLean.SymExpr.Core

namespace SymbolicLean

structure FiniteSolve (s : SessionTok) (σ : SSort) where
  solutions : List (SymExpr s σ)

inductive EvalOr (α : Type) where
  | value : α → EvalOr α
  | unknown : EvalOr α
  deriving Repr, DecidableEq, Inhabited

structure ODESolution (s : SessionTok) where
  equation : SymExpr s .boolean

structure SolveSetResult (s : SessionTok) (σ : SSort) where
  setExpr : SymExpr s (.set σ)

structure SatAssignment where
  name : String
  value : Bool
  deriving Repr, DecidableEq, Inhabited

inductive SatisfiableResult where
  | unsat
  | model (assignments : List SatAssignment)
  deriving Repr, DecidableEq, Inhabited

end SymbolicLean
