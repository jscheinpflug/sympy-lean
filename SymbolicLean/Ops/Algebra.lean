import SymbolicLean.Backend.Client
import SymbolicLean.Syntax.DeclareOp
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

open Lean

class SubstCompat (fromSort toSort : SSort) : Prop where
  compat : True := True.intro

instance : SubstCompat σ σ where

instance (priority := low) : SubstCompat (.scalar d1) (.scalar d2) where

structure SubstPair (s : SessionTok) where
  fromSort : SSort
  toSort : SSort
  [compat : SubstCompat fromSort toSort]
  fromExpr : SymExpr s fromSort
  toExpr : SymExpr s toSort

declare_op simplifyExpr => "simplify" doc "Apply SymPy's `simplify` to a realized expression."

declare_op factorExpr => "factor" doc "Factor a realized expression with SymPy."

declare_op expandExpr => "expand" doc "Expand a realized expression with SymPy."

declare_op cancelExpr => "cancel" doc "Cancel common factors in a realized expression."

private def encodeSubstPairs (pairs : List (SubstPair s)) : Json :=
  Json.arr <| pairs.toArray.map fun pair =>
    Json.arr #[encodeRefArg pair.fromExpr.ref.ident, encodeRefArg pair.toExpr.ref.ident]

declare_op subsExprJson {σ : SSort} for (expr : SymExpr s σ) (pairs : Json) returns σ => "subs"
  doc "Substitute a list of realized expression pairs into a realized expression."

def subsExpr (expr : SymExpr s σ) (pairs : List (SubstPair s)) : SymPyM s (SymExpr s σ) := do
  subsExprJson expr (encodeSubstPairs pairs)

end SymbolicLean
