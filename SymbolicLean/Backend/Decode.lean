import Lean.Data.Json
import SymbolicLean.Backend.Protocol
import SymbolicLean.Session.Errors
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean

private def invalidResponse (message : String) : SymPyError :=
  .protocol (.invalidResponse message)

private def invalidResponseE {α : Type} (message : String) : Except SymPyError α :=
  .error (invalidResponse message)

private def payloadTag : WorkerResponsePayload → String
  | .pong _ => "pong"
  | .ref _ => "ref"
  | .json _ => "json"
  | .pretty _ => "pretty"
  | .released _ => "released"
  | .error _ => "error"

def parseResponseJson (json : Json) : Except SymPyError WorkerResponse := do
  let response ← match (fromJson? json : Except String WorkerResponse) with
    | .ok response => .ok response
    | .error err => invalidResponseE s!"worker response did not match protocol: {err}"
  if response.version != protocolVersion then
    invalidResponseE
      s!"worker protocol version mismatch: expected {protocolVersion}, got {response.version}"
  else
    .ok response

def parseResponseText (text : String) : Except SymPyError WorkerResponse := do
  let json ← match Json.parse text with
    | .ok json => .ok json
    | .error err => invalidResponseE s!"worker emitted invalid JSON: {err}"
  parseResponseJson json

def ensureSuccess (response : WorkerResponse) : Except SymPyError WorkerResponsePayload :=
  match response.payload with
  | .error info => .error <| .worker <| .requestFailed s!"{info.code}: {info.message}"
  | payload => .ok payload

def decodePong (response : WorkerResponse) : Except SymPyError PongInfo := do
  match ← ensureSuccess response with
  | .pong info => .ok info
  | payload =>
      invalidResponseE s!"expected pong payload, got {payloadTag payload}"

def decodeRef (response : WorkerResponse) : Except SymPyError Ref := do
  match ← ensureSuccess response with
  | .ref info => .ok { ident := info.ref }
  | payload =>
      invalidResponseE s!"expected ref payload, got {payloadTag payload}"

def decodeJsonInfo (response : WorkerResponse) : Except SymPyError Json := do
  match ← ensureSuccess response with
  | .json info => .ok info.value
  | payload =>
      invalidResponseE s!"expected json payload, got {payloadTag payload}"

def decodeJsonAs [FromJson α] (response : WorkerResponse) : Except SymPyError α := do
  let value ← decodeJsonInfo response
  match (fromJson? value : Except String α) with
  | .ok decoded => .ok decoded
  | .error err => .error <| .decode <| .malformedPayload err

def decodePretty (response : WorkerResponse) : Except SymPyError String := do
  match ← ensureSuccess response with
  | .pretty info => .ok info.text
  | payload =>
      invalidResponseE s!"expected pretty payload, got {payloadTag payload}"

def decodeReleased (response : WorkerResponse) : Except SymPyError (List Ref) := do
  match ← ensureSuccess response with
  | .released info => .ok <| info.refs.map (fun ref => { ident := ref })
  | payload =>
      invalidResponseE s!"expected released payload, got {payloadTag payload}"

end SymbolicLean
