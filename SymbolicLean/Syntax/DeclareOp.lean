import Lean
import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Decl.Assumptions
import SymbolicLean.Syntax.Registry
import SymbolicLean.SymExpr.Core
import SymbolicLean.SymExpr.Refined
import SymbolicLean.Term.Core

namespace SymbolicLean

open Lean Elab Command

class OpArgEncode (α : Type) where
  encode : α → Json

class OpTargetRef (α : Type) where
  targetRef : α → Ref

instance : OpArgEncode Nat where
  encode := toJson

instance : OpArgEncode Int where
  encode := toJson

instance : OpArgEncode String where
  encode := toJson

instance : OpArgEncode Json where
  encode := id

instance : OpArgEncode Assumption where
  encode
    | .positive => toJson "positive"
    | .nonnegative => toJson "nonnegative"
    | .nonzero => toJson "nonzero"
    | .integer => toJson "integer"
    | .rational => toJson "rational"
    | .real => toJson "real"
    | .complex => toJson "complex"
    | .finite => toJson "finite"
    | .invertible => toJson "invertible"

instance : OpArgEncode (SymExpr s σ) where
  encode expr := encodeRefArg expr.ref.ident

instance : OpArgEncode (SymSymbol s σ) where
  encode symbol := encodeRefArg symbol.expr.ref.ident

instance : OpTargetRef (SymExpr s σ) where
  targetRef expr := expr.ref

instance : OpTargetRef (SymSymbol s σ) where
  targetRef symbol := symbol.expr.ref

class OpPayloadDecode (s : SessionTok) (α : Type) where
  decodePayload : Json → SymPyM s α

class IntoPureTerm (α : Type) (σ : outParam SSort) where
  intoPureTerm : α → Term σ

instance : IntoPureTerm (Term σ) σ where
  intoPureTerm := id

instance : IntoPureTerm (SymDecl σ) σ where
  intoPureTerm decl := (decl : Term σ)

instance : IntoPureTerm Nat (.scalar (.ground .ZZ)) where
  intoPureTerm := Term.natLit

instance : IntoPureTerm Int (.scalar (.ground .ZZ)) where
  intoPureTerm := Term.intLit

instance : IntoPureTerm Nat (.scalar (.ground .QQ)) where
  intoPureTerm value := Term.ratLit value

instance : IntoPureTerm Int (.scalar (.ground .QQ)) where
  intoPureTerm value := Term.ratLit value

instance : IntoPureTerm Rat (.scalar (.ground .QQ)) where
  intoPureTerm := Term.ratLit

private def malformedPayload (message : String) : SymPyError :=
  .decode (.malformedPayload message)

private def decodeJsonValueAs [FromJson α] (value : Json) : Except SymPyError α :=
  match (fromJson? value : Except String α) with
  | .ok decoded => .ok decoded
  | .error err => .error <| malformedPayload err

instance (priority := low) {s : SessionTok} [FromJson α] : OpPayloadDecode s α where
  decodePayload payload :=
    match decodeJsonValueAs (α := α) payload with
    | .ok decoded => pure decoded
    | .error err => throw err

declare_syntax_cat pureHeadArg
declare_syntax_cat pureHeadOpt

syntax "(" ident " : " term ")" : pureHeadArg
syntax "call_style " ident : pureHeadOpt
syntax "sympy_alias" : pureHeadOpt
syntax "doc " str : pureHeadOpt

syntax "register_op " ident " => " str : command
syntax "register_op " ident " => " str " doc " str : command
syntax "declare_pure_head " ident bracketedBinder* " returns " term " => " str pureHeadOpt* : command
syntax "declare_pure_head " ident bracketedBinder*
  " for " pureHeadArg+ " returns " term " => " str pureHeadOpt* : command
syntax "declare_scalar_fn₁ " ident bracketedBinder* " => " str pureHeadOpt* : command
syntax "declare_scalar_fn₂ " ident bracketedBinder* " => " str pureHeadOpt* : command
syntax "declare_sympy_op " ident " => " str : command
syntax "declare_sympy_op " ident " => " str " doc " str : command
syntax "declare_sympy_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str : command
syntax "declare_sympy_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str " doc " str : command
syntax "declare_op " ident " => " str : command
syntax "declare_op " ident " => " str " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" " returns " term " => " str :
  command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" " returns " term " => " str
  " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" "(" ident " : " term ")"
  " returns " term " => " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" "(" ident " : " term ")"
  " returns " term " => " str " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" "(" ident " : " term ")"
  "(" ident " : " term ")" " returns " term " => " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" "(" ident " : " term ")"
  "(" ident " : " term ")" " returns " term " => " str " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " decodes " term " => " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" " decodes " term " => " str " doc " str : command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" " decodes " term " => " str :
  command
syntax "declare_op " ident bracketedBinder*
  " for " "(" ident " : " term ")" "(" ident " : " term ")" " decodes " term " => " str
  " doc " str : command
syntax "declare_head " ident " => " str : command
syntax "declare_head " ident " => " str " doc " str : command
syntax "declare_head " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str : command
syntax "declare_head " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str " doc " str : command

private partial def lastNameComponent : Name → String
  | .anonymous => ""
  | .str _ value => value
  | .num _ value => toString value

private def shortIdentName (name : TSyntax `ident) : Name :=
  Name.mkSimple <| lastNameComponent name.getId

private def shortIdent (name : TSyntax `ident) : TSyntax `ident :=
  Lean.mkIdentFrom name <| shortIdentName name

private def mkAuxIdent (base : TSyntax `ident) (suffix : String) : TSyntax `ident :=
  Lean.mkIdentFrom base <| (shortIdentName base).appendAfter suffix

private def attachGeneratedDoc (name : TSyntax `ident) (doc? : Option (TSyntax `str)) :
    CommandElabM Unit := do
  match doc? with
  | none => pure ()
  | some docString =>
      let declName := (← getCurrNamespace) ++ shortIdentName name
      Lean.addDocStringCore declName docString.getString

private def attachGeneratedDocAt (declName : Name) (doc? : Option (TSyntax `str)) :
    CommandElabM Unit := do
  match doc? with
  | none => pure ()
  | some docString => Lean.addDocStringCore declName docString.getString

private def backendPathOf (backendName : String) : List String :=
  backendName.splitOn "." |>.filter (!·.isEmpty)

private def backendLeanNameOf (backendName : String) : Lean.Name :=
  (backendPathOf backendName).foldl Lean.Name.str Lean.Name.anonymous

private def registerSymbolicDecl
    (kind : RegistryKind)
    (name : TSyntax `ident)
    (backendName : TSyntax `str)
    (dispatchMode : DispatchMode)
    (doc? : Option (TSyntax `str))
    (callStyle : CallStyle := .call)
    (pureSpec? : Option PureSpec := none)
    (extraAliases : List String := [])
    (errorTemplate? : Option String := none) : CommandElabM Unit := do
  let declName := (← getCurrNamespace) ++ shortIdentName name
  let backendName := backendName.getString
  let entry : RegistryEntry := {
    kind := kind
    declName := declName
    backendName := backendName
    metadata := {
      dispatchMode := dispatchMode
      callStyle := callStyle
      pureSpec? := pureSpec?
      backendPath := backendPathOf backendName
      aliases := (backendName :: extraAliases).eraseDups
      categories := [reprStr kind, reprStr dispatchMode]
      docs := doc?.map (·.getString)
      errorTemplate := errorTemplate?
    }
  }
  modifyEnv fun env => addRegistryEntry env entry

private structure PureHeadOptions where
  callStyle : CallStyle := .call
  sympyAlias : Bool := false
  doc? : Option (TSyntax `str) := none

private def parsePureHeadArg (stx : Syntax) : CommandElabM (TSyntax `ident × TSyntax `term) := do
  match stx with
  | `(pureHeadArg| ($arg:ident : $argTy:term)) => pure (arg, argTy)
  | _ => throwUnsupportedSyntax

private def parsePureHeadOptions (opts : Array Syntax) : CommandElabM PureHeadOptions := do
  let mut parsed : PureHeadOptions := {}
  for opt in opts do
    match opt with
    | `(pureHeadOpt| call_style $style:ident) =>
        let callStyle ←
          match style.getId.toString with
          | "call" => pure CallStyle.call
          | "attr" => pure CallStyle.attr
          | other => throwError "unsupported call_style `{other}`; expected `call` or `attr`"
        parsed := { parsed with callStyle := callStyle }
    | `(pureHeadOpt| sympy_alias) =>
        parsed := { parsed with sympyAlias := true }
    | `(pureHeadOpt| doc $docString:str) =>
        parsed := { parsed with doc? := some docString }
    | _ => throwUnsupportedSyntax
  pure parsed

private def mkExtHeadSchemaTerm (argSorts : Array (TSyntax `term)) (resultSort : TSyntax `term) :
    MacroM (TSyntax `term) := do
  `(term| { args := [$argSorts,*], result := $resultSort })

private def mkExtHeadValueTerm (backendName : TSyntax `str) : MacroM (TSyntax `term) := do
  `(term| { name := backendLeanNameOf $backendName })

private def mkArgsValueTerm (args : List (TSyntax `term)) : MacroM (TSyntax `term) := do
  match args with
  | [] => `(term| SymbolicLean.Args.nil)
  | arg :: rest =>
      let restTerm ← mkArgsValueTerm rest
      `(term| SymbolicLean.Args.cons $arg $restTerm)

private def mkPureInputTypeIdent (arg : TSyntax `ident) : TSyntax `ident :=
  mkAuxIdent arg "Input"

private def elabGeneratedDef
    (binders : Array Syntax)
    (name : TSyntax `ident)
    (argBinders : Array Syntax)
    (retTy body : TSyntax `term) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let argBinders := argBinders.map TSyntax.mk
  let name := shortIdent name
  elabCommand <| ← `(command|
    def $name $binders* $argBinders* : $retTy := $body)

private def elabGeneratedRootNamespacedDef
    (ns : Name)
    (binders : Array Syntax)
    (name : TSyntax `ident)
    (argBinders : Array Syntax)
    (retTy body : TSyntax `term) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let argBinders := argBinders.map TSyntax.mk
  let targetNs :=
    if ns == `SymPy then
      `_root_.SymPy
    else
      ns
  let declIdent := mkIdentFrom name <| targetNs ++ shortIdentName name
  elabCommand <| ← `(command|
    def $declIdent $binders* $argBinders* : $retTy := $body)

private def mkClosedPureSpec?
    (binders : Array Syntax)
    (argSorts : Array (TSyntax `term))
    (resultSort : TSyntax `term) : CommandElabM (Option PureSpec) := do
  let _ := binders
  let _ := argSorts
  let _ := resultSort
  -- `RegistryMetadata.pureSpec?` is reserved for a later manifest-backed reify pass.
  -- The declaration command still exposes the field now so the schema is stable.
  return none

private def elabDeclarePureHead
    (name : TSyntax `ident)
    (binders : Array Syntax)
    (argSpecs : Array (TSyntax `ident × TSyntax `term))
    (resultSort : TSyntax `term)
    (backendName : TSyntax `str)
    (options : PureHeadOptions) : CommandElabM Unit := do
  let schemaTerm ← liftMacroM <| mkExtHeadSchemaTerm (argSpecs.map Prod.snd) resultSort
  let specValue ← liftMacroM <| mkExtHeadValueTerm backendName
  let specName := mkAuxIdent name "HeadSpec"
  let pureSpec? ← mkClosedPureSpec? binders (argSpecs.map Prod.snd) resultSort
  let extraAliases :=
    let helperAlias := (shortIdentName name).toString
    if options.sympyAlias then
      [helperAlias, s!"SymPy.{helperAlias}"]
    else
      [helperAlias]
  let quotedBinders := binders.map TSyntax.mk
  elabCommand <| ← `(command|
    def $specName $quotedBinders* : ExtHeadSpec $schemaTerm := $specValue)
  let mut argBinders : Array Syntax := #[]
  let mut argTerms : List (TSyntax `term) := []
  for (arg, argTy) in argSpecs do
    let inputTy := mkPureInputTypeIdent arg
    argBinders := argBinders.push <| ← `(bracketedBinder| {$inputTy : Type})
    argBinders := argBinders.push <| ← `(bracketedBinder| [IntoPureTerm $inputTy $argTy])
    argBinders := argBinders.push <| ← `(bracketedBinder| ($arg : $inputTy))
    let argTerm := mkIdentFrom arg arg.getId
    let pureArg ← `(term| IntoPureTerm.intoPureTerm (σ := $argTy) $argTerm)
    argTerms := argTerms.concat pureArg
  let argsValue ← liftMacroM <| mkArgsValueTerm argTerms
  let helperBody ← `(term|
    let spec : ExtHeadSpec $schemaTerm := $specValue
    SymbolicLean.Term.headApp (.ext spec) $argsValue)
  elabGeneratedDef binders name argBinders
    (← `(term| Term $resultSort)) helperBody
  attachGeneratedDoc name options.doc?
  if options.sympyAlias then
    elabGeneratedRootNamespacedDef `SymPy binders name argBinders
      (← `(term| Term $resultSort)) helperBody
    attachGeneratedDocAt (`SymPy ++ shortIdentName name) options.doc?
  registerSymbolicDecl .head name backendName .pureHead options.doc?
    options.callStyle pureSpec? extraAliases

private def elabRegisterOp
    (name : TSyntax `ident)
    (opLiteral : TSyntax `str)
    (doc? : Option (TSyntax `str)) : CommandElabM Unit := do
  attachGeneratedDoc name doc?
  registerSymbolicDecl .op name opLiteral .effectfulOp doc?

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
      let ref ← applyOpRemoteRef $outSort $opLiteral (OpTargetRef.targetRef expr) encodeExtraArgs.toList
      pure (decodeRef ref))
  attachGeneratedDoc name doc?
  registerSymbolicDecl .op name opLiteral .effectfulOp doc?

private def elabDeclareHead
    (name : TSyntax `ident)
    (backendName : TSyntax `str)
    (doc? : Option (TSyntax `str)) : CommandElabM Unit := do
  registerSymbolicDecl .head name backendName .pureHead doc?

private def elabDeclareSympyOpWithExtras
    (name : TSyntax `ident)
    (binders : Array Syntax)
    (arg : TSyntax `ident)
    (argTy : TSyntax `term)
    (extraArgs : Array (TSyntax `ident × TSyntax `term))
    (outSort : TSyntax `term)
    (opLiteral : TSyntax `str)
    (doc? : Option (TSyntax `str)) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let extraBinders ←
    extraArgs.mapM fun (extraArg, extraTy) => `(bracketedBinder| ($extraArg : $extraTy))
  let encodedArgs ←
    extraArgs.mapM fun (extraArg, _) => `(term| OpArgEncode.encode $extraArg)
  let argTerm := Lean.mkIdentFrom arg arg.getId
  elabCommand <| ← `(command|
    def $name {s : SessionTok} $binders* ($arg : $argTy) $extraBinders* :
        SymPyM s (SymExpr s $outSort) := do
      let expr := $argTerm
      let encodeExtraArgs : Array Json := #[$encodedArgs,*]
      let decodeRef (ref : Ref) : SymExpr s $outSort := { ref := ref }
      let ref ← applyOpRemoteRef $outSort $opLiteral (OpTargetRef.targetRef expr) encodeExtraArgs.toList
      pure (decodeRef ref))
  attachGeneratedDoc name doc?
  registerSymbolicDecl .op name opLiteral .effectfulOp doc?

private def elabDeclareJsonOpWithExtras
    (name : TSyntax `ident)
    (binders : Array Syntax)
    (arg : TSyntax `ident)
    (argTy : TSyntax `term)
    (extraArgs : Array (TSyntax `ident × TSyntax `term))
    (decodedTy : TSyntax `term)
    (opLiteral : TSyntax `str)
    (doc? : Option (TSyntax `str)) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let extraBinders ←
    extraArgs.mapM fun (extraArg, extraTy) => `(bracketedBinder| ($extraArg : $extraTy))
  let encodedArgs ←
    extraArgs.mapM fun (extraArg, _) => `(term| OpArgEncode.encode $extraArg)
  let argTerm := Lean.mkIdentFrom arg arg.getId
  elabCommand <| ← `(command|
    def $name {s : SessionTok} $binders* ($arg : $argTy) $extraBinders* :
        SymPyM s $decodedTy := do
      let expr := $argTerm
      let encodeExtraArgs : Array Json := #[$encodedArgs,*]
      let payload ← decodeJsonInfo (← applyOpRemote $opLiteral (OpTargetRef.targetRef expr) encodeExtraArgs.toList)
      let decoded : $decodedTy ← OpPayloadDecode.decodePayload payload
      pure decoded)
  attachGeneratedDoc name doc?
  registerSymbolicDecl .op name opLiteral .effectfulOp doc?

macro_rules
  | `(declare_scalar_fn₁ $name:ident $binders:bracketedBinder* => $backend:str $opts:pureHeadOpt*) =>
      `(declare_pure_head $name {d : DomainDesc} $binders*
          for (x : .scalar d) returns (.scalar d) => $backend $opts*)
  | `(declare_scalar_fn₂ $name:ident $binders:bracketedBinder* => $backend:str $opts:pureHeadOpt*) =>
      `(declare_pure_head $name {d : DomainDesc} $binders*
          for (x : .scalar d) (y : .scalar d) returns (.scalar d) => $backend $opts*)
  | `(declare_sympy_op $name:ident => $op:str) =>
      `(declare_sympy_op $name {σ : SSort} for (expr : SymExpr s σ) returns σ => $op)
  | `(declare_sympy_op $name:ident => $op:str doc $docString:str) =>
      `(declare_sympy_op $name {σ : SSort} for (expr : SymExpr s σ) returns σ => $op doc $docString)
  | `(declare_op $name:ident => $op:str) =>
      `(declare_op $name {σ : SSort} for (expr : SymExpr s σ) returns σ => $op)
  | `(declare_op $name:ident => $op:str doc $docString:str) =>
      `(declare_op $name {σ : SSort} for (expr : SymExpr s σ) returns σ => $op doc $docString)
  | `(declare_head $name:ident $_binders:bracketedBinder*
      for ($_arg:ident : $_argTy:term) returns $_outSort:term => $backendName:str) =>
      `(declare_head $name => $backendName)
  | `(declare_head $name:ident $_binders:bracketedBinder*
      for ($_arg:ident : $_argTy:term) returns $_outSort:term => $backendName:str
      doc $docString:str) =>
      `(declare_head $name => $backendName doc $docString)

elab "declare_sympy_op " name:ident " => " op:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op none

elab "register_op " name:ident " => " op:str : command => do
  elabRegisterOp name op none

elab "register_op " name:ident " => " op:str " doc " docString:str : command => do
  elabRegisterOp name op (some docString)

elab_rules : command
  | `(declare_pure_head $name:ident $binders:bracketedBinder*
      returns $resultSort:term => $backendName:str $opts:pureHeadOpt*) => do
      let options ← parsePureHeadOptions (opts.map (·.raw))
      elabDeclarePureHead name (binders.map (·.raw)) #[] resultSort backendName options
  | `(declare_pure_head $name:ident $binders:bracketedBinder*
      for $argSpecs:pureHeadArg* returns $resultSort:term => $backendName:str
      $opts:pureHeadOpt*) => do
      let args ← (argSpecs.map (·.raw)).mapM parsePureHeadArg
      let options ← parsePureHeadOptions (opts.map (·.raw))
      elabDeclarePureHead name (binders.map (·.raw)) args resultSort backendName options

elab "declare_sympy_op " name:ident " => " op:str " doc " docString:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op (some docString)

elab "declare_op " name:ident " => " op:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op none

elab "declare_op " name:ident " => " op:str " doc " docString:str : command => do
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

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " returns " outSort:term " => " op:str :
    command => do
  elabDeclareSympyOp name (binders.map (·.raw)) arg argTy outSort op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " returns " outSort:term " => " op:str
    " doc " docString:str : command => do
  elabDeclareSympyOp name (binders.map (·.raw)) arg argTy outSort op (some docString)

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg:ident " : " extraTy:term ")"
    " returns " outSort:term " => " op:str : command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy #[(extraArg, extraTy)] outSort op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg:ident " : " extraTy:term ")"
    " returns " outSort:term " => " op:str " doc " docString:str : command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy #[(extraArg, extraTy)] outSort op (some docString)

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg1:ident " : " extraTy1:term ")"
    "(" extraArg2:ident " : " extraTy2:term ")" " returns " outSort:term " => " op:str :
    command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy
    #[(extraArg1, extraTy1), (extraArg2, extraTy2)] outSort op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg1:ident " : " extraTy1:term ")"
    "(" extraArg2:ident " : " extraTy2:term ")" " returns " outSort:term " => " op:str
    " doc " docString:str : command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy
    #[(extraArg1, extraTy1), (extraArg2, extraTy2)] outSort op (some docString)

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg1:ident " : " extraTy1:term ")"
    "(" extraArg2:ident " : " extraTy2:term ")" "(" extraArg3:ident " : " extraTy3:term ")"
    " returns " outSort:term " => " op:str : command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy
    #[(extraArg1, extraTy1), (extraArg2, extraTy2), (extraArg3, extraTy3)] outSort op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg1:ident " : " extraTy1:term ")"
    "(" extraArg2:ident " : " extraTy2:term ")" "(" extraArg3:ident " : " extraTy3:term ")"
    " returns " outSort:term " => " op:str " doc " docString:str : command => do
  elabDeclareSympyOpWithExtras
    name (binders.map (·.raw)) arg argTy
    #[(extraArg1, extraTy1), (extraArg2, extraTy2), (extraArg3, extraTy3)] outSort op
    (some docString)

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " decodes " decodedTy:term " => " op:str :
    command => do
  elabDeclareJsonOpWithExtras name (binders.map (·.raw)) arg argTy #[] decodedTy op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" " decodes " decodedTy:term " => " op:str
    " doc " docString:str : command => do
  elabDeclareJsonOpWithExtras
    name (binders.map (·.raw)) arg argTy #[] decodedTy op (some docString)

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg:ident " : " extraTy:term ")"
    " decodes " decodedTy:term " => " op:str : command => do
  elabDeclareJsonOpWithExtras
    name (binders.map (·.raw)) arg argTy #[(extraArg, extraTy)] decodedTy op none

elab "declare_op " name:ident binders:bracketedBinder*
    " for " "(" arg:ident " : " argTy:term ")" "(" extraArg:ident " : " extraTy:term ")"
    " decodes " decodedTy:term " => " op:str " doc " docString:str : command => do
  elabDeclareJsonOpWithExtras
    name (binders.map (·.raw)) arg argTy #[(extraArg, extraTy)] decodedTy op (some docString)

elab "declare_head " name:ident " => " backendName:str : command => do
  elabDeclareHead name backendName none

elab "declare_head " name:ident " => " backendName:str " doc " docString:str : command => do
  elabDeclareHead name backendName (some docString)

end SymbolicLean
