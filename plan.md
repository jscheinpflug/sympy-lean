# Plain-Lean Refactor Plan for sympy-lean

## Project

`sympy-lean` is a Lean 4 frontend for SymPy with:

- a pure typed expression layer `Term σ`
- a realized backend layer `SymExpr s σ`
- a Python worker that evaluates and manipulates expressions in SymPy

The long-term goal is a scalable typed symbolic interface that feels like ordinary Lean code, not a separate DSL bolted onto Lean.

## Why This Refactor

The current design does not scale well:

- `Term` grows by one constructor per SymPy concept
- `term!` depends on a separate hand-written grammar
- adding a new SymPy operation requires touching multiple Lean and Python files
- the public surface exposes internal implementation details like `.ground .QQ`, `.scalar`, and `.static`

The replacement design should make it possible to add most new SymPy concepts by registering metadata once, then generating Lean sugar, Python dispatch, decoding, docs, and completion data from that single source of truth.

## Target Outcome

Real code should use ordinary Lean syntax only. Exploration should use `#sympy`.

Desired user experience:

```lean
open SymPy

symbols (x : Rat) (M : Mat Rat 2 2)
functions (f : Rat → Rat)

let t : Term (Scalar Rat) := Integral (f x, (x, 0, 1))
let u : Term (Scalar Rat) := Piecewise ((x, x > 0), (-x, true))
let v := (x^2 - 1).factor()
let w := M.T
```

Exploration should reuse the same expression language:

```lean
#sympy Rat => (x^2 - 1).factor()
```

## Scope

### In Scope

- carrier-based public sorts and declaration builders
- coercions so declared symbols/functions participate naturally in Lean expressions
- an open typed `headApp` core for extensible symbolic heads
- a Lean registry that generates syntax-facing declarations, backend manifest data, decoding hooks, docs, and completions
- generated method/property/namespace sugar
- structured arguments, dict syntax, indexing, and slicing
- a manifest-driven Python worker
- reification, canonicalization, and session-level interning
- migration of current algebra, calculus, linear-algebra, and solver surfaces onto the new system

### Out of Scope

- mutation-heavy OOP workflows in SymPy physics/mechanics APIs
- authoring custom SymPy subclasses from Lean
- code generation APIs as first-class typed syntax

These remain available through lower-level escape hatches rather than first-class typed wrappers.

## Architectural Decisions

### 1. One Public Syntax Surface

- Delete `symterm`, `term!`, and `sympy!`
- Keep ordinary Lean term syntax for real code
- Keep `#sympy` as the only exploration entrypoint
- Use the same symbolic surface in both strict code and exploration

### 2. Carrier-Based Public Surface

Expose public aliases and builders:

- `SymCarrier`
- `Scalar α`
- `Mat α m n`
- `MatD α m n`
- `Vec α n`
- `sym`
- `symWith`
- `funSym`

Hide raw internal domain/sort constructors from normal public use.

### 3. Open Typed Core

Keep `Term σ` typed, but replace most operator-specific constructors with:

- `CoreHead`
- `ExtHeadSpec`
- `Head`
- `HeadSchema`
- `Term.headApp`

Atoms, literals, and function application stay primitive. Symbolic heads move to the typed extensible core.

### 4. Generated Views for Internal Code

Dependent core terms should not make the codebase unreadable. Generate:

- `CoreView`
- `Term.coreView`
- projector helpers like `asAdd?`, `asIntegral?`, `asPiecewise?`

Encoder, canonicalizer, and reifier should match on these views rather than raw dependent argument packs.

### 5. Registry as Single Source of Truth

Replace narrow wrapper generation with a registry-backed system:

- `declare_head`
- `declare_op`

Each entry should declare:

- typed argument schema
- result sort
- surface role: free call, method, property, or namespace attribute
- forward dispatch mode
- reification mode
- result mode
- help text
- custom symbolic error template

### 6. Generated Sugar Instead of a Separate DSL

Use Lean metaprogramming to generate:

- free symbolic heads under `SymPy`
- extension methods on `Term` and `SymExpr`
- receiver properties like `.T` and `.I`
- namespaces like `SymPy.Q` and `SymPy.S`

This keeps one expression language while still covering broad SymPy surface area.

### 7. Structured Arguments and Small Syntax Extensions

Most SymPy surface should use ordinary Lean syntax plus generated elaboration. Only a few syntax forms need project-local support:

- multi-index and slice syntax like `A[i, j]`, `A[:, j]`, `A[i:j]`
- mapping syntax like `dict{ x ↦ 1, y ↦ 2 }`

Structured SymPy argument groups should use ordinary tuples coerced into schema structs:

- `BoundSpec`
- `DerivSpec`
- `PieceBranch`
- binder tuple wrappers for `Lambda`

### 8. Manifest-Driven Backend

Lean remains the source of truth. The build should generate a versioned manifest consumed by Python at worker startup.

The worker should use that manifest for:

- pure head evaluation
- effectful op dispatch
- reification
- version compatibility checks

### 9. Runtime Semantics

- Lean `Term` values are always unevaluated syntax
- backend evaluation may return a more canonical SymPy form
- round-trip correctness is only required modulo Lean canonicalization
- canonical-equivalent terms should reuse the same remote ref within a session

## `#sympy` Semantics

`#sympy` is the only exploration entrypoint.

Supported forms:

- `#sympy α => expr`
- `#sympy α do ...`

Behavior:

- opens a temporary session with default scalar carrier `α`
- uses the same expression language as strict mode
- unresolved argument-position names become scalar symbols
- unresolved unqualified call heads may become undefined function symbols
- unresolved constructor-like or qualified heads should warn and fall back to raw named calls
- final `Term` results are evaluated and pretty-printed
- final `SymExpr` results are pretty-printed directly
- structured results use registered renderers or `repr`

## Migration Strategy

1. Add carrier aliases, builders, and coercions without breaking old code.
2. Add the typed head system alongside existing constructors.
3. Add the registry and build-integrated manifest generation.
4. Make backend encode/decode and Python dispatch work in both old and new paths.
5. Add the generic symbolic application elaborator plus generated methods/properties.
6. Redesign `#sympy` on top of the new system.
7. Add reification, canonicalization, and expression interning.
8. Remove `symterm`, `term!`, and the old raw public surface once parity is reached.

## Validation Rules

After each coherent batch:

- update mirrored docs for touched source files
- run `lake build SymbolicLean`
- run `python3 scripts/check_doc_harness.py --mode local --scope core`

Add focused smoke tests for:

- plain Lean symbolic code
- method/property elaboration
- structured argument coercions
- `#sympy` exploration behavior
- round-trip reification modulo canonicalization
- manifest freshness and protocol compatibility

## Acceptance Criteria

- real code uses ordinary Lean syntax only
- `#sympy` is the only exploration-only syntax surface
- public examples no longer expose `.ground .QQ`, `.scalar`, or `.static`
- adding a new registered SymPy head/op usually requires one registry declaration
- the Python worker uses generated manifest data rather than hand-maintained parallel tables
- registered pure heads round-trip through `reify(eval(t))` modulo canonicalization
