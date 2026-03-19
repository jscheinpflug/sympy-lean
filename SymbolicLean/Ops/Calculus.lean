import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

open Lean

private def refArg (expr : SymExpr s σ) : Json :=
  encodeRefArg expr.ref.ident

def diffExpr (expr : SymExpr s σ) (x : SymSymbol s (.scalar d)) (order : Nat := 1) :
    SymPyM s (SymExpr s σ) := do
  let ref ← applyOpRemoteRef σ "diff" expr.ref [refArg x.expr, toJson order]
  pure { ref := ref }

def integrate (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (SymExpr s (.scalar d)) := do
  let ref ← applyOpRemoteRef (.scalar d) "integrate" expr.ref [refArg x.expr]
  pure { ref := ref }

def limitExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
    (atPoint : SymExpr s (.scalar d)) : SymPyM s (SymExpr s (.scalar d)) := do
  let ref ← applyOpRemoteRef (.scalar d) "limit" expr.ref [refArg x.expr, refArg atPoint]
  pure { ref := ref }

def seriesExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
    (atPoint : SymExpr s (.scalar d)) (order : Nat) : SymPyM s (SymExpr s (.scalar d)) := do
  let ref ←
    applyOpRemoteRef (.scalar d) "series" expr.ref [refArg x.expr, refArg atPoint, toJson order]
  pure { ref := ref }

end SymbolicLean
