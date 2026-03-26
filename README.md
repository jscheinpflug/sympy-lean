# SymbolicLean

SymbolicLean is a typed Lean front end for SymPy.

It gives Lean a disciplined symbolic-computation bridge:
- pure symbolic declarations and terms live in Lean,
- realized symbolic expressions live in a session-scoped SymPy worker,
- front-door wrappers keep common workflows close to ordinary mathematical Lean syntax.

The project is deliberately narrow:
- Lean checks expression formation, sort discipline, domain discipline, matrix dimensions, declaration identity, and session safety.
- SymPy performs the actual symbolic computation.
- The library does not try to reimplement SymPy inside Lean or prove every SymPy result correct.

## What You Get

- Pure symbolic declarations and functions via `SymDecl`, `FunDecl`, `sym`, `funSym`, `symbols`, and `functions`
- Typed symbolic terms via `Term`, including scalar arithmetic, logic, relations, calculus heads, matrices, containers, and structured symbolic forms
- Session-scoped realized expressions via `SymExpr` and `SymPyM`
- Front-door algebra, calculus, evaluation/render, linear-algebra, and solver operations over declarations, terms, or realized expressions
- Registry-backed pure special functions plus solver-facing set and matrix vocabulary such as `Interval`, `FiniteSet`, and `Trace`
- Ordinary-Lean syntax for:
  - `sympy Rat do ...`
  - `#sympy Rat => ...`
  - `Derivative`, `Integral`, `Sum`, `Product`, `Lambda`, `Piecewise`, `Limit`
  - substitution, indexing, slicing, dictionaries, and scoped assumptions
- Round-trip bridges through `realize`, `reify`, and `pretty`
- Canonical effectful front doors such as `solve`, `integrate`, `differentiate`, `doit`, `evalf`, `latex`, and `trace`

## Quick Examples

The executable versions of these snippets live under [`SymbolicLean/Examples`](SymbolicLean/Examples).

### Exploratory syntax

SymPy:

```python
from sympy import Function, symbols
x, y = symbols("x y")
f = Function("f")

x + y
f(x)
```

Lean:

```lean
#sympy Rat => x + y
#sympy Rat => f x
```

### Pure special functions

SymPy:

```python
from sympy import Min, asinh, atan2, cot, gamma, sin, sqrt, symbols
x, y = symbols("x y")

sin(x) + cot(y) + asinh(x) + gamma(x + 1) + sqrt(x + 1) + atan2(x, y) + Min(1, x, y)
```

Lean:

```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  SymPy.sin x + SymPy.cot y + SymPy.asinh x + SymPy.gamma (x + 1) +
    SymPy.sqrt (x + 1) + SymPy.atan2 x y +
    SymPy.Min ([x, y, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat)))
```

### Polynomial factorization

SymPy:

```python
from sympy import factor, symbols
x, y = symbols("x y")

factor(x**2 + 2*x*y + y**2)
```

Lean:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 + 2 * x * y + y ^ 2
    let factored ← factor expr
    pretty factored
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### Eager calculus

SymPy:

```python
from sympy import diff, limit, symbols
x = symbols("x")

diff(x**3, x, 2)
limit(sin(x)/x, x, 0)
```

Lean:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let derived ← differentiate (x ^ 3 : Term (Scalar Rat)) x 2
    let approached ← limit ((SymPy.sin x) / x : Term (Scalar Rat)) x (0 : Rat)
    pure s!"{← pretty derived}\n{← pretty approached}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### Solver workflow

SymPy:

```python
from sympy import solve, solveset, symbols
x = symbols("x")

solve(x**2 - 1, x)
solveset(x**2 - 1, x)
```

Lean:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← solve expr x
    let setExpr ← solveset expr x
    let firstText ←
      match solved.solutions with
      | solution :: _ => pretty solution
      | [] => pure "[]"
    let setText ← pretty setExpr.setExpr
    IO.println s!"first={← firstText}\nset={setText}"
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)
```

### Solver sets and assumptions

SymPy:

```python
from sympy import EmptySet, FiniteSet, Interval, Naturals, Q, ask, symbols
x = symbols("x", nonpositive=True)

Interval(0, x)
FiniteSet(1, x)
Naturals
EmptySet
ask(Q.nonpositive(x))
```

Lean:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat | nonpositive)
    let intervalText ← pretty (SymPy.Interval 0 x)
    let finiteText ←
      pretty (SymPy.FiniteSet ([x, (1 : Term (Scalar Rat))] : List (Term (Scalar Rat))))
    let naturalsText ← pretty (SymPy.S.Naturals : Term (.set (.scalar (.ground .ZZ))))
    let emptyText ← pretty (SymPy.S.EmptySet : Term (.set (.scalar (.ground .QQ))))
    let answer ← x.ask SymPy.Q.nonpositive
    pure s!"{intervalText}\n{finiteText}\n{naturalsText}\n{emptyText}\n{repr answer}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### Matrix workflow

SymPy:

```python
from sympy import MatrixSymbol, Trace, trace
A = MatrixSymbol("A", 2, 2)

Trace(A)
trace(A)
A.rank()
A.adjugate()
```

Lean:

```lean
example : Term (Scalar Rat) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  SymPy.Trace A

#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let tr ← trace A
    let rk ← rank A
    let cofactors ← adjugate A
    pure s!"trace={← pretty tr}\nrank={← pretty rk}\nadjugate={← pretty cofactors}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### Evaluation and rendering

SymPy:

```python
from sympy import integrate, latex, symbols
x = symbols("x")
latex(integrate(x**2, x))
```

Lean:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let integrated ← integrate (x ^ 2 : Term (Scalar Rat)) x
    latex integrated
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### Round-trip after evaluation

Lean:

```lean
noncomputable section

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
```

## Documentation

- Full project guide: [`docs/project-guide.md`](docs/project-guide.md)
- Documentation index: [`docs/index.md`](docs/index.md)
- Architecture and doc contracts: [`docs/architecture.md`](docs/architecture.md)
- Implementation status snapshot: [`docs/plans/symboliclean-implementation.md`](docs/plans/symboliclean-implementation.md)
- Public example docs:
  - [`docs/SymbolicLean/Examples/Scalars.lean.md`](docs/SymbolicLean/Examples/Scalars.lean.md)
  - [`docs/SymbolicLean/Examples/ScalarsRuntime.lean.md`](docs/SymbolicLean/Examples/ScalarsRuntime.lean.md)
  - [`docs/SymbolicLean/Examples/Evaluation.lean.md`](docs/SymbolicLean/Examples/Evaluation.lean.md)
  - [`docs/SymbolicLean/Examples/Matrices.lean.md`](docs/SymbolicLean/Examples/Matrices.lean.md)
  - [`docs/SymbolicLean/Examples/Proofs.lean.md`](docs/SymbolicLean/Examples/Proofs.lean.md)
  - [`docs/SymbolicLean/Examples/SpecialFunctions.lean.md`](docs/SymbolicLean/Examples/SpecialFunctions.lean.md)
  - [`docs/SymbolicLean/Examples/Solvers.lean.md`](docs/SymbolicLean/Examples/Solvers.lean.md)
  - [`docs/SymbolicLean/Examples/Negative.lean.md`](docs/SymbolicLean/Examples/Negative.lean.md)

## Documentation Harness

This project uses a docs-first agentic harness:
- `AGENTS.md` and `CLAUDE.md` are index files only.
- Canonical guidance lives under [`docs/`](docs/).
- Core source files are mirrored into `/docs` with the same relative path plus `.md`.

## Validate Local State

```bash
lake build SymbolicLean
lake build SymbolicLean.Examples
lake env lean SymbolicLean/Examples/Evaluation.lean
lake env lean SymbolicLean/Examples/Scalars.lean
# optional deeper scalar runtime/reify smoke
lake env lean SymbolicLean/Examples/ScalarsRuntime.lean
lake env lean SymbolicLean/Examples/Matrices.lean
lake env lean SymbolicLean/Examples/SpecialFunctions.lean
lake env lean SymbolicLean/Examples/Solvers.lean
python3 scripts/check_doc_harness.py --mode local --scope core
```
