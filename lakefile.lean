import Lake

open Lake DSL System

package «symbolic-lean» where
  version := v!"0.1.0"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.28.0"

@[default_target]
lean_lib SymbolicLean

lean_lib SymbolicLeanExamples where
  srcDir := "."
  roots := #[`SymbolicLean.Examples]
  extraDepTargets := #[`sympyManifest]

@[default_target]
lean_exe «symbolic-lean» where
  root := `Main

lean_exe sympy_manifest where
  root := `ManifestMain
  supportInterpreter := true

@[default_target]
target sympyManifest pkg : FilePath := do
  let manifestExe ← sympy_manifest.fetch
  let manifestFile := pkg.buildDir / "sympy" / "manifest.json"
  let leanPath ← getAugmentedLeanPath
  buildFileAfterDep (text := true) manifestFile manifestExe fun exeFile => do
    IO.FS.createDirAll <| manifestFile.parent.getD "."
    proc {
      cmd := exeFile.toString
      args := #[manifestFile.toString]
      cwd := some pkg.dir
      env := #[("LEAN_PATH", leanPath.toString)]
    } (quiet := true)
