import Lean.CoreM
import Lean.Data.Json
import Lean.Elab.Frontend
import SymbolicLean

open Lean
open SymbolicLean

structure RegistryManifest where
  version : Nat := manifestVersion
  entries : List RegistryEntry
  deriving ToJson

private def orderedEntries (env : Lean.Environment) : List RegistryEntry :=
  (registryEntries env).mergeSort fun lhs rhs =>
    lhs.declName.toString < rhs.declName.toString

def main (args : List String) : IO UInt32 := do
  let outFile ←
    match args with
    | [path] => pure path
    | _ => throw <| IO.userError "usage: sympy_manifest <output-path>"
  initSearchPath (← findSysroot)
  let manifest : RegistryManifest ←
    do
      let some env ← Lean.Elab.runFrontend "import SymbolicLean\n" {} "ManifestMainProbe.lean"
          `ManifestMainProbe (trustLevel := 1024)
        | throw <| IO.userError "failed to elaborate synthetic manifest probe module"
      pure ({ entries := orderedEntries env } : RegistryManifest)
  let outPath : System.FilePath := outFile
  IO.FS.createDirAll <| outPath.parent.getD "."
  IO.FS.writeFile outPath (toJson manifest).pretty
  pure 0
