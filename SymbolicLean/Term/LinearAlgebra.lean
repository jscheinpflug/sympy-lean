import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean

declare_pure_head Trace {d : DomainDesc} {n : Dim}
  for (matrix : .matrix d n n) returns (.scalar d) => "Trace"
  sympy_alias
  doc "Pure matrix-trace head backed by SymPy's `Trace`."

end SymbolicLean
