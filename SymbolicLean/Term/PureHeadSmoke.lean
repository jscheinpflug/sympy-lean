import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Decode
import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean.Smoke

declare_scalar_fn₁ smokeUnary => "sin" sympy_alias
  doc "Unary scalar smoke head generated through `declare_pure_head`, backed by `sympy.sin`."

declare_scalar_fn₁ smokeUnaryDupA => "sin"
  doc "Unary scalar smoke head sharing `sin` as a backend name to exercise duplicate-backend reify identity."

declare_scalar_fn₁ smokeUnaryDupB => "sin"
  doc "Second unary scalar smoke head sharing `sin` as a backend name to exercise duplicate-backend reify identity."

declare_scalar_fn₂ smokeBinary => "atan2"
  doc "Binary scalar smoke head generated through `declare_pure_head`, backed by `sympy.atan2`."

declare_op sreprText {d : DomainDesc} for (expr : SymExpr s (.scalar d))
  decodes String => "srepr"
  doc "String-decoding effectful smoke op used to exercise the generic `[FromJson α]` payload path."

register_op sreprText => "srepr" dispatch_namespace

def sreprDottedText (expr : SymExpr s (.scalar d)) : SymPyM s String := do
  let payload ← decodeJsonInfo (← applyOpRemote "printing.repr.srepr" expr.ref)
  let decoded : String ← OpPayloadDecode.decodePayload payload
  pure decoded

register_op sreprDottedText => "printing.repr.srepr" dispatch_namespace
  doc "Dotted namespace-function smoke op used to exercise manifest-driven effectful dispatch."

def doitShallowExpr (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) := do
  let kwargs := encodeKwArgs [opKwArg "deep" false]
  let ref ← applyOpRemoteRef σ "doit" expr.ref [] kwargs
  pure { ref := ref }

register_op doitShallowExpr => "doit" dispatch_method
  doc "Method-call smoke op with keyword arguments used to exercise manifest-driven effectful dispatch."

def latexModeText (expr : SymExpr s σ) (mode : String := "plain") : SymPyM s String := do
  let kwargs := encodeKwArgs [opKwArg "mode" mode]
  let payload ← decodeJsonInfo (← applyOpRemote "latex" expr.ref [] kwargs)
  let decoded : String ← OpPayloadDecode.decodePayload payload
  pure decoded

register_op latexModeText => "latex" dispatch_namespace
  doc "Namespace-function smoke op with keyword arguments used to exercise manifest-driven effectful dispatch."

end SymbolicLean.Smoke
