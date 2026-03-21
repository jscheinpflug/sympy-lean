import SymbolicLean.Term.Core

namespace SymbolicLean

def zz (value : Int) : Term (.scalar (.ground .ZZ)) := .intLit value

def qq (value : Rat) : Term (.scalar (.ground .QQ)) := .ratLit value

instance instOfNatZZTerm {n : Nat} : OfNat (Term (.scalar (.ground .ZZ))) n where
  ofNat := .natLit n

instance instOfNatQQTerm {n : Nat} : OfNat (Term (.scalar (.ground .QQ))) n where
  ofNat := qq n

end SymbolicLean
