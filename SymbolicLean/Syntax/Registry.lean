import Lean
import SymbolicLean.Sort.Base

namespace SymbolicLean

open Lean

inductive RegistryKind where
  | head
  | op
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive SurfaceRole where
  | free
  | method
  | property
  | namespaceAttr
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive DispatchMode where
  | pureHead
  | effectfulOp
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive ReifyMode where
  | opaque
  | immediate
  | deferred
  deriving Repr, Inhabited, BEq, Hashable, ToJson

-- `ResultMode` stays intentionally coarse: it is a discoverability/runtime-classification signal
-- for the manifest, while the precise transport-level shape still lives in `OpPayloadDecode`.
inductive ResultMode where
  | direct
  | transformed
  | structured
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive CallStyle where
  | call
  | attr
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive EffectfulDispatch where
  | method
  | namespace
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive PureParamKind where
  | sort
  | domain
  | dim
  deriving Repr, Inhabited, BEq, Hashable, ToJson

structure PureParam where
  name : String
  kind : PureParamKind
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive PureDomainSpec where
  | concrete : DomainDesc → PureDomainSpec
  | var : String → PureDomainSpec
  | fracField : PureDomainSpec → PureDomainSpec
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive PureDimSpec where
  | concrete : Dim → PureDimSpec
  | var : String → PureDimSpec
  deriving Repr, Inhabited, BEq, Hashable, ToJson

inductive PureSortSpec where
  | boolean
  | var : String → PureSortSpec
  | scalar : PureDomainSpec → PureSortSpec
  | matrix : PureDomainSpec → PureDimSpec → PureDimSpec → PureSortSpec
  | tensor : PureDomainSpec → List PureDimSpec → PureSortSpec
  | set : PureSortSpec → PureSortSpec
  | tuple : List PureSortSpec → PureSortSpec
  | seq : PureSortSpec → PureSortSpec
  | map : PureSortSpec → PureSortSpec → PureSortSpec
  | fn : List PureSortSpec → PureSortSpec → PureSortSpec
  | relation : RelKind → List PureSortSpec → PureSortSpec
  deriving Repr, Inhabited, BEq, Hashable, ToJson

structure PureSpec where
  params : List PureParam := []
  args : List PureSortSpec
  variadic? : Option PureSortSpec := none
  result : PureSortSpec
  deriving Repr, ToJson

structure RegistryMetadata where
  surfaceRole : SurfaceRole := .free
  dispatchMode : DispatchMode
  reifyMode : ReifyMode := .opaque
  resultMode : ResultMode := .direct
  backendPath : List String := []
  callStyle : CallStyle := .call
  effectfulDispatch? : Option EffectfulDispatch := none
  pureSpec? : Option PureSpec := none
  aliases : List String := []
  categories : List String := []
  docs : Option String := none
  errorTemplate : Option String := none
  deriving Repr, Inhabited, ToJson

structure RegistryEntry where
  kind : RegistryKind
  declName : Name
  backendName : String
  metadata : RegistryMetadata
  deriving Repr, Inhabited, ToJson

abbrev RegistryState := Std.HashMap Name RegistryEntry

initialize symbolicRegistryExt : SimplePersistentEnvExtension RegistryEntry RegistryState ←
  registerSimplePersistentEnvExtension {
    name := `symbolicRegistryExt
    addImportedFn := fun entries =>
      entries.foldl (init := {}) fun state entryArray =>
        entryArray.foldl (init := state) fun inner entry =>
          inner.insert entry.declName entry
    addEntryFn := fun state entry =>
      state.insert entry.declName entry
  }

def addRegistryEntry (env : Environment) (entry : RegistryEntry) : Environment :=
  symbolicRegistryExt.addEntry env entry

def findRegistryEntry? (env : Environment) (name : Name) : Option RegistryEntry :=
  (symbolicRegistryExt.getState env).get? name

def registryEntries (env : Environment) : List RegistryEntry :=
  (symbolicRegistryExt.getState env).toList.map Prod.snd

end SymbolicLean
