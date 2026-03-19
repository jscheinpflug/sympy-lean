import SymbolicLean.Ops.Core
import SymbolicLean.Syntax.Term

namespace SymbolicLean

open Lean Macro

declare_syntax_cat symSubstRule

syntax symterm " ↦ " symterm : symSubstRule

private def expandSubstRule (rule : TSyntax `symSubstRule) : MacroM (TSyntax `term) := do
  if rule.raw.getNumArgs != 3 then
    Macro.throwUnsupported
  else
    let lhs : TSyntax `symterm := ⟨rule.raw[0]⟩
    let rhs : TSyntax `symterm := ⟨rule.raw[2]⟩
    `(substTermPair term![$lhs:symterm] term![$rhs:symterm])

scoped macro:max expr:term noWs "[" rules:symSubstRule,* "]" : term => do
  let pairs ← rules.getElems.mapM expandSubstRule
  `(subs $expr [$pairs,*])

end SymbolicLean
