import SymbolicLean

open SymbolicLean

-- Solve a scalar polynomial equation as a finite solve.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x
    let solved ← solveUnivariate term![x^2 - 1] x
    match solved.solutions with
    | solution :: _ => IO.println (← prettyRemote solution.ref)
    | [] => IO.println "[]"
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)

-- Show the symbolic solve-set result.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x
    let solved := solveset term![x^2 - 1] x
    let setExpr ← solved
    prettyRemote setExpr.setExpr.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Solve a first-order ODE from pure declarations.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x
    functions f
    let ode : Term .boolean := eq_ (diff (term![f x]) x) (term![f x])
    let solved ← dsolve ode f
    prettyRemote solved.equation.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Boolean solver and assumption query examples.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols (x : positive)
    let xTerm : Term (.scalar (.ground .QQ)) := term![x]
    let zeroExpr : Term (.scalar (.ground .QQ)) := xTerm - xTerm
    let satFormula : Term .boolean := and_ (gt xTerm zeroExpr) (eq_ xTerm xTerm)
    let sat ← satisfiable satFormula
    IO.println (repr sat)
    let answer ← ask x .positive
    IO.println (repr answer)
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)
