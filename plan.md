 # SymbolicLean Implementation Plan Aligned With The Repo Harness

  ## Summary

  - Implement SymbolicLean with a two-level typed architecture:
    Term s σ for pure typed expression construction and Expr s σ for opaque session-scoped SymPy handles.
  - Keep SymPy communication monadic in SymPyM; keep expression building pure.
  - Treat the repo harness as part of the implementation contract:
    /docs is canonical project knowledge, mirrored docs are required for core modules, and long-running plans must stay discoverable from docs/plans/index.md.
  - Keep mathlib as the algebraic backbone and use the local Lean 4 workflow contract for all .lean work.

  ## Harness Alignment

  - Keep AGENTS.md index-only. Put implementation-facing project knowledge in /docs, not back into AGENTS.md.
  - Preserve the current high-level exploration in plan.md, but add a concrete implementation artifact under docs/plans/ and link it from docs/plans/index.md.
  - For every new core module under SymbolicLean/**, create the mirrored doc docs/<same path>.md in the same change set.
  - Every mirrored doc must include exactly these level-2 sections:
    ## Source, ## Responsibilities, ## Public Surface, ## Change Triggers, ## Related Files.
  - Keep module responsibilities narrow so the mirrored docs stay small and localizable.
  - Run the doc harness checker as part of implementation verification:
    python3 scripts/check_doc_harness.py --mode local --scope core.
  - Follow the repo Lean workflow contract:
    use the local Lean 4 skill for .lean work, and source .agents/lean4-env.sh before any helper-script usage.

  ## Human Digest

  - The earlier monadic-operator design was too awkward because it treated x + y like an RPC. That mixed “describe an expression” with “ask SymPy to compute”.
  - The final design separates those concerns:
    Term is pure data for symbolic expressions, Expr is a live backend object, and eval is the explicit boundary between them.
  - This maps well to how people actually use a CAS:
    blackboard expressions are built locally, while expensive transforms, solving, simplification, and matrix algorithms are effectful backend calls.
  - The type system still carries the important invariants:
    domain information, matrix dimensions, function arity, relation argument sorts, session scope, and typed solver result shapes.
  - We trust SymPy for semantic correctness of computations, but Lean prevents illegal constructions and illegal API calls.
  - Example:
    term![x^2 + 2*x + 1] builds a Term s (.scalar QQ);
    eval turns it into Expr s (.scalar QQ);
    factor runs in SymPyM and returns another Expr s (.scalar QQ).
  - Example:
    term![A * v] typechecks only when matrix dimensions line up.
    det only accepts square matrices with statically equal dimensions.
  - Example:
    let ode := term![diff (f x) x - f x = 0]
    let sol ← dsolve ode f
    where the front-door overload for dsolve accepts a Term and evaluates it internally, while the core implementation remains Expr-based.

  ## Core Design

  - Define recursive domain descriptors:
    GroundDom, DomainDesc := ground | polyRing | fracField | algExt | quotient.
  - Define recursive semantic sorts:
    SymSort ext := boolean | scalar d | matrix d m n | tensor d dims | set σ | tuple (List σ) | seq σ | map κ ν | fn (List σ) τ | relation rel (List σ) | ext ext.
  - Use List, not Array, in recursive sort positions to avoid Lean unifier and deriving problems.
  - Define runtime values as Expr s σ with SessionTok-scoped opaque refs.
  - Replace the earlier global FormTag index with small refinement wrappers only where static refinement matters:
    Symbol, FunSym, BoolExpr, RelExpr.
  - Keep assumptions in session metadata rather than type indices, and expose them via typed APIs like ask.
  - Define DomainCarrier, InterpretsDomain, and UnifyDomain so algebraic capabilities and mixed-domain arithmetic are encoded in types.

  ## Term And Expr Layers

  - Keep Term s σ intentionally small and expression-oriented:
    literals, atoms, arithmetic, negation, powers, function application, boolean connectives, equality/order/membership relations, derivatives, and the common unevaluated
    calculus forms.
  - Keep operator overloading only on Term; do not overload arithmetic directly on Expr.
  - Keep all SymPy communication in:
    SymPyM s := ReaderT SessionEnv (StateT SessionState (ExceptT SymPyError IO)).
  - Use withSession : SessionConfig → (∀ s, SymPyM s α) → IO (Except SymPyError α) so backend handles cannot escape their session.
  - Make eval : Term s σ → SymPyM s (Expr s σ) the main pure-to-effectful boundary.
  - Keep transforms and queries at the Expr level:
    simplify, factor, expand, cancel, det, inv, rref, eigenvals, solveset, solveUnivariate, dsolve, satisfiable, ask.
  - Decode nontrivial runtime results into explicit Lean result types such as FiniteSolve, EvalOr, ODESolution, SolveSetResult, and matrix decomposition result records.
  - Add thin user-facing overloads for selected high-frequency front doors so they accept either Term or Expr:
    simplify, factor, expand, dsolve, solveset, satisfiable.
    Keep the core implementations Expr-based; the overload layer is convenience only.

  ## Metaprogramming Layer

  - Add term![...] as the main expression quoter.
      - It expands only to Term constructors and helpers.
      - It must stay sort-agnostic; no scalar-only hardcoding.
  - Add sympy d do ... as a convenience elaborator:
      - opens withSession,
      - installs a default scalar domain,
      - brings smart constructors into scope.
  - Add smart constructors:
      - symbol, matrixSym, tensorSym, setSym,
      - function1, function2, predicateSym,
      - zero, one, numeric literal helpers,
      - mkEq, mkMem, mkBool, mkRel.
  - Add batch binders:
      - symbols x y z
      - functions f g
      - optional assumption-bearing forms like symbols (x : positive) (y : real) z
        These expand to repeated typed binder creation in the surrounding sympy ... do block.
  - Add substitution notation:
      - expr[x ↦ 2, y ↦ 3]
        lowering to the ordinary typed substitution API.
  - Add #sympy d <expr-or-call> as an exploratory command:
      - spins up a temporary session,
      - installs default domain d,
      - auto-creates free scalar symbols for simple exploratory inputs,
      - evaluates and pretty-prints results with logInfo,
      - is documented as a REPL-like exploration tool, not production API.
  - Implement declare_sympy_op as the scaling mechanism:
      - generate typed Expr-level wrapper,
      - request encoder,
      - response decoder,
      - docs,
      - optional Term helper when the operation is expression-forming rather than query/transform.
  - Keep the metaprogramming thin. The semantic source of truth is the typed core, not the macro layer.
  - Defer richer scoped calculus notation like ∂/∫ until after term!, symbols, substitution sugar, and #sympy are stable.

  ## Backend Contract And Trust Boundary

  - Use a persistent Python worker over JSON as the first transport.
  - eval serializes a well-typed Term into one backend expression build/evaluation request.
  - For eval, do not require heavy post-hoc sort validation; the emitted term is typed by construction.
  - For nontrivial result APIs, decode and validate runtime structure as needed:
    solver result cases,
    dynamic dimensions,
    optional/partial outcomes,
    extension-family tags.
  - Do not attempt proof-producing SymPy integration in v1.
  - Keep the design compatible with future proof bridges by making export/import codecs explicit.

  ## Module And Doc Layout

  - Split the implementation into focused modules under SymbolicLean/ such as:
    Core, Domain, Sort, Expr, Term, Session, Backend, Syntax/Term, Syntax/Binders, Syntax/Subst, Syntax/Command, Ops.
  - For every new module, add the mirrored doc under docs/SymbolicLean/...lean.md with the required sections from the harness.
  - Keep the root library module re-exporting the intended public surface and keep its mirrored doc current.
  - Keep the docs discoverable from docs/index.md and keep the concrete implementation plan discoverable from docs/plans/index.md.

  ## Verification

  - Follow the Lean workflow contract:
    source .agents/lean4-env.sh before helper scripts and use the local Lean 4 skill for Lean search, diagnostics, and build workflows.
  - Use the normal verification ladder during implementation:
    file diagnostics first, file-level Lean checks next, full lake build only at checkpoints and final integration gates.
  - Add tests for:
    matrix dimension rejection,
    field-only operations like inv,
    mixed-domain arithmetic through UnifyDomain,
    batch binder sugar,
    substitution notation,
    #sympy exploratory command behavior,
    structured decoding for solver results.
  - Run the doc harness checker whenever new core modules or mirrored docs are added or moved.

  ## Assumptions And Defaults

  - mathlib is a required dependency.
  - The initial backend is a persistent JSON worker around SymPy.
  - Term is intentionally a common expression fragment, not a full mirror of all SymPy APIs.
  - Specialized SymPy families are covered by SymSort ext and typed Expr-level APIs, not by endlessly growing the Term AST.
  - Manual equality/hash instances for recursive core datatypes are acceptable if Lean deriving is unreliable.
  - Unary symbolic-function application gets the ergonomic path first; higher arities use explicit helpers unless a clean general encoding proves stable.
  - Sugar is allowed only when it lowers directly to the typed core and remains documented as part of the public syntax surface.