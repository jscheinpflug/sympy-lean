import Lean
import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean Elab Command

syntax "declare_sympy_op " ident " => " str : command
syntax "declare_sympy_op " ident " => " str " doc " str : command
syntax "declare_sympy_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str : command
syntax "declare_sympy_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str " doc " str : command

private def mkAuxIdent (base : TSyntax `ident) (suffix : String) : TSyntax `ident :=
  Lean.mkIdentFrom base <| base.getId.appendAfter suffix

private def attachGeneratedDoc (name : TSyntax `ident) (doc? : Option (TSyntax `str)) :
    CommandElabM Unit := do
  match doc? with
  | none => pure ()
  | some docString =>
      let declName := (← getCurrNamespace) ++ name.getId
      Lean.addDocStringCore declName docString.getString

private def elabDeclareSympyOp
    (name : TSyntax `ident)
    (binders : Array Syntax)
    (arg : TSyntax `ident)
    (argTy outSort : TSyntax `term)
    (opLiteral : TSyntax `str)
    (doc? : Option (TSyntax `str)) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let argTerm := Lean.mkIdentFrom arg arg.getId
  elabCommand <| ← `(command|
    def $name {s : SessionTok} $binders* ($arg : $argTy) : SymPyM s (SymExpr s $outSort) := do
      let expr := $argTerm
      let encodeExtraArgs : Array Json := #[]
      let decodeRef (ref : Ref) : SymExpr s $outSort := { ref := ref }
      let ref ← applyOpRemoteRef $outSort $opLiteral expr.ref encodeExtraArgs.toList
      pure (decodeRef ref))
  attachGeneratedDoc name doc?

elab "declare_sympy_op " name:ident " => " op:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op none

elab "declare_sympy_op " name:ident " => " op:str " doc " docString:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op (some docString)

elab "declare_sympy_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " returns " outSort:term " => " op:str :
    command => do
  elabDeclareSympyOp name (binders.map (·.raw)) arg argTy outSort op none

elab "declare_sympy_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " returns " outSort:term " => " op:str
    " doc " docString:str : command => do
  elabDeclareSympyOp name (binders.map (·.raw)) arg argTy outSort op (some docString)

end SymbolicLean
