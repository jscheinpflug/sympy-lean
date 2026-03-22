import SymbolicLean

open SymbolicLean

#sympy_hover "Min"
#sympy_hover "Max"

private def sameEncodedTerm (lhs rhs : Term σ) : Bool :=
  (encodeTerm lhs).compress == (encodeTerm rhs).compress

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.sin x + SymPy.cos x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.sqrt (x + 1)

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  SymPy.atan2 x y

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  SymPy.Min ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  SymPy.Max ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.exp x + SymPy.log (x + 1)

noncomputable section

example : Term (.scalar (.ground .CC)) :=
  let z : SymDecl (.scalar (.ground .CC)) := sym `z
  SymPy.conjugate z

example : Term (.scalar (.ground .RR)) :=
  let z : SymDecl (.scalar (.ground .CC)) := sym `z
  SymPy.re z + SymPy.im z

#sympy Rat do
  symbols (x : Rat)
  let expr : Term (Scalar Rat) :=
    SymPy.sin (x + 1) + SymPy.exp (x + 1)
  pure expr

#sympy Complex do
  symbols (z : Complex)
  let expr : Term (Scalar Real) := SymPy.re z + SymPy.im z
  pure expr

-- Registry-backed pure special-function heads evaluate through the generic worker path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let expr : Term (Scalar Rat) :=
      SymPy.sin x + SymPy.cos y + SymPy.sqrt (x + 1) +
        SymPy.Min ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))
    let simplified ← simplify expr
    pretty simplified
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

-- Complex-valued pure heads also render through the same registry-driven path.
#eval do
  let result ← sympy Complex do
    symbols (z : Complex)
    let conjugateExpr : Term (.scalar (.ground .CC)) := SymPy.conjugate z
    let partsExpr : Term (.scalar (.ground .RR)) := SymPy.re z + SymPy.im z
    let conjugateText ← pretty conjugateExpr
    let partsText ← pretty partsExpr
    pure s!"{conjugateText}\n{partsText}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

noncomputable section

-- Generic reification round-trips representative unary special-function heads.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let term : Term (Scalar Rat) := SymPy.sin x
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- The same generic fallback also covers representative binary special-function heads.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let term : Term (Scalar Rat) := SymPy.atan2 x y
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

-- Homogeneous variadic scalar heads round-trip through the same manifest-driven reify path.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let term : Term (Scalar Rat) :=
      SymPy.Max ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))
    let simplified ← simplify term
    let reified ← reify simplified
    pure (sameEncodedTerm reified term.canonicalize)
  match result with
  | .ok ok => IO.println ok
  | .error err => IO.println (repr err)

end
