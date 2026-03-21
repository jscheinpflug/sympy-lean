import SymbolicLean

open SymbolicLean

-- Solve a scalar polynomial equation as a finite solve.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← solveUnivariate expr x
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
    let solved ← expr.solveUnivariate x
    match solved.solutions with
    | solution :: _ => IO.println (← pretty solution)
    | [] => IO.println "[]"
  match result with
  | .ok _ => pure ()
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
