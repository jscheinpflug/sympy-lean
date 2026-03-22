import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

declare_op doitExpr for (expr : SymExpr s σ) returns σ => "doit"
  doc "Force evaluation of an unevaluated realized SymPy expression such as an `Integral`, `Sum`, or `Product`."
register_op doitExpr => "doit" dispatch_method

declare_op evalfExpr for (expr : SymExpr s (.scalar d)) (precision : Nat)
  returns (.scalar d) => "evalf"
  doc "Numerically evaluate a realized scalar expression using the requested decimal precision."
register_op evalfExpr => "evalf" dispatch_method

declare_op latexText for (expr : SymExpr s σ)
  decodes String => "latex"
  doc "Render a realized SymPy expression as a LaTeX string."
register_op latexText => "latex" dispatch_namespace

end SymbolicLean
