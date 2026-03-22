import SymbolicLean

open SymbolicLean

namespace SymbolicLean.Smoke

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  smokeUnary x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.smokeUnary x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  smokeBinary x y

end SymbolicLean.Smoke

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  x + y

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let f : FunDecl [Scalar Rat] (Scalar Rat) := funSym `f
  f x

example : Term (Scalar Int) := 2
example : Term (Scalar Rat) := 2

-- Keep the raw structured values smoke-tested directly.
example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  x

example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, (1 : Term (Scalar Rat)))

example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))

example : DerivSpec (Scalar Rat) (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, 2)

example : PieceBranch (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, gt x 0)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Derivative (d := carrierDomain Rat) x (((x, 2) : DerivSpec (Scalar Rat) (carrierDomain Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Integral (x ^ 2) (x, 0, 1)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let a : SymDecl (Scalar Rat) := sym `a
  let b : SymDecl (Scalar Rat) := sym `b
  Integral (x ^ 2) (x, a, b)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Integral (x ^ 2) (x, 0, 1)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let a : SymDecl (Scalar Rat) := sym `a
  let b : SymDecl (Scalar Rat) := sym `b
  SymPy.Integral (x ^ 2) (x, a, b)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Sum x (x, 0, 3)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let n : SymDecl (Scalar Rat) := sym `n
  Sum x (x, n)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Sum x (x, 0, 3)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Product x (x, 1, 3)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Product x (x, 1, 3)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Limit (((x ^ 2) - 1) / (x - 1)) x 1

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Limit (((x ^ 2) - 1) / (x - 1)) x 1

example : Term (.fn [Scalar Rat] (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Lambda (x + 1) x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Piecewise (x, gt x 0) 0

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Piecewise (x, gt x 0) 0

example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  symcall% and(gt x 0, ge x 0)

example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  lt 0 x

example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  eq_ x 0

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  x / 2

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (1 : Rat) / x

example : Term (Scalar Rat) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[zz 0, zz 1])

example : Term (Mat Rat 2 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[0:1])

example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[:, 1])

example : Term (.map (Scalar Rat) (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  dict{ x ↦ 1, y ↦ 2 }

-- `#sympy` now accepts ordinary Lean terms and auto-binds scalar names/functions.
#sympy Rat => x + y

#sympy Rat => f x

#sympy Rat do
  symbols (x : Rat)
  let term : Term (Scalar Rat) := x + 1
  pure term
