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
    let realized ← eval product
    prettyRemote realized.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Determinant on a realized symbolic matrix.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let matrix ← realizeDecl A
    let determinant ← det matrix.expr
    prettyRemote determinant.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Property-style linear-algebra wrappers are available from the public front door.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let inverse ← A.I
    prettyRemote inverse.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
