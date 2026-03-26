import SymbolicLean

open SymbolicLean

#sympy_hover "rref"
#sympy_hover "solve"
#sympy_hover "satisfiable"
#sympy_hover "ask"
#sympy_hover "Smoke.latexModeText"
#sympy_hover "differentiate"
#sympy_hover "limitExpr"
#sympy_hover "seriesExprCore"
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

-- `differentiate` is the eager front door for realized differentiation.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let derived ← differentiate (x ^ 3 : Term (Scalar Rat)) x 2
    pretty derived
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `limit` is the eager front door for realized scalar limits.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let approached ← limit ((SymPy.sin x) / x : Term (Scalar Rat)) x (0 : Rat)
    pretty approached
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `series` eagerly computes a realized series expansion around a point.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expanded ← series (SymPy.sin x : Term (Scalar Rat)) x (0 : Rat) 6
    pretty expanded
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- `doit` remains available when the workflow intentionally starts from a pure builder.
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

-- Dotted namespace dispatch also works through the manifest-driven effectful path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let realized ← realize (x + 1 : Term (Scalar Rat))
    Smoke.sreprDottedText realized
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Method dispatch with keyword arguments uses the same manifest-driven path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (Scalar Rat) := SymPy.Integral (x ^ 2) x
    let realized ← realize term
    let shallow ← Smoke.doitShallowExpr realized
    pretty shallow
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Namespace dispatch with keyword arguments uses the same manifest-driven path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let realized ← realize (x ^ 2 + 1 : Term (Scalar Rat))
    SymbolicLean.Smoke.latexModeText realized "plain"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

noncomputable section

-- Evaluation results can be rendered and then reified back into typed pure terms.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let evaluated ← integrate (x ^ 2 + 1 : Term (Scalar Rat)) x
    let rendered ← latex evaluated
    let reified ← reify evaluated
    let prettyText ← pretty reified
    pure s!"{rendered}\n{prettyText}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

end
