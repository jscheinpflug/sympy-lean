 # SymbolicLean Project Plan

## Project Motivation

SymbolicLean exists to make symbolic computation inside Lean typed, ergonomic, and explicit.

Today, if a Lean user wants SymPy-level symbolic power, the usual options are poor:
- drop to Python and lose type information,
- pass raw strings around and hope they line up,
- or try to rebuild large parts of a CAS inside Lean.

This project takes a different route. We keep SymPy as the computation engine, but put a typed Lean interface around it so that:
- symbolic expressions can be built inside Lean without stringly-typed glue,
- illegal operations are rejected by Lean before they reach the backend,
- the common workflows stay concise enough to feel like normal symbolic mathematics,
- the boundary between Lean-side structure and SymPy-side computation stays explicit.

The project is not trying to prove every SymPy computation correct, and it is not trying to reimplement SymPy inside Lean. The goal is a disciplined bridge:
- Lean checks construction, typing, domain discipline, matrix dimensions, and session safety.
- SymPy performs the actual symbolic computation.

The success condition for v1 is:
- common scalar, matrix, boolean, and solver workflows feel concise,
- the interface is strongly typed enough to rule out obvious misuse,
- the implementation structure is small, local, and self-documenting so future agents can extend it without re-reading the whole repo.

## Design Goals

### Primary Goals

- Make symbolic expression building feel natural inside Lean.
- Preserve strong typing for domains, dimensions, function arity, relations, and result shapes.
- Keep backend interaction explicit and effectful.
- Make the codebase easy to extend one file at a time.

### Non-Goals

- Do not model every SymPy API as one giant Lean AST.
- Do not try to prove SymPy’s mathematics in v1.
- Do not hide the session boundary everywhere.
- Do not build giant “framework” modules that mix syntax, backend transport, types, and examples in one file.

## Core Architecture

### Two-Level Design

The project is built around two different representations because they solve different problems.

#### `Term s σ`

`Term s σ` is a pure typed syntax tree for ordinary symbolic expressions.

It exists so the user can write:
- `x^2 + 2*x + 1`
- `A * v`
- `f x`
- `x > 0 ∧ y < 1`
- `diff (f x) x`

without turning every operator into an effectful backend call.

`Term` is the blackboard layer. It should be easy to build, typecheck, inspect, elaborate from syntax, and serialize.

#### `SymExpr s σ`

`SymExpr s σ` is an opaque handle to a live SymPy object inside a session.

It exists because real SymPy objects are effectful resources:
- they live in a backend process,
- they require IO,
- they can fail to build or transform,
- they benefit from caching and reference reuse,
- they should not escape the session that created them.

`SymExpr` is the computation layer. Most actual CAS operations happen here.

#### Why the split matters

Earlier designs tried to make even basic symbolic arithmetic monadic. That was the wrong level of abstraction. It made `x + y` feel like an RPC and created unnecessary elaboration complexity.

The final split is:
- `Term` for describing symbolic expressions,
- `SymExpr` for asking SymPy to compute.

That is simpler, more ergonomic, and easier to type.

## Session Model

All SymPy interaction lives inside:

```lean
withSession : SessionConfig → (∀ s, SymPyM s α) → IO (Except SymPyError α)
```

This exists for one core reason: session-scoped handles must not escape.

The universal quantifier `∀ s` makes the session token abstract. A `SymExpr s σ` can only be used inside the session that created it. This gives a strong safety guarantee without runtime bookkeeping hacks.

`SymPyM` should carry:
- read-only transport and config,
- mutable session-local state,
- typed error handling,
- outer `IO` for the actual worker communication.

Expected shape:

```lean
abbrev SymPyM (s : SessionTok) :=
  ReaderT SessionEnv <| StateT SessionState <| ExceptT SymPyError IO
```

## Type Layer

### Domains: `DomainDesc`

`DomainDesc` models the algebraic domain attached to symbolic objects.

It exists because domain information changes which operations are legal and what their results mean.

Examples:
- scalar arithmetic over `ZZ` vs `QQ`,
- field-only operations like inversion,
- polynomial rings,
- fraction fields,
- algebraic extensions,
- quotients.

The core shape is:

```lean
GroundDom := ZZ | QQ | RR | CC | gaussianZZ | GF p

DomainDesc :=
| ground
| polyRing
| fracField
| algExt
| quotient
```

This must be recursive. A flat domain enum would not be expressive enough for actual SymPy usage.

### Sorts: `SymSort ext`

`SymSort ext` models what kind of symbolic object we have.

It exists so that the interface can distinguish:
- booleans,
- scalars,
- matrices,
- tensors,
- sets,
- tuples,
- sequences,
- maps,
- functions,
- relations,
- specialized SymPy families.

Planned shape:

```lean
SymSort ext :=
| boolean
| scalar d
| matrix d m n
| tensor d dims
| set σ
| tuple (List σ)
| seq σ
| map κ ν
| fn (List σ) τ
| relation rel (List σ)
| ext ext
```

Important decision:
- use `List`, not `Array`, in recursive sort positions.

Why:
- Lean elaboration and deriving behave better with recursive `List`-based structures,
- this avoids the issues already identified around recursive arrays and `CoeFun`-style typing,
- runtime arrays can still be used in non-recursive payloads.

### Refinement Wrappers

Some operations depend on more than just the coarse sort. For example:
- `ask` wants symbols,
- `dsolve` wants a function symbol,
- boolean APIs want boolean expressions,
- relation-oriented APIs benefit from a relation wrapper.

Instead of carrying a global `FormTag` parameter on every symbolic value, use small wrappers:
- `SymSymbol`
- `SymFun`
- `SymBool`
- `SymRel`

Why:
- the refinement tax only appears where needed,
- most ordinary symbolic code stays simple,
- the public surface is easier to read.

## Algebraic Bridge

The project should not reinvent an algebra hierarchy. It should use `mathlib`.

The symbolic domain layer therefore needs a bridge into Lean-side algebraic capabilities:
- `DomainCarrier`
- `InterpretsDomain`
- `UnifyDomain`

These exist for different reasons:
- `DomainCarrier` says what Lean carrier type a symbolic domain corresponds to when that interpretation is available.
- `InterpretsDomain` says which algebraic structures hold on that carrier.
- `UnifyDomain` computes the output domain for mixed-domain symbolic arithmetic.

Example motivations:
- `inv` should require a field-like domain.
- `ZZ + QQ` should land in `QQ`.
- matrix inversion should inherit the domain constraint of its scalar entries.

## Pure Expression Layer

### What belongs in `Term`

`Term` should stay small and expression-oriented.

Include:
- atoms,
- scalar literals,
- arithmetic,
- negation,
- powers,
- unary function application,
- boolean connectives,
- equality, inequalities, membership,
- derivative,
- a small set of common unevaluated calculus forms.

### What does not belong in `Term`

Do not put general CAS transforms or queries into `Term`.

Keep these out:
- `simplify`
- `factor`
- `expand`
- `det`
- `rref`
- `solveset`
- `dsolve`
- `satisfiable`

Why:
- they are backend computations, not expression constructors,
- they often have structured or partial results,
- they belong in `SymPyM`.

## Backend Computation Layer

The backend layer exists to do real work against SymPy.

Core operations should be defined over `SymExpr` and run in `SymPyM`, for example:
- `simplify`
- `factor`
- `expand`
- `cancel`
- `subs`
- `diffExpr`
- `integrate`
- `limit`
- `det`
- `inv`
- `rref`
- `solveUnivariate`
- `solveset`
- `dsolve`
- `satisfiable`
- `ask`

For common user-facing APIs, a very small overload layer may accept either `Term` or `SymExpr` and evaluate `Term` internally. This should be used sparingly, only on a few high-frequency front doors.

Why:
- users should not have to write `eval` by hand in the most obvious cases,
- but the architecture should still preserve the distinction between pure expression building and effectful computation.

## Trust Boundary

The trust model must stay explicit.

Lean guarantees:
- expressions are well-sorted,
- domains and dimensions are respected,
- refinement-sensitive APIs get the right wrapper types,
- session handles do not escape.

SymPy is trusted to:
- perform symbolic simplification,
- solve equations,
- manipulate matrices,
- answer assumption and logic queries correctly.

Implication for implementation:
- `eval : Term s σ → SymPyM s (SymExpr s σ)` can trust sort preservation because the serializer is produced from a typed `Term`,
- but structured runtime results still need decoding and lightweight validation.

Examples of results that should be decoded explicitly:
- finite solve results,
- solver case splits,
- ODE solution shapes,
- dynamic dimensions,
- extension-family tags.

## Syntax And Metaprogramming

Metaprogramming is important, but it should stay thin.

### `term![...]`

This is the main user-facing quoter for building pure symbolic expressions.

It exists to keep ordinary symbolic math readable while elaborating to the typed `Term` core.

It should support in v1:
- identifiers,
- numerals,
- unary minus,
- `+ - * / ^`,
- unary function application,
- boolean connectives,
- relations,
- membership,
- derivative syntax.

### `sympy d do ...`

This is the session-opening syntax.

It exists so users can write compact symbolic workflows without repeating the session plumbing and default scalar domain setup.

It should:
- open a `withSession`,
- install default scalar domain `d`,
- bring smart constructors and binder sugar into scope,
- preserve session non-escape.

### `symbols` and `functions`

These are binder macros for repeated symbol/function creation.

They exist because the raw constructor form is repetitive and distracts from the actual mathematics.

Examples:
- `symbols x y z`
- `functions f g`
- `symbols (x : positive) (y : real) z`

### Substitution sugar

Notation like:

```lean
expr[x ↦ 2, y ↦ 3]
```

exists because substitution is common enough to justify direct syntax.

It must lower to the ordinary typed substitution API rather than inventing a second semantic path.

### `#sympy`

This is an exploratory command.

It exists to make the library usable in a REPL-like way during development and experimentation.

For v1, keep the scope deliberately narrow:
- scalar exploration only,
- auto-create free scalar symbols,
- pretty-print results,
- no automatic matrix or function synthesis.

### `declare_sympy_op`

This is the scaling mechanism for wrapper generation.

It exists because hand-writing every encoder, decoder, wrapper, and docstring will not scale.

It should generate:
- a typed `SymExpr`-level wrapper,
- request encoding,
- result decode hooks,
- a docstring,
- optionally a `Term` helper only when the operation is expression-forming.

## Backend Transport

The first backend should be a persistent Python worker speaking JSON.

Why:
- simple to debug,
- transport-agnostic enough to replace later,
- supports session-local refs naturally,
- easy to inspect during bring-up.

Planned responsibilities:
- create symbols,
- create function symbols,
- evaluate serialized terms,
- apply named operations,
- pretty-print symbolic results,
- release refs when the session closes.

## Module And File Structure

The code should be self-documenting by structure, not by giant comments.

### Folder responsibilities

- `Domain/`: algebraic domains and domain interpretation
- `Sort/`: symbolic object families and relation kinds
- `SymExpr/`: opaque backend handles and refinement wrappers
- `Session/`: state, errors, and monad
- `Term/`: the pure expression language
- `Backend/`: transport, encoding, decoding, worker client
- `Ops/`: effectful symbolic APIs
- `Syntax/`: macros, elaborators, binder sugar, exploratory commands
- `Examples/`: canonical user-facing usage slices

### File-size policy

Files should usually stay around 80-150 lines and be split before they become kitchen-sink modules.

This matters because:
- smaller files are easier for agents to understand locally,
- mirrored docs stay short and specific,
- change triggers become clearer,
- API ownership stays obvious.

Example:
- do not put all term constructors, arithmetic instances, and syntax helpers into one `Term.lean`,
- instead use `Term/Core.lean`, `Term/Arithmetic.lean`, `Term/Logic.lean`, and so on.

## Documentation Harness Alignment

The repo contract matters as much as the code.

Therefore:
- `AGENTS.md` stays index-only,
- canonical implementation guidance lives in `/docs`,
- every core `SymbolicLean/**` source file gets a mirrored doc,
- plan artifacts live under `docs/plans/`.

The mirrored docs are not optional polish. They are part of how future agents localize changes without reopening the entire project.

## Example Workflows

### Scalar expression and factorization

```lean
sympy QQ do
  symbols x y
  let e := term![x^2 + 2*x*y + y^2]
  factor e
```

What this demonstrates:
- pure expression building through `term!`,
- default scalar domain installation,
- front-door overload from `Term` into the effectful `factor` API.

### Matrix typing

```lean
sympy QQ do
  let A : Term s (.matrix qq (.static 3) (.static 3)) := ...
  let v : Term s (.matrix qq (.static 3) (.static 1)) := ...
  let p := term![A * v]
  eval p
```

What this demonstrates:
- dimensions are checked in Lean,
- illegal matrix products fail before backend evaluation.

### ODE workflow

```lean
sympy QQ do
  symbols x
  functions f
  let ode := term![diff (f x) x - f x = 0]
  dsolve ode f
```

What this demonstrates:
- function symbols,
- derivative syntax,
- relation construction,
- a solver front door that accepts a `Term`.

## Delivery Strategy

Implementation should proceed in layers:
1. bootstrap the repo and module graph,
2. land the typed core,
3. land session and backend transport,
4. land the pure `Term` layer,
5. land effectful `Ops`,
6. land syntax sugar,
7. land generated wrappers,
8. land examples and verification.

This order matters because each later layer depends on the correctness and clarity of the earlier ones.

## Definition Of Done

The project reaches the planned v1 milestone when:
- `mathlib` is integrated,
- the `Term` / `SymExpr` split is reflected in code,
- the session model prevents handle escape,
- core scalar, matrix, boolean, and solver flows work,
- `term!`, `sympy`, `symbols`, substitution sugar, and `#sympy` exist in their planned scopes,
- mirrored docs exist for the new module tree,
- the codebase remains small-file and self-documenting,
- a no-context agent can extend the system by reading the local file plus its mirrored doc.
