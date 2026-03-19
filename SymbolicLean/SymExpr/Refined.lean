import SymbolicLean.SymExpr.Core

namespace SymbolicLean

structure SymSymbol (s : SessionTok) (σ : SSort) where
  expr : SymExpr s σ
  deriving Repr, Inhabited

structure SymFun (s : SessionTok) (args : List SSort) (ret : SSort) where
  expr : SymExpr s (.fn args ret)
  deriving Repr, Inhabited

structure SymBool (s : SessionTok) where
  expr : SymExpr s .boolean
  deriving Repr, Inhabited

structure SymRel (s : SessionTok) (rel : RelKind) (args : List SSort) where
  expr : SymExpr s (.relation rel args)
  deriving Repr, Inhabited

end SymbolicLean
