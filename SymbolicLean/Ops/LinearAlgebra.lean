import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Decode
import SymbolicLean.Domain.Classes
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean

structure RRefResult (s : SessionTok) (d : DomainDesc) (m n : Dim) where
  reduced : SymExpr s (.matrix d m n)
  pivots : List Nat

private structure JsonRef where
  ref : Nat
  deriving FromJson

private def malformedPayload (message : String) : SymPyError :=
  .decode (.malformedPayload message)

private def liftExcept (result : Except SymPyError α) : SymPyM s α :=
  match result with
  | .ok value => pure value
  | .error err => throw err

private def decodeJsonValueAs [FromJson α] (value : Json) : Except SymPyError α :=
  match (fromJson? value : Except String α) with
  | .ok decoded => .ok decoded
  | .error err => .error <| malformedPayload err

private def decodeRRefPayload (payload : Json) : Except SymPyError (Ref × List Nat) := do
  match payload with
  | .arr values =>
      match values.toList with
      | [reducedJson, pivotsJson] =>
          let reduced : JsonRef ← decodeJsonValueAs reducedJson
          let pivots : List Nat ← decodeJsonValueAs pivotsJson
          pure ({ ident := reduced.ref }, pivots)
      | _ => .error <| malformedPayload "expected rref payload [matrixRef, pivots]"
  | _ => .error <| malformedPayload "expected rref payload array"

private def rememberRef (ref : Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st => { st with liveRefs := st.liveRefs.insert ref sort }

def det [DomainCarrier d] [InterpretsCommRing d] (matrix : SymExpr s (.matrix d n n)) :
    SymPyM s (SymExpr s (.scalar d)) := do
  let ref ← applyOpRemoteRef (.scalar d) "det" matrix.ref
  pure { ref := ref }

def inv [DomainCarrier d] [InterpretsField d] (matrix : SymExpr s (.matrix d n n)) :
    SymPyM s (SymExpr s (.matrix d n n)) := do
  let ref ← applyOpRemoteRef (.matrix d n n) "inv" matrix.ref
  pure { ref := ref }

def rref [DomainCarrier d] [InterpretsField d] (matrix : SymExpr s (.matrix d m n)) :
    SymPyM s (RRefResult s d m n) := do
  let payload ← liftExcept <| decodeJsonInfo (← applyOpRemote "rref" matrix.ref)
  let (reducedRef, pivots) ← liftExcept <| decodeRRefPayload payload
  rememberRef reducedRef (.matrix d m n)
  pure { reduced := { ref := reducedRef }, pivots := pivots }

end SymbolicLean
