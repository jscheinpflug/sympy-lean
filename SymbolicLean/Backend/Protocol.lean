import Lean.Data.Json
import SymbolicLean.Decl.Assumptions

namespace SymbolicLean

open Lean

abbrev WireRef := Nat

def protocolVersion : Nat := 1

structure SymbolSpec where
  name : Lean.Name
  assumptions : List AssumptionFact := []
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure FunctionSpec where
  name : Lean.Name
  arity : Nat
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure EvalTermReq where
  term : Json
  deriving Inhabited, ToJson, FromJson

structure ApplyOpReq where
  op : String
  target : WireRef
  args : List Json := []
  kwargs : Json := Json.mkObj []
  deriving Inhabited, ToJson, FromJson

structure PrettyReq where
  ref : WireRef
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure ReleaseReq where
  refs : List WireRef
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive WorkerRequestPayload where
  | ping
  | mkSymbol (spec : SymbolSpec)
  | mkFunction (spec : FunctionSpec)
  | evalTerm (req : EvalTermReq)
  | applyOp (req : ApplyOpReq)
  | pretty (req : PrettyReq)
  | release (req : ReleaseReq)
  deriving Inhabited, ToJson, FromJson

structure WorkerRequest where
  id : Nat
  version : Nat := protocolVersion
  payload : WorkerRequestPayload
  deriving Inhabited, ToJson, FromJson

structure PongInfo where
  sympyVersion : String
  capabilities : List String := []
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure RefInfo where
  ref : WireRef
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure JsonInfo where
  value : Json
  deriving Inhabited, ToJson, FromJson

structure PrettyInfo where
  text : String
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure ReleasedInfo where
  refs : List WireRef
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure ErrorInfo where
  code : String
  message : String
  deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive WorkerResponsePayload where
  | pong (info : PongInfo)
  | ref (info : RefInfo)
  | json (info : JsonInfo)
  | pretty (info : PrettyInfo)
  | released (info : ReleasedInfo)
  | error (info : ErrorInfo)
  deriving Inhabited, ToJson, FromJson

structure WorkerResponse where
  id : Nat
  version : Nat := protocolVersion
  payload : WorkerResponsePayload
  deriving Inhabited, ToJson, FromJson

end SymbolicLean
