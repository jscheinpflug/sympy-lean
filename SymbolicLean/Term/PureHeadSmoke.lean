import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean.Smoke

declare_scalar_fn₁ smokeUnary => "sin" sympy_alias
  doc "Unary scalar smoke head generated through `declare_pure_head`, backed by `sympy.sin`."

declare_scalar_fn₂ smokeBinary => "atan2"
  doc "Binary scalar smoke head generated through `declare_pure_head`, backed by `sympy.atan2`."

declare_op sreprText {d : DomainDesc} for (expr : SymExpr s (.scalar d))
  decodes String => "srepr"
  doc "String-decoding effectful smoke op used to exercise the generic `[FromJson α]` payload path."

end SymbolicLean.Smoke
