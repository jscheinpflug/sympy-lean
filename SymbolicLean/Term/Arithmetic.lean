import SymbolicLean.Term.Head
import SymbolicLean.Term.Literals

namespace SymbolicLean

class CanNeg (σ : SSort) where
  neg : Term σ → Term σ

class CanAdd (lhs rhs : SSort) (out : outParam SSort) where
  add : Term lhs → Term rhs → Term out

class CanSub (lhs rhs : SSort) (out : outParam SSort) where
  sub : Term lhs → Term rhs → Term out

class CanMul (lhs rhs : SSort) (out : outParam SSort) where
  mul : Term lhs → Term rhs → Term out

class CanDiv (lhs rhs : SSort) (out : outParam SSort) where
  div : Term lhs → Term rhs → Term out

class CanPow (base exp : SSort) (out : outParam SSort) where
  pow : Term base → Term exp → Term out

instance : CanNeg (.scalar d) where
  neg term := Term.headApp (.core (.scalarNeg d)) (.singleton term)

instance [UnifyDomain d1 d2 out] : CanAdd (.scalar d1) (.scalar d2) (.scalar out) where
  add lhs rhs := Term.headApp (.core (.scalarAdd d1 d2 out)) (.pair lhs rhs)

instance [UnifyDomain d1 d2 out] : CanSub (.scalar d1) (.scalar d2) (.scalar out) where
  sub lhs rhs := Term.headApp (.core (.scalarSub d1 d2 out)) (.pair lhs rhs)

instance [UnifyDomain d1 d2 out] : CanMul (.scalar d1) (.scalar d2) (.scalar out) where
  mul lhs rhs := Term.headApp (.core (.scalarMul d1 d2 out)) (.pair lhs rhs)

instance : CanDiv (.scalar d) (.scalar d) (.scalar d) where
  div lhs rhs := Term.headApp (.core (.scalarDiv d)) (.pair lhs rhs)

instance : CanPow (.scalar d) (.scalar (.ground .ZZ)) (.scalar d) where
  pow lhs rhs := Term.headApp (.core (.scalarPow d)) (.pair lhs rhs)

instance : CanAdd (.matrix d m n) (.matrix d m n) (.matrix d m n) where
  add lhs rhs := Term.headApp (.core (.matrixAdd d m n)) (.pair lhs rhs)

instance : CanSub (.matrix d m n) (.matrix d m n) (.matrix d m n) where
  sub lhs rhs := Term.headApp (.core (.matrixSub d m n)) (.pair lhs rhs)

instance : CanMul (.matrix d m n) (.matrix d n p) (.matrix d m p) where
  mul lhs rhs := Term.headApp (.core (.matrixMul d m n p)) (.pair lhs rhs)

instance [CanNeg σ] : Neg (Term σ) where
  neg := CanNeg.neg

instance [CanAdd σ τ υ] : HAdd (Term σ) (Term τ) (Term υ) where
  hAdd := CanAdd.add

instance [CanSub σ τ υ] : HSub (Term σ) (Term τ) (Term υ) where
  hSub := CanSub.sub

instance [CanMul σ τ υ] : HMul (Term σ) (Term τ) (Term υ) where
  hMul := CanMul.mul

instance [CanDiv σ τ υ] : HDiv (Term σ) (Term τ) (Term υ) where
  hDiv := CanDiv.div

instance [CanPow σ τ υ] : HPow (Term σ) (Term τ) (Term υ) where
  hPow := CanPow.pow

instance [CanAdd σ τ υ] : HAdd (SymDecl σ) (SymDecl τ) (Term υ) where
  hAdd lhs rhs := (lhs : Term σ) + (rhs : Term τ)

instance [CanAdd σ τ υ] : HAdd (SymDecl σ) (Term τ) (Term υ) where
  hAdd lhs rhs := (lhs : Term σ) + rhs

instance [CanAdd σ τ υ] : HAdd (Term σ) (SymDecl τ) (Term υ) where
  hAdd lhs rhs := lhs + (rhs : Term τ)

instance [CanSub σ τ υ] : HSub (SymDecl σ) (SymDecl τ) (Term υ) where
  hSub lhs rhs := (lhs : Term σ) - (rhs : Term τ)

instance [CanSub σ τ υ] : HSub (SymDecl σ) (Term τ) (Term υ) where
  hSub lhs rhs := (lhs : Term σ) - rhs

instance [CanSub σ τ υ] : HSub (Term σ) (SymDecl τ) (Term υ) where
  hSub lhs rhs := lhs - (rhs : Term τ)

instance [CanMul σ τ υ] : HMul (SymDecl σ) (SymDecl τ) (Term υ) where
  hMul lhs rhs := (lhs : Term σ) * (rhs : Term τ)

instance [CanMul σ τ υ] : HMul (SymDecl σ) (Term τ) (Term υ) where
  hMul lhs rhs := (lhs : Term σ) * rhs

instance [CanMul σ τ υ] : HMul (Term σ) (SymDecl τ) (Term υ) where
  hMul lhs rhs := lhs * (rhs : Term τ)

instance [CanDiv σ τ υ] : HDiv (SymDecl σ) (SymDecl τ) (Term υ) where
  hDiv lhs rhs := (lhs : Term σ) / (rhs : Term τ)

instance [CanDiv σ τ υ] : HDiv (SymDecl σ) (Term τ) (Term υ) where
  hDiv lhs rhs := (lhs : Term σ) / rhs

instance [CanDiv σ τ υ] : HDiv (Term σ) (SymDecl τ) (Term υ) where
  hDiv lhs rhs := lhs / (rhs : Term τ)

instance [CanPow σ τ υ] : HPow (SymDecl σ) (Term τ) (Term υ) where
  hPow base exp := (base : Term σ) ^ exp

instance [CanPow σ τ υ] : HPow (Term σ) (SymDecl τ) (Term υ) where
  hPow base exp := base ^ (exp : Term τ)

instance [CanPow σ τ υ] : HPow (SymDecl σ) (SymDecl τ) (Term υ) where
  hPow base exp := (base : Term σ) ^ (exp : Term τ)

instance [CanPow σ (.scalar (.ground .ZZ)) υ] : HPow (Term σ) Nat (Term υ) where
  hPow base exp := base ^ Term.natLit exp

instance [CanPow σ (.scalar (.ground .ZZ)) υ] : HPow (SymDecl σ) Nat (Term υ) where
  hPow base exp := (base : Term σ) ^ Term.natLit exp

private def natScalarTerm (value : Nat) : Term (.scalar (.ground .ZZ)) := .natLit value

private def intScalarTerm (value : Int) : Term (.scalar (.ground .ZZ)) := .intLit value

private def ratScalarTerm (value : Rat) : Term (.scalar (.ground .QQ)) := .ratLit value

instance [UnifyDomain d (.ground .ZZ) out] : HAdd (Term (.scalar d)) Nat (Term (.scalar out)) where
  hAdd lhs rhs := lhs + natScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HAdd (SymDecl (.scalar d)) Nat (Term (.scalar out)) where
  hAdd lhs rhs := (lhs : Term (.scalar d)) + natScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HAdd Nat (Term (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := natScalarTerm lhs + rhs

instance [UnifyDomain (.ground .ZZ) d out] : HAdd Nat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := natScalarTerm lhs + (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .ZZ) out] : HAdd (Term (.scalar d)) Int (Term (.scalar out)) where
  hAdd lhs rhs := lhs + intScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HAdd (SymDecl (.scalar d)) Int (Term (.scalar out)) where
  hAdd lhs rhs := (lhs : Term (.scalar d)) + intScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HAdd Int (Term (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := intScalarTerm lhs + rhs

instance [UnifyDomain (.ground .ZZ) d out] : HAdd Int (SymDecl (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := intScalarTerm lhs + (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .QQ) out] : HAdd (Term (.scalar d)) Rat (Term (.scalar out)) where
  hAdd lhs rhs := lhs + ratScalarTerm rhs

instance [UnifyDomain d (.ground .QQ) out] : HAdd (SymDecl (.scalar d)) Rat (Term (.scalar out)) where
  hAdd lhs rhs := (lhs : Term (.scalar d)) + ratScalarTerm rhs

instance [UnifyDomain (.ground .QQ) d out] : HAdd Rat (Term (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := ratScalarTerm lhs + rhs

instance [UnifyDomain (.ground .QQ) d out] : HAdd Rat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hAdd lhs rhs := ratScalarTerm lhs + (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .ZZ) out] : HSub (Term (.scalar d)) Nat (Term (.scalar out)) where
  hSub lhs rhs := lhs - natScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HSub (SymDecl (.scalar d)) Nat (Term (.scalar out)) where
  hSub lhs rhs := (lhs : Term (.scalar d)) - natScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HSub Nat (Term (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := natScalarTerm lhs - rhs

instance [UnifyDomain (.ground .ZZ) d out] : HSub Nat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := natScalarTerm lhs - (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .ZZ) out] : HSub (Term (.scalar d)) Int (Term (.scalar out)) where
  hSub lhs rhs := lhs - intScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HSub (SymDecl (.scalar d)) Int (Term (.scalar out)) where
  hSub lhs rhs := (lhs : Term (.scalar d)) - intScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HSub Int (Term (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := intScalarTerm lhs - rhs

instance [UnifyDomain (.ground .ZZ) d out] : HSub Int (SymDecl (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := intScalarTerm lhs - (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .QQ) out] : HSub (Term (.scalar d)) Rat (Term (.scalar out)) where
  hSub lhs rhs := lhs - ratScalarTerm rhs

instance [UnifyDomain d (.ground .QQ) out] : HSub (SymDecl (.scalar d)) Rat (Term (.scalar out)) where
  hSub lhs rhs := (lhs : Term (.scalar d)) - ratScalarTerm rhs

instance [UnifyDomain (.ground .QQ) d out] : HSub Rat (Term (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := ratScalarTerm lhs - rhs

instance [UnifyDomain (.ground .QQ) d out] : HSub Rat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hSub lhs rhs := ratScalarTerm lhs - (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .ZZ) out] : HMul (Term (.scalar d)) Nat (Term (.scalar out)) where
  hMul lhs rhs := lhs * natScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HMul (SymDecl (.scalar d)) Nat (Term (.scalar out)) where
  hMul lhs rhs := (lhs : Term (.scalar d)) * natScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HMul Nat (Term (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := natScalarTerm lhs * rhs

instance [UnifyDomain (.ground .ZZ) d out] : HMul Nat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := natScalarTerm lhs * (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .ZZ) out] : HMul (Term (.scalar d)) Int (Term (.scalar out)) where
  hMul lhs rhs := lhs * intScalarTerm rhs

instance [UnifyDomain d (.ground .ZZ) out] : HMul (SymDecl (.scalar d)) Int (Term (.scalar out)) where
  hMul lhs rhs := (lhs : Term (.scalar d)) * intScalarTerm rhs

instance [UnifyDomain (.ground .ZZ) d out] : HMul Int (Term (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := intScalarTerm lhs * rhs

instance [UnifyDomain (.ground .ZZ) d out] : HMul Int (SymDecl (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := intScalarTerm lhs * (rhs : Term (.scalar d))

instance [UnifyDomain d (.ground .QQ) out] : HMul (Term (.scalar d)) Rat (Term (.scalar out)) where
  hMul lhs rhs := lhs * ratScalarTerm rhs

instance [UnifyDomain d (.ground .QQ) out] : HMul (SymDecl (.scalar d)) Rat (Term (.scalar out)) where
  hMul lhs rhs := (lhs : Term (.scalar d)) * ratScalarTerm rhs

instance [UnifyDomain (.ground .QQ) d out] : HMul Rat (Term (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := ratScalarTerm lhs * rhs

instance [UnifyDomain (.ground .QQ) d out] : HMul Rat (SymDecl (.scalar d)) (Term (.scalar out)) where
  hMul lhs rhs := ratScalarTerm lhs * (rhs : Term (.scalar d))

instance [IntoScalarTerm Rat d] : HDiv (Term (.scalar d)) Nat (Term (.scalar d)) where
  hDiv lhs rhs := lhs / IntoTerm.intoTerm (σ := .scalar d) (rhs : Rat)

instance [IntoScalarTerm Rat d] : HDiv (SymDecl (.scalar d)) Nat (Term (.scalar d)) where
  hDiv lhs rhs := (lhs : Term (.scalar d)) / IntoTerm.intoTerm (σ := .scalar d) (rhs : Rat)

instance [IntoScalarTerm Rat d] : HDiv Nat (Term (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) (lhs : Rat) / rhs

instance [IntoScalarTerm Rat d] : HDiv Nat (SymDecl (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) (lhs : Rat) / (rhs : Term (.scalar d))

instance [IntoScalarTerm Rat d] : HDiv (Term (.scalar d)) Int (Term (.scalar d)) where
  hDiv lhs rhs := lhs / IntoTerm.intoTerm (σ := .scalar d) (rhs : Rat)

instance [IntoScalarTerm Rat d] : HDiv (SymDecl (.scalar d)) Int (Term (.scalar d)) where
  hDiv lhs rhs := (lhs : Term (.scalar d)) / IntoTerm.intoTerm (σ := .scalar d) (rhs : Rat)

instance [IntoScalarTerm Rat d] : HDiv Int (Term (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) (lhs : Rat) / rhs

instance [IntoScalarTerm Rat d] : HDiv Int (SymDecl (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) (lhs : Rat) / (rhs : Term (.scalar d))

instance [IntoScalarTerm Rat d] : HDiv (Term (.scalar d)) Rat (Term (.scalar d)) where
  hDiv lhs rhs := lhs / IntoTerm.intoTerm (σ := .scalar d) rhs

instance [IntoScalarTerm Rat d] : HDiv (SymDecl (.scalar d)) Rat (Term (.scalar d)) where
  hDiv lhs rhs := (lhs : Term (.scalar d)) / IntoTerm.intoTerm (σ := .scalar d) rhs

instance [IntoScalarTerm Rat d] : HDiv Rat (Term (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) lhs / rhs

instance [IntoScalarTerm Rat d] : HDiv Rat (SymDecl (.scalar d)) (Term (.scalar d)) where
  hDiv lhs rhs := IntoTerm.intoTerm (σ := .scalar d) lhs / (rhs : Term (.scalar d))

example : Term (.scalar (.ground .QQ)) := zz 1 + qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 2 - qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 3 * qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := qq (1 : Rat) / 2
example : Term (.scalar (.ground .QQ)) := (1 : Rat) / qq (2 : Rat)

end SymbolicLean
