import SymbolicLean.Syntax.StructuredArgs
import SymbolicLean.Term.Calculus

namespace SymbolicLean

def integralUpperHeadName : Lean.Name := `integralUpper
def integralLowerHeadName : Lean.Name := `integralLower
def integralRangeHeadName : Lean.Name := `integralRange
def sumUpperHeadName : Lean.Name := `summationUpper
def sumLowerHeadName : Lean.Name := `summationLower
def sumRangeHeadName : Lean.Name := `summationRange
def productUpperHeadName : Lean.Name := `productUpper
def productLowerHeadName : Lean.Name := `productLower
def productRangeHeadName : Lean.Name := `productRange
def lambdaHeadName : Lean.Name := `lambda
def piecewiseHeadName : Lean.Name := `piecewise

private def unaryBoundSpec (name : Lean.Name) (d : DomainDesc) :
    ExtHeadSpec { args := [.scalar d, .scalar d, .scalar d], result := .scalar d } :=
  { name := name }

private def rangeBoundSpec (name : Lean.Name) (d : DomainDesc) :
    ExtHeadSpec { args := [.scalar d, .scalar d, .scalar d, .scalar d], result := .scalar d } :=
  { name := name }

private def lambdaHeadSpec (σ : SSort) (d : DomainDesc) :
    ExtHeadSpec { args := [σ, .scalar d], result := .fn [.scalar d] σ } :=
  { name := lambdaHeadName }

private def piecewiseHeadSpec (σ : SSort) :
    ExtHeadSpec { args := [σ, .boolean, σ], result := σ } :=
  { name := piecewiseHeadName }

def diffWith (body : Term σ) (spec : DerivSpec σ d) : Term σ :=
  diff body spec.var spec.order

def integralWith (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  match bound.lower?, bound.upper? with
  | none, none => integral body bound.var
  | none, some upper =>
      .headApp (.ext (unaryBoundSpec integralUpperHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons upper .nil)))
  | some lower, none =>
      .headApp (.ext (unaryBoundSpec integralLowerHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower .nil)))
  | some lower, some upper =>
      .headApp (.ext (rangeBoundSpec integralRangeHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower (.cons upper .nil))))

def summation (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  match bound.lower?, bound.upper? with
  | none, none =>
      .headApp (.ext (unaryBoundSpec sumUpperHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons (bound.var : Term (.scalar d)) .nil)))
  | none, some upper =>
      .headApp (.ext (unaryBoundSpec sumUpperHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons upper .nil)))
  | some lower, none =>
      .headApp (.ext (unaryBoundSpec sumLowerHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower .nil)))
  | some lower, some upper =>
      .headApp (.ext (rangeBoundSpec sumRangeHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower (.cons upper .nil))))

def productTerm (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  match bound.lower?, bound.upper? with
  | none, none =>
      .headApp (.ext (unaryBoundSpec productUpperHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons (bound.var : Term (.scalar d)) .nil)))
  | none, some upper =>
      .headApp (.ext (unaryBoundSpec productUpperHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons upper .nil)))
  | some lower, none =>
      .headApp (.ext (unaryBoundSpec productLowerHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower .nil)))
  | some lower, some upper =>
      .headApp (.ext (rangeBoundSpec productRangeHeadName d))
        (.cons body (.cons (bound.var : Term (.scalar d)) (.cons lower (.cons upper .nil))))

def lambdaTerm (body : Term σ) (var : BoundVar d) : Term (.fn [.scalar d] σ) :=
  .headApp (.ext (lambdaHeadSpec σ d)) (.pair body (var : Term (.scalar d)))

@[match_pattern] def piecewise (branch : PieceBranch σ) (fallback : Term σ) : Term σ :=
  .headApp (.ext (piecewiseHeadSpec σ))
    (.cons branch.body (.cons branch.condition (.cons fallback .nil)))

end SymbolicLean
