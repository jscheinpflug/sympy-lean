import SymbolicLean

open SymbolicLean

/-
These examples show the current proof boundary.

Pure `SymPy.*` builders such as `SymPy.Derivative`, `SymPy.Integral`, `SymPy.Sum`,
`SymPy.Product`, and `SymPy.Piecewise` build ordinary `Term`s, so they can be used
inside kernel proofs.

Effectful calls such as `factor`, `simplify`, `solveUnivariate`, and `det` still live
in `SymPyM` and ultimately `IO`, so they belong in executable examples rather than in
ordinary theorem terms.
-/

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Derivative (x ^ 3) x 2 = diff (x ^ 3) x 2 := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Integral (x ^ 2) (x, 0, 1) = Integral (x ^ 2) (x, 0, 1) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Sum x (x, 0, 3) = Sum x (x, 0, 3) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Product x (x, 1, 3) = Product x (x, 1, 3) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Limit (((x ^ 2) - 1) / (x - 1)) x 1 =
      Limit (((x ^ 2) - 1) / (x - 1)) x 1 := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Piecewise (x, gt x 0) 0 =
      Piecewise (x, gt x 0) 0 := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    let predicate : Term .boolean := gt (SymPy.Derivative (x ^ 2) x) 0
    predicate = gt (diff (x ^ 2) x 1) 0 := by
  rfl
