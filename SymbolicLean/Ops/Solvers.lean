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

instance {s : SessionTok} : OpPayloadDecode s SatisfiableResult where
  decodePayload payload := do
    match payload with
    | .bool false => pure .unsat
    | .str "False" => pure .unsat
    | _ => pure <| .model (← liftExcept <| decodeModelAssignments payload)

instance {s : SessionTok} : OpPayloadDecode s Truth where
  decodePayload payload := liftExcept <| decodeTruthResult payload

instance {s : SessionTok} : OpPayloadDecode s (List Ref) where
  decodePayload payload := liftExcept <| decodeRefList payload

declare_op satisfiesFormula for (formula : SymExpr s .boolean)
  decodes SatisfiableResult => "satisfiable"
  doc "Check satisfiability and decode the returned model payload."

declare_op askSymbol for (symbol : SymSymbol s (.scalar d)) (query : Assumption)
  decodes Truth => "ask"
  doc "Evaluate a SymPy assumption query on a realized scalar symbol."

declare_op solveUnivariateRefs for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  decodes (List Ref) => "solve"
  doc "Decode the finite list of solution refs returned by SymPy's `solve`."

def solveUnivariateExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (FiniteSolve s (.scalar d)) := do
  let refs ← solveUnivariateRefs expr x
  rememberRefs refs (.scalar d)
  pure { solutions := refs.map fun ref => { ref := ref } }

declare_op solvesetExprCore for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  returns (.set (.scalar d)) => "solveset"
  doc "Compute the realized solution set for a scalar equation."

def solvesetExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (SolveSetResult s (.scalar d)) := do
  pure { setExpr := ← solvesetExprCore expr x }

declare_op dsolveEquation for (ode : SymExpr s .boolean) returns .boolean => "dsolve"
  doc "Solve a realized ODE and return the resulting equation handle."

def dsolveExpr (ode : SymExpr s .boolean) : SymPyM s (ODESolution s) := do
  pure { equation := ← dsolveEquation ode }

def satisfiableExpr (formula : SymExpr s .boolean) : SymPyM s SatisfiableResult := do
  satisfiesFormula formula

end SymbolicLean
