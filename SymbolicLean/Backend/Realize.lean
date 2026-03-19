import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Refined
import SymbolicLean.Term.Core

namespace SymbolicLean

private def internedRef (key : DeclKey) : SymPyM s (Option Ref) := do
  pure <| (← get).declIntern.get? key

private def rememberInterned (key : DeclKey) (ref : Ref) : SymPyM s Unit :=
  modify fun st => { st with declIntern := st.declIntern.insert key ref }

def realizeDecl (decl : SymDecl σ) : SymPyM s (SymSymbol s σ) := do
  let key := decl.key
  let ref ←
    match ← internedRef key with
    | some ref => pure ref
    | none =>
        let ref ← mkSymbolRemote decl
        rememberInterned key ref
        pure ref
  pure { expr := { ref := ref } }

def realizeFun (decl : FunDecl args ret) : SymPyM s (SymFun s args ret) := do
  let key := decl.key
  let ref ←
    match ← internedRef key with
    | some ref => pure ref
    | none =>
        let ref ← mkFunctionRemote decl
        rememberInterned key ref
        pure ref
  pure { expr := { ref := ref } }

def eval : Term σ → SymPyM s (SymExpr s σ)
  | .atom (.sym decl) => return (← realizeDecl decl).expr
  | .atom (.fun_ decl) => return (← realizeFun decl).expr
  | term => return { ref := (← evalTermRemote term) }

end SymbolicLean
