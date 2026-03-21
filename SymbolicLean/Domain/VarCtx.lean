import Lean.Data.Json

namespace SymbolicLean

open Lean

structure VarCtx where
  names : List Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

namespace VarCtx

def empty : VarCtx := ⟨[]⟩

def ofList (names : List Lean.Name) : VarCtx := ⟨names.eraseDups⟩

def isWellFormed (ctx : VarCtx) : Prop := ctx.names.Nodup

end VarCtx

end SymbolicLean
