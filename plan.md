# SymPy Import Platform And High-Coverage Expansion

## Motivation

The current codebase is no longer a prototype. It has a real registry, a generated manifest,
a session-scoped worker, typed pure terms, effectful front doors, and the beginnings of a
usable public UX. That is enough for a curated slice, but it is not yet enough for importing a
large fraction of SymPy without regressions in quality.

The limiting problems are no longer foundational correctness problems. They are scalability
problems:

- the registry and manifest are not yet the complete source of truth for all pure heads and
  effectful ops
- the worker still has hard-coded behavior for too many shapes, especially reification
- effectful dispatch is still too flat for broad `backendPath` and keyword-heavy coverage
- public wrappers are still too manual to scale to large coverage waves
- pure-term ergonomics have improved, but they are not yet complete across the main scalar,
  set, and structured-builder workflows
- the docs still need a stronger distinction between canonical eager UX and lower-level pure
  constructors

If we try to import most of SymPy now, the repo will grow in coverage but lose coherence:
each new family will bring a little more worker special-casing, a little more wrapper
duplication, and a little more user-visible inconsistency. This plan prevents that.

## Core Idea

The next feature is not "add one more SymPy family". The next feature is to make broad SymPy
coverage mechanically scalable.

The target architecture is:

1. declare a pure head or effectful op once in Lean
2. emit complete registry metadata into the manifest
3. let the worker evaluate and reify it generically from that metadata
4. generate the public Lean wrapper surface from the same declaration
5. document it once and have hover/search/docs all agree

When that is true, importing more of SymPy becomes a coverage problem instead of an
architecture problem.

This plan is intentionally platform-first. Broad import is the goal, but broad import only
starts after the generic path is strong enough that new families do not require family-specific
glue in the worker or in `Ops/Core`.

## Goals

- Make the registry and manifest the single source of truth for extension metadata.
- Make most new pure heads declarative rather than hand-wired.
- Make most new effectful ops declarative rather than hand-wired.
- Make the public UX feel intentionally designed instead of "whatever shape happened to land".
- Import large SymPy families in grouped waves with clear acceptance gates.
- Keep compatibility aliases only where they help migration or readability; do not let them
  define the primary documented UX.

## Non-Goals

- Reimplement all of SymPy semantics inside Lean.
- Provide proof-producing or trusted-proof integration in this slice.
- Import niche subpackages just to maximize function count.
- Solve every possible coercion or inference problem before adding any coverage.

The target is broad, high-value SymPy coverage with a consistent typed Lean UX, not literal
100 percent parity with every obscure SymPy corner.

## What "Ready To Scale" Means

The repo is ready for broad import only when the following are true:

- adding a fixed-arity pure head usually means one declaration, one doc update, and one example
- adding a common effectful op usually means one declaration plus an optional structured decoder
- worker evaluation of extension heads is manifest-driven, not switch-by-switch manual
- worker reification of extension heads is manifest-driven for the supported families, not
  hard-coded per function
- public wrappers are emitted from a small number of generators rather than copied by hand
- ordinary examples use the intended syntax without repeated `Term` casts or constructor-only
  workflows
- README, project guide, hover/search, examples, and actual runtime behavior all describe the
  same public surface

## Design Principles

### 1. Registry First

Every new public head and every new public op must exist in the registry with enough metadata to
drive:

- manifest generation
- hover/search discoverability
- worker dispatch
- worker reify
- public wrapper generation
- docs/examples classification

The registry is not documentation only and not worker metadata only. It is the cross-layer
contract.

### 2. Generated Beats Hand-Wired

Broad coverage will fail if every new SymPy family needs:

- a new Lean helper
- a new worker `if backend_name == ...`
- a new reify special case
- a new wrapper in `Ops/Core`
- a new ad hoc example style

That is exactly the maintenance pattern we are trying to eliminate. Hand-written code should
only remain where the family is genuinely special:

- built-in arithmetic/logic/calculus core heads
- structured result decoders such as `rref`, `solve`, or solver models
- unusually typed or keyword-heavy public convenience wrappers

### 3. Canonical UX Over Raw Coverage

The repo should not import a large surface and then explain away the awkward parts. The default
documented UX must be the best UX we can offer now.

That means:

- eager effectful ops such as `integrate`, `solve`, `doit`, `evalf`, and `latex` are the
  primary public workflow where they are the natural user-facing SymPy action
- pure constructors such as `Integral`, `Derivative`, `Sum`, and `Piecewise` remain available,
  but they are explained as typed symbolic builders rather than the main on-ramp
- extension families should inherit the same ergonomic layer automatically wherever possible

### 4. Import By Family, Not By One-Off Function

Large import should happen in grouped waves whose members share the same runtime and UX shape.
Examples:

- scalar call-head functions
- predicates and relations
- set constructors and set constants
- matrix and linear-algebra operations
- calculus constructors and eager evaluators
- common combinatorics / special-function families

Each wave must land only after the platform already supports that family's shape.

## Main Workstreams

### 1. Complete The Registry And Manifest Contract

The current schema is close, but not complete enough for broad import. This workstream finishes
it.

Required outcomes:

- `pureSpec?` becomes real manifest data, not placeholder metadata
- registry entries distinguish the data needed for pure-head eval, pure-head reify, and
  effectful op dispatch
- the manifest carries enough information for dotted backend paths, call-vs-attr dispatch,
  aliases, docs, categories, and result shape expectations
- hover/search output becomes a faithful view of what the runtime will actually do

This is the key architectural pivot: the manifest stops being "helpful metadata" and becomes
the runtime contract for extension coverage.

### 2. Generalize Pure-Head Evaluation And Reify

The current worker support is still too narrow. It needs to support the shapes that broad
coverage will actually use.

Required support:

- nullary attr constants such as `SymPy.S.*` and similar namespaced constants
- fixed-arity call heads beyond the current unary/binary scalar-only slice
- homogeneous variadic heads for families such as `FiniteSet`, `Union`, `Intersection`, `Min`,
  and `Max`
- scalar, boolean, set, matrix, tuple, and sequence-returning pure heads where the sort is
  fully known from metadata
- generic reify for extension heads in those supported families

Core arithmetic, logic, and structured calculus heads should stay built in. They are part of
the typed term core and should not be forced through the extension path just for uniformity.

### 3. Generalize Effectful Op Dispatch

Broad SymPy coverage will not fit inside flat `backendName` method lookup. Many operations need:

- dotted backend paths
- namespace functions vs instance methods
- keyword arguments
- optional trailing arguments
- more than one common result shape

The effectful op layer needs to become as declarative as the pure-head layer:

- `declare_op` metadata must be rich enough to describe the dispatch path
- the worker must use registry metadata to resolve effectful calls
- the Lean side must have a generic decode path for common JSON and ref-shaped results
- custom decoders should remain only for genuinely structured payloads

This is the prerequisite for importing broad solver, matrix, and evaluation coverage without
turning `tools/sympy_worker.py` into another giant switch.

### 4. Finish The Lean Ergonomic Layer

The current scalar ergonomics work is a good foundation, but broad coverage still needs more:

- mixed scalar arithmetic across the common domain lifts, not just the current narrow slice
- cleaner relation-builder ergonomics
- better structured-builder inference for bounds, limits, and piecewise branches
- a clear, reusable policy for optional arguments and keyword-heavy public APIs
- less friction at the pure/effectful boundary where the obvious user intent is already typed

This workstream is about making sure that when we import a family, users can actually use it in
the way the docs advertise.

### 5. Generate The Public Wrapper Surface

`Ops/Core` is already carrying more repetition than a high-coverage import can tolerate.

The next state should be:

- a small set of generator commands/macros that emit `SymPy.*` aliases and method forms
- wrapper generation parameterized by:
  - receiver kind (`Term`, `SymDecl`, `SymExpr`)
  - conversion class (`IntoSymExpr`, `IntoSymSymbol`, `IntoSymFun`, pure coercion classes)
  - result shape
  - optional docs/aliases/category metadata
- hand-written wrappers only where they materially improve typing or defaults

This turns wrapper expansion into structured data and eliminates one of the main scaling risks.

### 6. Import Coverage In Waves

Once the platform is ready, coverage should land in the following order:

1. scalar pure-head families and common predicates
2. set vocabulary and set-building operations
3. matrix and linear-algebra operations
4. calculus constructors plus eager calculus/evaluation UX cleanup
5. additional high-value top-level SymPy families that fit the generic path

Each wave should include:

- declarations
- examples
- docs
- hover/search checks
- runtime validation

No wave should land with knowingly incomplete runtime support for its shape.

## Public Interface Direction

This feature will add or stabilize the following kinds of public interfaces:

- richer `declare_pure_head` metadata usage, possibly with a companion variadic declaration path
- richer `declare_op` metadata usage for dotted effectful dispatch and keyword-heavy calls
- generated public wrappers instead of large manual `Ops/Core` expansions
- broader `IntoPureTerm`, `IntoTerm`, `IntoScalarTerm`, and related builder-coercion support
- clearer canonical public names for eager operations

Compatibility policy:

- keep existing user-facing names where they are already good
- keep compatibility aliases when they cost little and reduce churn
- do not let legacy or transition wrappers remain the primary documented path

## Validation Strategy

The platform phase is complete only when it proves itself against representative coverage, not
just unit-sized smoke tests.

Required validation categories:

- build and example suite
- manifest generation
- hover/search discoverability
- pure eval and reify round-trips
- effectful op dispatch over dotted paths and keyword-heavy calls
- docs parity with runnable examples

Representative commands:

```bash
lake build SymbolicLean
lake build sympyManifest
lake build SymbolicLean.Examples
python3 scripts/check_doc_harness.py --mode local --scope core
```

Representative coverage must include:

- scalar unary/binary/variadic pure heads
- attr constants
- set constructors and set constants
- matrix operations
- effectful algebra/calculus/evaluation/solver operations
- reify after effectful simplification/evaluation where the family claims to support it

## Deferred

- proof certification or trusted-proof integration
- literal parity with every SymPy subpackage
- obscure or highly specialized SymPy modules that do not fit the broad high-value surface
- broad tensor-specific import unless it becomes a first-class product goal

## End State

At the end of this feature, the repo should be able to import a large fraction of top-level,
high-value SymPy functionality without each family reopening architecture questions.

The practical test is simple:

- a new family should feel like a declaration-and-docs task, not a cross-cutting surgery task
- the public UX should stay coherent as coverage grows
- examples should look like intended user code, not internal plumbing

That is the point at which broad SymPy import becomes sustainable.
