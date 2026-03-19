import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean

structure SubstPair (s : SessionTok) where
  σ : SSort
  fromExpr : SymExpr s σ
  toExpr : SymExpr s σ

private def unaryPreserving (op : String) (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) := do
  let ref ← applyOpRemoteRef σ op expr.ref
  pure { ref := ref }

def simplifyExpr (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) :=
  unaryPreserving "simplify" expr

def factorExpr (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) :=
  unaryPreserving "factor" expr

def expandExpr (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) :=
  unaryPreserving "expand" expr

def cancelExpr (expr : SymExpr s σ) : SymPyM s (SymExpr s σ) :=
  unaryPreserving "cancel" expr

private def encodeSubstPairs (pairs : List (SubstPair s)) : Json :=
  Json.arr <| pairs.toArray.map fun pair =>
    Json.arr #[encodeRefArg pair.fromExpr.ref.ident, encodeRefArg pair.toExpr.ref.ident]

def subsExpr (expr : SymExpr s σ) (pairs : List (SubstPair s)) : SymPyM s (SymExpr s σ) := do
  let ref ← applyOpRemoteRef σ "subs" expr.ref [encodeSubstPairs pairs]
  pure { ref := ref }

end SymbolicLean
