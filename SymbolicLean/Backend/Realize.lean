import SymbolicLean.Backend.Client
import SymbolicLean.SymExpr.Refined
import SymbolicLean.Term.Canon
import SymbolicLean.Term.Core

namespace SymbolicLean

private def internedRef (key : DeclKey) : SymPyM s (Option Ref) := do
  pure <| (← get).declIntern.get? key

private def rememberInterned (key : DeclKey) (ref : Ref) : SymPyM s Unit :=
  modify fun st => { st with declIntern := st.declIntern.insert key ref }

private def canonicalRef? (key : UInt64) : SymPyM s (Option Ref) := do
  pure <| (← get).canonicalRefs.get? key

private def rememberCanonicalRef (key : UInt64) (ref : Ref) : SymPyM s Unit :=
  modify fun st => { st with canonicalRefs := st.canonicalRefs.insert key ref }

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

def eval (term : Term σ) : SymPyM s (SymExpr s σ) := do
  let canonical := term.canonicalize
  match canonical with
  | .atom (.sym decl) => return (← realizeDecl decl).expr
  | .atom (.fun_ decl) => return (← realizeFun decl).expr
  | _ =>
      let key := canonical.fingerprint
      let ref ←
        match ← canonicalRef? key with
        | some ref => pure ref
        | none =>
            let ref ← evalTermRemote term
            rememberCanonicalRef key ref
            pure ref
      return { ref := ref }

noncomputable def reify (expr : SymExpr s σ) : SymPyM s (Term σ) :=
  reifyRemote σ expr.ref

end SymbolicLean
