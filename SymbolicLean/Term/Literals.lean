import SymbolicLean.Sort.Aliases
import SymbolicLean.Term.Core

namespace SymbolicLean

class IntoScalarTerm (α : Type) (d : outParam DomainDesc) extends IntoTerm α (.scalar d) where
  -- Scalar-specialized pure-term conversion used when the target domain matters for literals.

def zz (value : Int) : Term (.scalar (.ground .ZZ)) := .intLit value

def qq (value : Rat) : Term (.scalar (.ground .QQ)) := .ratLit value

instance : IntoScalarTerm (Term (.scalar d)) d where
  intoTerm := id

instance : IntoScalarTerm (SymDecl (.scalar d)) d where
  intoTerm decl := (decl : Term (.scalar d))

instance : IntoScalarTerm Nat (.ground .ZZ) where
  intoTerm := .natLit

instance : IntoScalarTerm Int (.ground .ZZ) where
  intoTerm := .intLit

instance : IntoScalarTerm Nat (carrierDomain Int) where
  intoTerm := .natLit

instance : IntoScalarTerm Int (carrierDomain Int) where
  intoTerm := .intLit

instance : IntoScalarTerm Nat (.ground .QQ) where
  intoTerm value := qq value

instance : IntoScalarTerm Int (.ground .QQ) where
  intoTerm value := qq value

instance : IntoScalarTerm Rat (.ground .QQ) where
  intoTerm := qq

instance : IntoScalarTerm Nat (carrierDomain Rat) where
  intoTerm value := qq value

instance : IntoScalarTerm Int (carrierDomain Rat) where
  intoTerm value := qq value

instance : IntoScalarTerm Rat (carrierDomain Rat) where
  intoTerm := qq

instance instOfNatZZTerm {n : Nat} : OfNat (Term (.scalar (.ground .ZZ))) n where
  ofNat := .natLit n

instance instOfNatQQTerm {n : Nat} : OfNat (Term (.scalar (.ground .QQ))) n where
  ofNat := qq n

instance instOfNatScalarInt {n : Nat} : OfNat (Term (Scalar Int)) n where
  ofNat := .natLit n

instance instOfNatScalarRat {n : Nat} : OfNat (Term (Scalar Rat)) n where
  ofNat := qq n

end SymbolicLean
