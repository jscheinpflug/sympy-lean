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
  neg := Term.scalarNeg

instance [UnifyDomain d1 d2 out] : CanAdd (.scalar d1) (.scalar d2) (.scalar out) where
  add := Term.scalarAdd

instance [UnifyDomain d1 d2 out] : CanSub (.scalar d1) (.scalar d2) (.scalar out) where
  sub := Term.scalarSub

instance [UnifyDomain d1 d2 out] : CanMul (.scalar d1) (.scalar d2) (.scalar out) where
  mul := Term.scalarMul

instance : CanDiv (.scalar d) (.scalar d) (.scalar d) where
  div := Term.scalarDiv

instance : CanPow (.scalar d) (.scalar (.ground .ZZ)) (.scalar d) where
  pow := Term.scalarPow

instance : CanAdd (.matrix d m n) (.matrix d m n) (.matrix d m n) where
  add := Term.matrixAdd

instance : CanSub (.matrix d m n) (.matrix d m n) (.matrix d m n) where
  sub := Term.matrixSub

instance : CanMul (.matrix d m n) (.matrix d n p) (.matrix d m p) where
  mul := Term.matrixMul

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

example : Term (.scalar (.ground .QQ)) := zz 1 + qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 2 - qq (0 : Rat)
example : Term (.scalar (.ground .QQ)) := zz 3 * qq (0 : Rat)

end SymbolicLean
