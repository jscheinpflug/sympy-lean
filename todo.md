  # SymbolicLean Execution Checklist

  ## Summary

  - This replaces the earlier checklist and fixes the remaining execution ambiguities: concrete names, exact module tree, syntax scope, backend protocol, test layout, and
    docs-harness updates.
  - Naming decision: use SymExpr instead of Expr to avoid confusion with Lean.Expr.
  - Self-documenting structure decision: target files at roughly 80-150 LOC, split before ~200 LOC, and name files by one concept or one API slice.

  ## 0. Harness And Standards

  - [ ] Update docs/standards/lean-engineering.md to state:
    small focused files, folders by responsibility, file names by concept, split before kitchen-sink modules.
  - [ ] Update docs/architecture.md to state that mirrored docs plus narrow modules are the main self-documenting mechanism.
  - [ ] Add docs/plans/symboliclean-implementation.md and link it from docs/plans/index.md.
  - [ ] Keep AGENTS.md unchanged as index-only; do not move canonical guidance back into it.
  - [ ] For every new SymbolicLean/** file, add the mirrored doc docs/<same path>.md with the required five ## sections.

  ## 1. Bootstrap

  - [ ] Add mathlib to lakefile.toml.
  - [ ] Replace the placeholder root exports in SymbolicLean.lean with the real module graph.
  - [ ] Keep Main.lean as a tiny smoke/demo entrypoint only.
  - [ ] Verify bootstrap with source .agents/lean4-env.sh && lake build.

  ## 2. Final Module Tree

  - [ ] Create SymbolicLean/Domain/Dim.lean.
  - [ ] Create SymbolicLean/Domain/VarCtx.lean.
  - [ ] Create SymbolicLean/Domain/Desc.lean.
  - [ ] Create SymbolicLean/Domain/Classes.lean.
  - [ ] Create SymbolicLean/Sort/Relations.lean.
  - [ ] Create SymbolicLean/Sort/Ext.lean.
  - [ ] Create SymbolicLean/Sort/Base.lean.
  - [ ] Create SymbolicLean/SymExpr/Core.lean.
  - [ ] Create SymbolicLean/SymExpr/Refined.lean.
  - [ ] Create SymbolicLean/Session/Errors.lean.
  - [ ] Create SymbolicLean/Session/State.lean.
  - [ ] Create SymbolicLean/Session/Monad.lean.
  - [ ] Create SymbolicLean/Term/Core.lean.
  - [ ] Create SymbolicLean/Term/Literals.lean.
  - [ ] Create SymbolicLean/Term/Arithmetic.lean.
  - [ ] Create SymbolicLean/Term/Logic.lean.
  - [ ] Create SymbolicLean/Term/Relations.lean.
  - [ ] Create SymbolicLean/Term/Calculus.lean.
  - [ ] Create SymbolicLean/Term/Application.lean.
  - [ ] Create SymbolicLean/Backend/Protocol.lean.
  - [ ] Create SymbolicLean/Backend/Encode.lean.
  - [ ] Create SymbolicLean/Backend/Decode.lean.
  - [ ] Create SymbolicLean/Backend/Client.lean.
  - [ ] Create SymbolicLean/Ops/Core.lean.
  - [ ] Create SymbolicLean/Ops/Algebra.lean.
  - [ ] Create SymbolicLean/Ops/Calculus.lean.
  - [ ] Create SymbolicLean/Ops/LinearAlgebra.lean.
  - [ ] Create SymbolicLean/Ops/Solvers.lean.
  - [ ] Create SymbolicLean/Syntax/Term.lean.
  - [ ] Create SymbolicLean/Syntax/Binders.lean.
  - [ ] Create SymbolicLean/Syntax/Subst.lean.
  - [ ] Create SymbolicLean/Syntax/Command.lean.
  - [ ] Create SymbolicLean/Syntax/DeclareOp.lean.
  - [ ] Create SymbolicLean/Examples/Scalars.lean.
  - [ ] Create SymbolicLean/Examples/Matrices.lean.
  - [ ] Create SymbolicLean/Examples/Solvers.lean.
  - [ ] Create SymbolicLean/Examples/Negative.lean.
  - [ ] Create SymbolicLean/Examples.lean re-exporting the example modules.

  ## 3. Concrete Core Names And Types

  - [ ] In Sort/Ext.lean, define a concrete project extension enum SymExt with grouped constructors for at least geometry, combinatorics, stats, physics, indexedTensor,
    codegen, numberTheory, and other Name.
  - [ ] In Sort/Base.lean, define inductive SymSort (ext : Type) and export abbrev SSort := SymSort SymExt.
  - [ ] In Domain/Desc.lean, define GroundDom, PolyPresentation, AlgRelation, IdealRelation, and recursive DomainDesc.
  - [ ] In Sort/Relations.lean, define Truth and RelKind.
  - [ ] Use List, not Array, in recursive sort positions.
  - [ ] Add manual DecidableEq/BEq/Hashable implementations anywhere deriving fails.

  ## 4. Runtime And Session Layer

  - [ ] In SymExpr/Core.lean, define opaque SessionTok, structure Ref, and structure SymExpr (s : SessionTok) (σ : SSort).
  - [ ] In SymExpr/Refined.lean, define SymSymbol, SymFun, SymBool, and SymRel.
  - [ ] In Session/Errors.lean, define typed backend, decode, and user-surface errors.
  - [ ] In Session/State.lean, define handle tables, symbol assumptions metadata, caches, and dynamic shape metadata.
  - [ ] In Session/Monad.lean, define SymPyM := ReaderT SessionEnv (StateT SessionState (ExceptT SymPyError IO)) and withSession : SessionConfig -> (∀ s, SymPyM s α) -> IO
    (Except SymPyError α).
  - [ ] Ensure handles cannot escape sessions at the type level.

  ## 5. Algebraic Bridge

  - [ ] In Domain/Classes.lean, define DomainCarrier, InterpretsDomain, and UnifyDomain.
  - [ ] Add instances for ZZ, QQ, RR, CC, gaussianZZ, GF p.
  - [ ] Add recursive propagation instances for polyRing, fracField, algExt, and quotient.
  - [ ] Add explicit tests that ZZ + QQ -> QQ and same-domain arithmetic uses reflexive UnifyDomain.

  ## 6. Pure Term Layer

  - [ ] In Term/Core.lean, define inductive Term (s : SessionTok) : SSort -> Type.
  - [ ] Keep v1 constructors limited to: atom, scalar literals, add/sub/mul/div/pow/neg, unary function application, boolean connectives, equality/order/membership,
    derivative, and common unevaluated calculus forms.
  - [ ] In Term/Arithmetic.lean, define CanAdd, CanMul, CanPow and standard operator instances on Term.
  - [ ] In Term/Logic.lean, define CanLogic.
  - [ ] In Term/Relations.lean, define CanCompare.
  - [ ] In Term/Application.lean, support unary symbolic function application in syntax; provide explicit appN helpers for arity > 1.
  - [ ] Do not add monadic operator instances anywhere.

  ## 7. Backend Protocol

  - [ ] Implement tools/sympy_worker.py with JSON commands:
    ping, mk_symbol, mk_function, eval_term, apply_op, pretty, release.
  - [ ] In Backend/Protocol.lean, define the request/response schema matching those commands.
  - [ ] In Backend/Encode.lean, serialize Term to eval_term payloads.
  - [ ] In Backend/Decode.lean, decode structured result payloads for solver and other nontrivial APIs.
  - [ ] In Backend/Client.lean, implement worker lifecycle, request dispatch, and ref bookkeeping.
  - [ ] Keep eval : Term s σ -> SymPyM s (SymExpr s σ) trusted on sort preservation; reserve runtime decoding for structured outputs.

  ## 8. Core Operations

  - [ ] In Ops/Algebra.lean, implement simplify, factor, expand, cancel, and subs.
  - [ ] In Ops/Calculus.lean, implement diffExpr, integrate, limit, and minimal series support.
  - [ ] In Ops/LinearAlgebra.lean, implement det, inv, and rref.
  - [ ] In Ops/Solvers.lean, implement solveUnivariate, solveset, dsolve, satisfiable, and ask.
  - [ ] Define explicit structured result types: FiniteSolve, EvalOr, ODESolution, and SolveSetResult.
  - [ ] In Ops/Core.lean, define a tiny IntoSymExpr class with only SymExpr and Term instances, and use it only for selected front-door APIs:
    simplify, factor, expand, dsolve, solveset, satisfiable.

  ## 9. Syntax And Sugar

  - [ ] In Syntax/Term.lean, implement term![...] expanding only to Term constructors and helpers.
  - [ ] Scope of term! in v1: identifiers, numerals, unary minus, + - * / ^, unary application f(x), relations, boolean connectives, membership, and derivative syntax.
  - [ ] In Syntax/Binders.lean, implement symbols x y z and functions f g.
  - [ ] In Syntax/Binders.lean, add optional assumption syntax:
    symbols (x : positive) (y : real) z.
  - [ ] In Syntax/Subst.lean, implement substitution sugar:
    expr[x ↦ 2, y ↦ 3].
  - [ ] In Syntax/Command.lean, implement sympy d do ....
  - [ ] In Syntax/Command.lean, implement #sympy d ... with this exact v1 scope:
    scalar exploratory expressions only, auto-create free scalar symbols in domain d, no auto function or matrix creation.
  - [ ] Keep ∂ and ∫ notation out of v1 unless everything above lands cleanly and the files stay small.

  ## 10. Generated Operation Layer

  - [ ] In Syntax/DeclareOp.lean, implement declare_sympy_op.
  - [ ] Make it generate: typed wrapper, encoder, decoder hook, and docstring.
  - [ ] Support optional Term helpers only for expression-forming operations.
  - [ ] Migrate one algebra op, one linear-algebra op, and one solver op onto declare_sympy_op before calling the generator complete.

  ## 11. Examples And Negative Cases

  - [ ] In Examples/Solvers.lean, add dsolve, solveset, satisfiable, and ask examples.
    symbol.
  - [ ] Re-export them from Examples.lean.

  ## 12. Verification

  - [ ] Use Lean LSP diagnostics first on each file; source .agents/lean4-env.sh before helper-script usage.
  - [ ] Run lake build once imports stabilize.
  - [ ] Run python3 scripts/check_doc_harness.py --mode local --scope core.
  - [ ] Do one manual smoke pass with #sympy QQ simplify(x^2 + 2*x + 1) and at least one sympy QQ do ... example.
  - [ ] Do not close the task until code, mirrored docs, examples, and harness checks all pass together.

  ## Done Criteria

  - [ ] The codebase uses the planned small-file, self-documenting folder structure.
  - [ ] Every core module has a mirrored doc and the doc harness passes.
  - [ ] lake build passes.
  - [ ] The examples compile and show the intended UX.
  - [ ] User-facing symbolic expression construction is pure Term; backend communication is monadic SymPyM; no monadic arithmetic leaks into the surface API.