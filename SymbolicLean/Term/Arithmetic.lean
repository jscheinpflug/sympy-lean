import SymbolicLean.Term.Core

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

instance : CanAdd (.scalar d) (.scalar d) (.scalar d) where
  add := Term.scalarAdd

instance : CanSub (.scalar d) (.scalar d) (.scalar d) where
  sub := Term.scalarSub

instance : CanMul (.scalar d) (.scalar d) (.scalar d) where
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

end SymbolicLean
