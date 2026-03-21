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

example : Term (.scalar (.ground .QQ)) := zz 1 + qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 2 - qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 3 * qq (0 : Rat)

end SymbolicLean
