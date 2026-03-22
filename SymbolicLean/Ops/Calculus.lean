import Lean.Data.Json
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

declare_op diffExprCore {σ : SSort} {d : DomainDesc}
  for (expr : SymExpr s σ) (x : SymSymbol s (.scalar d)) (order : Nat) returns σ => "diff"
  doc "Differentiate a realized expression with respect to a realized scalar symbol."
register_op diffExprCore => "diff" dispatch_namespace

def diffExpr (expr : SymExpr s σ) (x : SymSymbol s (.scalar d)) (order : Nat := 1) :
    SymPyM s (SymExpr s σ) :=
  diffExprCore expr x order

declare_op integrateExpr for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  returns (.scalar d) => "integrate"
  doc "Ask SymPy to construct the realized indefinite integral of a scalar expression with respect to a realized scalar symbol."
register_op integrateExpr => "integrate" dispatch_namespace

declare_op limitExpr for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  (atPoint : SymExpr s (.scalar d)) returns (.scalar d) => "limit"
  doc "Compute a realized limit at a realized scalar point."
register_op limitExpr => "limit" dispatch_namespace

declare_op seriesExprCore for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  (atPoint : SymExpr s (.scalar d)) (order : Nat) returns (.scalar d) => "series"
  doc "Compute a realized series expansion to the requested order."
register_op seriesExprCore => "series" dispatch_namespace

def seriesExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
    (atPoint : SymExpr s (.scalar d)) (order : Nat) : SymPyM s (SymExpr s (.scalar d)) :=
  seriesExprCore expr x atPoint order

end SymbolicLean
