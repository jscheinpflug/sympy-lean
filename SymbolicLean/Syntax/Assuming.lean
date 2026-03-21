import SymbolicLean.Decl.Core

namespace SymbolicLean

open Lean Macro

declare_syntax_cat sympyAssumeEntry
syntax ident " ↦ " term : sympyAssumeEntry
syntax:lead "assuming " "[" sepBy1(sympyAssumeEntry, ", ") "]" " do " doSeq : term

private def applyAssumptionEntry (body : TSyntax `term) (entry : Syntax) : MacroM (TSyntax `term) :=
  match entry with
  | `(sympyAssumeEntry| $id:ident ↦ $query:term) =>
      `(do
          let $id := ($id : SymDecl _).addAssumption $query
          let __sympy_assuming_result ← ($body)
          pure __sympy_assuming_result)
  | _ => Macro.throwUnsupported

macro_rules
  | `(assuming [$entries,*] do $seq) => do
      let mut body : TSyntax `term := ← `(do
        $seq)
      for entry in entries.getElems.reverse do
        body ← applyAssumptionEntry body entry
      pure body

end SymbolicLean
