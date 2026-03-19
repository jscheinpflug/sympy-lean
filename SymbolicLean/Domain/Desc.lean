import SymbolicLean.Domain.VarCtx

namespace SymbolicLean

inductive GroundDom where
  | ZZ
  | QQ
  | RR
  | CC
  | gaussianZZ
  | GF : Nat → GroundDom
  deriving Repr, DecidableEq, BEq, Hashable

structure PolyPresentation where
  vars : VarCtx
  deriving Repr, DecidableEq, BEq, Hashable

structure AlgRelation where
  name : Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable

structure IdealRelation where
  name : Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable

inductive DomainDesc where
  | ground : GroundDom → DomainDesc
  | polyRing : DomainDesc → PolyPresentation → DomainDesc
  | fracField : DomainDesc → DomainDesc
  | algExt : DomainDesc → PolyPresentation → List AlgRelation → DomainDesc
  | quotient : DomainDesc → List IdealRelation → DomainDesc
  deriving Repr, DecidableEq, BEq, Hashable

end SymbolicLean
