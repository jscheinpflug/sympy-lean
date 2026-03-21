import Lean
import Lean.Data.Json
import SymbolicLean.Backend.Client
import SymbolicLean.Decl.Assumptions
import SymbolicLean.Syntax.Registry
import SymbolicLean.SymExpr.Core
import SymbolicLean.SymExpr.Refined

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

private def mkAuxIdent (base : TSyntax `ident) (suffix : String) : TSyntax `ident :=
  Lean.mkIdentFrom base <| base.getId.appendAfter suffix

private def attachGeneratedDoc (name : TSyntax `ident) (doc? : Option (TSyntax `str)) :
    CommandElabM Unit := do
  match doc? with
  | none => pure ()
  | some docString =>
      let declName := (← getCurrNamespace) ++ name.getId
      Lean.addDocStringCore declName docString.getString

private def registerSymbolicDecl
    (kind : RegistryKind)
    (name : TSyntax `ident)
    (backendName : TSyntax `str)
    (dispatchMode : DispatchMode)
    (doc? : Option (TSyntax `str))
    (errorTemplate? : Option String := none) : CommandElabM Unit := do
  let declName := (← getCurrNamespace) ++ name.getId
  let entry : RegistryEntry := {
    kind := kind
    declName := declName
    backendName := backendName.getString
    metadata := {
      dispatchMode := dispatchMode
      aliases := [backendName.getString]
      categories := [reprStr kind, reprStr dispatchMode]
      docs := doc?.map (·.getString)
      errorTemplate := errorTemplate?
    }
  }
  modifyEnv fun env => addRegistryEntry env entry

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

elab "declare_sympy_op " name:ident " => " op:str : command => do
  let sigmaBinder ← `(bracketedBinder| {σ : SSort})
  let argTy ← `(term| SymExpr s σ)
  let outSort ← `(term| σ)
  let exprId := Lean.mkIdent `expr
  elabDeclareSympyOp name #[sigmaBinder.raw] exprId argTy outSort op none

elab "declare_sympy_op " name:ident " => " op:str " doc " docString:str : command => do
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

elab "declare_head " name:ident binders:bracketedBinder*
    " for " "(" _arg:ident " : " _argTy:term ")" " returns " _outSort:term " => "
    backendName:str : command => do
  let _ := binders
  elabDeclareHead name backendName none

elab "declare_head " name:ident binders:bracketedBinder*
    " for " "(" _arg:ident " : " _argTy:term ")" " returns " _outSort:term " => "
    backendName:str " doc " docString:str : command => do
  let _ := binders
  elabDeclareHead name backendName (some docString)

end SymbolicLean
