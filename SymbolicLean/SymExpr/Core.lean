import SymbolicLean.Sort.Base

namespace SymbolicLean

structure SessionTok where
  nonce : Nat
  deriving Repr, DecidableEq, BEq, Hashable, Inhabited

structure Ref where
  ident : Nat
  deriving Repr, DecidableEq, BEq, Hashable, Inhabited

structure SymExpr (s : SessionTok) (σ : SSort) where
  ref : Ref
  deriving Repr, Inhabited

end SymbolicLean
