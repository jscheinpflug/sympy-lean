import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Decode
import SymbolicLean.Domain.Classes
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean

structure RRefResult (s : SessionTok) (d : DomainDesc) (m n : Dim) where
  reduced : SymExpr s (.matrix d m n)
  pivots : List Nat

declare_op detExpr {d : DomainDesc} {n : Dim} [DomainCarrier d] [InterpretsCommRing d]
  for (matrix : SymExpr s (.matrix d n n)) returns (.scalar d) => "det"
  doc "Compute the determinant of a realized square matrix through SymPy's matrix backend."
register_op detExpr => "det" dispatch_method

declare_op traceExpr {d : DomainDesc} {n : Dim} [DomainCarrier d]
  for (matrix : SymExpr s (.matrix d n n)) returns (.scalar d) => "trace"
  doc "Compute the trace of a realized square matrix through SymPy's namespace trace helper."
register_op traceExpr => "trace" dispatch_namespace

declare_op transpose {d : DomainDesc} {m n : Dim} [DomainCarrier d]
  for (matrix : SymExpr s (.matrix d m n)) returns (.matrix d n m) => "transpose"
  doc "Transpose a realized symbolic matrix."
register_op transpose => "transpose" dispatch_method

declare_op inv {d : DomainDesc} {n : Dim} [DomainCarrier d] [InterpretsField d]
  for (matrix : SymExpr s (.matrix d n n)) returns (.matrix d n n) => "inv"
  doc "Invert a realized square matrix over a field-like domain using SymPy's matrix inverse."
register_op inv => "inv" dispatch_method

def rrefExpr [DomainCarrier d] [InterpretsField d] (matrix : SymExpr s (.matrix d m n)) :
    SymPyM s (RRefResult s d m n) := do
  let payload ← liftDecodeExcept <| decodeJsonInfo (← applyOpRemote "rref" matrix.ref)
  let decoded : Ref × List Nat ← OpPayloadDecode.decodePayload payload
  let (reducedRef, pivots) := decoded
  rememberLiveRef reducedRef (.matrix d m n)
  pure { reduced := { ref := reducedRef }, pivots := pivots }

register_op rrefExpr => "rref"
  dispatch_method
  result_mode structured
  doc "Compute row-reduced echelon form and decode SymPy's structured `[matrixRef, pivots]` payload from `rref`."

end SymbolicLean
