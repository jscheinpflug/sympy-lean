# SymbolicLean Execution Checklist

This file is the implementation checklist. Each item explains why it exists, what to do, and what counts as done. If a task changes architecture, update `plan.md` first.

## Phase 0: Planning And Standards

- [ ] Ensure `plan.md` reflects the corrected architecture.
  Why: the project plan is the decision record for future implementers.
  Do: keep the plan aligned with the pure declaration layer, pure `Term`, runtime `SymExpr`, declaration interning, and the updated syntax rules.
  Done when: `plan.md` no longer treats `Term` as session-scoped and no longer treats assumptions as session-owned source-of-truth data.

- [ ] Keep `todo.md` execution-oriented.
  Why: agents need an operational document, not just architecture notes.
  Do: keep tasks checkable, local, and explicit about purpose and completion criteria.
  Done when: a no-context implementer can follow the file top to bottom without inventing missing steps.

- [ ] Add explicit small-file guidance to `docs/standards/lean-engineering.md`.
  Why: the plan depends on narrow, self-documenting files.
  Do: add guidance for 80-150 LOC target, split-before-200 LOC, one responsibility per file, and folders by concern.
  Done when: the standards doc clearly tells future agents not to create kitchen-sink modules.

- [ ] Add one short note to `docs/architecture.md` about self-documenting structure.
  Why: mirrored docs only work well if the source tree is already narrow and well named.
  Do: state that mirrored docs plus small responsibility-aligned files are the main localization mechanism.
  Done when: the architecture doc says this explicitly.

- [ ] Add `docs/plans/symboliclean-implementation.md` and link it from `docs/plans/index.md`.
  Why: the repo harness expects discoverable long-running plans under `/docs/plans`.
  Do: summarize the final architecture and point back to `plan.md` and `todo.md`.
  Done when: `docs/plans/index.md` links to the new implementation plan artifact.

## Phase 1: Bootstrap And Public Module Surface

- [ ] Add `mathlib` to `lakefile.toml`.
  Why: the symbolic domain layer needs real algebraic capabilities instead of a local hierarchy clone.
  Do: add the dependency and refresh manifests if required.
  Done when: `lake build` succeeds with `mathlib` installed.

- [ ] Replace placeholder exports in `SymbolicLean.lean`.
  Why: the root module should describe the real public surface as the implementation grows.
  Do: re-export the intended top-level declaration, domain, sort, symbolic-expression, session, term, ops, syntax, and examples modules.
  Done when: users can import `SymbolicLean` and reach the main public API from there.

- [ ] Keep `Main.lean` as a minimal smoke/demo entrypoint.
  Why: examples should live in `SymbolicLean/Examples`, not in the executable root.
  Do: keep `Main.lean` tiny and descriptive, or leave a minimal demo path only.
  Done when: `Main.lean` is not carrying library logic.

- [ ] Create the final folder tree under `SymbolicLean/`.
  Why: the architecture depends on separating concerns cleanly so files remain small and local.
  Do: create `Decl`, `Domain`, `Sort`, `SymExpr`, `Session`, `Term`, `Backend`, `Ops`, `Syntax`, and `Examples`.
  Done when: the directory structure matches `plan.md` and no folder mixes unrelated concerns.

## Phase 2: Pure Declarations, Domains, And Sorts

- [ ] Implement `SymbolicLean/Decl/Assumptions.lean`.
  Why: assumptions are part of pure symbolic identity and should not live only in session state.
  Do: define `Assumption`, `Polarity`, and `AssumptionFact`.
  Done when: declaration-time assumptions have a stable typed representation.

- [ ] Implement `SymbolicLean/Decl/Core.lean`.
  Why: pure symbolic identity must exist before any backend session exists.
  Do: define `SymDecl`, `FunDecl`, and a hashable declaration key type that includes everything relevant for backend realization.
  Done when: symbols and function symbols can be represented as pure data with stable identity.

- [ ] Implement `SymbolicLean/Domain/Dim.lean`.
  Why: matrices and tensors need a first-class dimension type at the core of the design.
  Do: define `Dim := static Nat | dyn Name`.
  Done when: dimensions can be used in matrix and tensor sorts without placeholder types.

- [ ] Implement `SymbolicLean/Domain/VarCtx.lean`.
  Why: polynomial and algebraic-extension domains need explicit variable contexts.
  Do: define `VarCtx`, store ordered variable names, and keep the `Nodup` invariant.
  Done when: polynomial-related domain constructors can refer to a stable variable context.

- [ ] Implement `SymbolicLean/Domain/Desc.lean`.
  Why: the domain language determines which symbolic operations are legal and how results are interpreted.
  Do: define `GroundDom`, `PolyPresentation`, `AlgRelation`, `IdealRelation`, and recursive `DomainDesc`.
  Done when: the domain layer can express ground domains, polynomial rings, fraction fields, algebraic extensions, and quotients.

- [ ] Implement `SymbolicLean/Domain/Classes.lean`.
  Why: domain descriptions need a bridge to Lean-side algebraic structure and mixed-domain arithmetic.
  Do: define `DomainCarrier`, `InterpretsDomain`, and `UnifyDomain`.
  Done when: APIs can state field-like requirements and mixed-domain arithmetic has a typed output domain.

- [ ] Implement `SymbolicLean/Sort/Relations.lean`.
  Why: boolean truth values and relation kinds are shared across the sort layer and the term language.
  Do: define `Truth` and `RelKind`.
  Done when: the rest of the sort layer can depend on a stable relation vocabulary.

- [ ] Implement `SymbolicLean/Sort/Ext.lean`.
  Why: the framework needs a typed story for specialized SymPy families without collapsing to raw strings.
  Do: define a concrete `SymExt` enum covering at least geometry, combinatorics, stats, physics, indexed tensors, codegen, number theory, and a fallback like `other Name`.
  Done when: extension-family values can appear in `SymSort`.

- [ ] Implement `SymbolicLean/Sort/Base.lean`.
  Why: every pure declaration, term, and backend handle is indexed by a symbolic object family.
  Do: define `SymSort ext` and export `abbrev SSort := SymSort SymExt`.
  Done when: the sort language can represent booleans, scalars, matrices, tensors, sets, tuples, sequences, maps, functions, relations, and extension families.

- [ ] Use `List` in recursive sort positions.
  Why: recursive `Array` positions already caused elaboration and deriving problems in review.
  Do: keep `tuple`, `fn`, and `relation` list-based, even if runtime payloads use arrays elsewhere.
  Done when: recursive sorts compile cleanly and no recursive `Array (SymSort ...)` remains.

- [ ] Add manual `DecidableEq` / `BEq` / `Hashable` only where deriving fails.
  Why: the design should not depend on fragile deriving success for recursive datatypes.
  Do: try deriving first; if Lean resists, write manual instances in the smallest local file.
  Done when: declarations, domains, and sorts have stable equality and hashing support.

## Phase 3: Runtime Handles And Sessions

- [ ] Implement `SymbolicLean/SymExpr/Core.lean`.
  Why: the project needs a Lean-side name for live backend objects that does not conflict with `Lean.Expr`.
  Do: define `opaque SessionTok`, `Ref`, and `SymExpr (s : SessionTok) (σ : SSort)`.
  Done when: runtime symbolic values can be referenced abstractly and typed by sort.

- [ ] Implement `SymbolicLean/SymExpr/Refined.lean`.
  Why: some APIs require realized symbols, function symbols, booleans, or relations specifically.
  Do: define `SymSymbol`, `SymFun`, `SymBool`, and `SymRel` as thin wrappers over `SymExpr`.
  Done when: symbol-only and relation-specific APIs can require these wrappers instead of ad hoc runtime checks.

- [ ] Implement `SymbolicLean/Session/Errors.lean`.
  Why: the backend boundary needs typed failures rather than stringly error handling.
  Do: define worker, decode, protocol, and user-surface errors.
  Done when: `SymPyM` can fail with structured error types.

- [ ] Implement `SymbolicLean/Session/State.lean`.
  Why: sessions own handle lifetimes, caches, and declaration realization.
  Do: store live handles, a declaration-interning table, canonicalization caches, and any dynamic shape/domain metadata needed for decoded results.
  Done when: session state no longer treats assumptions as the authoritative symbolic source of truth and instead interns pure declarations into backend refs.

- [ ] Implement `SymbolicLean/Session/Monad.lean`.
  Why: all backend communication is effectful and should live in one explicit monad.
  Do: define `SymPyM := ReaderT SessionEnv (StateT SessionState (ExceptT SymPyError IO))` and `withSession`.
  Done when: backend APIs can run inside a session and produce typed results or typed errors.

- [ ] Preserve handle non-escape by construction.
  Why: session safety is one of the key type-level guarantees of the entire project.
  Do: keep public handle-returning APIs under `∀ s` and do not leak raw refs.
  Done when: a `SymExpr s σ` cannot be stored or returned outside the session scope.

## Phase 4: Algebraic Bridge

- [ ] Add `InterpretsDomain` instances for the ground domains.
  Why: users need field/ring-sensitive operations to typecheck immediately on the common domains.
  Do: cover `ZZ`, `QQ`, `RR`, `CC`, `gaussianZZ`, and `GF p`.
  Done when: field-only and ring-only APIs can be stated over those domains.

- [ ] Add recursive propagation instances for composite domains.
  Why: the recursive domain language is useless unless capabilities propagate through it.
  Do: define the expected behavior for `polyRing`, `fracField`, `algExt`, and `quotient`.
  Done when: the typeclass layer can infer the right algebraic capability on those constructions.

- [ ] Implement and test `UnifyDomain`.
  Why: mixed-domain symbolic arithmetic is common and must not rely on ad hoc operator overlap.
  Do: add reflexive and mixed-domain instances such as `ZZ + QQ -> QQ`.
  Done when: scalar arithmetic uses a single domain-unification path for both same-domain and mixed-domain cases.

## Phase 5: Pure Term Language

- [ ] Implement `SymbolicLean/Term/Core.lean`.
  Why: users need a pure typed symbolic language before any backend calls happen.
  Do: define `Atom : SSort -> Type`, `Term : SSort -> Type`, and the base `atom` constructor over pure declarations.
  Done when: `Term` is genuinely pure and no longer carries a session parameter.

- [ ] Implement `SymbolicLean/Term/Literals.lean`.
  Why: numerals and scalar literals should not bloat the core term file.
  Do: add literal constructors and default-domain helpers used by `term!`.
  Done when: numerals in `term!` can elaborate without special cases elsewhere.

- [ ] Implement `SymbolicLean/Term/Arithmetic.lean`.
  Why: arithmetic is the main blackboard-math surface.
  Do: define `CanAdd`, `CanMul`, `CanPow`, and the standard operator instances on `Term`.
  Done when: users can write typed symbolic arithmetic without touching the backend.

- [ ] Implement `SymbolicLean/Term/Logic.lean`.
  Why: boolean formulas are a major SymPy use case and should be available in the pure layer.
  Do: define typed boolean connectives and any needed helper classes.
  Done when: boolean expressions can be built and typechecked as pure terms.

- [ ] Implement `SymbolicLean/Term/Relations.lean`.
  Why: equality, order, and membership should be typed constructors, not ad hoc macros.
  Do: define `CanCompare` and the core relation constructors.
  Done when: relations and membership are expressible as pure terms with typed argument sorts.

- [ ] Implement `SymbolicLean/Term/Calculus.lean`.
  Why: ODE/PDE and calculus workflows need derivative and common unevaluated forms at the term level.
  Do: add derivative plus the common unevaluated forms that v1 actually uses.
  Done when: `term!` can express the planned calculus examples without calling the backend directly.

- [ ] Implement `SymbolicLean/Term/Application.lean`.
  Why: symbolic function application is central to solver workflows.
  Do: support unary function application directly and provide explicit helpers for higher arities.
  Done when: `f x` style syntax works for unary pure function declarations and higher-arity application has a typed fallback.

- [ ] Keep `Term` small on purpose.
  Why: the project should not slide back into “model all of SymPy in Lean”.
  Do: keep transforms and queries out of the term language.
  Done when: `Term` remains an expression language rather than a catch-all API surface.

## Phase 6: Declaration Realization And Backend Transport

- [ ] Implement `tools/sympy_worker.py`.
  Why: Lean needs a stable, inspectable backend process for sessions and symbolic operations.
  Do: support `ping`, `mk_symbol`, `mk_function`, `eval_term`, `apply_op`, `pretty`, and `release`.
  Done when: a Lean client can create refs, evaluate terms, apply named operations, and shut down cleanly.

- [ ] Implement `SymbolicLean/Backend/Protocol.lean`.
  Why: the wire protocol should be explicit and versioned on the Lean side.
  Do: define request and response payload types matching the worker commands.
  Done when: backend messages are encoded through typed protocol structures rather than raw JSON fragments everywhere.

- [ ] Implement `SymbolicLean/Backend/Encode.lean`.
  Why: pure terms need a single deterministic serialization path to the backend.
  Do: encode `Term` and generic op payloads.
  Done when: every supported term constructor has a backend encoding.

- [ ] Implement `SymbolicLean/Backend/Decode.lean`.
  Why: solver-like and other structured APIs return more than a single opaque handle.
  Do: decode tagged payloads for structured results and lightweight dynamic metadata.
  Done when: the backend client can reconstruct typed result containers instead of leaking JSON upward.

- [ ] Implement `SymbolicLean/Backend/Realize.lean`.
  Why: realization is now its own subsystem, not just a side effect of term encoding.
  Do: intern declarations by full declaration key, create backend symbols/functions when missing, and expose helpers like `realizeDecl`, `realizeFun`, and `eval`.
  Done when: the same pure declaration maps to the same backend ref throughout one session.

- [ ] Implement `SymbolicLean/Backend/Client.lean`.
  Why: worker lifecycle, request dispatch, and ref bookkeeping should be isolated from symbolic APIs.
  Do: manage the persistent worker process, JSON request/response flow, and session ref tracking.
  Done when: higher layers call backend helpers instead of shelling out or manually assembling protocol messages.

- [ ] Implement `eval : Term σ -> SymPyM s (SymExpr s σ)`.
  Why: this is the core bridge from pure symbolic syntax to live SymPy objects.
  Do: recursively realize declarations, serialize the term, send it to `eval_term`, and allocate a typed handle for the returned ref.
  Done when: a pure typed term can be evaluated into a live `SymExpr` with no manual plumbing.

## Phase 7: Effectful Symbolic Operations

- [ ] Implement `SymbolicLean/Ops/Algebra.lean`.
  Why: algebraic transforms are the most common first interaction with a CAS.
  Do: add `simplify`, `factor`, `expand`, `cancel`, and `subs`.
  Done when: common scalar-algebra examples can run entirely through the Lean API.

- [ ] Implement `SymbolicLean/Ops/Calculus.lean`.
  Why: symbolic calculus is a major SymPy strength and is needed for solver workflows.
  Do: add `diffExpr`, `integrate`, `limit`, and minimal series support.
  Done when: the planned calculus and ODE examples can be expressed without missing backend operations.

- [ ] Implement `SymbolicLean/Ops/LinearAlgebra.lean`.
  Why: typed matrix operations are one of the clearest benefits of the design.
  Do: add `det`, `inv`, and `rref`.
  Done when: matrix examples work and field-only operations respect domain constraints.

- [ ] Implement `SymbolicLean/Ops/Solvers.lean`.
  Why: solver APIs justify the whole Lean-to-SymPy bridge.
  Do: add `solveUnivariate`, `solveset`, `dsolve`, `satisfiable`, and `ask`.
  Done when: the v1 solver examples compile and run through typed result containers.

- [ ] Define structured result types in the smallest sensible files.
  Why: solver and query results should not leak raw JSON or untyped lists.
  Do: define `FiniteSolve`, `EvalOr`, `ODESolution`, and `SolveSetResult`.
  Done when: each nontrivial operation returns a typed Lean container with a clear public surface.

- [ ] Implement the small front-door conversion layer in `Ops/Core.lean`.
  Why: a few high-frequency APIs should accept pure and realized inputs without collapsing the architecture.
  Do: add `IntoSymExpr` for `Term` and `SymExpr`, `IntoSymSymbol` for `SymDecl` and `SymSymbol`, and `IntoSymFun` for `FunDecl` and `SymFun`.
  Done when: users can write `factor term![...]`, `ask x ...`, and `dsolve term![...] f` while low-level APIs remain clearly realized-object APIs.

## Phase 8: Syntax And Sugar

- [ ] Implement `SymbolicLean/Syntax/Term.lean`.
  Why: `term![...]` is the main ergonomic gateway into the pure symbolic layer.
  Do: elaborate identifiers, numerals, unary minus, `+ - * / ^`, unary application, relations, boolean connectives, membership, and derivative syntax into `Term`.
  Done when: the planned examples can be written with `term!` instead of raw constructors.

- [ ] Keep identifier resolution in `term!` explicit.
  Why: implicit name synthesis would blur the pure declaration layer and make ordinary code harder to reason about.
  Do: resolve only bound locals, including pure declarations and prebuilt terms.
  Done when: ordinary `term!` does not auto-create free symbolic names.

- [ ] Implement `SymbolicLean/Syntax/Binders.lean`.
  Why: repeated declaration creation is boilerplate and obscures the actual mathematics.
  Do: add `symbols x y z`, `functions f g`, and optional assumption-bearing forms such as `symbols (x : positive) (y : real) z`.
  Done when: session examples can declare pure symbols and function symbols concisely.

- [ ] Fix the v1 defaults for binders.
  Why: `functions f g` must mean something concrete or it is not executable as a plan.
  Do: inside `sympy d do`, make `symbols` default to scalar declarations of sort `.scalar d` and make `functions` default to unary scalar-to-scalar declarations over `.scalar d`.
  Done when: the ODE example is fully specified without hidden decisions.

- [ ] Implement `SymbolicLean/Syntax/Subst.lean`.
  Why: substitution is frequent enough to deserve direct notation.
  Do: add `expr[x ↦ 2, y ↦ 3]` and lower it to the ordinary typed substitution API.
  Done when: substitution sugar exists without introducing a second semantic path.

- [ ] Implement `SymbolicLean/Syntax/Command.lean` for `sympy d do ...`.
  Why: users need one obvious way to open a session, install a default scalar domain, and use the sugar together.
  Do: wrap `withSession`, install the default domain, and bring constructors and binder macros into scope.
  Done when: the common examples can be written inside a compact `sympy ... do` block without hidden name creation.

- [ ] Implement `SymbolicLean/Syntax/Command.lean` for `#sympy d ...`.
  Why: the project needs a quick exploratory interface during development and debugging.
  Do: keep v1 scope intentionally narrow: scalar exploration only, auto-created scalar declarations, realized evaluation, and pretty-printed output.
  Done when: a user can try scalar expressions interactively without writing a full session block.

- [ ] Keep richer calculus notation out of v1 unless the earlier sugar lands cleanly.
  Why: extra parser surface is lower value than stabilizing the core sugar.
  Do: treat `∂` and `∫` as optional follow-up work, not a dependency.
  Done when: they are absent from v1 unless clearly justified and still implemented in small files.

## Phase 9: Generated Wrapper Layer

- [ ] Implement `SymbolicLean/Syntax/DeclareOp.lean`.
  Why: the wrapper count will grow too quickly if every operation is written by hand.
  Do: implement `declare_sympy_op`.
  Done when: the generator can define a typed wrapper, encoding hook, decode hook, and docstring from one declaration.

- [ ] Restrict generated pure helpers to expression-forming operations.
  Why: query and transform operations belong on realized backend objects, not in the pure expression layer.
  Do: generate pure helpers only where the operation truly constructs symbolic syntax.
  Done when: the generator respects the declaration / `Term` / `SymExpr` split.

- [ ] Prove the generator on one op from each family.
  Why: the mechanism is only useful if it handles varied operation shapes.
  Do: migrate one algebra op, one linear-algebra op, and one solver op.
  Done when: those wrappers are generated rather than hand-written.

## Phase 10: Examples, Negative Cases, And Verification

- [ ] Implement `SymbolicLean/Examples/Scalars.lean`.
  Why: scalar algebra is the first thing users will test.
  Do: include factorization, simplification, and substitution examples built from pure declarations and `term!`.
  Done when: scalar symbolic flows are demonstrated end-to-end.

- [ ] Implement `SymbolicLean/Examples/Matrices.lean`.
  Why: matrix typing is one of the clearest demonstrations of the project’s value.
  Do: include matrix-vector multiplication and determinant examples.
  Done when: dimension-checked matrix workflows compile and run.

- [ ] Implement `SymbolicLean/Examples/Solvers.lean`.
  Why: solver workflows are the major payoff for the Lean/SymPy bridge.
  Do: include `dsolve`, `solveset`, `satisfiable`, and `ask`.
  Done when: the planned solver stories exist as readable examples and use the corrected pure-declaration surface.

- [ ] Implement `SymbolicLean/Examples/Negative.lean`.
  Why: the project claims compile-time rejection of illegal operations and should demonstrate it.
  Do: add `#guard_msgs`-style cases for dimension mismatch, non-field inversion, and differentiation with respect to a non-symbol.
  Done when: the examples suite includes both positive and negative cases.

- [ ] Re-export examples from `SymbolicLean/Examples.lean`.
  Why: example discovery should be as easy as importing one module.
  Do: keep the file tiny and purely organizational.
  Done when: `SymbolicLean.Examples` exposes the example set cleanly.

- [ ] Add mirrored docs for every new core module.
  Why: the repo harness treats mirrored docs as part of the implementation, not optional polish.
  Do: add `docs/<source>.md` files with the required sections in the same change set as each source file.
  Done when: there are no missing mirrored docs for the new module tree.

- [ ] Verify incrementally with Lean LSP first.
  Why: file-local feedback is faster and keeps errors localized.
  Do: use file diagnostics before reaching for whole-project builds.
  Done when: each file is locally clean before integration.

- [ ] Run the full verification gate.
  Why: the task is not complete until code, docs, and harness all pass together.
  Do: run `source .agents/lean4-env.sh`, `lake build`, and `python3 scripts/check_doc_harness.py --mode local --scope core`, then do a manual `#sympy` smoke pass.
  Done when: build, docs harness, and interactive smoke checks all succeed.

## Final Completion Criteria

- [ ] `plan.md` explains the project motivation, trust model, declaration model, core data structures, and design decisions clearly enough for a new contributor.
- [ ] `todo.md` provides a step-by-step execution plan with purpose and completion criteria for each major task.
- [ ] The module tree follows the small-file, self-documenting structure described in the plan.
- [ ] Pure declarations, pure `Term`, and session-scoped `SymExpr` are all visible in code and preserved by the public API.
- [ ] Declarations are interned on realization and assumptions are attached on the pure side before realization.
- [ ] Core scalar, matrix, boolean, and solver workflows are implemented and demonstrated.
- [ ] Mirrored docs exist for the new core modules and the harness checker passes.
- [ ] A future agent can continue implementation by reading the local module, its mirrored doc, `plan.md`, and this checklist, without needing hidden context from old conversations.

