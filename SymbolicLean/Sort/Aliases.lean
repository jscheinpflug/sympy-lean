import SymbolicLean.Domain.Classes
import SymbolicLean.Sort.Base

namespace SymbolicLean

abbrev SymCarrier := CarrierDomain

abbrev carrierDomain (α : Type) [SymCarrier α] : DomainDesc :=
  CarrierDomain.domain (α := α)

abbrev Scalar (α : Type) [SymCarrier α] : SSort :=
  .scalar (carrierDomain α)

abbrev Mat (α : Type) [SymCarrier α] (m n : Nat) : SSort :=
  .matrix (carrierDomain α) (.static m) (.static n)

abbrev MatD (α : Type) [SymCarrier α] (m n : Lean.Name) : SSort :=
  .matrix (carrierDomain α) (.dyn m) (.dyn n)

abbrev Vec (α : Type) [SymCarrier α] (n : Nat) : SSort :=
  Mat α n 1

instance : DomainCarrier (carrierDomain Int) :=
  show DomainCarrier (.ground .ZZ) from inferInstance

instance : DomainCarrier (carrierDomain Rat) :=
  show DomainCarrier (.ground .QQ) from inferInstance

noncomputable instance : DomainCarrier (carrierDomain Real) :=
  show DomainCarrier (.ground .RR) from inferInstance

noncomputable instance : DomainCarrier (carrierDomain Complex) :=
  show DomainCarrier (.ground .CC) from inferInstance

instance : DomainCarrier (carrierDomain GaussianInt) :=
  show DomainCarrier (.ground .gaussianZZ) from inferInstance

instance (p : Nat) : DomainCarrier (carrierDomain (ZMod p)) :=
  show DomainCarrier (.ground (.GF p)) from inferInstance

instance : InterpretsIntegralDomain (carrierDomain Int) :=
  show InterpretsIntegralDomain (.ground .ZZ) from inferInstance

instance : InterpretsField (carrierDomain Rat) :=
  show InterpretsField (.ground .QQ) from inferInstance

noncomputable instance : InterpretsField (carrierDomain Real) :=
  show InterpretsField (.ground .RR) from inferInstance

noncomputable instance : InterpretsField (carrierDomain Complex) :=
  show InterpretsField (.ground .CC) from inferInstance

instance : InterpretsIntegralDomain (carrierDomain GaussianInt) :=
  show InterpretsIntegralDomain (.ground .gaussianZZ) from inferInstance

instance (p : Nat) : InterpretsCommRing (carrierDomain (ZMod p)) :=
  show InterpretsCommRing (.ground (.GF p)) from inferInstance

instance (p : Nat) [Fact p.Prime] : InterpretsField (carrierDomain (ZMod p)) :=
  show InterpretsField (.ground (.GF p)) from inferInstance

instance [SymCarrier α] [DomainCarrier (CarrierDomain.domain (α := α))] :
    DomainCarrier (carrierDomain α) :=
  show DomainCarrier (CarrierDomain.domain (α := α)) from inferInstance

instance [SymCarrier α] [DomainCarrier (CarrierDomain.domain (α := α))]
    [InterpretsDomain (CarrierDomain.domain (α := α))] :
    InterpretsDomain (carrierDomain α) :=
  show InterpretsDomain (CarrierDomain.domain (α := α)) from inferInstance

instance [SymCarrier α] [DomainCarrier (CarrierDomain.domain (α := α))]
    [InterpretsCommRing (CarrierDomain.domain (α := α))] :
    InterpretsCommRing (carrierDomain α) :=
  show InterpretsCommRing (CarrierDomain.domain (α := α)) from inferInstance

instance [SymCarrier α] [DomainCarrier (CarrierDomain.domain (α := α))]
    [InterpretsIntegralDomain (CarrierDomain.domain (α := α))] :
    InterpretsIntegralDomain (carrierDomain α) :=
  show InterpretsIntegralDomain (CarrierDomain.domain (α := α)) from inferInstance

instance [SymCarrier α] [DomainCarrier (CarrierDomain.domain (α := α))]
    [InterpretsField (CarrierDomain.domain (α := α))] :
    InterpretsField (carrierDomain α) :=
  show InterpretsField (CarrierDomain.domain (α := α)) from inferInstance

end SymbolicLean
