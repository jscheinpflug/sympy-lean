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
  (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Derivative (d := carrierDomain Rat) x (((x, 2) : DerivSpec (Scalar Rat) (carrierDomain Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Sum x (x, (0 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Sum x (x, (0 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Product x (x, (1 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Product x (x, (1 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))

example : Term (.fn [Scalar Rat] (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Lambda (x + 1) x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Piecewise (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))) (0 : Term (Scalar Rat))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Piecewise (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))) (0 : Term (Scalar Rat))

example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  symcall% and(gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat)),
    ge (x : Term (Scalar Rat)) (0 : Term (Scalar Rat)))

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

-- Scalar factorization over pure declarations in ordinary Lean syntax.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 + 2 * x * y + y ^ 2
    let factored ← factor expr
    pretty factored
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Term field notation routes through the public op front door.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let factored ← expr.factor
    pretty factored
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `SymPy` namespace wrappers reuse the same public symbolic surface.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let derived : Term (Scalar Rat) := SymPy.Derivative (x ^ 2) x
    let simplified ← SymPy.simplify derived
    pretty simplified
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Scalar cancellation through the effectful algebra front door.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := (x ^ 2 - 1) / (x - 1)
    let canceled ← cancel expr
    pretty canceled
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Canonical-equivalent scalar terms reuse the same remote ref.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let lhsTerm : Term (Scalar Rat) := x + 0
    let lhs ← eval lhsTerm
    let rhs ← eval (x : Term (Scalar Rat))
    pure (lhs.ref.ident == rhs.ref.ident)
  match result with
  | .ok reused => IO.println reused
  | .error err => IO.println (repr err)

noncomputable section

-- Round-trip reification matches canonicalization for pure arithmetic and relation heads.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let lhs : Term (Scalar Rat) := x + 0
    let rhs : Term (Scalar Rat) := y + 0
    let term : Term .boolean := gt lhs rhs
    let realized ← eval term
    let reified ← reify realized
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Round-trip reification also preserves unevaluated calculus heads such as integrals.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let body : Term (Scalar Rat) := x ^ 2 + 0
    let term : Term (Scalar Rat) := SymPy.Integral body
      (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))
    let realized ← eval term
    let reified ← reify realized
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Reification also works for effectful algebra results once the worker knows the output sort.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let simplified ← simplify (x + x)
    let reified ← reify simplified
    let target : Term (Scalar Rat) := 2 * x
    pure (sameEncodedTerm reified target.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

end

-- Substitution sugar lowers to the ordinary typed substitution path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let substituted ← (x + y)[x ↦ 2, y ↦ 3]
    pretty substituted
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
