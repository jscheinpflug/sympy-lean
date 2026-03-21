import SymbolicLean

open SymbolicLean

private def sameEncodedTerm (lhs rhs : Term σ) : Bool :=
  (encodeTerm lhs).compress == (encodeTerm rhs).compress

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  x + y

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let f : FunDecl [Scalar Rat] (Scalar Rat) := funSym `f
  f x

example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  x

example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, qq 1)

example : BoundSpec (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, qq 0, qq 1)

example : DerivSpec (Scalar Rat) (carrierDomain Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  (x, 2)

example : PieceBranch (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  ((x : Term (Scalar Rat)), gt (x : Term (Scalar Rat)) (qq 0))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  diffWith (x : Term (Scalar Rat)) ((x, 2) : DerivSpec (Scalar Rat) (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Derivative (x : Term (Scalar Rat)) ((x, 2) : DerivSpec (Scalar Rat) (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  integralWith (x : Term (Scalar Rat)) ((x, qq 0, qq 1) : BoundSpec (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Integral (x : Term (Scalar Rat)) ((x, qq 0, qq 1) : BoundSpec (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  summation (x : Term (Scalar Rat)) ((x, qq 0, qq 3) : BoundSpec (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Sum (x : Term (Scalar Rat)) ((x, qq 0, qq 3) : BoundSpec (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  productTerm (x : Term (Scalar Rat)) ((x, qq 1, qq 3) : BoundSpec (carrierDomain Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Product (x : Term (Scalar Rat)) ((x, qq 1, qq 3) : BoundSpec (carrierDomain Rat))

example : Term (.fn [Scalar Rat] (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  lambdaTerm (x + qq 1) x

example : Term (.fn [Scalar Rat] (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Lambda (x + qq 1) x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  piecewise (((x : Term (Scalar Rat)), gt (x : Term (Scalar Rat)) (qq 0)) : PieceBranch (Scalar Rat))
    (qq 0)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Piecewise (((x : Term (Scalar Rat)), gt (x : Term (Scalar Rat)) (qq 0)) : PieceBranch (Scalar Rat))
    (qq 0)

example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  symcall% and(gt (x : Term (Scalar Rat)) (qq 0), ge (x : Term (Scalar Rat)) (qq 0))

example : Term (Scalar Rat) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[zz 0, zz 1])

example : Term (Mat Rat 2 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[zz 0:zz 1])

example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[:, zz 1])

example : Term (.map (Scalar Rat) (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  dict{ x ↦ qq 1, y ↦ qq 2 }

-- `#sympy` now accepts ordinary Lean terms and auto-binds scalar names/functions.
#sympy Rat => x + y

#sympy Rat => f x

#sympy Rat do
  symbols (x : Rat)
  pure (x + qq 1)

-- Scalar factorization over pure declarations in ordinary Lean syntax.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat) (y : Rat)
    let xTerm : Term (Scalar Rat) := x
    let yTerm : Term (Scalar Rat) := y
    let expr : Term (Scalar Rat) := xTerm ^ 2 + qq 2 * xTerm * yTerm + yTerm ^ 2
    let factored ← factor expr
    prettyRemote factored.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Term field notation routes through the public op front door.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let factored ← (xTerm ^ 2 - qq 1).factor
    prettyRemote factored.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `SymPy` namespace wrappers reuse the same public symbolic surface.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let derived : Term (Scalar Rat) := SymPy.Derivative (xTerm ^ 2) x
    let simplified ← SymPy.simplify derived
    prettyRemote simplified.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Scalar cancellation through the effectful algebra front door.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let numerator : Term (Scalar Rat) := xTerm ^ 2 - qq 1
    let denominator : Term (Scalar Rat) := xTerm - qq 1
    let expr : Term (Scalar Rat) := Term.scalarDiv numerator denominator
    let canceled ← cancel expr
    prettyRemote canceled.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Canonical-equivalent scalar terms reuse the same remote ref.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let lhs ← eval (xTerm + qq 0)
    let rhs ← eval xTerm
    pure (lhs.ref.ident == rhs.ref.ident)
  match result with
  | .ok reused => IO.println reused
  | .error err => IO.println (repr err)

noncomputable section

-- Round-trip reification matches canonicalization for pure arithmetic and relation heads.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat) (y : Rat)
    let xTerm : Term (Scalar Rat) := x
    let yTerm : Term (Scalar Rat) := y
    let term : Term .boolean := gt (xTerm + qq 0) (yTerm + qq 0)
    let realized ← eval term
    let reified ← reify realized
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Round-trip reification also preserves unevaluated calculus heads such as integrals.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let term : Term (Scalar Rat) := SymPy.Integral (xTerm ^ 2 + qq 0) x
    let realized ← eval term
    let reified ← reify realized
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Reification also works for effectful algebra results once the worker knows the output sort.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat)
    let xTerm : Term (Scalar Rat) := x
    let simplified ← simplify (xTerm + xTerm)
    let reified ← reify simplified
    pure (sameEncodedTerm reified (qq 2 * xTerm).canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

end

-- Substitution sugar lowers to the ordinary typed substitution path.
#eval do
  let result ← sympy (carrierDomain Rat) do
    symbols (x : Rat) (y : Rat)
    let xTerm : Term (Scalar Rat) := x
    let yTerm : Term (Scalar Rat) := y
    let substituted ← (xTerm + yTerm)[x ↦ 2, y ↦ 3]
    prettyRemote substituted.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
