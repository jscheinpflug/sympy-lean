import SymbolicLean

open SymbolicLean

example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 2) := sym `v
  A * v

-- Dimension-checked matrix-vector multiplication built from pure declarations.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2) (v : Vec Rat 2)
    let product : Term (Vec Rat 2) := A * v
    pretty product
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Determinant now goes through the public matrix front door.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let determinant ← det A
    pretty determinant
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Property-style linear-algebra wrappers are available from the public front door.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let inverse ← A.I
    pretty inverse
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Row-reduction also goes through the public front door.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let reduced ← rref A
    let text ← pretty reduced.reduced
    pure s!"{text} pivots={reduced.pivots}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
