# Production UX and Extensibility Backbone

## Overview

This slice is about turning `sympy-lean` into a production-ready symbolic front end instead of a promising prototype.

The current architecture already has the right major pieces:
- typed pure terms in Lean
- a registry and generated manifest
- a session-scoped SymPy worker
- public front-door wrappers

The main problem is that these pieces are not yet the full source of truth for one another. In practice:
- new pure heads still require worker-side special cases
- reification support is too narrow for new coverage to feel complete
- some public effectful ops are not registry-backed
- simple string/JSON-returning ops are harder to add than they should be
- public naming and examples are not yet consistent enough to feel like a production UX

This plan fixes those problems in the right order:
1. make the registry/manifest drive extension and discoverability
2. make pure-head evaluation and reification generic enough for real coverage growth
3. make effectful op decoding and public front doors easier to extend
4. land a first coverage wave that proves the infrastructure works
5. improve solver/set UX so the current public surface feels complete, not partial

## Goals

- Make the registry and manifest the single source of truth for extension, worker dispatch, hover/search, and generated public surface.
- Make adding most new SymPy pure functions declarative instead of multi-file manual work.
- Improve the public UX so the documented surface feels SymPy-aligned, consistent, and production-ready.
- Keep the current wrapper shapes mostly intact while shifting canonical docs/examples toward SymPy naming.
- Land a first coverage wave for scalar special functions, then a small solver/set wave.

## Scope Of This Slice

- Registry metadata expansion
- Generic pure-head declaration infrastructure
- Worker-side generic pure-head evaluation
- Worker-side targeted generic reification for the newly added public surface
- Generic JSON/string effectful decode support
- Public front doors for `solve`, `integrate`, `doit`, `evalf`, and `latex`
- First scalar special-function coverage wave
- Minimal set vocabulary for solver UX
- README, project-guide, mirrored docs, and examples refresh

## Public Interface Changes

- Extend `RegistryMetadata` with pure-head dispatch metadata:
  - `backendPath : List String`
  - `callStyle : call | attr`
  - `pureSpec? : Option { args : List SSort, result : SSort }`
- Add a metadata-only effectful registration command:
  - `register_op ... => ...`
- Add a generic pure-head declaration command:
  - `declare_pure_head ...`
- Add scalar sugar on top of it:
  - `declare_scalar_fn₁`
  - `declare_scalar_fn₂`
- Add canonical public front doors:
  - `solve`
  - `integrate`
  - `doit`
  - `evalf`
  - `latex`
- Keep existing compatibility wrappers such as `solveUnivariate` in this slice unless they actively block consistency.
- Add public solver/set constants:
  - `SymPy.S.Reals`
  - `SymPy.S.Integers`

## Workstreams

### 1. Registry And Manifest As The Backbone

- Refactor the declaration machinery so registry registration is a first-class primitive, not just a side effect of `declare_op`.
- Make every public head and every public effectful op registry-backed.
- Replace the current `rref` metadata gap with a proper `register_op` path instead of a hand-written unregistered exception.
- Keep hover/search entirely registry-driven, including docs, aliases, categories, and error templates.

Why:
- This removes drift between public API, manifest contents, and discoverability.
- It also gives the worker enough structured information to stop hard-coding extension behavior.

### 2. Generic Pure-Head Declaration Pipeline

- Implement `declare_pure_head` in the syntax/registry layer.
- `declare_pure_head` must generate:
  - the registry entry
  - the typed `ExtHeadSpec`
  - the Lean term helper
  - the optional `SymPy.*` alias when requested
- Build `declare_scalar_fn₁` and `declare_scalar_fn₂` as thin sugar on top of `declare_pure_head`.
- Keep the existing core arithmetic/logic/calculus constructors unchanged; this slice generalizes extension heads, not core heads.

Why:
- This is the main extensibility win.
- After this lands, most new scalar SymPy functions should be declared instead of hand-wired.

### 3. Worker Eval And Reify Generalization

- Replace the current hard-coded “unsupported manifest-dispatched pure head” fallback with registry-driven evaluation in `tools/sympy_worker.py`.
- Evaluation rules:
  - `callStyle.call`: resolve `backendPath` and call the target with evaluated args
  - `callStyle.attr`: resolve the attribute object directly with no call
- Reification rules in this slice:
  - required: registered unary/binary scalar call-heads
  - required: public nullary attribute constants used by solver UX
  - deferred: broad variadic/set/tensor reification beyond the explicitly added public surface
- Preserve existing special cases for core heads and structured calculus heads where custom behavior already exists.

Why:
- Without this, “registered” still does not mean “works”.
- This is the difference between coverage on paper and coverage that actually evaluates, pretty-prints, and round-trips.

### 4. Effectful Op Framework And Public Front Doors

- Add a generic `OpPayloadDecode` fallback for any `[FromJson α]`.
- Add explicit decode instances only when `FromJson` is insufficient.
- Use that path to support `latex` as a string-returning op without bespoke command syntax.
- Keep custom hand-written bodies only for truly structured results such as `rref`, but require them to register metadata through `register_op`.
- Add public front doors for:
  - `integrate`
  - `doit`
  - `evalf`
  - `latex`
  - `solve`
- Make `solve` the documented public name for the current finite univariate solve surface, while keeping `solveUnivariate` as a compatibility alias in this slice.

Why:
- This improves UX immediately.
- It also removes friction when adding common effectful SymPy operations later.

### 5. First Coverage Wave: Scalar Special Functions

- Add a dedicated pure-head module for special functions and use it as the reference implementation pattern for future coverage.
- Include:
  - `sin`, `cos`, `tan`
  - `asin`, `acos`, `atan`, `atan2`
  - `sinh`, `cosh`, `tanh`
  - `exp`, `log`, `sqrt`
  - `Abs`, `sign`, `floor`, `ceiling`
  - `re`, `im`, `conjugate`, `arg`
- Do not add variadic names such as `Max`, `Min`, or `FiniteSet` in this slice.

Why:
- This is the highest-value first wave for tutorial parity and exploratory UX.
- It also proves the new pure-head infrastructure on real SymPy coverage, not a toy example.

### 6. Solver And Set UX Follow-Up

- Add the minimal set vocabulary needed for actual `solveset` workflows:
  - `Interval`
  - `Union`
  - `Intersection`
  - `Complement`
  - `SymPy.S.Reals`
  - `SymPy.S.Integers`
- Build these on the same registry-driven pure-head machinery plus `callStyle.attr`/dotted backend paths.
- Make `solveset` examples show both `pretty solved.setExpr` and use of the new pure set constants.
- Treat broader set algebra and variadic set constructors as the next wave, not this slice.

Why:
- Solver UX is currently readable but not composable.
- This closes a real user-facing gap without trying to cover all of SymPy’s set system at once.

### 7. Docs, Examples, And Validation

- Every touched `SymbolicLean/**` file must land with its mirrored `/docs` update in the same change.
- Refresh README and the project guide so the documented canonical surface is:
  - SymPy-like in naming
  - valid Lean syntax
  - explicit about pure constructors vs effectful ops
- Add one dedicated example module for special functions and one for eval/render ops if the existing files become too noisy.
- Keep the negative and compile-time type-level examples intact where the new surface affects them.

## Success Criteria

- A new unary or binary scalar SymPy function usually requires one declaration plus docs/examples, not bespoke worker eval code.
- New pure scalar heads can:
  - evaluate
  - pretty-print
  - reify in the supported slice
- `rref`, `solve`, `integrate`, `latex`, and the new pure heads all appear in `#sympy_hover` / `#sympy_search`.
- README and example files use the canonical production surface.
- Local build, example compilation, runtime examples, and the doc harness all pass.

## Validation Commands

```bash
lake build SymbolicLean
lake build SymbolicLean.Examples
lake env lean SymbolicLean/Examples/Scalars.lean
lake env lean SymbolicLean/Examples/Matrices.lean
lake env lean SymbolicLean/Examples/Solvers.lean
python3 scripts/check_doc_harness.py --mode local --scope core
```

## Deferred

- `Term` constructor collapse
- Broad variadic pure-head support
- Broad set/tensor reification beyond the explicitly added public surface
- Proof-producing or trusted-proof SymPy integration

## Assumptions

- Canonical naming should move toward SymPy, but current wrappers should mostly remain available as compatibility aliases in this slice.
- The current wrapper shapes should not be reshaped broadly unless needed for naming parity or typing.
- Generic reify support is required only for the new scalar special functions and the small set of public constants introduced for solver UX.
