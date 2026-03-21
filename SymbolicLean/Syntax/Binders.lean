import Lean
import SymbolicLean.Decl.Core
import SymbolicLean.Sort.Aliases

namespace SymbolicLean

open Lean Elab Macro

class DefaultScalarDomain where
  domain : DomainDesc

def mkDefaultSymbol [inst : DefaultScalarDomain] (name : Name)
    (assumptions : List AssumptionFact := []) : SymDecl (.scalar inst.domain) where
  name := name
  assumptions := assumptions

def mkDefaultFunction [inst : DefaultScalarDomain] (name : Name) :
    FunDecl [(.scalar inst.domain)] (.scalar inst.domain) where
  name := name

declare_syntax_cat sympyAssumption

syntax "positive" : sympyAssumption
syntax "nonnegative" : sympyAssumption
syntax "nonzero" : sympyAssumption
syntax "integer" : sympyAssumption
syntax "rational" : sympyAssumption
syntax "real" : sympyAssumption
syntax "complex" : sympyAssumption
syntax "finite" : sympyAssumption
syntax "invertible" : sympyAssumption

declare_syntax_cat symSymbolBinder

syntax ident : symSymbolBinder
syntax "(" ident " : " sympyAssumption ")" : symSymbolBinder
syntax "(" ident " : " term ")" : symSymbolBinder
syntax "(" ident " : " term " | " sympyAssumption ")" : symSymbolBinder

declare_syntax_cat symFunctionBinder

syntax ident : symFunctionBinder
syntax "(" ident " : " term ")" : symFunctionBinder

declare_syntax_cat sameLineSymSymbolBinderTail
declare_syntax_cat sameLineIdentTail
declare_syntax_cat sameLineSymFunctionBinderTail

syntax ppSpace lineEq symSymbolBinder : sameLineSymSymbolBinderTail
syntax ppSpace lineEq ident : sameLineIdentTail
syntax ppSpace lineEq symFunctionBinder : sameLineSymFunctionBinderTail

private def assumptionFactSyntax (stx : TSyntax `sympyAssumption) : MacroM (TSyntax `term) := do
  match stx with
  | `(sympyAssumption| positive) =>
      `({ assumption := Assumption.positive : AssumptionFact })
  | `(sympyAssumption| nonnegative) =>
      `({ assumption := Assumption.nonnegative : AssumptionFact })
  | `(sympyAssumption| nonzero) =>
      `({ assumption := Assumption.nonzero : AssumptionFact })
  | `(sympyAssumption| integer) =>
      `({ assumption := Assumption.integer : AssumptionFact })
  | `(sympyAssumption| rational) =>
      `({ assumption := Assumption.rational : AssumptionFact })
  | `(sympyAssumption| real) =>
      `({ assumption := Assumption.real : AssumptionFact })
  | `(sympyAssumption| complex) =>
      `({ assumption := Assumption.complex : AssumptionFact })
  | `(sympyAssumption| finite) =>
      `({ assumption := Assumption.finite : AssumptionFact })
  | `(sympyAssumption| invertible) =>
      `({ assumption := Assumption.invertible : AssumptionFact })
  | _ => Macro.throwUnsupported

private partial def expandPublicSort (stx : TSyntax `term) : MacroM (TSyntax `term) := do
  match stx with
  | `(Scalar $_:term) => pure stx
  | `(Mat $_:term $_:term $_:term) => pure stx
  | `(MatD $_:term $_:term $_:term) => pure stx
  | `(Vec $_:term $_:term) => pure stx
  | _ => `(Scalar $stx)

private partial def expandFunctionSignature (stx : TSyntax `term) :
    MacroM (TSyntax `term × TSyntax `term) := do
  match stx with
  | `($dom:term → $cod:term) => do
      let domSort ← expandPublicSort dom
      let (codArgs, codRet) ← expandFunctionSignature cod
      pure (← `($domSort :: $codArgs), codRet)
  | _ => do
      let retSort ← expandPublicSort stx
      pure (← `([]), retSort)

private def symbolBinderSyntax (stx : TSyntax `symSymbolBinder) :
    MacroM (TSyntax `ident × TSyntax `term) := do
  match stx with
  | `(symSymbolBinder| $id:ident) =>
      pure (id, ← `(mkDefaultSymbol $(quote id.getId)))
  | `(symSymbolBinder| ($id:ident : $assump:sympyAssumption)) =>
      let fact ← assumptionFactSyntax assump
      pure (id, ← `(mkDefaultSymbol $(quote id.getId) [$fact]))
  | `(symSymbolBinder| ($id:ident : $sort:term)) =>
      let sort ← expandPublicSort sort
      pure (id, ← `(show SymDecl $sort from sym $(quote id.getId)))
  | `(symSymbolBinder| ($id:ident : $sort:term | $assump:sympyAssumption)) =>
      let sort ← expandPublicSort sort
      let fact ← assumptionFactSyntax assump
      pure (id, ← `(show SymDecl $sort from symWith $(quote id.getId) [$fact]))
  | _ => Macro.throwUnsupported

private partial def mkNestedProd (items : List (TSyntax `term)) : MacroM (TSyntax `term) := do
  match items with
  | [] => Macro.throwError "expected at least one binder"
  | [item] => pure item
  | item :: rest => do
      let tail ← mkNestedProd rest
      `(($item, $tail))

private def mkSymbolLet (binders : Array (TSyntax `symSymbolBinder)) : MacroM (TSyntax `doElem) := do
  let expanded ← binders.toList.mapM symbolBinderSyntax
  let ids := expanded.map fun (id, _) => id.raw
  let values := expanded.map fun (_, value) => value
  let pattern ← mkNestedProd <| ids.map (TSyntax.mk ·)
  let value ← mkNestedProd values
  `(doElem| let $pattern:term := $value:term)

private def mkFunctionLet (idents : Array (TSyntax `ident)) : MacroM (TSyntax `doElem) := do
  let ids := idents.toList
  let values ← ids.mapM fun id => `(mkDefaultFunction $(quote id.getId))
  let pattern ← mkNestedProd <| ids.map fun id => TSyntax.mk id.raw
  let value ← mkNestedProd values
  `(doElem| let $pattern:term := $value:term)

private def functionBinderSyntax (stx : TSyntax `symFunctionBinder) :
    MacroM (TSyntax `ident × TSyntax `term) := do
  match stx with
  | `(symFunctionBinder| $id:ident) =>
      pure (id, ← `(mkDefaultFunction $(quote id.getId)))
  | `(symFunctionBinder| ($id:ident : $sig:term)) => do
      let (args, ret) ← expandFunctionSignature sig
      pure (id, ← `(show FunDecl $args $ret from funSym $(quote id.getId)))
  | _ => Macro.throwUnsupported

private def mkTypedFunctionLet (binders : Array (TSyntax `symFunctionBinder)) :
    MacroM (TSyntax `doElem) := do
  let expanded ← binders.toList.mapM functionBinderSyntax
  let ids := expanded.map fun (id, _) => id.raw
  let values := expanded.map fun (_, value) => value
  let pattern ← mkNestedProd <| ids.map TSyntax.mk
  let value ← mkNestedProd values
  `(doElem| let $pattern:term := $value:term)

private def tailLastArg (stx : Syntax) : Syntax :=
  stx[stx.getNumArgs - 1]!

macro "symbols " head:symSymbolBinder tail:sameLineSymSymbolBinderTail* : doElem => do
  let binders := #[head] ++ tail.map (fun stx => ⟨tailLastArg stx.raw⟩)
  mkSymbolLet binders

macro "functions " head:ident tail:sameLineIdentTail* : doElem => do
  let ids := #[head] ++ tail.map (fun stx => ⟨tailLastArg stx.raw⟩)
  mkFunctionLet ids

macro "functions " head:symFunctionBinder tail:sameLineSymFunctionBinderTail* : doElem => do
  let binders := #[head] ++ tail.map (fun stx => ⟨tailLastArg stx.raw⟩)
  mkTypedFunctionLet binders

end SymbolicLean
