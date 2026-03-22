import Lean
import SymbolicLean.Syntax.Registry

namespace SymbolicLean

open Lean Elab Command

private def matchesNeedle (needle : String) (entry : RegistryEntry) : Bool :=
  let needle := needle.toLower
  let haystacks :=
    [ entry.declName.toString.toLower
    , entry.backendName.toLower
    ] ++
      entry.metadata.aliases.map String.toLower ++
      entry.metadata.categories.map String.toLower ++
      match entry.metadata.docs with
      | some docs => [docs.toLower]
      | none => []
  haystacks.any (·.contains needle)

private def prefixHaystacks (entry : RegistryEntry) : List String :=
  [entry.declName.toString, entry.backendName] ++ entry.metadata.aliases

private def matchesPrefix (needle : String) (entry : RegistryEntry) : Bool :=
  let needle := needle.toLower
  (prefixHaystacks entry).any fun value => value.toLower.startsWith needle

private def renderEntry (entry : RegistryEntry) : String :=
  let aliasSuffix :=
    match entry.metadata.aliases with
    | [] => ""
    | aliases => s!"\n  aliases: {String.intercalate ", " aliases}"
  let categorySuffix :=
    match entry.metadata.categories with
    | [] => ""
    | categories => s!"\n  categories: {String.intercalate ", " categories}"
  let docSuffix :=
    match entry.metadata.docs with
    | some docs => s!"\n  {docs}"
    | none => ""
  s!"{entry.declName} [{reprStr entry.kind}] => {entry.backendName}{aliasSuffix}{categorySuffix}{docSuffix}"

private def exactMatches (needle : String) (entry : RegistryEntry) : Bool :=
  let needle := needle.toLower
  let exactHaystacks :=
    [entry.declName.toString.toLower, entry.backendName.toLower] ++
      entry.metadata.aliases.map String.toLower
  exactHaystacks.any (· == needle)

private def renderHover (entry : RegistryEntry) : String :=
  let docs := entry.metadata.docs.getD "No attached docs."
  let backendPath :=
    match entry.metadata.backendPath with
    | [] => "none"
    | xs => String.intercalate "." xs
  let aliases :=
    match entry.metadata.aliases with
    | [] => "none"
    | xs => String.intercalate ", " xs
  let categories :=
    match entry.metadata.categories with
      | [] => "none"
      | xs => String.intercalate ", " xs
  let errorTemplate := entry.metadata.errorTemplate.getD "none"
  let effectfulDispatch :=
    match entry.metadata.effectfulDispatch? with
    | some dispatch => reprStr dispatch
    | none => "none"
  let pureSpec :=
    match entry.metadata.pureSpec? with
    | some spec => reprStr spec
    | none => "none"
  s!"{entry.declName}\nkind: {reprStr entry.kind}\nbackend: {entry.backendName}\nbackendPath: {backendPath}\ncallStyle: {reprStr entry.metadata.callStyle}\neffectfulDispatch: {effectfulDispatch}\npureSpec: {pureSpec}\naliases: {aliases}\ncategories: {categories}\ndispatch: {reprStr entry.metadata.dispatchMode}\nreify: {reprStr entry.metadata.reifyMode}\nresult: {reprStr entry.metadata.resultMode}\nerrorTemplate: {errorTemplate}\n{docs}"

private def renderCompletion (entry : RegistryEntry) : String :=
  let aliasSuffix :=
    match entry.metadata.aliases with
    | [] => ""
    | xs => s!" aliases: {String.intercalate ", " xs}"
  s!"{entry.declName} => {entry.backendName}{aliasSuffix}"

syntax "#sympy_search " str : command
syntax "#sympy_hover " str : command
syntax "#sympy_complete " str : command

elab "#sympy_search " needle:str : command => do
  let entries :=
    registryEntries (← getEnv)
      |>.filter (matchesNeedle needle.getString)
      |>.mergeSort fun lhs rhs => lhs.declName.toString < rhs.declName.toString
  if entries.isEmpty then
    logInfo m!"no symbolic registry entries matched {needle.getString}"
  else
    logInfo m!"{String.intercalate "\n\n" (entries.map renderEntry)}"

elab "#sympy_hover " needle:str : command => do
  let entries := registryEntries (← getEnv)
  let exact := entries.filter (exactMatches needle.getString)
  let candidates :=
    if exact.length == 1 then exact
    else
      entries
        |>.filter (matchesNeedle needle.getString)
        |>.mergeSort fun lhs rhs => lhs.declName.toString < rhs.declName.toString
  match candidates with
  | [] => logInfo m!"no symbolic registry entry matched {needle.getString}"
  | [entry] => logInfo m!"{renderHover entry}"
  | entries =>
      logInfo m!"multiple registry entries matched {needle.getString}:\n{String.intercalate "\n" (entries.map renderCompletion)}"

elab "#sympy_complete " needle:str : command => do
  let entries :=
    registryEntries (← getEnv)
      |>.filter (matchesPrefix needle.getString)
      |>.mergeSort fun lhs rhs => lhs.declName.toString < rhs.declName.toString
  if entries.isEmpty then
    logInfo m!"no symbolic completions matched {needle.getString}"
  else
    logInfo m!"{String.intercalate "\n" (entries.map renderCompletion)}"

end SymbolicLean
