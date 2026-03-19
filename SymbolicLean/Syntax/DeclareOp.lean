import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Core

namespace SymbolicLean

syntax "declare_sympy_op " ident " => " str : command

macro_rules
  | `(declare_sympy_op $name:ident => $op:str) =>
      `(def $name {s : SessionTok} {σ : SSort} (expr : SymExpr s σ) :
          SymPyM s (SymExpr s σ) := do
          let ref ← applyOpRemoteRef σ $op expr.ref
          pure { ref := ref })

end SymbolicLean
