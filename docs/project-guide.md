# SymbolicLean Project Guide

This guide explains the current project as it exists today: what each major subsystem does, how the pure and effectful layers fit together, what the library can do, what the current boundaries are, and how to extend it safely.

For the shorter entrypoint narrative, see `README.md`. For the module-by-module mirror docs, start at [docs/index.md](index.md). For the repository-wide documentation rules, see [architecture.md](architecture.md).

## What SymbolicLean Is

SymbolicLean is a typed Lean front end for SymPy.

It is deliberately not trying to:
- reimplement SymPy inside Lean,
- prove every SymPy computation correct,
- or replace Lean's own theorem-proving infrastructure.

Instead, it splits the problem in two:
- Lean owns expression formation, sorts, domains, dimensions, declaration identity, and session safety.
- SymPy owns symbolic computation, simplification, solving, pretty-printing, and evaluation of effectful operations.

That split gives the project its main shape:
- pure symbolic objects live in Lean as typed declarations and terms,
- realized symbolic objects live in a session-scoped backend process,
- front-door wrappers let users write ordinary Lean syntax while keeping the pure/effectful boundary explicit.

## Design At A Glance

The main runtime flow is:

```text
SymDecl / FunDecl
        |
        v
     Term σ
        |
      eval
        |
        v
   SymExpr s σ  -- session-scoped backend ref
        |
  algebra / calculus / solver / matrix ops
        |
        v
 SymExpr s τ or typed result container
        |
  pretty / reify / further ops
```

The most important design decision is that `Term` and `SymExpr` are different things:
- `Term σ` is a pure Lean AST. Building it does not contact SymPy.
- `SymExpr s σ` is a live handle to a backend object in session `s`.
- `eval` crosses the boundary from pure to realized.
- `reify` crosses back from realized to pure.

The other key design decision is that backend handles are session-indexed:
- a `SymExpr s σ` cannot be mixed with a `SymExpr t σ` from a different session,
- a `SessionTok` is minted by `withSession`,
- front-door syntax like `sympy Rat do ...` opens a session and keeps the token implicit.

## Core Types And Invariants

### Pure layer
- `SymDecl σ`
  - a pure symbolic declaration with sort `σ`
  - stable Lean-side identity, plus optional symbolic assumptions
  - declared with `sym`, `symWith`, or binder sugar such as `symbols (x : Rat | positive)`
- `FunDecl args ret`
  - a pure symbolic function declaration
  - declared with `funSym` or binder sugar such as `functions (f : Rat → Rat)`
- `Term σ`
  - the pure typed symbolic AST
  - supports coercions from `SymDecl` and `FunDecl`
  - carries sort information at the type level
  - uses a hybrid internal representation, but public users mostly see ordinary operators and helper builders

### Realized layer
- `Ref`
  - backend object identifier returned by the worker
- `SymExpr s σ`
  - realized symbolic expression of sort `σ` in session `s`
- `SymSymbol s σ`, `SymFun s args ret`
  - thin refined wrappers over `SymExpr`
  - used when an operation requires a realized symbol or function specifically
- `SessionTok`
  - phantom token tying realized handles to one session
- `SymPyM s α`
  - the effect monad used for worker-backed symbolic workflows
  - owns session state, worker process access, caches, and errors

### Result containers
Structured effectful APIs return typed containers instead of raw JSON. The main ones today live in [Ops/Results](SymbolicLean/Ops/Results.lean.md):
- `FiniteSolve`
- `SolveSetResult`
- `ODESolution`
- `SatisfiableResult`
- `SatAssignment`
- `RRefResult` is defined in [Ops/LinearAlgebra](SymbolicLean/Ops/LinearAlgebra.lean.md)

## Component Map

### Sort and domain layer
Main docs:
- [Sort/Aliases](SymbolicLean/Sort/Aliases.lean.md)
- [Sort/Base](SymbolicLean/Sort/Base.lean.md)
- [Domain/Desc](SymbolicLean/Domain/Desc.lean.md)
- [Domain/Classes](SymbolicLean/Domain/Classes.lean.md)
- [Domain/Dim](SymbolicLean/Domain/Dim.lean.md)

Purpose:
- define symbolic sorts such as scalars, matrices, booleans, functions, and maps,
- map public carrier types like `Rat`, `Int`, and matrix aliases back to symbolic domains,
- enforce domain-specific constraints such as ring/field requirements and dimension compatibility.

This is why the public surface can use `Scalar Rat`, `Mat Rat 2 2`, and `Vec Rat 2` while still preserving the actual symbolic domain underneath.

### Declaration layer
Main docs:
- [Decl/Core](SymbolicLean/Decl/Core.lean.md)
- [Decl/Assumptions](SymbolicLean/Decl/Assumptions.lean.md)

Purpose:
- define `SymDecl` and `FunDecl`,
- attach symbolic assumptions such as positivity,
- provide stable Lean-side declaration keys used by session interning and backend realization.

### Pure term layer
Main docs:
- [Term/Core](SymbolicLean/Term/Core.lean.md)
- [Term/Arithmetic](SymbolicLean/Term/Arithmetic.lean.md)
- [Term/Logic](SymbolicLean/Term/Logic.lean.md)
- [Term/Relations](SymbolicLean/Term/Relations.lean.md)
- [Term/Calculus](SymbolicLean/Term/Calculus.lean.md)
- [Term/Structured](SymbolicLean/Term/Structured.lean.md)
- [Term/Containers](SymbolicLean/Term/Containers.lean.md)
- [Term/View](SymbolicLean/Term/View.lean.md)
- [Term/Canon](SymbolicLean/Term/Canon.lean.md)

Purpose:
- define the pure typed AST,
- provide ordinary operator instances so `x + y`, `A * v`, and `f x` work directly on declarations,
- represent structured symbolic heads such as bounded integrals, sums, products, lambdas, piecewise terms, indexing, and dictionaries,
- normalize internal shapes through `Term.coreView` and projector helpers,
- canonicalize terms for session-local cache reuse.

The term layer is where most user-facing syntax eventually lands.

### Syntax and ergonomics layer
Main docs:
- [Syntax/Binders](SymbolicLean/Syntax/Binders.lean.md)
- [Syntax/Command](SymbolicLean/Syntax/Command.lean.md)
- [Syntax/Elab](SymbolicLean/Syntax/Elab.lean.md)
- [Syntax/StructuredArgs](SymbolicLean/Syntax/StructuredArgs.lean.md)
- [Syntax/Subst](SymbolicLean/Syntax/Subst.lean.md)
- [Syntax/Indexing](SymbolicLean/Syntax/Indexing.lean.md)
- [Syntax/Dict](SymbolicLean/Syntax/Dict.lean.md)
- [Syntax/Assuming](SymbolicLean/Syntax/Assuming.lean.md)

Purpose:
- provide `symbols` and `functions` binder sugar,
- define `sympy Rat do ...` and exploratory `#sympy Rat => ...` commands,
- expose the capitalized structured builders `Derivative`, `Integral`, `Sum`, `Product`, `Lambda`, `Piecewise`, and `Limit`,
- support tuple-shaped structured arguments through `IntoBoundSpec`, `IntoDerivSpec`, and `IntoPieceBranch`,
- provide substitution, indexing, slicing, dictionary, and scoped-assumption syntax.

This layer is intentionally thin. Its job is to lower convenient syntax onto the real declaration, term, and operation layers.

### Runtime/session layer
Main docs:
- [SymExpr/Core](SymbolicLean/SymExpr/Core.lean.md)
- [SymExpr/Refined](SymbolicLean/SymExpr/Refined.lean.md)
- [Session/Monad](SymbolicLean/Session/Monad.lean.md)
- [Session/State](SymbolicLean/Session/State.lean.md)
- [Session/Errors](SymbolicLean/Session/Errors.lean.md)

Purpose:
- define session-indexed realized handles,
- ensure backend refs cannot escape or be mixed across sessions,
- store worker handles, timeouts, interning tables, and canonical caches,
- carry typed error information back to Lean code.

### Backend transport and realization layer
Main docs:
- [Backend/Protocol](SymbolicLean/Backend/Protocol.lean.md)
- [Backend/Encode](SymbolicLean/Backend/Encode.lean.md)
- [Backend/Decode](SymbolicLean/Backend/Decode.lean.md)
- [Backend/Client](SymbolicLean/Backend/Client.lean.md)
- [Backend/Realize](SymbolicLean/Backend/Realize.lean.md)
- [ManifestMain](ManifestMain.lean.md)

Purpose:
- define the typed JSON wire protocol,
- encode pure terms for the worker,
- decode worker responses and reified terms,
- manage the Python worker process and enforce startup/version checks,
- realize declarations and terms into backend refs,
- emit `.lake/build/sympy/manifest.json` from the registry so the worker knows which heads and ops exist.

This is the layer that makes the Lean and Python halves agree on both operations and pure symbolic heads.

### Effectful ops and front-door wrappers
Main docs:
- raw op layers:
  - [Ops/Algebra](SymbolicLean/Ops/Algebra.lean.md)
  - [Ops/Calculus](SymbolicLean/Ops/Calculus.lean.md)
  - [Ops/LinearAlgebra](SymbolicLean/Ops/LinearAlgebra.lean.md)
  - [Ops/Solvers](SymbolicLean/Ops/Solvers.lean.md)
- front-door wrapper layer:
  - [Ops/Core](SymbolicLean/Ops/Core.lean.md)
- shared result containers:
  - [Ops/Results](SymbolicLean/Ops/Results.lean.md)

Purpose:
- define low-level realized operations over `SymExpr`,
- decode structured payloads such as finite solves, solver models, and `rref`,
- lift those realized operations onto pure declarations and terms through `IntoSymExpr`, `IntoSymSymbol`, and `IntoSymFun`,
- export the public `SymPy.*` namespace aliases and Lean field-notation wrappers.

This split is important:
- `Ops/*` raw modules are closer to the backend.
- `Ops/Core` is what makes the public API ergonomic.

### Registry and manifest generation
Main docs:
- [Syntax/Registry](SymbolicLean/Syntax/Registry.lean.md)
- [Syntax/DeclareOp](SymbolicLean/Syntax/DeclareOp.lean.md)
- [Term/RegistryHeads](SymbolicLean/Term/RegistryHeads.lean.md)

Purpose:
- store environment metadata for symbolic heads and effectful ops,
- generate wrappers through `declare_op`, `declare_head`, and related helpers,
- emit a manifest that the Python worker loads at startup.

This registry-backed design is what keeps new heads and new worker operations discoverable without hard-coding everything in one place.

### Examples and negative tests
Main docs:
- [Examples/Scalars](SymbolicLean/Examples/Scalars.lean.md)
- [Examples/Matrices](SymbolicLean/Examples/Matrices.lean.md)
- [Examples/Solvers](SymbolicLean/Examples/Solvers.lean.md)
- [Examples/Negative](SymbolicLean/Examples/Negative.lean.md)

Purpose:
- document the intended public surface,
- provide executable end-to-end examples,
- keep key type-level failures locked in with negative examples.

`Examples/Negative.lean` matters because it shows what the library rejects before SymPy is ever contacted.

## Capabilities With SymPy vs Lean Examples

The examples below use the current public surface. When a snippet is effectful, it runs inside `sympy Rat do ...` or `withSession {}`.

### 1. Quick exploration

SymPy:
```python
from sympy import symbols
x, y = symbols("x y")
x + y
```

Lean:
```lean
#sympy Rat => x + y
```

SymPy:
```python
from sympy import Function, symbols
x = symbols("x")
f = Function("f")
f(x)
```

Lean:
```lean
#sympy Rat => f x
```

Use `#sympy` for short exploratory commands. Use `sympy Rat do ...` when you want the full session surface.

### 2. Symbols and functions

SymPy:
```python
from sympy import Function, symbols
x, y = symbols("x y")
f = Function("f")
f(x) + y
```

Lean:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  let f : FunDecl [Scalar Rat] (Scalar Rat) := funSym `f
  f x + y
```

Session-local binder sugar:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat | positive)
    functions (f : Rat → Rat)
    let expr : Term (Scalar Rat) := f x + y
    let realized ← eval expr
    pretty realized
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### 3. Pure algebraic terms

SymPy:
```python
from sympy import symbols
x, y = symbols("x y")
x**2 + 2*x*y + y**2
```

Lean:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  x ^ 2 + 2 * x * y + y ^ 2
```

Direct numeral support exists today for `Term (Scalar Int)` and `Term (Scalar Rat)`:

```lean
example : Term (Scalar Int) := 2
example : Term (Scalar Rat) := 2
```

### 4. Algebra operations

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

The same front door is available through field notation:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let factored ← expr.factor
    pretty factored
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

And through the `SymPy` namespace:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let derived : Term (Scalar Rat) := SymPy.Derivative (x ^ 2) x
    let simplified ← SymPy.simplify derived
    pretty simplified
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### 5. Calculus and structured symbolic heads

#### Derivative

SymPy:
```python
from sympy import diff, symbols
x = symbols("x")
diff(x**3, x, 2)
```

Lean, capitalized builder:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Derivative (d := carrierDomain Rat) (x ^ 3) (x, 2)
```

Lean, `SymPy` alias:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Derivative (x ^ 3) x 2
```

Today the capitalized `Derivative` builder may need an explicit `d := carrierDomain Rat` when the derivative spec is given as a tuple. The `SymPy.Derivative` alias does not have that particular inference issue.

#### Bounded integral

SymPy:
```python
from sympy import integrate, symbols
x = symbols("x")
integrate(x**2, (x, 0, 1))
```

Lean:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))
```

Lean, `SymPy` alias:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  SymPy.Integral (x ^ 2) (x, (0 : Term (Scalar Rat)), (1 : Term (Scalar Rat)))
```

#### Sum and product

SymPy:
```python
from sympy import product, summation, symbols
x = symbols("x")
summation(x, (x, 0, 3))
product(x, (x, 1, 3))
```

Lean:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Sum x (x, (0 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Product x (x, (1 : Term (Scalar Rat)), (3 : Term (Scalar Rat)))
```

#### Limit, lambda, and piecewise

SymPy:
```python
from sympy import Lambda, Piecewise, limit, symbols
x = symbols("x")
limit((x**2 - 1)/(x - 1), x, 1)
Lambda(x, x + 1)
Piecewise((x, x > 0), (0, True))
```

Lean:
```lean
example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Limit (((x ^ 2) - 1) / (x - 1)) x (1 : Term (Scalar Rat))

example : Term (.fn [Scalar Rat] (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Lambda (x + 1) x

example : Term (Scalar Rat) :=
  let x : SymDecl (Scalar Rat) := sym `x
  Piecewise (x, gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))) (0 : Term (Scalar Rat))
```

For generic structured calls, `symcall%` gives a registry-backed escape hatch that still builds typed `Term`s:

```lean
example : Term .boolean :=
  let x : SymDecl (Scalar Rat) := sym `x
  symcall% and(
    gt (x : Term (Scalar Rat)) (0 : Term (Scalar Rat)),
    ge (x : Term (Scalar Rat)) (0 : Term (Scalar Rat))
  )
```

### 6. Matrix operations

Pure dimension-checked matrix multiplication:

SymPy:
```python
from sympy import MatrixSymbol
A = MatrixSymbol("A", 2, 2)
v = MatrixSymbol("v", 2, 1)
A * v
```

Lean:
```lean
example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 2) := sym `v
  A * v
```

Determinant:

SymPy:
```python
from sympy import MatrixSymbol
A = MatrixSymbol("A", 2, 2)
A.det()
```

Lean:
```lean
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let determinant ← det A
    pretty determinant
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

Inverse:

SymPy:
```python
from sympy import MatrixSymbol
A = MatrixSymbol("A", 2, 2)
A.inv()
```

Lean:
```lean
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let inverse ← A.I
    pretty inverse
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

Reduced row echelon form:

SymPy:
```python
from sympy import MatrixSymbol
A = MatrixSymbol("A", 2, 2)
A.rref()
```

Lean:
```lean
#eval do
  let result ← withSession {} fun _s => do
    symbols (A : Mat Rat 2 2)
    let reduced ← rref A
    let text ← pretty reduced.reduced
    pure s!"{text} pivots={reduced.pivots}"
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

### 7. Solvers and assumptions

Finite solve:

SymPy:
```python
from sympy import solve, symbols
x = symbols("x")
solve(x**2 - 1, x)
```

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let solved ← solveUnivariate expr x
    match solved.solutions with
    | solution :: _ => IO.println (← pretty solution)
    | [] => IO.println "[]"
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)
```

Set-valued solve:

SymPy:
```python
from sympy import solveset, symbols
x = symbols("x")
solveset(x**2 - 1, x)
```

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let expr : Term (Scalar Rat) := x ^ 2 - 1
    let setExpr ← solveset expr x
    pretty setExpr.setExpr
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

ODE solve:

SymPy:
```python
from sympy import Function, Eq, dsolve, diff, symbols
x = symbols("x")
f = Function("f")
dsolve(Eq(diff(f(x), x), f(x)))
```

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    functions (f : Rat → Rat)
    let ode : Term .boolean := eq_ (SymPy.Derivative (f x) x) (f x)
    let solved ← dsolve ode f
    pretty solved.equation
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

Assumptions and satisfiability:

SymPy:
```python
from sympy import Q, Symbol, ask
x = Symbol("x", positive=True)
ask(Q.positive(x))
```

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat | positive)
    let answer ← x.ask SymPy.Q.positive
    IO.println (repr answer)
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)
```

Scoped assumptions in Lean stay inside ordinary `do` notation:

```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    assuming [x ↦ SymPy.Q.positive] do
      let answer ← x.ask SymPy.Q.positive
      IO.println (repr answer)
  match result with
  | .ok _ => pure ()
  | .error err => IO.println (repr err)
```

### 8. Substitution, indexing, slicing, and dictionaries

Substitution:

SymPy:
```python
from sympy import symbols
x, y = symbols("x y")
(x + y).subs({x: 2, y: 3})
```

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)
    let substituted ← (x + y)[x ↦ 2, y ↦ 3]
    pretty substituted
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
```

Indexing and slicing are currently demonstrated primarily at the pure term layer:

```lean
example : Term (Scalar Rat) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[zz 0, zz 1])

example : Term (Mat Rat 2 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[0:1])

example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  ((A : Term (Mat Rat 2 2))[:, 1])
```

Dictionary literals also live in the pure term layer today:

```lean
example : Term (.map (Scalar Rat) (Scalar Rat)) :=
  let x : SymDecl (Scalar Rat) := sym `x
  let y : SymDecl (Scalar Rat) := sym `y
  dict{ x ↦ 1, y ↦ 2 }
```

### 9. Realization, caching, and reification

The `eval` / `reify` boundary is central to the design.

Lean:
```lean
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let lhsTerm : Term (Scalar Rat) := x + 0
    let lhs ← eval lhsTerm
    let rhs ← eval (x : Term (Scalar Rat))
    pure (lhs.ref.ident == rhs.ref.ident)
  match result with
  | .ok reused => IO.println reused
  | .error err => IO.println (repr err)
```

The example above relies on term canonicalization so equivalent pure terms can reuse a cached backend ref.

And reification can bring a realized expression back to a pure `Term`:

```lean
noncomputable section
#eval do
  let result ← sympy Rat do
    symbols (x : Rat)
    let simplified ← simplify (x + x)
    let reified ← reify simplified
    let roundTrip ← eval reified
    pretty roundTrip
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)
end
```

## What Lean Rejects Earlier Than SymPy

The negative example suite shows the kind of errors the type layer is supposed to catch.

### Matrix dimension mismatches

This is rejected before any backend call:

```lean
#guard_msgs in
example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 3) := sym `v
  A * v
```

### Field-only matrix operations

Inversion requires a field interpretation, so integer matrices are rejected at the typeclass level:

```lean
#guard_msgs in
example {s : SessionTok} (matrix : SymExpr s (Mat Int 2 2)) :
    SymPyM s (SymExpr s (Mat Int 2 2)) :=
  inv matrix
```

### Differentiation requires a symbolic variable

Trying to differentiate with respect to an arbitrary term is rejected:

```lean
#guard_msgs in
example : Term (Scalar Int) :=
  let x : Term (Scalar Int) := zz 1
  diff x x
```

## How To Extend The Project

### Add a new pure symbolic head

Use this route when the operation should first exist as a pure `Term`, even before any worker-backed effectful API.

1. Decide whether the new construct belongs in an existing term family.
   - arithmetic / logic / relations go in the existing core term helpers,
   - structured symbolic forms usually belong in [Term/Structured](SymbolicLean/Term/Structured.lean.md),
   - indexing-like or map-like syntax belongs in [Term/Containers](SymbolicLean/Term/Containers.lean.md).
2. Define the head name and typed helper.
3. Register the head in [Term/RegistryHeads](SymbolicLean/Term/RegistryHeads.lean.md) so it enters the generated manifest.
4. If the head needs canonicalization or internal pattern matching support, update [Term/View](SymbolicLean/Term/View.lean.md) and [Term/Canon](SymbolicLean/Term/Canon.lean.md).
5. If worker-side reification needs to reconstruct the term shape specially, update [Backend/Decode](SymbolicLean/Backend/Decode.lean.md) and the worker logic.
6. If users need a friendlier surface, add a builder in [Syntax/Elab](SymbolicLean/Syntax/Elab.lean.md) or a `SymPy.*` alias in [Ops/Core](SymbolicLean/Ops/Core.lean.md).
7. Add positive and, if relevant, negative examples.
8. Update mirrored docs and rebuild the manifest through the normal build.

Default rule: keep syntax thin and put the actual symbolic meaning in the term layer.

### Add a new effectful backend op

Use this route when the operation fundamentally requires a realized SymPy object.

1. Add the raw realized operation in the appropriate raw op module:
   - [Ops/Algebra](SymbolicLean/Ops/Algebra.lean.md)
   - [Ops/Calculus](SymbolicLean/Ops/Calculus.lean.md)
   - [Ops/LinearAlgebra](SymbolicLean/Ops/LinearAlgebra.lean.md)
   - [Ops/Solvers](SymbolicLean/Ops/Solvers.lean.md)
2. If the op returns a backend ref, the `declare_op ... returns ...` path is usually enough.
3. If the op returns structured JSON, add or reuse a typed result container in [Ops/Results](SymbolicLean/Ops/Results.lean.md) and decode it in the raw op layer.
4. Implement the matching worker branch in `tools/sympy_worker.py`.
5. Expose the ergonomic public front door in [Ops/Core](SymbolicLean/Ops/Core.lean.md) if the op should accept `Term`, `SymDecl`, or `SymExpr` uniformly.
6. Add `pretty`-based executable examples if the op is meant to be used end-to-end.
7. Update mirrored docs.

Default rule: raw backend operation first, public ergonomic wrapper second.

### Add a new syntax form

Use this route only when the term or op layer already has the real semantics.

1. Pick the syntax layer that matches the feature:
   - binders: [Syntax/Binders](SymbolicLean/Syntax/Binders.lean.md)
   - structured builders: [Syntax/Elab](SymbolicLean/Syntax/Elab.lean.md)
   - substitution: [Syntax/Subst](SymbolicLean/Syntax/Subst.lean.md)
   - indexing / slicing: [Syntax/Indexing](SymbolicLean/Syntax/Indexing.lean.md)
   - dictionaries: [Syntax/Dict](SymbolicLean/Syntax/Dict.lean.md)
   - command/session entrypoints: [Syntax/Command](SymbolicLean/Syntax/Command.lean.md)
2. Lower the syntax directly to an existing typed helper or wrapper.
3. Do not hide backend behavior in syntax elaboration.
4. Add at least one positive example and one diagnostic or negative example if the syntax is ambiguous.

### Add a new public carrier alias or literal surface

Use this route when the problem is public ergonomics rather than new symbolic behavior.

1. Extend [Sort/Aliases](SymbolicLean/Sort/Aliases.lean.md) if a new carrier-backed alias is needed.
2. Extend [Domain/Classes](SymbolicLean/Domain/Classes.lean.md) if new domain interpretation or algebraic structure instances are required.
3. Extend [Term/Literals](SymbolicLean/Term/Literals.lean.md) only if the literal should be constructible directly at the public term layer.
4. Update binder examples and front-door examples so the new surface is actually exercised.

## Current Boundaries And Caveats

- SymPy remains the computation engine. Lean checks formation and typing, not semantic correctness of the returned symbolic result.
- The pure term layer is richer than the currently showcased end-to-end execution layer. In particular, indexing, slicing, and dictionaries are primarily demonstrated today as typed pure terms.
- The internal `Term` representation still includes a compatibility layer; internal code should prefer `Term.coreView` and projector helpers instead of matching only on raw constructor packs.
- Not every SymPy API is exposed. New capabilities should usually be added through the registry, raw op layer, worker, and front-door wrapper path described above.
- Session-scoped handles are intentional. If a value must outlive a session, reify it back into a pure `Term`.

## Validation Commands

After documentation or API changes, the standard local checks are:

```bash
lake build SymbolicLean
lake env lean SymbolicLean/Examples/Scalars.lean
lake env lean SymbolicLean/Examples/Matrices.lean
lake env lean SymbolicLean/Examples/Solvers.lean
python3 scripts/check_doc_harness.py --mode local --scope core
```

## Where To Read Next

- Landing page: `README.md`
- Documentation map: [index.md](index.md)
- Architecture and doc contracts: [architecture.md](architecture.md)
- Implementation status snapshot: [plans/symboliclean-implementation.md](plans/symboliclean-implementation.md)
- Public example docs:
  - [Examples/Scalars](SymbolicLean/Examples/Scalars.lean.md)
  - [Examples/Matrices](SymbolicLean/Examples/Matrices.lean.md)
  - [Examples/Solvers](SymbolicLean/Examples/Solvers.lean.md)
  - [Examples/Negative](SymbolicLean/Examples/Negative.lean.md)
