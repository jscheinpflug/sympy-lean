import Lean.Data.Json
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

declare_op diffExprCore {σ : SSort} {d : DomainDesc}
  for (expr : SymExpr s σ) (x : SymSymbol s (.scalar d)) (order : Nat) returns σ => "diff"
  doc "Differentiate a realized expression with respect to a realized scalar symbol."

def diffExpr (expr : SymExpr s σ) (x : SymSymbol s (.scalar d)) (order : Nat := 1) :
    SymPyM s (SymExpr s σ) :=
  diffExprCore expr x order

declare_op integrate for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  returns (.scalar d) => "integrate"
  doc "Form a realized indefinite integral over a realized scalar symbol."

declare_op limitExpr for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  (atPoint : SymExpr s (.scalar d)) returns (.scalar d) => "limit"
  doc "Compute a realized limit at a realized scalar point."

declare_op seriesExprCore for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  (atPoint : SymExpr s (.scalar d)) (order : Nat) returns (.scalar d) => "series"
  doc "Compute a realized series expansion to the requested order."

def seriesExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
    (atPoint : SymExpr s (.scalar d)) (order : Nat) : SymPyM s (SymExpr s (.scalar d)) :=
  seriesExprCore expr x atPoint order

end SymbolicLean
