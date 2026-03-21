import Std
import SymbolicLean.Decl.Core
import SymbolicLean.Domain.Dim
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

abbrev WorkerChild :=
  IO.Process.Child
    { stdin := IO.Process.Stdio.null
      stdout := IO.Process.Stdio.piped
      stderr := IO.Process.Stdio.piped }

structure WorkerProcess where
  stdin : IO.FS.Handle
  child : WorkerChild

structure SessionConfig where
  workerPath : Option System.FilePath := none
  workerTimeoutMs : UInt32 := 15000
  prettyUnicode : Bool := true
  deriving Repr, Inhabited

structure SessionEnv where
  config : SessionConfig := {}
  deriving Repr, Inhabited

structure SessionState where
  nextRequestId : Nat := 0
  nextRef : Nat := 0
  worker : Option WorkerProcess := none
  workerReady : Bool := false
  liveRefs : Std.HashMap Ref SSort := {}
  declIntern : Std.HashMap DeclKey Ref := {}
  canonicalRefs : Std.HashMap UInt64 Ref := {}
  prettyCache : Std.HashMap Ref String := {}
  deriving Inhabited

end SymbolicLean
