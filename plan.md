 # SymbolicLean Project Plan

## Project Motivation

SymbolicLean exists to make symbolic computation inside Lean typed, ergonomic, and explicit.

Today, a Lean user who wants SymPy-level symbolic power usually ends up in one of three bad positions:
- drop to Python and lose Lean-side structure,
- move symbolic expressions through raw strings and hope they stay aligned,
- or try to rebuild large parts of a CAS inside Lean.

This project takes a narrower and more practical route. SymPy remains the computation engine, but Lean gets a typed interface around it so that:
- symbolic expressions can be built in Lean without stringly glue,
- illegal operations are rejected before they reach SymPy,
- common workflows stay concise enough to feel like normal symbolic mathematics,
- the boundary between Lean structure and backend computation stays explicit.

The project is not trying to prove every SymPy computation correct, and it is not trying to reimplement SymPy inside Lean. The goal is a disciplined bridge:
- Lean checks expression formation, domain discipline, matrix dimensions, declaration identity, and session safety.
- SymPy performs the actual symbolic computation.

The success condition for v1 is:
- scalar, matrix, boolean, and solver workflows feel concise,
- the API rules out obvious misuse at compile time,
- the implementation structure is small and self-documenting enough that future agents can extend it one file at a time.

## Design Goals

### Primary Goals

- Make symbolic expression building feel natural inside Lean.
- Preserve strong typing for domains, dimensions, function arity, relations, and structured results.
- Keep backend interaction explicit and effectful.
- Keep the codebase easy to extend locally with small files and narrow module responsibilities.

### Non-Goals

- Do not model all of SymPy as one giant Lean AST.
- Do not try to prove SymPy’s mathematics in v1.
- Do not blur pure expression building and backend computation into one layer.
- Do not build giant framework files that mix syntax, transport, types, and examples.

## Core Architecture

### Two-Level Design

The project uses two representations because they solve different problems.

#### `Term σ`

`Term σ` is a pure typed syntax tree for ordinary symbolic expressions.

It exists so the user can write:
- `x^2 + 2*x + 1`
- `A * v`
- `f x`
- `x > 0 ∧ y < 1`
- `diff (f x) x`

without turning every operator into an effectful backend call.

`Term` is the blackboard layer. It should be easy to build, typecheck, inspect, elaborate from syntax, hash, compare, and serialize.

#### `SymExpr s σ`

`SymExpr s σ` is an opaque handle to a live SymPy object inside one session.

It exists because real SymPy objects are effectful resources:
- they live in a backend process,
- they require IO,
- they can fail to build or transform,
- they benefit from caching and ref reuse,
- they must not escape the session that created them.

`SymExpr` is the computation layer. Most actual CAS operations happen here.

#### Why the split matters

Earlier drafts still carried one leftover assumption from the older handle-centric design: they let `Term` atoms be session-scoped backend refs. That was a mistake. If `Term` is supposed to be pure, its atoms cannot be live backend objects.

The corrected split is:
- `Term` for pure symbolic syntax,
- `SymExpr` for realized backend objects.

That keeps purity, session safety, and syntax ergonomics aligned instead of fighting each other.

### Pure Declarations

Pure terms still need symbolic identity. That identity should live on the pure side first and only be realized into SymPy during evaluation.

The core declaration layer should therefore be explicit:
- `SymDecl σ` for named symbolic declarations,
- `FunDecl args ret` for named function-symbol declarations,
- `AssumptionFact` attached to declarations, not to sessions,
- a declaration key used for session-local interning.

Rough shape:

```lean
structure SymDecl (σ : SSort) where
  name : Name
  assumptions : List AssumptionFact := []

structure FunDecl (args : List SSort) (ret : SSort) where
  name : Name
```

`Term` atoms should be pure declarations rather than backend refs:

```lean
inductive Atom : SSort → Type
| sym : SymDecl σ → Atom σ
| fun : FunDecl args ret → Atom (.fn args ret)
```

and then:

```lean
inductive Term : SSort → Type
| atom : Atom σ → Term σ
| ...
```

This is important because:
- terms become genuinely pure data,
- assumptions travel with declarations,
- terms can be compared and cached without backend state,
- `eval` becomes the one clear realization boundary.

### Session Model

All SymPy interaction lives inside:

```lean
withSession : SessionConfig → (∀ s, SymPyM s α) → IO (Except SymPyError α)
```

This exists so session-scoped handles cannot escape.

The universal quantifier `∀ s` makes the session token abstract. A `SymExpr s σ` can only be used inside the session that created it.

`SymPyM` should carry:
- read-only transport and config,
- mutable session-local state,
- typed error handling,
- outer `IO` for worker communication.

Expected shape:

```lean
abbrev SymPyM (s : SessionTok) :=
  ReaderT SessionEnv <| StateT SessionState <| ExceptT SymPyError IO
```

The important correction is that session state is no longer the source of truth for assumptions. Instead, it should store:
- live backend refs,
- a declaration-interning table from declaration key to backend ref,
- caches for already realized terms or pretty-prints,
- dynamic metadata needed to decode structured results.

### Declaration Interning

Once declarations are pure, `eval` must intern them.

If the same pure declaration `x` appears:
- twice in one term,
- in two separately evaluated terms,
- or as both a solver argument and part of an expression,

it should realize to the same backend symbol ref within one session.

So session state needs a map keyed by the full declaration identity, not just the display name. The key should include everything that matters to backend symbol creation, especially:
- declaration kind,
- name,
- sort,
- attached assumptions.

This is one of the core runtime subsystems. Without it, the pure declaration layer would not line up with backend identity.

## Type Layer

### Domains: `DomainDesc`

`DomainDesc` models the algebraic domain attached to symbolic objects.

It exists because domain information changes which operations are legal and what results mean.

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
- Lean elaboration and deriving behave better with recursive `List` structures,
- this avoids the previously identified recursive-array issues,
- runtime arrays can still be used in non-recursive payloads.

### Refinement Wrappers

Some operations depend on more than just coarse sort. For example:
- `ask` wants a realized symbol,
- `dsolve` wants a realized function symbol,
- boolean APIs want boolean expressions,
- relation-oriented APIs benefit from a relation wrapper.

So the runtime layer should keep small wrappers:
- `SymSymbol`
- `SymFun`
- `SymBool`
- `SymRel`

These remain wrappers over `SymExpr`, not over `Term`.

Why:
- refinement only appears where legality depends on it,
- most APIs stay simpler than a global form-tag system,
- the pure layer remains separate from runtime realization.

## Algebraic Bridge

The project should use `mathlib`, not a local algebra hierarchy.

The symbolic domain layer therefore needs:
- `DomainCarrier`
- `InterpretsDomain`
- `UnifyDomain`

These exist for different reasons:
- `DomainCarrier` says what Lean carrier type a symbolic domain corresponds to when such an interpretation is available.
- `InterpretsDomain` says which algebraic structures hold on that carrier.
- `UnifyDomain` computes output domains for mixed-domain arithmetic.

Example motivations:
- `inv` should require a field-like domain,
- `ZZ + QQ` should land in `QQ`,
- matrix inversion should inherit the domain constraint of its scalar entries.

## Pure Expression Layer

### What belongs in `Term`

`Term` should stay small and expression-oriented.

Include:
- atoms built from pure declarations,
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

Core effectful operations should be defined over `SymExpr` and run in `SymPyM`, for example:
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

For common front doors, a very small overload layer may accept pure inputs and realize them internally. This should be split by input kind:
- `IntoSymExpr` for expression-valued inputs (`Term` or `SymExpr`),
- `IntoSymSymbol` for symbol inputs (`SymDecl` or `SymSymbol`),
- `IntoSymFun` for function-symbol inputs (`FunDecl` or `SymFun`).

Why:
- users should not have to write realization code in the most obvious cases,
- but the architecture should still preserve the distinction between pure declarations, pure expressions, and runtime objects.

### Realization Helpers

The runtime layer needs explicit realization helpers:
- `realizeDecl : SymDecl σ → SymPyM s (SymSymbol s σ)` when appropriate,
- `realizeFun : FunDecl args ret → SymPyM s (SymFun s args ret)`,
- `eval : Term σ → SymPyM s (SymExpr s σ)`.

These should all use the same declaration interning table so the same pure declaration maps to the same backend ref in one session.

## Trust Boundary

The trust model must stay explicit.

Lean guarantees:
- pure expressions are well-sorted,
- domains and dimensions are respected,
- declaration identity is explicit,
- assumptions are attached to declarations before realization,
- refined runtime APIs get the right wrapper types,
- session handles do not escape.

SymPy is trusted to:
- perform symbolic simplification,
- solve equations,
- manipulate matrices,
- answer assumption and logic queries correctly.

Implication for implementation:
- `eval : Term σ → SymPyM s (SymExpr s σ)` can trust sort preservation because the serializer is produced from a typed pure term,
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

Important resolution rule:
- `term!` resolves only bound locals,
- it does not auto-create free names,
- it may resolve bound declaration locals and bound `Term` locals,
- free-name auto-creation is reserved for `#sympy`.

### `sympy d do ...`

This is the session-opening syntax.

It exists so users can write compact symbolic workflows without repeating the session plumbing and default scalar domain setup.

It should:
- open a `withSession`,
- install default scalar domain `d`,
- bring constructors and binder sugar into scope,
- preserve session non-escape.

It should not silently invent symbolic identifiers. Users still bind declarations explicitly with `symbols` and `functions`.

### `symbols` and `functions`

These are binder macros for repeated declaration creation.

They exist because writing explicit declaration constructors everywhere would bury the actual mathematics.

Important decision:
- they bind pure declarations, not backend refs.

Examples:
- `symbols x y z`
- `functions f g`
- `symbols (x : positive) (y : real) z`

For v1:
- `symbols` inside `sympy d do` should default to scalar declarations of sort `.scalar d`,
- `functions` inside `sympy d do` should default to unary scalar-to-scalar function declarations over `.scalar d`.

If richer declaration signatures are needed later, they can be added as explicit constructors or typed binder variants.

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
- auto-create free scalar declarations,
- realize and evaluate them in a temporary session,
- pretty-print results,
- no automatic matrix or function synthesis.

This is the only place where free symbolic names should be implicitly created.

### `declare_sympy_op`

This is the scaling mechanism for wrapper generation.

It exists because hand-writing every encoder, decoder, wrapper, and docstring will not scale.

It should generate:
- a typed `SymExpr`-level wrapper,
- request encoding,
- result decode hooks,
- a docstring,
- optionally a pure `Term` helper only when the operation is expression-forming.

## Backend Transport

The first backend should be a persistent Python worker speaking JSON.

Why:
- simple to debug,
- easy to replace later,
- supports session-local refs naturally,
- easy to inspect during bring-up.

Planned responsibilities:
- create realized symbols and function symbols from pure declarations,
- evaluate serialized terms,
- apply named operations,
- pretty-print symbolic results,
- release refs when the session closes.

## Module And File Structure

The code should be self-documenting by structure, not by giant comments.

### Folder responsibilities

- `Decl/`: pure symbolic declarations and assumptions
- `Domain/`: algebraic domains and domain interpretation
- `Sort/`: symbolic object families and relation kinds
- `SymExpr/`: opaque backend handles and runtime refinement wrappers
- `Session/`: state, errors, and monad
- `Term/`: the pure expression language
- `Backend/`: transport, encoding, realization, decoding, worker client
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
- do not put all declarations, assumptions, and binder helpers into one file,
- split them into small responsibility-aligned modules such as `Decl/Core.lean` and `Decl/Assumptions.lean`.

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
- `symbols` creates pure declarations,
- `term!` builds a pure term from bound locals,
- `factor` realizes the term and runs a backend computation.

### Matrix typing

```lean
let A : Term (.matrix qq (.static 3) (.static 3)) := ...
let v : Term (.matrix qq (.static 3) (.static 1)) := ...
let p := term![A * v]
```

What this demonstrates:
- matrix dimensions are checked in Lean,
- illegal matrix products fail before backend evaluation,
- no session is needed just to form the term.

### ODE workflow

```lean
sympy QQ do
  symbols x
  functions f
  let ode := term![diff (f x) x - f x = 0]
  dsolve ode f
```

What this demonstrates:
- pure declarations for symbols and function symbols,
- derivative syntax,
- relation construction,
- separate realization of the equation term and function declaration.

## Delivery Strategy

Implementation should proceed in layers:
1. bootstrap the repo and module graph,
2. land declarations, domains, and sorts,
3. land session and backend transport,
4. land pure `Term`,
5. land declaration realization and `eval`,
6. land effectful `Ops`,
7. land syntax sugar,
8. land generated wrappers,
9. land examples and verification.

This order matters because later layers depend on earlier ones being stable and decision-complete.

## Definition Of Done

The project reaches the planned v1 milestone when:
- `mathlib` is integrated,
- the `Term` / `SymExpr` split is reflected in code,
- declarations are pure and interned during realization,
- assumptions live on pure declarations and are realized into the backend,
- the session model prevents handle escape,
- core scalar, matrix, boolean, and solver flows work,
- `term!`, `sympy`, `symbols`, substitution sugar, and `#sympy` exist in their planned scopes,
- mirrored docs exist for the new module tree,
- the codebase remains small-file and self-documenting,
- a no-context agent can extend the system by reading the local file plus its mirrored doc.
