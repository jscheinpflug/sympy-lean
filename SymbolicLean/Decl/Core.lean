import SymbolicLean.Decl.Assumptions
import SymbolicLean.Sort.Base

namespace SymbolicLean

structure SymDecl (σ : SSort) where
  name : Lean.Name
  assumptions : List AssumptionFact := []

structure FunDecl (args : List SSort) (ret : SSort) where
  name : Lean.Name

inductive DeclKind where
  | sym
  | fun_
  deriving Repr, DecidableEq, BEq, Hashable

structure DeclKey where
  kind : DeclKind
  name : Lean.Name
  sort : SSort
  assumptions : List AssumptionFact := []
  deriving Repr, BEq, Hashable

namespace SymDecl

def key (decl : SymDecl σ) : DeclKey where
  kind := .sym
  name := decl.name
  sort := σ
  assumptions := decl.assumptions

end SymDecl

namespace FunDecl

def key (decl : FunDecl args ret) : DeclKey where
  kind := .fun_
  name := decl.name
  sort := .fn args ret

end FunDecl

end SymbolicLean
