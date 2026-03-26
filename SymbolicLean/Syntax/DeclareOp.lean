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

instance : OpArgEncode Bool where
  encode := toJson

instance : OpArgEncode String where
  encode := toJson

instance : OpArgEncode Json where
  encode := id

structure OpKwArg where
  name : String
  value : Json

def opKwArg [OpArgEncode α] (name : String) (value : α) : OpKwArg :=
  { name := name, value := OpArgEncode.encode value }

def encodeKwArgs (kwargs : List OpKwArg) : Json :=
  Json.mkObj <| kwargs.map fun kw => (kw.name, kw.value)

structure OpJsonRef where
  ref : Nat
  deriving FromJson

instance : OpArgEncode Assumption where
  encode
    | .positive => toJson "positive"
    | .negative => toJson "negative"
    | .nonnegative => toJson "nonnegative"
    | .nonpositive => toJson "nonpositive"
    | .nonzero => toJson "nonzero"
    | .zero => toJson "zero"
    | .integer => toJson "integer"
    | .rational => toJson "rational"
    | .irrational => toJson "irrational"
    | .real => toJson "real"
    | .complex => toJson "complex"
    | .imaginary => toJson "imaginary"
    | .odd => toJson "odd"
    | .even => toJson "even"
    | .finite => toJson "finite"
    | .infinite => toJson "infinite"
    | .prime => toJson "prime"
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
  -- Narrow pure-input conversion used by generated registry-backed extension-head helpers.
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

def malformedPayload (message : String) : SymPyError :=
  .decode (.malformedPayload message)

def liftDecodeExcept (result : Except SymPyError α) : SymPyM s α :=
  match result with
  | .ok value => pure value
  | .error err => throw err

def decodeJsonValueAs [FromJson α] (value : Json) : Except SymPyError α :=
  match (fromJson? value : Except String α) with
  | .ok decoded => .ok decoded
  | .error err => .error <| malformedPayload err

def decodeEmbeddedRef (value : Json) : Except SymPyError Ref := do
  let decoded : OpJsonRef ← decodeJsonValueAs value
  pure { ident := decoded.ref }

def decodeEmbeddedRefList (value : Json) : Except SymPyError (List Ref) := do
  let decoded : List OpJsonRef ← decodeJsonValueAs value
  pure <| decoded.map fun entry => { ident := entry.ref }

def decodeJsonArray2 (value : Json) : Except SymPyError (Json × Json) := do
  match value with
  | .arr values =>
      match values.toList with
      | [lhs, rhs] => pure (lhs, rhs)
      | _ => .error <| malformedPayload "expected JSON array of length 2"
  | _ => .error <| malformedPayload "expected JSON array"

def rememberLiveRef (ref : Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st => { st with liveRefs := st.liveRefs.insert ref sort }

def rememberLiveRefs (refs : List Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st =>
    let liveRefs := refs.foldl (fun acc ref => acc.insert ref sort) st.liveRefs
    { st with liveRefs := liveRefs }

def variadicHeadApp
    (headName : Lean.Name)
    (argSort resultSort : SSort)
    (args : List (Term argSort)) : Term resultSort :=
  let spec : ExtHeadSpec { args := List.replicate args.length argSort, result := resultSort } :=
    { name := headName }
  Term.headApp (.ext spec) (Args.ofHomogeneousList args)

instance (priority := low) {s : SessionTok} [FromJson α] : OpPayloadDecode s α where
  decodePayload payload :=
    liftDecodeExcept <| decodeJsonValueAs (α := α) payload

instance {s : SessionTok} : OpPayloadDecode s Ref where
  decodePayload payload := liftDecodeExcept <| decodeEmbeddedRef payload

instance {s : SessionTok} : OpPayloadDecode s (List Ref) where
  decodePayload payload := liftDecodeExcept <| decodeEmbeddedRefList payload

instance {s : SessionTok} [FromJson α] : OpPayloadDecode s (Ref × α) where
  decodePayload payload := do
    let (refJson, valueJson) ← liftDecodeExcept <| decodeJsonArray2 payload
    let ref ← liftDecodeExcept <| decodeEmbeddedRef refJson
    let value : α ← liftDecodeExcept <| decodeJsonValueAs valueJson
    pure (ref, value)

declare_syntax_cat pureHeadArg
declare_syntax_cat pureHeadOpt
declare_syntax_cat effectfulOpOpt

syntax "(" ident " : " term ")" : pureHeadArg
syntax "call_style " ident : pureHeadOpt
syntax "sympy_alias" : pureHeadOpt
syntax "doc " str : pureHeadOpt
syntax "dispatch_method" : effectfulOpOpt
syntax "dispatch_namespace" : effectfulOpOpt
syntax "call_style " ident : effectfulOpOpt
syntax "result_mode " ident : effectfulOpOpt
syntax "doc " str : effectfulOpOpt

syntax "register_op " ident " => " str effectfulOpOpt* : command
syntax "declare_pure_head " ident bracketedBinder* " returns " term " => " str pureHeadOpt* : command
syntax "declare_pure_head " ident bracketedBinder*
  " for " pureHeadArg+ " returns " term " => " str pureHeadOpt* : command
syntax "declare_variadic_pure_head " ident bracketedBinder*
  " for " "(" ident " : " term ")" " returns " term " => " str pureHeadOpt* : command
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
    (effectfulDispatch? : Option EffectfulDispatch := none)
    (resultMode? : Option ResultMode := none)
    (pureSpec? : Option PureSpec := none)
    (extraAliases : List String := [])
    (errorTemplate? : Option String := none) : CommandElabM Unit := do
  let declName := (← getCurrNamespace) ++ shortIdentName name
  let previous? := findRegistryEntry? (← getEnv) declName
  let previousMetadata? := previous?.map RegistryEntry.metadata
  let backendName := backendName.getString
  let entry : RegistryEntry := {
    kind := kind
    declName := declName
    backendName := backendName
    metadata := {
      dispatchMode := dispatchMode
      callStyle := callStyle
      resultMode := resultMode?.getD <| previousMetadata?.map RegistryMetadata.resultMode |>.getD .direct
      effectfulDispatch? := effectfulDispatch? <|> previousMetadata?.bind RegistryMetadata.effectfulDispatch?
      pureSpec? := pureSpec? <|> previousMetadata?.bind RegistryMetadata.pureSpec?
      backendPath := backendPathOf backendName
      aliases := ((previousMetadata?.map RegistryMetadata.aliases |>.getD []) ++
        backendName :: extraAliases).eraseDups
      categories := [reprStr kind, reprStr dispatchMode]
      docs := doc?.map (·.getString) <|> previousMetadata?.bind RegistryMetadata.docs
      errorTemplate := errorTemplate? <|> previousMetadata?.bind RegistryMetadata.errorTemplate
    }
  }
  modifyEnv fun env => addRegistryEntry env entry

private structure PureHeadOptions where
  callStyle : CallStyle := .call
  sympyAlias : Bool := false
  doc? : Option (TSyntax `str) := none

private structure EffectfulOpOptions where
  callStyle? : Option CallStyle := none
  effectfulDispatch? : Option EffectfulDispatch := none
  resultMode? : Option ResultMode := none
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

private def parseEffectfulOpOptions (opts : Array Syntax) : CommandElabM EffectfulOpOptions := do
  let mut parsed : EffectfulOpOptions := {}
  for opt in opts do
    match opt with
    | `(effectfulOpOpt| dispatch_method) =>
        parsed := { parsed with effectfulDispatch? := some .method }
    | `(effectfulOpOpt| dispatch_namespace) =>
        parsed := { parsed with effectfulDispatch? := some .namespace }
    | `(effectfulOpOpt| call_style $style:ident) =>
        let callStyle ←
          match style.getId.toString with
          | "call" => pure CallStyle.call
          | "attr" => pure CallStyle.attr
          | other => throwError "unsupported call_style `{other}`; expected `call` or `attr`"
        parsed := { parsed with callStyle? := some callStyle }
    | `(effectfulOpOpt| result_mode $mode:ident) =>
        let resultMode ←
          match mode.getId.toString with
          | "direct" => pure ResultMode.direct
          | "transformed" => pure ResultMode.transformed
          | "structured" => pure ResultMode.structured
          | other =>
              throwError
                "unsupported result_mode `{other}`; expected `direct`, `transformed`, or `structured`"
        parsed := { parsed with resultMode? := some resultMode }
    | `(effectfulOpOpt| doc $docString:str) =>
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

private abbrev PureParamCtx := Std.HashMap Name PureParam

private def parsePureParamKind? (stx : TSyntax `term) : Option PureParamKind :=
  match stx with
  | `(term| DomainDesc) => some .domain
  | `(term| Dim) => some .dim
  | `(term| SSort) => some .sort
  | _ => none

private def parsePureParamBinder? (binder : Syntax) : Option (Name × PureParam) :=
  match binder with
  | `(bracketedBinder| {$id:ident : $ty:term}) =>
      parsePureParamKind? ty |>.map fun kind =>
        (id.getId, { name := lastNameComponent id.getId.eraseMacroScopes, kind := kind })
  | `(bracketedBinder| ($id:ident : $ty:term)) =>
      parsePureParamKind? ty |>.map fun kind =>
        (id.getId, { name := lastNameComponent id.getId.eraseMacroScopes, kind := kind })
  | _ => none

private partial def parseClosedGroundDom? (stx : Syntax) : Option GroundDom :=
  match stx with
  | `(term| ($inner)) => parseClosedGroundDom? inner
  | `(term| .ZZ) => some .ZZ
  | `(term| .QQ) => some .QQ
  | `(term| .RR) => some .RR
  | `(term| .CC) => some .CC
  | `(term| .gaussianZZ) => some .gaussianZZ
  | `(term| GroundDom.ZZ) => some .ZZ
  | `(term| GroundDom.QQ) => some .QQ
  | `(term| GroundDom.RR) => some .RR
  | `(term| GroundDom.CC) => some .CC
  | `(term| GroundDom.gaussianZZ) => some .gaussianZZ
  | `(term| .GF $n:num) => some (.GF n.getNat)
  | `(term| GroundDom.GF $n:num) => some (.GF n.getNat)
  | _ => none

private partial def parseClosedDomainDesc? (stx : Syntax) : Option DomainDesc :=
  match stx with
  | `(term| ($inner)) => parseClosedDomainDesc? inner
  | `(term| .ground $ground) => parseClosedGroundDom? ground |>.map DomainDesc.ground
  | `(term| DomainDesc.ground $ground) => parseClosedGroundDom? ground |>.map DomainDesc.ground
  | `(term| .fracField $base) => parseClosedDomainDesc? base |>.map DomainDesc.fracField
  | `(term| DomainDesc.fracField $base) => parseClosedDomainDesc? base |>.map DomainDesc.fracField
  | _ => none

private partial def parsePureDomainSpec? (ctx : PureParamCtx) (stx : Syntax) : Option PureDomainSpec :=
  match stx with
  | `(term| ($inner)) => parsePureDomainSpec? ctx inner
  | `(term| $id:ident) =>
      match ctx.get? id.getId with
      | some param =>
          if param.kind == .domain then some (.var param.name)
          else parseClosedDomainDesc? stx |>.map PureDomainSpec.concrete
      | _ => parseClosedDomainDesc? stx |>.map PureDomainSpec.concrete
  | `(term| .fracField $base) => parsePureDomainSpec? ctx base |>.map PureDomainSpec.fracField
  | `(term| DomainDesc.fracField $base) => parsePureDomainSpec? ctx base |>.map PureDomainSpec.fracField
  | _ => parseClosedDomainDesc? stx |>.map PureDomainSpec.concrete

private partial def parsePureDimSpec? (ctx : PureParamCtx) (stx : Syntax) : Option PureDimSpec :=
  match stx with
  | `(term| ($inner)) => parsePureDimSpec? ctx inner
  | `(term| $id:ident) =>
      match ctx.get? id.getId with
      | some param =>
          if param.kind == .dim then some (.var param.name) else none
      | _ => none
  | `(term| .static $n:num) => some (.concrete (.static n.getNat))
  | `(term| Dim.static $n:num) => some (.concrete (.static n.getNat))
  | _ => none

private partial def parseClosedRelKind? (stx : Syntax) : Option RelKind :=
  match stx with
  | `(term| ($inner)) => parseClosedRelKind? inner
  | `(term| .eq) => some .eq
  | `(term| .ne) => some .ne
  | `(term| .lt) => some .lt
  | `(term| .le) => some .le
  | `(term| .gt) => some .gt
  | `(term| .ge) => some .ge
  | `(term| .mem) => some .mem
  | `(term| .subset) => some .subset
  | `(term| RelKind.eq) => some .eq
  | `(term| RelKind.ne) => some .ne
  | `(term| RelKind.lt) => some .lt
  | `(term| RelKind.le) => some .le
  | `(term| RelKind.gt) => some .gt
  | `(term| RelKind.ge) => some .ge
  | `(term| RelKind.mem) => some .mem
  | `(term| RelKind.subset) => some .subset
  | _ => none

private partial def parsePureSortSpec? (ctx : PureParamCtx) (stx : Syntax) : Option PureSortSpec :=
  match stx with
  | `(term| ($inner)) => parsePureSortSpec? ctx inner
  | `(term| $id:ident) =>
      match ctx.get? id.getId with
      | some param =>
          if param.kind == .sort then some (.var param.name) else none
      | _ => none
  | `(term| .boolean) => some .boolean
  | `(term| SymSort.boolean) => some .boolean
  | `(term| .scalar $domain) => parsePureDomainSpec? ctx domain |>.map PureSortSpec.scalar
  | `(term| SymSort.scalar $domain) => parsePureDomainSpec? ctx domain |>.map PureSortSpec.scalar
  | `(term| .matrix $domain $rows $cols) =>
      match parsePureDomainSpec? ctx domain, parsePureDimSpec? ctx rows, parsePureDimSpec? ctx cols with
      | some d, some r, some c => some (.matrix d r c)
      | _, _, _ => none
  | `(term| SymSort.matrix $domain $rows $cols) =>
      match parsePureDomainSpec? ctx domain, parsePureDimSpec? ctx rows, parsePureDimSpec? ctx cols with
      | some d, some r, some c => some (.matrix d r c)
      | _, _, _ => none
  | `(term| .tensor $domain [$dims,*]) =>
      match parsePureDomainSpec? ctx domain, dims.getElems.toList.mapM (parsePureDimSpec? ctx) with
      | some d, some ds => some (.tensor d ds)
      | _, _ => none
  | `(term| SymSort.tensor $domain [$dims,*]) =>
      match parsePureDomainSpec? ctx domain, dims.getElems.toList.mapM (parsePureDimSpec? ctx) with
      | some d, some ds => some (.tensor d ds)
      | _, _ => none
  | `(term| .set $elem) => parsePureSortSpec? ctx elem |>.map PureSortSpec.set
  | `(term| SymSort.set $elem) => parsePureSortSpec? ctx elem |>.map PureSortSpec.set
  | `(term| .seq $elem) => parsePureSortSpec? ctx elem |>.map PureSortSpec.seq
  | `(term| SymSort.seq $elem) => parsePureSortSpec? ctx elem |>.map PureSortSpec.seq
  | `(term| .map $key $value) =>
      match parsePureSortSpec? ctx key, parsePureSortSpec? ctx value with
      | some k, some v => some (.map k v)
      | _, _ => none
  | `(term| SymSort.map $key $value) =>
      match parsePureSortSpec? ctx key, parsePureSortSpec? ctx value with
      | some k, some v => some (.map k v)
      | _, _ => none
  | `(term| .tuple [$items,*]) =>
      items.getElems.toList.mapM (parsePureSortSpec? ctx) |>.map PureSortSpec.tuple
  | `(term| SymSort.tuple [$items,*]) =>
      items.getElems.toList.mapM (parsePureSortSpec? ctx) |>.map PureSortSpec.tuple
  | `(term| .fn [$args,*] $ret) =>
      match args.getElems.toList.mapM (parsePureSortSpec? ctx), parsePureSortSpec? ctx ret with
      | some argSorts, some retSort => some (.fn argSorts retSort)
      | _, _ => none
  | `(term| SymSort.fn [$args,*] $ret) =>
      match args.getElems.toList.mapM (parsePureSortSpec? ctx), parsePureSortSpec? ctx ret with
      | some argSorts, some retSort => some (.fn argSorts retSort)
      | _, _ => none
  | `(term| .relation $kind [$args,*]) =>
      match parseClosedRelKind? kind, args.getElems.toList.mapM (parsePureSortSpec? ctx) with
      | some relKind, some argSorts => some (.relation relKind argSorts)
      | _, _ => none
  | `(term| SymSort.relation $kind [$args,*]) =>
      match parseClosedRelKind? kind, args.getElems.toList.mapM (parsePureSortSpec? ctx) with
      | some relKind, some argSorts => some (.relation relKind argSorts)
      | _, _ => none
  | _ => none

private def mkPureSpec?
    (binders : Array Syntax)
    (argSorts : Array (TSyntax `term))
    (variadicSort? : Option (TSyntax `term))
    (resultSort : TSyntax `term) : CommandElabM (Option PureSpec) := do
  let parsedBinders := binders.map parsePureParamBinder?
  if parsedBinders.any Option.isNone then
    return none
  let params := parsedBinders.toList.filterMap id
  let ctx : PureParamCtx :=
    params.foldl (init := {}) fun acc (name, param) => acc.insert name param
  let variadicSpec? := variadicSort?.bind (fun sortTerm => parsePureSortSpec? ctx sortTerm.raw)
  match argSorts.toList.mapM (fun sortTerm => parsePureSortSpec? ctx sortTerm.raw),
      parsePureSortSpec? ctx resultSort.raw with
  | some args, some result =>
      return some
        { params := params.map Prod.snd
          args := args
          variadic? := variadicSpec?
          result := result }
  | _, _ => return none

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
  let pureSpec? ← mkPureSpec? binders (argSpecs.map Prod.snd) none resultSort
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
    options.callStyle none none pureSpec? extraAliases

private def elabDeclareVariadicPureHead
    (name : TSyntax `ident)
    (binders : Array Syntax)
    (arg : TSyntax `ident)
    (argSort resultSort : TSyntax `term)
    (backendName : TSyntax `str)
    (options : PureHeadOptions) : CommandElabM Unit := do
  if options.callStyle == .attr then
    throwError "declare_variadic_pure_head does not support `call_style attr`"
  let pureSpec? ← mkPureSpec? binders #[] (some argSort) resultSort
  let extraAliases :=
    let helperAlias := (shortIdentName name).toString
    if options.sympyAlias then
      [helperAlias, s!"SymPy.{helperAlias}"]
    else
      [helperAlias]
  let inputTy := mkPureInputTypeIdent arg
  let argBinders : Array Syntax := #[
    ← `(bracketedBinder| {$inputTy : Type}),
    ← `(bracketedBinder| [IntoPureTerm $inputTy $argSort]),
    ← `(bracketedBinder| (args : List $inputTy))
  ]
  let helperBody ← `(term|
    let pureArgs : List (Term $argSort) :=
      args.map (IntoPureTerm.intoPureTerm (σ := $argSort))
    SymbolicLean.variadicHeadApp (backendLeanNameOf $backendName) $argSort $resultSort pureArgs)
  elabGeneratedDef binders name argBinders
    (← `(term| Term $resultSort)) helperBody
  attachGeneratedDoc name options.doc?
  if options.sympyAlias then
    elabGeneratedRootNamespacedDef `SymPy binders name argBinders
      (← `(term| Term $resultSort)) helperBody
    attachGeneratedDocAt (`SymPy ++ shortIdentName name) options.doc?
  registerSymbolicDecl .head name backendName .pureHead options.doc?
    options.callStyle none none pureSpec? extraAliases

private def elabRegisterOp
    (name : TSyntax `ident)
    (opLiteral : TSyntax `str)
    (options : EffectfulOpOptions) : CommandElabM Unit := do
  let declName := (← getCurrNamespace) ++ shortIdentName name
  let previousDocs := (findRegistryEntry? (← getEnv) declName).bind (·.metadata.docs)
  let doc? := options.doc? <|> previousDocs.map fun text => Syntax.mkStrLit text
  attachGeneratedDoc name options.doc?
  registerSymbolicDecl .op name opLiteral .effectfulOp doc?
    (options.callStyle?.getD .call) options.effectfulDispatch? options.resultMode?

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

elab_rules : command
  | `(register_op $name:ident => $op:str $opts:effectfulOpOpt*) => do
      let options ← parseEffectfulOpOptions (opts.map (·.raw))
      elabRegisterOp name op options

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
  | `(declare_variadic_pure_head $name:ident $binders:bracketedBinder*
      for ($arg:ident : $argSort:term) returns $resultSort:term => $backendName:str
      $opts:pureHeadOpt*) => do
      let options ← parsePureHeadOptions (opts.map (·.raw))
      elabDeclareVariadicPureHead name (binders.map (·.raw)) arg argSort resultSort backendName options

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
