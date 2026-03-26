import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Decode
import SymbolicLean.Decl.Assumptions
import SymbolicLean.Ops.Results
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Refined

namespace SymbolicLean

open Lean

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
  | .negative => toJson "negative"
  | .nonnegative => toJson "nonnegative"
  | .nonpositive => toJson "nonpositive"
  | .nonzero => toJson "nonzero"
  | .zero => toJson "zero"
  | .integer => toJson "integer"
  | .rational => toJson "rational"
  | .irrational => toJson "irrational"
  | .real => toJson "real"
  | .complex => toJson "complex"
  | .imaginary => toJson "imaginary"
  | .odd => toJson "odd"
  | .even => toJson "even"
  | .finite => toJson "finite"
  | .infinite => toJson "infinite"
  | .prime => toJson "prime"
  | .invertible => toJson "invertible"

instance {s : SessionTok} : OpPayloadDecode s SatisfiableResult where
  decodePayload payload := do
    match payload with
    | .bool false => pure .unsat
    | .str "False" => pure .unsat
    | _ => pure <| .model (← liftDecodeExcept <| decodeModelAssignments payload)

instance {s : SessionTok} : OpPayloadDecode s Truth where
  decodePayload payload := liftDecodeExcept <| decodeTruthResult payload

declare_op satisfiesFormula for (formula : SymExpr s .boolean)
  decodes SatisfiableResult => "satisfiable"
  doc "Check satisfiability and decode the returned model payload."
register_op satisfiesFormula => "satisfiable" dispatch_namespace
  result_mode structured

declare_op askSymbol for (symbol : SymSymbol s (.scalar d)) (query : Assumption)
  decodes Truth => "ask"
  doc "Evaluate a SymPy assumption query on a realized scalar symbol."
register_op askSymbol => "ask" dispatch_namespace
  result_mode structured

declare_op solveUnivariateRefs for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  decodes (List Ref) => "solve"
  doc "Decode the finite list of solution refs returned by SymPy's univariate `solve` backend."
register_op solveUnivariateRefs => "solve" dispatch_namespace
  result_mode structured

def solveUnivariateExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (FiniteSolve s (.scalar d)) := do
  let refs ← solveUnivariateRefs expr x
  rememberLiveRefs refs (.scalar d)
  pure { solutions := refs.map fun ref => { ref := ref } }

declare_op solvesetExprCore for (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d))
  returns (.set (.scalar d)) => "solveset"
  doc "Compute the realized solution set for a scalar equation through SymPy's `solveset`."
register_op solvesetExprCore => "solveset" dispatch_namespace

def solvesetExpr (expr : SymExpr s (.scalar d)) (x : SymSymbol s (.scalar d)) :
    SymPyM s (SolveSetResult s (.scalar d)) := do
  pure { setExpr := ← solvesetExprCore expr x }

declare_op dsolveEquation for (ode : SymExpr s .boolean) returns .boolean => "dsolve"
  doc "Solve a realized ODE and return the resulting equation handle."
register_op dsolveEquation => "dsolve" dispatch_namespace

def dsolveExpr (ode : SymExpr s .boolean) : SymPyM s (ODESolution s) := do
  pure { equation := ← dsolveEquation ode }

def satisfiableExpr (formula : SymExpr s .boolean) : SymPyM s SatisfiableResult := do
  satisfiesFormula formula

end SymbolicLean
