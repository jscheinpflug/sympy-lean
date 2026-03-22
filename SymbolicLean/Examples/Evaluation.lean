import SymbolicLean

open SymbolicLean

#sympy_hover "rref"
#sympy_hover "solve"
#sympy_search "latex"

example {s : SessionTok} (x : SymDecl (Scalar Rat)) : SymPyM s String :=
  x.latex

example {s : SessionTok} (x : SymExpr s (Scalar Rat)) : SymPyM s (SymExpr s (Scalar Rat)) :=
  x.evalf 20

-- The public `integrate` front door works over pure terms.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let integrated ← integrate (x ^ 2 : Term (Scalar Rat)) x
    pretty integrated
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `doit` forces evaluation of unevaluated pure calculus constructors.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (Scalar Rat) := SymPy.Integral (x ^ 2) x
    let evaluated ← term.doit
    pretty evaluated
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `evalf` numerically evaluates scalar expressions with explicit precision.
#eval do
  let result ← sympy Rat do
    let approximated ← evalf (SymPy.sqrt (2 : Term (Scalar Rat))) 20
    pretty approximated
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `latex` returns string output through the generic effectful decode path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    latex (x ^ 2 + 1 : Term (Scalar Rat))
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

noncomputable section

-- Evaluation results can be rendered and then reified back into typed pure terms.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (Scalar Rat) := SymPy.Integral (((x : Term (Scalar Rat)) ^ 2) + 1) x
    let evaluated ← term.doit
    let rendered ← latex evaluated
    let reified ← reify evaluated
    let prettyText ← pretty reified
    pure s!"{rendered}\n{prettyText}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

end
