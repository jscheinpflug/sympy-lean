import Std
import SymbolicLean.Decl.Core
import SymbolicLean.Domain.Dim
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

structure SessionConfig where
  workerPath : Option System.FilePath := none
  prettyUnicode : Bool := true
  deriving Repr, Inhabited

structure SessionEnv where
  config : SessionConfig := {}
  deriving Repr, Inhabited

structure SessionState where
  nextRef : Nat := 0
  liveRefs : Std.HashMap Ref SSort := {}
  declIntern : Std.HashMap DeclKey Ref := {}
  canonicalRefs : Std.HashMap UInt64 Ref := {}
  prettyCache : Std.HashMap Ref String := {}
  dynamicDims : Std.HashMap Lean.Name Dim := {}
  deriving Inhabited

end SymbolicLean
