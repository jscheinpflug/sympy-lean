import Lean
import SymbolicLean.Decl.Core

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

declare_syntax_cat sameLineSymSymbolBinderTail
declare_syntax_cat sameLineIdentTail

syntax ppSpace lineEq symSymbolBinder : sameLineSymSymbolBinderTail
syntax ppSpace lineEq ident : sameLineIdentTail

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

private def symbolBinderSyntax (stx : TSyntax `symSymbolBinder) :
    MacroM (TSyntax `ident × TSyntax `term) := do
  match stx with
  | `(symSymbolBinder| $id:ident) =>
      pure (id, ← `(mkDefaultSymbol $(quote id.getId)))
  | `(symSymbolBinder| ($id:ident : $assump:sympyAssumption)) =>
      let fact ← assumptionFactSyntax assump
      pure (id, ← `(mkDefaultSymbol $(quote id.getId) [$fact]))
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

private def tailLastArg (stx : Syntax) : Syntax :=
  stx[stx.getNumArgs - 1]!

macro "symbols " head:symSymbolBinder tail:sameLineSymSymbolBinderTail* : doElem => do
  let binders := #[head] ++ tail.map (fun stx => ⟨tailLastArg stx.raw⟩)
  mkSymbolLet binders

macro "functions " head:ident tail:sameLineIdentTail* : doElem => do
  let ids := #[head] ++ tail.map (fun stx => ⟨tailLastArg stx.raw⟩)
  mkFunctionLet ids

end SymbolicLean
