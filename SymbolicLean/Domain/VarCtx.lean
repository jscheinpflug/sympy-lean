namespace SymbolicLean

structure VarCtx where
  names : List Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable

namespace VarCtx

def empty : VarCtx := ⟨[]⟩

def ofList (names : List Lean.Name) : VarCtx := ⟨names.eraseDups⟩

def isWellFormed (ctx : VarCtx) : Prop := ctx.names.Nodup

end VarCtx

end SymbolicLean
