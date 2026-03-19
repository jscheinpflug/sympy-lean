import SymbolicLean

open SymbolicLean

-- Scalar factorization over pure declarations and `term!`.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x y
    let expr := term![x^2 + 2*x*y + y^2]
    let factored ← factor expr
    prettyRemote factored.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Scalar cancellation through the effectful algebra front door.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x
    let xTerm : Term (.scalar (.ground .QQ)) := term![x]
    let numerator : Term (.scalar (.ground .QQ)) := term![x^2 - 1]
    let denominator : Term (.scalar (.ground .QQ)) := xTerm - term![1]
    let expr : Term (.scalar (.ground .QQ)) := Term.scalarDiv numerator denominator
    let canceled ← cancel expr
    prettyRemote canceled.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Substitution sugar lowers to the ordinary typed substitution path.
#eval do
  let result ← sympy (.ground .QQ) do
    symbols x y
    let substituted ← term![x + y][x ↦ 2, y ↦ 3]
    prettyRemote substituted.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
