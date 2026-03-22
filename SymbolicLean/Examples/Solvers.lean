import SymbolicLean

open SymbolicLean

#sympy_hover "FiniteSet"
#sympy_hover "Reals"

private def sameEncodedTerm (lhs rhs : Term σ) : Bool :=
  (encodeTerm lhs).compress == (encodeTerm rhs).compress

example : Term (.set (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Interval 0 x

example : Term (.set (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Union (SymPy.Interval 0 x) (SymPy.Interval 1 2)

example : Term (.set (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  SymPy.FiniteSet ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))

example : Term (.set (.scalar (.ground .RR))) :=
  SymPy.S.Reals

example : Term (.set (.scalar (.ground .ZZ))) :=
  SymPy.S.Integers

example : Term (.set (Scalar Rat)) :=
  SymPy.Interval (-1 : Int) 1

-- Solve a scalar polynomial equation as a finite solve.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← solve expr x
    match solved.solutions with
    | solution :: _ => IO.println (← pretty solution)
    | [] => IO.println "[]"
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)

-- Show the symbolic solve-set result.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let setExpr ← solveset expr x
    pretty setExpr.setExpr
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Solver front-door methods also work through Lean field notation.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← expr.solve x
    match solved.solutions with
    | solution :: _ => IO.println (← pretty solution)
    | [] => IO.println "[]"
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)

-- The compatibility alias remains available while `solve` becomes the canonical front door.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← solveUnivariate expr x
    pure solved.solutions.length
  match result with
  | .ok n => IO.println n
  | .error err => IO.println (repr err)

-- Solve a first-order ODE from pure declarations.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    functions (f : Rat → Rat)
    let ode : Term .boolean := eq_ (SymPy.Derivative (f x) x) (f x)
    let solved ← dsolve ode f
    pretty solved.equation
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Boolean solver and assumption query examples.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat | positive)
    let zeroExpr : Term (Scalar Rat) := x - x
    let satFormula : Term .boolean := and_ (gt x zeroExpr) SymPy.S.true_
    let sat ← satFormula.satisfiable
    IO.println (repr sat)
    let answer ← x.ask SymPy.Q.positive
    IO.println (repr answer)
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)

-- Pure set vocabulary is available alongside the realized solver result surface.
#eval do
  let result ← sympy Rat do
    let intervalText ← pretty (SymPy.Interval 0 1)
    let realsText ← pretty (SymPy.S.Reals : Term (.set (.scalar (.ground .RR))))
    pure s!"{intervalText}\n{realsText}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Symbolic interval and union constructors stay usable inside solver-oriented sessions.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let intervalText ← pretty (SymPy.Interval 0 x)
    let unionText ← pretty (SymPy.Union (SymPy.Interval (-1 : Int) 0) (SymPy.Interval 1 2))
    let finiteText ←
      pretty (SymPy.FiniteSet ([x, (1 : Term (Scalar Rat)), 2] : List (Term (Scalar Rat))))
    pure s!"{intervalText}\n{unionText}\n{finiteText}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

noncomputable section

-- Generic reification now also covers set-returning extension call heads.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (.set (Scalar Rat)) := SymPy.Interval 0 x
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Nullary `S.*` attr constants round-trip through the same manifest-driven reify path.
#eval do
  let result ← sympy Rat do
    let term : Term (.set (.scalar (.ground .RR))) := SymPy.S.Reals
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Homogeneous variadic set constructors also round-trip through the generic reify path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (.set (Scalar Rat)) :=
      SymPy.FiniteSet ([x, (1 : Term (Scalar Rat)), 2] : List (Term (Scalar Rat)))
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Assumption scopes shadow declarations with additional `Q.*` facts inside ordinary Lean `do`.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    assuming [x ↦ SymPy.Q.positive] do
      let answer ← x.ask SymPy.Q.positive
      IO.println (repr answer)
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)

end
