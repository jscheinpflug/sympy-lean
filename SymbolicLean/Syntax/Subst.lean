import SymbolicLean.Ops.Core

namespace SymbolicLean

open Lean Macro

declare_syntax_cat symSubstRule

syntax term " ↦ " term : symSubstRule

private def expandSubstRule (rule : TSyntax `symSubstRule) : MacroM (TSyntax `term) := do
  if rule.raw.getNumArgs != 3 then
    Macro.throwUnsupported
  else
    let lhs : TSyntax `term := ⟨rule.raw[0]⟩
    let rhs : TSyntax `term := ⟨rule.raw[2]⟩
    `(substPair $lhs $rhs)

scoped macro:max expr:term noWs "[" rules:symSubstRule,* "]" : term => do
  let pairs ← rules.getElems.mapM expandSubstRule
  `(subs $expr [$pairs,*])

end SymbolicLean
