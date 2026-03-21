import Lean

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

inductive ResultMode where
  | direct
  | transformed
  | structured
  deriving Repr, Inhabited, BEq, Hashable, ToJson

structure RegistryMetadata where
  surfaceRole : SurfaceRole := .free
  dispatchMode : DispatchMode
  reifyMode : ReifyMode := .opaque
  resultMode : ResultMode := .direct
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
