import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

declare_op doitExpr for (expr : SymExpr s σ) returns σ => "doit"
  doc "Force evaluation of an unevaluated realized SymPy expression such as an `Integral`, `Sum`, or `Product`."

declare_op evalfExpr for (expr : SymExpr s (.scalar d)) (precision : Nat)
  returns (.scalar d) => "evalf"
  doc "Numerically evaluate a realized scalar expression using the requested decimal precision."

declare_op latexText for (expr : SymExpr s σ)
  decodes String => "latex"
  doc "Render a realized SymPy expression as a LaTeX string."

end SymbolicLean
