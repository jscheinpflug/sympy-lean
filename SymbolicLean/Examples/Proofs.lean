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
    SymPy.Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat))) =
      Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat))) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Sum (x : Term (Scalar Rat)) (x, (0 : Term (Scalar Rat)), (3 : Term (Scalar Rat))) =
      Sum (x : Term (Scalar Rat)) (x, (0 : Term (Scalar Rat)), (3 : Term (Scalar Rat))) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Product (x : Term (Scalar Rat)) (x, (1 : Term (Scalar Rat)), (3 : Term (Scalar Rat))) =
      Product (x : Term (Scalar Rat)) (x, (1 : Term (Scalar Rat)), (3 : Term (Scalar Rat))) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    SymPy.Piecewise (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))) (0 : Term (Scalar Rat)) =
      Piecewise (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))) (0 : Term (Scalar Rat)) := by
  rfl

example :
    let x : SymDecl (Scalar Rat) := sym `x
    let predicate : Term .boolean := gt (SymPy.Derivative (x ^ 2) x) (0 : Term (Scalar Rat))
    predicate = gt (diff (x ^ 2) x 1) (0 : Term (Scalar Rat)) := by
  rfl
