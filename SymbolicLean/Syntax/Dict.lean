import SymbolicLean.Term.Containers

namespace SymbolicLean

open Lean Macro

declare_syntax_cat dictEntry

syntax term " ↦ " term : dictEntry
syntax "dict{" "}" : term
syntax "dict{" dictEntry,* "}" : term

private def expandDictEntry (entry : TSyntax `dictEntry) : MacroM (TSyntax `term × TSyntax `term) := do
  if entry.raw.getNumArgs != 3 then
    Macro.throwUnsupported
  else
    pure (⟨entry.raw[0]⟩, ⟨entry.raw[2]⟩)

scoped macro:max "dict{" "}" : term => `(dictEmpty)

scoped macro:max "dict{" entries:dictEntry,* "}" : term => do
  let mut result : TSyntax `term ← `(dictEmpty)
  for entry in entries.getElems do
    let (key, value) ← expandDictEntry entry
    result ← `(dictInsert $result $key $value)
  pure result

end SymbolicLean
