import SymbolicLean.Domain.Desc

namespace SymbolicLean

class DomainCarrier (d : DomainDesc) where
  Carrier : Type

class InterpretsDomain (d : DomainDesc) [DomainCarrier d] where
  instNonempty : Nonempty (DomainCarrier.Carrier d)

attribute [instance] InterpretsDomain.instNonempty

class UnifyDomain (lhs rhs out : DomainDesc) : Prop where
  witness : True := trivial

instance (d : DomainDesc) : UnifyDomain d d d := ⟨trivial⟩

end SymbolicLean
