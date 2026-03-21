import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Realize
import SymbolicLean.Session.Monad
import SymbolicLean.Syntax.Binders

namespace SymbolicLean

open Lean Elab Term Macro

syntax:lead "sympy " termBeforeDo " do " doSeq : term

private def mkSympyDomainTerm (arg : TSyntax `term) : TermElabM (TSyntax `term) := do
  let domainTy := Lean.mkConst ``DomainDesc
  let carrierCandidate ← `(term| carrierDomain $arg)
  try
    discard <| elabTerm carrierCandidate (some domainTy)
    pure carrierCandidate
  catch _ =>
    discard <| elabTerm arg (some domainTy)
    pure arg

elab_rules : term
  | `(sympy $arg do $seq) => do
      let domain ← mkSympyDomainTerm arg
      elabTerm (← `(term|
        letI : DefaultScalarDomain := { domain := $domain };
        withSession {} fun _s => do
          $seq)) none

class ExploreRenderable (s : SessionTok) (α : Type) where
  render : α → SymPyM s String

instance : ExploreRenderable s (Term σ) where
  render term := do
    let realized ← eval term
    prettyRemote realized.ref

instance : ExploreRenderable s (SymExpr s σ) where
  render expr := prettyRemote expr.ref

instance (priority := low) [Repr α] : ExploreRenderable s α where
  render value := pure (reprStr value)

instance (priority := high) [ExploreRenderable s α] : ExploreRenderable s (SymPyM s α) where
  render action := do
    let value ← action
    ExploreRenderable.render value

def renderExploreResult [ExploreRenderable s α] (value : α) : SymPyM s String :=
  ExploreRenderable.render value

private structure ExploreNames where
  symbolNames : Std.HashSet Name
  functionNames : Std.HashSet Name
  qualifiedFunctions : Std.HashMap Name Name
  ctorLikeFunctions : Std.HashSet Name
  nextAlias : Nat

private def emptyExploreNames : ExploreNames :=
  { symbolNames := {}, functionNames := {}, qualifiedFunctions := {}, ctorLikeFunctions := {}, nextAlias := 0 }

private def ExploreNames.addSymbol (state : ExploreNames) (name : Name) : ExploreNames :=
  if state.functionNames.contains name then
    state
  else
    { state with symbolNames := state.symbolNames.insert name }

private def ExploreNames.addFunction (state : ExploreNames) (name : Name) : ExploreNames :=
  let ctorLikeFunctions :=
    match name.toString.toList.head? with
    | some head =>
        if head.isUpper then
          state.ctorLikeFunctions.insert name
        else
          state.ctorLikeFunctions
    | none => state.ctorLikeFunctions
  { state with
      symbolNames := state.symbolNames.erase name
      functionNames := state.functionNames.insert name
      ctorLikeFunctions := ctorLikeFunctions }

private def ExploreNames.aliasName (idx : Nat) : Name :=
  Name.mkSimple s!"_sympy_head_{idx}"

private def ExploreNames.addQualifiedFunction (state : ExploreNames) (name : Name) :
    ExploreNames × Name :=
  match state.qualifiedFunctions.get? name with
  | some aliasName => (state, aliasName)
  | none =>
      let aliasName := ExploreNames.aliasName state.nextAlias
      ({ state with
          qualifiedFunctions := state.qualifiedFunctions.insert name aliasName
          nextAlias := state.nextAlias + 1 }, aliasName)

private def isSimpleExploreIdent (stx : TSyntax `ident) : Bool :=
  let name := stx.getId
  !name.isAnonymous && !name.isInternal && name == Name.mkSimple name.toString

private def isResolvedExploreName (name : Name) : MacroM Bool := do
  pure <| (← Macro.resolveGlobalName name).any (·.fst == name)

private partial def prepareExploreTerm (stx : Syntax) : StateT ExploreNames MacroM Syntax := do
  if stx.isIdent then
    let id : TSyntax `ident := ⟨stx⟩
    if isSimpleExploreIdent id then
      modify fun state => state.addSymbol id.getId
    return stx
  match stx with
  | `(term| ($inner:term)) =>
      let inner' := TSyntax.mk (← prepareExploreTerm inner.raw)
      `(term| ($inner'))
  | `(term| - $inner:term) =>
      let inner' := TSyntax.mk (← prepareExploreTerm inner.raw)
      `(term| - $inner')
  | `(term| ¬ $inner:term) =>
      let inner' := TSyntax.mk (← prepareExploreTerm inner.raw)
      `(term| ¬ $inner')
  | `(term| $_lhs:term + $_rhs:term)
  | `(term| $_lhs:term - $_rhs:term)
  | `(term| $_lhs:term * $_rhs:term)
  | `(term| $_lhs:term / $_rhs:term)
  | `(term| $_lhs:term ^ $_rhs:term)
  | `(term| $_lhs:term = $_rhs:term)
  | `(term| $_lhs:term < $_rhs:term)
  | `(term| $_lhs:term ≤ $_rhs:term)
  | `(term| $_lhs:term > $_rhs:term)
  | `(term| $_lhs:term ≥ $_rhs:term)
  | `(term| $_lhs:term ∧ $_rhs:term)
  | `(term| $_lhs:term ∨ $_rhs:term) => do
      for arg in stx.getArgs do
        discard <| prepareExploreTerm arg
      pure stx
  | `(term| $f:ident $arg:term) => do
      let arg' := TSyntax.mk (← prepareExploreTerm arg.raw)
      if isSimpleExploreIdent f then
        modify fun state => state.addFunction f.getId
        `(term| $f $arg')
      else if !f.getId.isAnonymous && !f.getId.isInternal then
        if ← liftM <| isResolvedExploreName f.getId then
          `(term| $f $arg')
        else
          let aliasId ← modifyGet fun state =>
            let (state', aliasName) := state.addQualifiedFunction f.getId
            (mkIdent aliasName, state')
          `(term| $aliasId $arg')
      else
        let f' := TSyntax.mk (← prepareExploreTerm f.raw)
        `(term| $f' $arg')
  | _ =>
      for arg in stx.getArgs do
        discard <| prepareExploreTerm arg
      pure stx

private def orderedExploreNames (names : Std.HashSet Name) : List Name :=
  names.toList.mergeSort fun lhs rhs => lhs.toString < rhs.toString

private def orderedExploreAliases (names : Std.HashMap Name Name) : List (Name × Name) :=
  names.toList.mergeSort fun lhs rhs => lhs.fst.toString < rhs.fst.toString

private def wrapExplorePrelude (alpha : TSyntax `term) (body : TSyntax `term) :
    MacroM (TSyntax `term × Array MessageData) := do
  let (prepared, names) ← (prepareExploreTerm body.raw).run emptyExploreNames
  let mut wrapped := TSyntax.mk prepared
  let mut warnings : Array MessageData := #[]
  for name in orderedExploreNames names.ctorLikeFunctions do
    warnings := warnings.push
      m!"`#sympy` falling back to an undefined scalar function for constructor-like head `{name}`"
  for (name, aliasName) in (orderedExploreAliases names.qualifiedFunctions).reverse do
    warnings := warnings.push
      m!"`#sympy` falling back to an undefined scalar function for unresolved qualified head `{name}`"
    let id := mkIdent aliasName
    wrapped ← `(let $id : FunDecl [Scalar $alpha] (Scalar $alpha) := funSym $(quote name); $wrapped)
  for name in (orderedExploreNames names.functionNames).reverse do
    let id := mkIdent name
    wrapped ← `(let $id : FunDecl [Scalar $alpha] (Scalar $alpha) := funSym $(quote name); $wrapped)
  for name in (orderedExploreNames names.symbolNames).reverse do
    let id := mkIdent name
    wrapped ← `(let $id : SymDecl (Scalar $alpha) := sym $(quote name); $wrapped)
  pure (wrapped, warnings)

elab "#sympy " alpha:termBeforeDo " => " body:term : command => do
  let alphaTerm : TSyntax `term := ⟨alpha.raw⟩
  let (wrappedBody, warnings) ← Elab.liftMacroM <| wrapExplorePrelude alphaTerm body
  for warning in warnings do
    logWarningAt body.raw warning
  Elab.Command.elabCommand (← `(command|
    #eval do
      let result ← sympy (carrierDomain $alphaTerm) do
        let value := $wrappedBody
        renderExploreResult value
      match result with
      | Except.ok text => IO.println text
      | Except.error err => IO.println (repr err)))

elab "#sympy " alpha:termBeforeDo " do " seq:doSeq : command => do
  let alphaTerm : TSyntax `term := ⟨alpha.raw⟩
  Elab.Command.elabCommand (← `(command|
    #eval do
      let result ← sympy (carrierDomain $alphaTerm) do
        let value ← do
          $seq
        renderExploreResult value
      match result with
      | Except.ok text => IO.println text
      | Except.error err => IO.println (repr err)))

end SymbolicLean
