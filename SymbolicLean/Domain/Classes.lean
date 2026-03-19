import Mathlib.Algebra.Field.ULift
import Mathlib.Algebra.Field.ZMod
import Mathlib.Algebra.MvPolynomial.Basic
import Mathlib.Algebra.MvPolynomial.CommRing
import Mathlib.Algebra.MvPolynomial.NoZeroDivisors
import Mathlib.Data.Complex.Basic
import Mathlib.NumberTheory.Zsqrtd.GaussianInt
import Mathlib.RingTheory.Localization.FractionRing
import SymbolicLean.Domain.Desc

namespace SymbolicLean

class DomainCarrier (d : DomainDesc) where
  Carrier : Type

abbrev CarrierOf (d : DomainDesc) [DomainCarrier d] : Type := DomainCarrier.Carrier d

class InterpretsDomain (d : DomainDesc) [DomainCarrier d] where
  instNonempty : Nonempty (CarrierOf d)

attribute [instance] InterpretsDomain.instNonempty

class InterpretsCommRing (d : DomainDesc) [DomainCarrier d] where
  instCommRing : CommRing (CarrierOf d)

attribute [instance] InterpretsCommRing.instCommRing

class InterpretsIntegralDomain (d : DomainDesc) [DomainCarrier d] where
  instCommRing : CommRing (CarrierOf d)
  instIsDomain : IsDomain (CarrierOf d)

attribute [instance] InterpretsIntegralDomain.instCommRing
attribute [instance] InterpretsIntegralDomain.instIsDomain

class InterpretsField (d : DomainDesc) [DomainCarrier d] where
  instField : Field (CarrierOf d)

attribute [instance] InterpretsField.instField

instance [DomainCarrier d] [InterpretsIntegralDomain d] : InterpretsCommRing d :=
  ⟨InterpretsIntegralDomain.instCommRing (d := d)⟩

noncomputable instance [DomainCarrier d] [InterpretsField d] : InterpretsIntegralDomain d where
  instCommRing := inferInstance
  instIsDomain := inferInstance

instance [DomainCarrier d] [InterpretsCommRing d] : InterpretsDomain d := ⟨inferInstance⟩

instance : DomainCarrier (.ground .ZZ) where
  Carrier := Int

instance : DomainCarrier (.ground .QQ) where
  Carrier := Rat

instance : DomainCarrier (.ground .RR) where
  Carrier := Real

instance : DomainCarrier (.ground .CC) where
  Carrier := Complex

instance : DomainCarrier (.ground .gaussianZZ) where
  Carrier := GaussianInt

instance (p : Nat) : DomainCarrier (.ground (.GF p)) where
  Carrier := ZMod p

instance : InterpretsIntegralDomain (.ground .ZZ) where
  instCommRing := show CommRing Int from inferInstance
  instIsDomain := show IsDomain Int from inferInstance

instance : InterpretsField (.ground .QQ) where
  instField := show Field Rat from inferInstance

noncomputable instance : InterpretsField (.ground .RR) where
  instField := show Field Real from inferInstance

noncomputable instance : InterpretsField (.ground .CC) where
  instField := show Field Complex from inferInstance

instance : InterpretsIntegralDomain (.ground .gaussianZZ) where
  instCommRing := show CommRing GaussianInt from inferInstance
  instIsDomain := show IsDomain GaussianInt from inferInstance

instance (p : Nat) : InterpretsCommRing (.ground (.GF p)) where
  instCommRing := show CommRing (ZMod p) from inferInstance

instance (p : Nat) [Fact p.Prime] : InterpretsField (.ground (.GF p)) where
  instField := show Field (ZMod p) from inferInstance

instance [DomainCarrier d] [InterpretsCommRing d] :
    DomainCarrier (.polyRing d presentation) where
  Carrier := MvPolynomial (Fin presentation.vars.names.length) (CarrierOf d)

noncomputable instance [DomainCarrier d] [InterpretsCommRing d] :
    InterpretsCommRing (.polyRing d presentation) where
  instCommRing :=
    show CommRing (MvPolynomial (Fin presentation.vars.names.length) (CarrierOf d)) from
      inferInstance

noncomputable instance [DomainCarrier d] [InterpretsIntegralDomain d] :
    InterpretsIntegralDomain (.polyRing d presentation) where
  instCommRing :=
    show CommRing (MvPolynomial (Fin presentation.vars.names.length) (CarrierOf d)) from
      inferInstance
  instIsDomain :=
    show IsDomain (MvPolynomial (Fin presentation.vars.names.length) (CarrierOf d)) from
      inferInstance

instance [DomainCarrier d] [InterpretsCommRing d] : DomainCarrier (.fracField d) where
  Carrier := FractionRing (CarrierOf d)

noncomputable instance [DomainCarrier d] [InterpretsIntegralDomain d] :
    InterpretsField (.fracField d) where
  instField := show Field (FractionRing (CarrierOf d)) from inferInstance

instance [DomainCarrier d] : DomainCarrier (.algExt d presentation relations) where
  Carrier := ULift (CarrierOf d)

instance [DomainCarrier d] [InterpretsCommRing d] :
    InterpretsCommRing (.algExt d presentation relations) where
  instCommRing := show CommRing (ULift (CarrierOf d)) from inferInstance

noncomputable instance [DomainCarrier d] [InterpretsField d] :
    InterpretsField (.algExt d presentation relations) where
  instField := show Field (ULift (CarrierOf d)) from inferInstance

instance [DomainCarrier d] : DomainCarrier (.quotient d relations) where
  Carrier := ULift (CarrierOf d)

instance [DomainCarrier d] [InterpretsCommRing d] :
    InterpretsCommRing (.quotient d relations) where
  instCommRing := show CommRing (ULift (CarrierOf d)) from inferInstance

class UnifyDomain (lhs rhs : DomainDesc) (out : outParam DomainDesc) : Prop where
  witness : True := trivial

instance (d : DomainDesc) : UnifyDomain d d d := ⟨trivial⟩

instance : UnifyDomain (.ground .ZZ) (.ground .QQ) (.ground .QQ) := ⟨trivial⟩
instance : UnifyDomain (.ground .QQ) (.ground .ZZ) (.ground .QQ) := ⟨trivial⟩
instance : UnifyDomain (.ground .ZZ) (.ground .RR) (.ground .RR) := ⟨trivial⟩
instance : UnifyDomain (.ground .RR) (.ground .ZZ) (.ground .RR) := ⟨trivial⟩
instance : UnifyDomain (.ground .ZZ) (.ground .CC) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .CC) (.ground .ZZ) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .QQ) (.ground .RR) (.ground .RR) := ⟨trivial⟩
instance : UnifyDomain (.ground .RR) (.ground .QQ) (.ground .RR) := ⟨trivial⟩
instance : UnifyDomain (.ground .QQ) (.ground .CC) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .CC) (.ground .QQ) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .RR) (.ground .CC) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .CC) (.ground .RR) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .gaussianZZ) (.ground .CC) (.ground .CC) := ⟨trivial⟩
instance : UnifyDomain (.ground .CC) (.ground .gaussianZZ) (.ground .CC) := ⟨trivial⟩
instance (d : DomainDesc) : UnifyDomain d (.fracField d) (.fracField d) := ⟨trivial⟩
instance (d : DomainDesc) : UnifyDomain (.fracField d) d (.fracField d) := ⟨trivial⟩

private def samplePresentation : PolyPresentation :=
  { vars := VarCtx.ofList [`x, `y] }

private def requiresCommRing (d : DomainDesc) [DomainCarrier d] [InterpretsCommRing d] :
    PUnit := .unit

private def requiresField (d : DomainDesc) [DomainCarrier d] [InterpretsField d] : PUnit :=
  .unit

example : PUnit := requiresCommRing (.ground .ZZ)
example : PUnit := requiresField (.ground .QQ)
example : PUnit := requiresCommRing (.ground (.GF 5))
example : PUnit := requiresCommRing (.polyRing (.ground .QQ) samplePresentation)
example : PUnit := requiresField (.fracField (.ground .ZZ))
example : PUnit := requiresField (.algExt (.ground .QQ) samplePresentation [])
example : PUnit := requiresCommRing (.quotient (.ground .ZZ) [])
example : UnifyDomain (.ground .ZZ) (.ground .QQ) (.ground .QQ) := inferInstance
example : UnifyDomain (.ground .ZZ) (.fracField (.ground .ZZ)) (.fracField (.ground .ZZ)) :=
  inferInstance

end SymbolicLean
