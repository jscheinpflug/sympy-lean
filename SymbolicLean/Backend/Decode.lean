import Lean.Data.Json
import Mathlib.Data.Rat.Defs
import SymbolicLean.Backend.Protocol
import SymbolicLean.Decl.Core
import SymbolicLean.Domain.Classes
import SymbolicLean.Session.Errors
import SymbolicLean.SymExpr.Core
import SymbolicLean.Term.Calculus
import SymbolicLean.Term.Core

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

private def malformedE {α : Type} (message : String) : Except SymPyError α :=
  .error <| .decode <| .malformedPayload message

private def decodeJsonAs [FromJson α] (json : Json) : Except SymPyError α :=
  match (fromJson? json : Except String α) with
  | .ok value => .ok value
  | .error err => malformedE err

private def getObjVal (json : Json) (field : String) : Except SymPyError Json := do
  match json.getObjVal? field with
  | .ok value => pure value
  | .error _ => .error <| .decode <| .missingField field

private def decodeFieldAs [FromJson α] (json : Json) (field : String) : Except SymPyError α := do
  decodeJsonAs (← getObjVal json field)

private def decodeArray (json : Json) : Except SymPyError (List Json) :=
  match json with
  | .arr values => pure values.toList
  | _ => malformedE "expected JSON array"

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
  | payload => invalidResponseE s!"expected pong payload, got {payloadTag payload}"

def decodeRef (response : WorkerResponse) : Except SymPyError Ref := do
  match ← ensureSuccess response with
  | .ref info => .ok { ident := info.ref }
  | payload => invalidResponseE s!"expected ref payload, got {payloadTag payload}"

def decodeJsonInfo (response : WorkerResponse) : Except SymPyError Json := do
  match ← ensureSuccess response with
  | .json info => .ok info.value
  | payload => invalidResponseE s!"expected json payload, got {payloadTag payload}"

def decodeJsonPayloadAs [FromJson α] (response : WorkerResponse) : Except SymPyError α := do
  decodeJsonAs (← decodeJsonInfo response)

def decodePretty (response : WorkerResponse) : Except SymPyError String := do
  match ← ensureSuccess response with
  | .pretty info => .ok info.text
  | payload => invalidResponseE s!"expected pretty payload, got {payloadTag payload}"

def decodeReleased (response : WorkerResponse) : Except SymPyError (List Ref) := do
  match ← ensureSuccess response with
  | .released info => .ok <| info.refs.map (fun ref => { ident := ref })
  | payload => invalidResponseE s!"expected released payload, got {payloadTag payload}"

partial def decodeSort (json : Json) : Except SymPyError SSort := do
  let tag : String ← decodeFieldAs json "tag"
  match tag with
  | "boolean" => pure .boolean
  | "scalar" => pure <| .scalar (← decodeFieldAs json "domain")
  | "matrix" =>
      pure <| .matrix
        (← decodeFieldAs json "domain")
        (← decodeFieldAs json "rows")
        (← decodeFieldAs json "cols")
  | "tensor" => pure <| .tensor (← decodeFieldAs json "domain") (← decodeFieldAs json "dims")
  | "set" => pure <| .set (← decodeSort (← getObjVal json "elem"))
  | "tuple" =>
      pure <| .tuple (← (← decodeArray (← getObjVal json "items")).mapM decodeSort)
  | "seq" => pure <| .seq (← decodeSort (← getObjVal json "elem"))
  | "map" =>
      pure <| .map
        (← decodeSort (← getObjVal json "key"))
        (← decodeSort (← getObjVal json "value"))
  | "fn" =>
      pure <| .fn
        (← (← decodeArray (← getObjVal json "args")).mapM decodeSort)
        (← decodeSort (← getObjVal json "ret"))
  | "relationSort" =>
      pure <| .relation
        (← decodeFieldAs json "kind")
        (← (← decodeArray (← getObjVal json "args")).mapM decodeSort)
  | "ext" => pure <| .ext (← decodeFieldAs json "value")
  | other => .error <| .decode <| .unexpectedTag other

private abbrev SomeTerm := Sigma Term

private def castTerm {σ τ : SSort} (h : σ = τ) (term : Term σ) : Term τ := by
  cases h
  exact term

private def castScalarTerm {d₁ d₂ : DomainDesc}
    (h : d₁ = d₂) (term : Term (.scalar d₁)) : Term (.scalar d₂) := by
  cases h
  exact term

private abbrev ScalarBinOpCtor :=
  {d₁ d₂ out : DomainDesc} → [UnifyDomain d₁ d₂ out] →
    Term (.scalar d₁) → Term (.scalar d₂) → Term (.scalar out)

private def tryScalarBinOpCase (ctor : ScalarBinOpCtor)
    {d₁ d₂ out : DomainDesc}
    (lhs : Term (.scalar d₁))
    (rhs : Term (.scalar d₂))
    (lhsDomain rhsDomain outDomain : DomainDesc)
    [UnifyDomain lhsDomain rhsDomain outDomain] :
    Except SymPyError (Option (Term (.scalar out))) := do
  if h : d₁ = lhsDomain ∧ d₂ = rhsDomain ∧ out = outDomain then
    let ⟨h₁, h'⟩ := h
    let ⟨h₂, h₃⟩ := h'
    let lhs' : Term (.scalar lhsDomain) := castScalarTerm h₁ lhs
    let rhs' : Term (.scalar rhsDomain) := castScalarTerm h₂ rhs
    let term : Term (.scalar outDomain) := ctor lhs' rhs'
    pure <| some <| castScalarTerm h₃.symm term
  else
    pure none

private def tryScalarFracRightCase (ctor : ScalarBinOpCtor)
    {d₁ d₂ out : DomainDesc}
    (lhs : Term (.scalar d₁))
    (rhs : Term (.scalar d₂)) :
    Except SymPyError (Option (Term (.scalar out))) := do
  if h : d₂ = .fracField d₁ ∧ out = .fracField d₁ then
    let ⟨h₂, h₃⟩ := h
    let rhs' : Term (.scalar (.fracField d₁)) := castScalarTerm h₂ rhs
    let term : Term (.scalar (.fracField d₁)) := ctor lhs rhs'
    pure <| some <| castScalarTerm h₃.symm term
  else
    pure none

private def tryScalarFracLeftCase (ctor : ScalarBinOpCtor)
    {d₁ d₂ out : DomainDesc}
    (lhs : Term (.scalar d₁))
    (rhs : Term (.scalar d₂)) :
    Except SymPyError (Option (Term (.scalar out))) := do
  if h : d₁ = .fracField d₂ ∧ out = .fracField d₂ then
    let ⟨h₁, h₃⟩ := h
    let lhs' : Term (.scalar (.fracField d₂)) := castScalarTerm h₁ lhs
    let term : Term (.scalar (.fracField d₂)) := ctor lhs' rhs
    pure <| some <| castScalarTerm h₃.symm term
  else
    pure none

private def firstSomeE : List (Except SymPyError (Option α)) → Except SymPyError (Option α)
  | [] => pure none
  | result :: rest =>
      match result with
      | .error err => .error err
      | .ok (some value) => pure (some value)
      | .ok none => firstSomeE rest

private def decodeScalarBinOp (ctor : ScalarBinOpCtor)
    {d₁ d₂ out : DomainDesc}
    (lhs : Term (.scalar d₁))
    (rhs : Term (.scalar d₂)) :
    Except SymPyError (Term (.scalar out)) := do
  if h₁ : d₁ = out then
    if h₂ : d₂ = out then
      pure <| ctor (castScalarTerm h₁ lhs) (castScalarTerm h₂ rhs)
    else
      match ← firstSomeE
          [ tryScalarBinOpCase ctor lhs rhs (.ground .ZZ) (.ground .QQ) (.ground .QQ)
          , tryScalarBinOpCase ctor lhs rhs (.ground .ZZ) (.ground .RR) (.ground .RR)
          , tryScalarBinOpCase ctor lhs rhs (.ground .ZZ) (.ground .CC) (.ground .CC)
          , tryScalarBinOpCase ctor lhs rhs (.ground .QQ) (.ground .RR) (.ground .RR)
          , tryScalarBinOpCase ctor lhs rhs (.ground .QQ) (.ground .CC) (.ground .CC)
          , tryScalarBinOpCase ctor lhs rhs (.ground .RR) (.ground .CC) (.ground .CC)
          , tryScalarBinOpCase ctor lhs rhs (.ground .gaussianZZ) (.ground .CC) (.ground .CC)
          , tryScalarFracRightCase ctor lhs rhs ] with
      | some term => pure term
      | none => malformedE "unsupported scalar domain combination"
  else if _h₂ : d₂ = out then
    match ← firstSomeE
        [ tryScalarBinOpCase ctor lhs rhs (.ground .QQ) (.ground .ZZ) (.ground .QQ)
        , tryScalarBinOpCase ctor lhs rhs (.ground .RR) (.ground .ZZ) (.ground .RR)
        , tryScalarBinOpCase ctor lhs rhs (.ground .CC) (.ground .ZZ) (.ground .CC)
        , tryScalarBinOpCase ctor lhs rhs (.ground .RR) (.ground .QQ) (.ground .RR)
        , tryScalarBinOpCase ctor lhs rhs (.ground .CC) (.ground .QQ) (.ground .CC)
        , tryScalarBinOpCase ctor lhs rhs (.ground .CC) (.ground .RR) (.ground .CC)
        , tryScalarBinOpCase ctor lhs rhs (.ground .CC) (.ground .gaussianZZ) (.ground .CC)
        , tryScalarFracLeftCase ctor lhs rhs ] with
    | some term => pure term
    | none => malformedE "unsupported scalar domain combination"
  else
    malformedE "unsupported scalar domain combination"

private def decodeRatLit (json : Json) : Except SymPyError Rat := do
  pure <| mkRat (← decodeFieldAs json "num") (← decodeFieldAs json "den")

private def decodeSymDecl (σ : SSort) (json : Json) : Except SymPyError (SymDecl σ) := do
  pure
    { name := (← decodeFieldAs json "name")
      assumptions := (← decodeFieldAs json "assumptions") }

private def decodeFunDecl (args : List SSort) (ret : SSort) (json : Json) :
    Except SymPyError (FunDecl args ret) := do
  pure { name := (← decodeFieldAs json "name") }

private def decodeHeadIdentity (json : Json) : Except SymPyError (String × Json) := do
  match json with
  | .str name => pure (name, Json.mkObj [])
  | .obj _ =>
      pure ((← decodeFieldAs json "name"), json)
  | _ => malformedE "headApp head identity must be a string or object"

private def genericExtHeadSpec (headName : String) (schema : HeadSchema) : ExtHeadSpec schema :=
  { name := Lean.Name.mkSimple headName }

noncomputable section

mutual

partial def decodeTermAs (σ : SSort) (json : Json) : Except SymPyError (Term σ) := do
  let ⟨σ', term⟩ ← decodeTermAny json
  if h : σ' = σ then
    pure <| castTerm h term
  else
    .error <| .decode <| .malformedPayload
      s!"term sort mismatch: expected {reprStr σ}, got {reprStr σ'}"

private partial def decodeHeadVar (d : DomainDesc) (json : Json) :
    Except SymPyError (SymDecl (.scalar d)) := do
  match ← decodeTermAs (.scalar d) json with
  | .atom (.sym decl) => pure decl
  | _ => malformedE "headApp calculus variable must be a scalar symbol"

private partial def decodeArgsFor :
    (σs : List SSort) → List Json → Except SymPyError (Args σs)
  | [], [] => pure .nil
  | σ :: σs, json :: jsons => do
      pure <| .cons (← decodeTermAs σ json) (← decodeArgsFor σs jsons)
  | _, _ => malformedE "argument arity mismatch"

private partial def decodeGenericScalarHead
    (headName : String)
    (out : DomainDesc)
    (args : List Json) : Except SymPyError SomeTerm := do
  match args with
  | [argJson] =>
      let ⟨argSort, arg⟩ ← decodeTermAny argJson
      match argSort with
      | .scalar d =>
          let spec :
              ExtHeadSpec { args := [.scalar d], result := .scalar out } :=
            genericExtHeadSpec headName _
          pure ⟨_, .headApp (.ext spec) (.singleton arg)⟩
      | _ => malformedE s!"headApp {headName} expected scalar operand"
  | [lhsJson, rhsJson] =>
      let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
      let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
      match lhsSort, rhsSort with
      | .scalar d₁, .scalar d₂ =>
          let spec :
              ExtHeadSpec { args := [.scalar d₁, .scalar d₂], result := .scalar out } :=
            genericExtHeadSpec headName _
          pure ⟨_, .headApp (.ext spec) (.pair lhs rhs)⟩
      | _, _ => malformedE s!"headApp {headName} expected scalar operands"
  | _ => malformedE s!"headApp {headName} expected one or two scalar operands"

private partial def decodeTermAny (json : Json) : Except SymPyError SomeTerm := do
  let sort ← decodeSort (← getObjVal json "sort")
  let tag : String ← decodeFieldAs json "tag"
  match sort, tag with
  | .scalar (.ground .ZZ), "natLit" =>
      pure ⟨_, .natLit (← decodeFieldAs json "value")⟩
  | .scalar (.ground .ZZ), "intLit" =>
      pure ⟨_, .intLit (← decodeFieldAs json "value")⟩
  | .scalar (.ground .QQ), "ratLit" =>
      pure ⟨_, .ratLit (← decodeRatLit json)⟩
  | σ, "atomSym" =>
      pure ⟨σ, .atom (.sym (← decodeSymDecl σ json))⟩
  | .fn args ret, "atomFun" =>
      pure ⟨_, .atom (.fun_ (← decodeFunDecl args ret json))⟩
  | sort, "headApp" =>
      let (headName, headInfo) ← decodeHeadIdentity (← getObjVal json "head")
      let args := ← decodeArray (← getObjVal json "args")
      match sort, headName, args with
      | .scalar d, "scalarNeg", [arg] =>
          pure ⟨_, .scalarNeg (← decodeTermAs (.scalar d) arg)⟩
      | .scalar out, "scalarAdd", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          match lhsSort, rhsSort with
          | .scalar d₁, .scalar d₂ =>
              pure ⟨.scalar out, ← decodeScalarBinOp (out := out) Term.scalarAdd lhs rhs⟩
          | _, _ => malformedE "headApp scalarAdd expected scalar operands"
      | .scalar out, "scalarSub", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          match lhsSort, rhsSort with
          | .scalar d₁, .scalar d₂ =>
              pure ⟨.scalar out, ← decodeScalarBinOp (out := out) Term.scalarSub lhs rhs⟩
          | _, _ => malformedE "headApp scalarSub expected scalar operands"
      | .scalar out, "scalarMul", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          match lhsSort, rhsSort with
          | .scalar d₁, .scalar d₂ =>
              pure ⟨.scalar out, ← decodeScalarBinOp (out := out) Term.scalarMul lhs rhs⟩
          | _, _ => malformedE "headApp scalarMul expected scalar operands"
      | .scalar d, "scalarDiv", [lhsJson, rhsJson] =>
          pure ⟨_, Term.scalarDiv
            (← decodeTermAs (.scalar d) lhsJson)
            (← decodeTermAs (.scalar d) rhsJson)⟩
      | .scalar d, "scalarPow", [lhsJson, rhsJson] =>
          pure ⟨_, Term.scalarPow
            (← decodeTermAs (.scalar d) lhsJson)
            (← decodeTermAs (.scalar (.ground .ZZ)) rhsJson)⟩
      | .matrix d m n, "matrixAdd", [lhsJson, rhsJson] =>
          pure ⟨_, Term.matrixAdd
            (← decodeTermAs (.matrix d m n) lhsJson)
            (← decodeTermAs (.matrix d m n) rhsJson)⟩
      | .matrix d m n, "matrixSub", [lhsJson, rhsJson] =>
          pure ⟨_, Term.matrixSub
            (← decodeTermAs (.matrix d m n) lhsJson)
            (← decodeTermAs (.matrix d m n) rhsJson)⟩
      | .matrix d m p, "matrixMul", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          match lhsSort with
          | .matrix d' m' n =>
              if hd : d' = d then
                if hm : m' = m then
                  let lhs' : Term (.matrix d m n) := castTerm (by cases hd; cases hm; rfl) lhs
                  let rhs' ← decodeTermAs (.matrix d n p) rhsJson
                  pure ⟨_, Term.matrixMul lhs' rhs'⟩
                else
                  malformedE "headApp matrixMul output rows mismatch"
              else
                malformedE "headApp matrixMul lhs domain mismatch"
          | _ => malformedE "headApp matrixMul expected matrix operands"
      | .boolean, "truth", [] =>
          pure ⟨_, Term.truth (← decodeFieldAs headInfo "truth")⟩
      | .boolean, "not", [arg] =>
          pure ⟨_, Term.not_ (← decodeTermAs .boolean arg)⟩
      | .boolean, "and", [lhsJson, rhsJson] =>
          pure ⟨_, Term.and_
            (← decodeTermAs .boolean lhsJson)
            (← decodeTermAs .boolean rhsJson)⟩
      | .boolean, "or", [lhsJson, rhsJson] =>
          pure ⟨_, Term.or_
            (← decodeTermAs .boolean lhsJson)
            (← decodeTermAs .boolean rhsJson)⟩
      | .boolean, "implies", [lhsJson, rhsJson] =>
          pure ⟨_, Term.implies
            (← decodeTermAs .boolean lhsJson)
            (← decodeTermAs .boolean rhsJson)⟩
      | .boolean, "iff", [lhsJson, rhsJson] =>
          pure ⟨_, Term.iff
            (← decodeTermAs .boolean lhsJson)
            (← decodeTermAs .boolean rhsJson)⟩
      | .boolean, "relation", [lhsJson, rhsJson] =>
          let rel ← decodeFieldAs headInfo "rel"
          let ⟨_, lhs⟩ ← decodeTermAny lhsJson
          let ⟨_, rhs⟩ ← decodeTermAny rhsJson
          pure ⟨_, Term.relation rel lhs rhs⟩
      | .boolean, "eq", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let rhs ← decodeTermAs lhsSort rhsJson
          pure ⟨_, Term.relation .eq lhs rhs⟩
      | .boolean, "ne", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let rhs ← decodeTermAs lhsSort rhsJson
          pure ⟨_, Term.relation .ne lhs rhs⟩
      | .boolean, "lt", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          pure ⟨_, Term.relation .lt lhs rhs⟩
      | .boolean, "le", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          pure ⟨_, Term.relation .le lhs rhs⟩
      | .boolean, "gt", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          pure ⟨_, Term.relation .gt lhs rhs⟩
      | .boolean, "ge", [lhsJson, rhsJson] =>
          let ⟨lhsSort, lhs⟩ ← decodeTermAny lhsJson
          let ⟨rhsSort, rhs⟩ ← decodeTermAny rhsJson
          pure ⟨_, Term.relation .ge lhs rhs⟩
      | .boolean, "membership", [elemJson, setJson] =>
          let ⟨elemSort, elem⟩ ← decodeTermAny elemJson
          let setTerm ← decodeTermAs (.set elemSort) setJson
          pure ⟨_, Term.membership elem setTerm⟩
      | .boolean, "mem", [elemJson, setJson] =>
          let ⟨elemSort, elem⟩ ← decodeTermAny elemJson
          let setTerm ← decodeTermAs (.set elemSort) setJson
          pure ⟨_, Term.membership elem setTerm⟩
      | σ, "diff", [bodyJson, varJson, orderJson] =>
          let ⟨varSort, _⟩ ← decodeTermAny varJson
          match varSort with
          | .scalar d =>
              let body ← decodeTermAs σ bodyJson
              let var := (← decodeHeadVar d varJson : SymDecl (.scalar d))
              let order ← decodeTermAs (.scalar (.ground .ZZ)) orderJson
              pure ⟨_, .headApp (.ext (diffHeadSpec σ d))
                (.cons body (.cons (var : Term (.scalar d)) (.cons order .nil)))⟩
          | _ => malformedE "headApp diff variable must be scalar"
      | .scalar d, "integral", [bodyJson, varJson] =>
          let body ← decodeTermAs (.scalar d) bodyJson
          let var := (← decodeHeadVar d varJson : SymDecl (.scalar d))
          pure ⟨_, .headApp (.ext (integralHeadSpec d)) (.pair body (var : Term (.scalar d)))⟩
      | .scalar d, "limit", [bodyJson, varJson, valueJson] =>
          let body ← decodeTermAs (.scalar d) bodyJson
          let var := (← decodeHeadVar d varJson : SymDecl (.scalar d))
          let value ← decodeTermAs (.scalar d) valueJson
          pure ⟨_, .headApp (.ext (limitHeadSpec d))
            (.cons body (.cons (var : Term (.scalar d)) (.cons value .nil)))⟩
      | .scalar out, headName, args =>
          decodeGenericScalarHead headName out args
      | _, _, _ => malformedE s!"unsupported headApp shape for {headName}"
  | σ, "app" =>
      let ⟨fnSort, fn⟩ ← decodeTermAny (← getObjVal json "fn")
      match fnSort with
      | .fn args ret =>
          if h : ret = σ then
            let args' ← decodeArgsFor args (← decodeArray (← getObjVal json "args"))
            pure ⟨σ, castTerm h <| .app fn args'⟩
          else
            malformedE "app result sort mismatch"
      | _ => malformedE "app expected function term"
  | _, other => .error <| .decode <| .unexpectedTag other

end

end

end SymbolicLean
