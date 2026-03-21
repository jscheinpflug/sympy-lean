# Refactor Todo

## Phase 1: Public Surface

- [x] Add `SymbolicLean/Sort/Aliases.lean` with `SymCarrier`, `Scalar`, `Mat`, `MatD`, and `Vec`.
- [x] Extend `SymbolicLean/Domain/Classes.lean` with the public carrier bridge used by the aliases.
- [x] Add `sym`, `symWith`, and `funSym` builders in the declaration layer.
- [x] Extend `SymbolicLean/Syntax/Binders.lean` so `symbols (x : Rat | positive)` and `symbols (A : Mat Rat 2 2)` work.
- [x] Export the new aliases/builders from `SymbolicLean.lean`.
- [x] Rewrite public examples away from raw `.ground .QQ` / `.scalar` / `.static` surface forms.

## Phase 2: Plain Lean Ergonomics

- [x] Add coercions from `SymDecl σ` to `Term σ` in `SymbolicLean/Term/Core.lean`.
- [x] Add coercions from `FunDecl args ret` to `Term (.fn args ret)` in `SymbolicLean/Term/Core.lean`.
- [x] Keep and adapt `CoeFun` support in `SymbolicLean/Term/Application.lean` so declared unary functions are callable in plain Lean syntax.
- [x] Verify `x + y`, `f x`, and `A * v` typecheck in ordinary Lean code once declarations are in scope.

## Phase 3: Typed Head Core

- [x] Create `SymbolicLean/Term/Head.lean` with `CoreHead`, `ExtHeadSpec`, `Head`, and `HeadSchema`.
- [x] Extend `SymbolicLean/Term/Core.lean` with `Term.headApp` while keeping existing constructors temporarily.
- [x] Keep atoms, literals, and function application primitive during the migration.
- [x] Wire the new head core into `SymbolicLean.lean`.

## Phase 4: Internal Views

- [x] Create `SymbolicLean/Term/View.lean` with `CoreView`.
- [x] Implement `Term.coreView`.
- [x] Generate or define projectors like `asAdd?`, `asIntegral?`, and `asPiecewise?`.
- [x] Plan encoder/reifier/canonicalizer work around the generated views instead of raw dependent packs.

## Phase 5: Registry Foundation

- [x] Create `SymbolicLean/Syntax/Registry.lean` with the environment extension for symbolic registry entries.
- [x] Replace `SymbolicLean/Syntax/DeclareOp.lean` with registry-driven `declare_head` and `declare_op`.
- [x] Add registry metadata types for surface role, dispatch mode, reify mode, result mode, docs, and custom error templates.
- [x] Key registry lookup by `Name` for fast elaboration-time lookup.

## Phase 6: Build Graph and Manifest

- [x] Replace `lakefile.toml` with `lakefile.lean`.
- [x] Add a Lake target or executable that emits `.lake/build/sympy/manifest.json` from the Lean registry environment extension.
- [x] Make the manifest target part of the normal build graph so `lake build` refreshes it.
- [x] Document the manifest build path and versioning contract in mirrored docs.

## Phase 7: Backend Protocol and Reification

- [x] Extend `SymbolicLean/Backend/Protocol.lean` with manifest version data and reification request/response payloads.
- [x] Extend `SymbolicLean/Backend/Client.lean` with manifest/version checks and `reifyRemote`.
- [x] Extend `SymbolicLean/Backend/Realize.lean` with `reify : SymExpr s σ → SymPyM s (Term σ)`.
- [x] Extend `SymbolicLean/Backend/Decode.lean` to decode reified head-based terms.

## Phase 8: Python Worker Refactor

- [x] Refactor `tools/sympy_worker.py` to load the generated manifest at startup.
- [x] Replace constructor-by-constructor pure-term dispatch with generic manifest-driven `headApp` evaluation.
- [x] Replace hand-maintained effectful op dispatch with manifest-driven dispatch modes.
- [x] Add manifest-driven reification in Python.
- [x] Fail fast when protocol or manifest versions do not match Lean expectations.

## Phase 9: Canonicalization and Interning

- [x] Create `SymbolicLean/Term/Canon.lean`.
- [x] Implement recursive canonicalization.
- [x] Implement literal folding for selected core heads.
- [x] Implement identity elimination for selected core heads.
- [x] Implement flattening of associative core heads.
- [x] Implement stable structural ordering for commutative arguments.
- [x] Extend `SymbolicLean/Session/State.lean` with a cache from canonical term keys to remote refs.
- [x] Use the canonical cache in evaluation/realization paths.

## Phase 10: Dual-Path Encoding During Migration

- [x] Update `SymbolicLean/Backend/Encode.lean` to support both existing constructors and new `headApp` nodes.
- [x] Ensure the worker can evaluate both legacy tags and `headApp` tags during the migration.
- [x] Keep old behavior unchanged while migrating operator families one-by-one.

## Phase 11: First Registry-Backed Heads

- [x] Migrate arithmetic smart constructors in `SymbolicLean/Term/Arithmetic.lean` onto `CoreHead`/`headApp`.
- [x] Migrate logic smart constructors in `SymbolicLean/Term/Logic.lean`.
- [x] Migrate relation smart constructors in `SymbolicLean/Term/Relations.lean`.
- [x] Migrate calculus smart constructors in `SymbolicLean/Term/Calculus.lean`.
- [x] Preserve existing `HAdd`, `HMul`, `HPow`, and related instances while changing their internals to use `headApp`.

## Phase 12: Generic Symbolic Application Elaboration

- [x] Create `SymbolicLean/Syntax/Elab.lean` with the generic application elaborator for registered heads.
- [x] Make registered free heads callable from ordinary Lean application syntax.
- [x] Support variadic positional arguments and named arguments in the symbolic elaborator.
- [x] Route elaboration through registry-defined schemas and custom error templates.

## Phase 13: Structured Argument Support

- [x] Create `SymbolicLean/Syntax/StructuredArgs.lean`.
- [x] Define schema structs such as `BoundSpec`, `DerivSpec`, `PieceBranch`, and binder tuple wrappers.
- [x] Add tuple-to-structure `Coe` instances so ordinary tuples elaborate into structured symbolic arguments.
- [x] Use these structured schemas for `Integral`, `Derivative`, `Piecewise`, `Lambda`, `Sum`, and `Product`.

## Phase 14: Generated Methods, Properties, and Namespaces

- [x] Generate free symbolic head declarations under the `SymPy` namespace.
- [x] Generate extension methods on `Term` and `SymExpr` for method-form ops like `.expand()` and `.subs(...)`.
- [x] Generate receiver properties like `.T` and `.I`.
- [x] Generate namespaces like `SymPy.Q` and `SymPy.S` for predicates and named constants.
- [x] Keep property generation scoped so short names do not pollute the global namespace.

## Phase 15: Missing Surface Syntax

- [x] Create `SymbolicLean/Syntax/Indexing.lean` for multi-index and slice forms like `A[i, j]`, `A[:, j]`, and `A[i:j]`.
- [x] Create `SymbolicLean/Syntax/Dict.lean` for `dict{ x ↦ 1, y ↦ 2 }`.
- [x] Connect indexing/slicing and dict forms to the registry-backed elaboration pipeline.

## Phase 16: `#sympy` Redesign

- [x] Rewrite `SymbolicLean/Syntax/Command.lean` so `#sympy α => expr` and `#sympy α do ...` use ordinary Lean syntax.
- [x] Make `#sympy` open a temporary session with default scalar carrier `α`.
- [x] Auto-create unresolved argument-position names as scalar symbols.
- [x] Auto-create unresolved simple call heads as undefined function symbols when appropriate.
- [x] Warn on unresolved constructor-like or qualified heads before falling back to raw named calls.
- [x] Evaluate and pretty-print final `Term` results.
- [x] Pretty-print final `SymExpr` results directly.
- [x] Render structured final results via registered renderers or `repr`.

## Phase 17: Assumption Scoping

- [x] Add `assuming [...] do ...` support over the session/evaluation layer.
- [x] Thread assumption scopes through the monad/context rather than inventing a second expression language.
- [x] Connect `Q.*` predicates to the assumption-scoping surface.

## Phase 18: Discoverability

- [x] Add registry-backed hover doc support for generated heads/ops.
- [x] Add completion metadata for registered heads/methods/properties.
- [x] Create `SymbolicLean/Syntax/Search.lean` with `#sympy_search "keyword"`.
- [x] Search over names, aliases, docs, and categories.

## Phase 19: Effectful Op Migration

- [x] Migrate `SymbolicLean/Ops/Algebra.lean` to `declare_op`.
- [x] Migrate `SymbolicLean/Ops/Calculus.lean` to `declare_op`.
- [x] Migrate `SymbolicLean/Ops/LinearAlgebra.lean` to `declare_op`.
- [x] Migrate `SymbolicLean/Ops/Solvers.lean` to `declare_op`.
- [x] Update `SymbolicLean/Ops/Core.lean` so generated method-form wrappers are part of the public front door.

## Phase 20: Example and Doc Migration

- [x] Rewrite `SymbolicLean/Examples/Scalars.lean` to the carrier-based plain-Lean surface.
- [x] Rewrite `SymbolicLean/Examples/Matrices.lean` to the carrier-based plain-Lean surface.
- [x] Rewrite `SymbolicLean/Examples/Solvers.lean` to the carrier-based plain-Lean surface.
- [x] Update `SymbolicLean/Examples.lean` exports if needed.
- [x] Update `docs/index.md`.
- [x] Update `docs/plans/symboliclean-implementation.md`.
- [x] Update mirrored docs for every touched source file in the same change set.

## Phase 21: Verification

- [x] Add smoke tests for plain Lean symbolic code in strict mode.
- [x] Add smoke tests for generated methods and properties.
- [x] Add smoke tests for structured argument coercions.
- [x] Add smoke tests for `dict{...}` and indexing/slicing surface forms.
- [x] Add smoke tests for `#sympy` single-line and block behavior.
- [x] Add round-trip tests for `reify(eval(t)) = canonicalize(t)` on registered pure heads.
- [x] Add cache reuse tests for canonical-equivalent terms.
- [x] Add manifest freshness/version mismatch tests.
- [x] Keep running `lake build SymbolicLean`.
- [x] Keep running `python3 scripts/check_doc_harness.py --mode local --scope core`.

## Phase 22: Final Cleanup

- [x] Delete `SymbolicLean/Syntax/Term.lean`.
- [x] Remove old public raw-domain syntax from the public front door.
- [x] Remove deprecated legacy constructor paths once all migrated families use `headApp`.
- [x] Add negative tests ensuring old public `.ground .QQ` examples fail.
- [x] Add negative tests ensuring removed `term!` syntax fails.
- [x] Confirm public examples and docs no longer expose internal domain/sort tags.
