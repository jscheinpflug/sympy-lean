import SymbolicLean

open SymbolicLean

#sympy_hover "SymbolicLean.Trace"
#sympy_search "trace"

example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 2) := sym `v
  A * v

example : Term (Scalar Rat) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  SymPy.Trace A

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

-- Pure matrix extension heads such as `Trace` also go through the manifest-driven path.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let tr : Term (Scalar Rat) := SymPy.Trace A
    pretty tr
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Effectful trace uses the generalized namespace dispatch path over realized matrices.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let tr ← trace A
    pretty tr
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Matrix rank returns a realized integer-valued scalar expression.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let rk ← rank A
    pretty rk
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

-- Adjugate also goes through the public front door for square symbolic matrices.
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let cofactors ← adjugate A
    pretty cofactors
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
