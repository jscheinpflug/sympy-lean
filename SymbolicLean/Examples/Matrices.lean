import SymbolicLean

open SymbolicLean

-- Dimension-checked matrix-vector multiplication built from pure declarations.
#eval do
  let result ← withSession {} fun _s => do
    let A : SymDecl (.matrix (.ground .QQ) (.static 2) (.static 2)) := { name := `A }
    let v : SymDecl (.matrix (.ground .QQ) (.static 2) (.static 1)) := { name := `v }
    let product := term![A * v]
    let realized ← eval product
    prettyRemote realized.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Determinant on a realized symbolic matrix.
#eval do
  let result ← withSession {} fun _s => do
    let A : SymDecl (.matrix (.ground .QQ) (.static 2) (.static 2)) := { name := `A }
    let matrix ← realizeDecl A
    let determinant ← det matrix.expr
    prettyRemote determinant.ref
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
