import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Decode
import SymbolicLean.Decl.Assumptions
import SymbolicLean.Ops.Results
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

open Lean

private structure SolverJsonRef where
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

private def rememberRef (ref : Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st => { st with liveRefs := st.liveRefs.insert ref sort }

private def rememberRefs (refs : List Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st =>
    let liveRefs := refs.foldl (fun acc ref => acc.insert ref sort) st.liveRefs
    { st with liveRefs := liveRefs }

private def decodeRefList (payload : Json) : Except SymPyError (List Ref) := do
  let entries : List SolverJsonRef ← decodeJsonValueAs payload
  pure <| entries.map fun entry => { ident := entry.ref }

private def decodeBoolLike (value : Json) : Except SymPyError Bool := do
  match value with
  | .bool flag => pure flag
  | .str "True" => pure true
  | .str "False" => pure false
  | _ => .error <| malformedPayload "expected boolean-like json value"

private def decodeTruthResult (payload : Json) : Except SymPyError Truth := do
  match payload with
  | .null => pure .unknown
  | _ =>
      if ← decodeBoolLike payload then
        pure .true_
      else
        pure .false_

private def decodeModelAssignments (payload : Json) : Except SymPyError (List SatAssignment) := do
  match payload with
  | .obj pairs =>
      pairs.toList.mapM fun (name, value) => do
        let flag ← decodeBoolLike value
        pure { name := name, value := flag }
  | _ => .error <| malformedPayload "expected satisfiable model object"

private def encodeAssumptionQuery : Assumption → Json
  | .positive => toJson "positive"
  | .nonnegative => toJson "nonnegative"
  | .nonzero => toJson "nonzero"
  | .integer => toJson "integer"
  | .rational => toJson "rational"
  | .real => toJson "real"
  | .complex => toJson "complex"
  | .finite => toJson "finite"
  | .invertible => toJson "invertible"

def solveUnivariateExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (FiniteSolve s (.scalar d)) := do
  let payload ← liftExcept <| decodeJsonInfo (← applyOpRemote "solve" expr.ref [encodeRefArg x.expr.ref.ident])
  let refs ← liftExcept <| decodeRefList payload
  rememberRefs refs (.scalar d)
  pure { solutions := refs.map fun ref => { ref := ref } }

def solvesetExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (SolveSetResult s (.scalar d)) := do
  let ref ← applyOpRemoteRef (.set (.scalar d)) "solveset" expr.ref [encodeRefArg x.expr.ref.ident]
  pure { setExpr := { ref := ref } }

declare_sympy_op dsolveEquation for (ode : SymExpr s .boolean) returns .boolean => "dsolve"
  doc "Solve a realized ODE and return the resulting equation handle."

def dsolveExpr (ode : SymExpr s .boolean) : SymPyM s (ODESolution s) := do
  pure { equation := ← dsolveEquation ode }

def satisfiableExpr (formula : SymExpr s .boolean) : SymPyM s SatisfiableResult := do
  let payload ← liftExcept <| decodeJsonInfo (← applyOpRemote "satisfiable" formula.ref)
  match payload with
  | .bool false => pure .unsat
  | .str "False" => pure .unsat
  | _ => pure <| .model (← liftExcept <| decodeModelAssignments payload)

def askSymbol (symbol : SymSymbol s (.scalar d)) (query : Assumption) : SymPyM s Truth := do
  let payload ←
    liftExcept <|
      decodeJsonInfo (← applyOpRemote "ask" symbol.expr.ref [encodeAssumptionQuery query])
  liftExcept <| decodeTruthResult payload

end SymbolicLean
