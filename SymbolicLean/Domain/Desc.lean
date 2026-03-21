import Lean.Data.Json
import SymbolicLean.Domain.VarCtx

namespace SymbolicLean

open Lean

inductive GroundDom where
  | ZZ
  | QQ
  | RR
  | CC
  | gaussianZZ
  | GF : Nat → GroundDom
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

structure PolyPresentation where
  vars : VarCtx
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

structure AlgRelation where
  name : Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

structure IdealRelation where
  name : Lean.Name
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

inductive DomainDesc where
  | ground : GroundDom → DomainDesc
  | polyRing : DomainDesc → PolyPresentation → DomainDesc
  | fracField : DomainDesc → DomainDesc
  | algExt : DomainDesc → PolyPresentation → List AlgRelation → DomainDesc
  | quotient : DomainDesc → List IdealRelation → DomainDesc
  deriving Repr, DecidableEq, BEq, Hashable, ToJson, FromJson

end SymbolicLean
