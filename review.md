  Side-by-side: SymPy Python vs. sympy-lean

  Symbol declaration

  # Python
  x, y = symbols('x y')
  x = Symbol('x', positive=True)
  A = MatrixSymbol('A', 2, 2)
  f = Function('f')

  -- Lean
  symbols (x : Rat) (y : Rat)
  symbols (x : Rat | positive)
  symbols (A : Mat Rat 2 2)
  functions (f : Rat → Rat)

  Verdict: Good. Lean is comparable and adds type information. The binder syntax is clean. Lean wins on typed function declarations.

  Simple arithmetic

  # Python
  x**2 + 2*x*y + y**2

  -- Lean (with expected type)
  x + y                    -- works directly on SymDecl

  -- Lean (in #eval do block — current examples)
  let xTerm : Term (Scalar Rat) := x
  let yTerm : Term (Scalar Rat) := y
  xTerm ^ 2 + qq 2 * xTerm * yTerm + yTerm ^ 2

  Verdict: Mixed. The example form where expected type is available is clean — x + y just works. But in do blocks, users write let xTerm : Term ... := x on every symbol and qq
   2 for numeric literals. The qq is necessary because 2 alone gives Term (Scalar Int) not Term (Scalar Rat), and UnifyDomain can't unify them without help. This is the single
   biggest UX friction point.

  Factorization

  # Python
  factor(x**2 - 1)                    # returns (x-1)*(x+1)

  -- Lean
  let factored ← factor (xTerm ^ 2 - qq 1)
  prettyRemote factored.ref

  Verdict: Okay. The factor call is clean. prettyRemote factored.ref is noise — Python auto-displays results. But this is inherent to Lean being compiled, not interpreted.

  Calculus

  # Python
  diff(x**2, x)
  Derivative(x**2, x, 2)
  Integral(x**2, (x, 0, 1))

  -- Lean
  SymPy.Derivative (xTerm ^ 2) x                          -- clean
  SymPy.Derivative (xTerm ^ 2) x 2                        -- clean with default arg

  -- But with structured bounds:
  Integral (x : Term (Scalar Rat)) ((x, qq 0, qq 1) : BoundSpec (carrierDomain Rat))

  Verdict: Bad for Integral/Sum/Product. The SymPy.Derivative form is fine. But the BoundSpec type ascription is terrible. The coercions exist (Coe (BoundRange d) (BoundSpec
  d)) — so (x, qq 0, qq 1) should coerce automatically when the expected type is BoundSpec. The explicit (... : BoundSpec (carrierDomain Rat)) ascription in the examples
  suggests the coercion isn't triggering reliably, likely because the expected type doesn't propagate through the function call.

  Piecewise

  # Python
  Piecewise((x, x > 0), (0, True))

  -- Lean
  Piecewise (((x : Term (Scalar Rat)), gt (x : Term (Scalar Rat)) (qq 0)) : PieceBranch (Scalar Rat))
      (qq 0)

  Verdict: Unacceptable. This is ~3x the length of Python and requires three inline type ascriptions. The PieceBranch coercion from (Term σ × Term .boolean) exists, but
  doesn't fire because (a) x is a SymDecl, not Term, and (b) gt returns Term .boolean but the pair (x, gt x (qq 0)) has type SymDecl × Term .boolean, not Term σ × Term
  .boolean. The coercion chain is too long for Lean to infer.

  Matrix operations

  # Python
  A * v
  det(A)
  A.inv()
  A.T

  -- Lean
  A * v                                    -- dimension-checked!
  let determinant ← det matrix.expr
  let inverse ← A.I

  Verdict: Good. Dimension-checked multiplication is a genuine advantage. A.I is clean property notation. The det matrix.expr is slightly verbose (why .expr?) but reasonable.

  Solvers

  # Python
  solve(x**2 - 1, x)        # returns [-1, 1]
  dsolve(Eq(f(x).diff(x), f(x)), f(x))

  -- Lean
  let solved ← solveUnivariate (xTerm ^ 2 - qq 1) x
  match solved.solutions with
  | solution :: _ => prettyRemote solution.ref
  | [] => IO.println "[]"

  let ode : Term .boolean := eq_ (SymPy.Derivative (f x) x) (f x)
  let solved ← dsolve ode f
  prettyRemote solved.equation.ref

  Verdict: Acceptable. The solve call is clean. Result extraction is verbose but typed (you know you're getting a FiniteSolve with .solutions). The ODE example is reasonable.

  Assumptions

  # Python
  with assuming(Q.positive(x)):
      ask(Q.positive(x + 1))

  -- Lean
  assuming [x ↦ SymPy.Q.positive] do
    let answer ← x.ask SymPy.Q.positive

  Verdict: Good. Arguably better than Python's with syntax.

  Exploration

  # Python REPL
  >>> factor(x**2 - 1)
  (x - 1)*(x + 1)

  -- Lean
  #sympy Rat => x + y                     -- auto-creates symbols, evaluates, prints
  #sympy Rat => f x                       -- auto-detects f as function

  Verdict: Good for simple expressions. #sympy auto-binding is well-implemented. But it can only build and evaluate pure terms — for effectful ops like factor, you need the do
   form with full boilerplate.

  Negative examples (type errors)

  -- Dimension mismatch: compile-time error
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 3) := sym `v
  A * v    -- ERROR: failed to synthesize HMul

  -- Domain constraint: compile-time error
  inv matrix    -- ERROR: InterpretsField (carrierDomain Int) not found

  -- Old syntax rejected:
  term!    -- ERROR: Unknown identifier

  Verdict: Excellent. Compile-time dimension and domain checking is a major advantage over Python. The error messages are clear. term! is properly deleted.

  ---
  UX issues ranked by impact

  1. The let xTerm : Term (Scalar Rat) := x pattern (HIGH)

  Every #eval example requires manually coercing SymDecl to Term with a type annotation before using it in complex expressions. This shouldn't be necessary — the coercion
  SymDecl σ → Term σ exists and works in example contexts. The problem is that in do blocks, without an expected type on the binding site, Lean can't infer the coercion
  target.

  Root cause: symbols (x : Rat) creates x : SymDecl (Scalar Rat). When you write x ^ 2, Lean looks for HPow (SymDecl (Scalar Rat)) .... The HPow instance is on Term, not
  SymDecl. The coercion fires for + (binary, both sides give context) but not always for ^ (second arg is Nat, not symbolic).

  Fix: Add HPow/HMul/HAdd instances directly on SymDecl that coerce and delegate, or make symbols produce Term values directly instead of SymDecl.

  2. qq 2 for rational literals (HIGH)

  Python: 2*x. Lean: qq 2 * xTerm. The qq is needed because (2 : Nat) coerces to Term (Scalar Int) via OfNat, not Term (Scalar Rat). Since most work is over Rat, this is
  constant friction.

  Fix: Either (a) make OfNat produce terms in the "current default domain" set by sympy (carrierDomain Rat) do, or (b) add a UnifyDomain instance that unifies ZZ with QQ to QQ
   so 2 * x works when x : Term (Scalar Rat) (this might already exist — if so, the examples should use it instead of qq).

  3. Structured argument ascriptions (HIGH)

  Integral (x : Term (Scalar Rat)) ((x, qq 0, qq 1) : BoundSpec (carrierDomain Rat))

  The coercions from tuples to BoundSpec exist but don't fire because the expected type doesn't propagate into tuple position. Users shouldn't need to write : BoundSpec
  (carrierDomain Rat).

  Fix: Either (a) make Integral / integralWith take raw tuples with overloaded signatures, or (b) use Lean's @[coe] attribute on the coercions so they participate in
  unification, or (c) provide Integral(body, x, lo, hi) as a flat-argument alternative.

  4. Piecewise verbosity (MEDIUM)

  The Piecewise example is ~3x Python's length. This is a combination of issues 1 and 3: symbols need coercion, tuples need ascription.

  Fix: If issues 1 and 3 are fixed, Piecewise could look like:
  Piecewise (x, gt x (qq 0)) (qq 0)
  Still not Piecewise((x, x > 0), (0, True)) but much closer.

  5. sympy (carrierDomain Rat) do is verbose (LOW)

  carrierDomain Rat leaks internal machinery. Should be sympy Rat do.

  Fix: The sympy macro could accept a Type directly and insert carrierDomain itself.

  6. prettyRemote result.ref for display (LOW)

  Every example ends with prettyRemote result.ref. Could be show result or pretty result.

  Fix: Add a pretty : SymExpr s σ → SymPyM s String that wraps prettyRemote expr.ref. (The IntoSymExpr pattern could be extended to Showable.)

  ---
  Architecture assessment

  Extensibility for SymPy's full surface

  The headApp + ExtHeadSpec system is genuinely extensible. Adding a new SymPy function requires:
  1. declare_head or declare_op — one line
  2. The Python worker already handles it via manifest-driven dispatch

  This covers the ~90% of SymPy that's function-call shaped. The remaining patterns (method calls, properties, namespace constants) are handled via generate_term_method,
  generate_symexpr_method, generate_sympy_alias, generate_sympy_q_const, generate_sympy_s_const. This is a good taxonomy.

  What scales well

  - Adding new scalar/matrix operations: trivial, one declare_op
  - Adding new special functions (gamma, bessel, etc.): trivial, one declare_head
  - Adding new properties (.T, .I): straightforward, one generate_*_method
  - Adding new SymPy namespace constants (Q.positive, S.Reals): one generate_sympy_*_const

  What doesn't scale well

  - Structured arguments for each new construct. Every construct with tuple-structured args (Integral, Sum, Product, Piecewise, Lambda, Derivative) needs a custom struct
  (BoundSpec, DerivSpec, PieceBranch), custom coercions, and a custom smart constructor. This is ~20 lines per construct. Not terrible but not "one line in the registry."
  - The generate_ macros require one line per (type × method) combination.* simplify needs generate_term_method simplify, generate_symexpr_method simplify,
  generate_sympy_alias simplify — three declarations. For N operations across 3 receiver types, that's 3N lines. This could be reduced to N with a single macro that generates
  all three.

  Compile-time guarantees (advantage over Python)

  - Dimension-checked matrix multiplication
  - Domain-aware field operations (inv requires field, not just ring)
  - Symbol sort enforcement (can't pass Term where SymDecl expected)
  - Protocol version and manifest version checking

  These are genuine advantages that Python can't match.

  ---
  Summary

  ┌───────────────────────────┬───────┬───────────────────────────────────────────────────────────────┐
  │          Aspect           │ Grade │                             Notes                             │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Symbol declaration        │ A     │ Clean, typed, with assumptions                                │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Simple arithmetic         │ B-    │ Good with expected types, verbose without (let xTerm, qq)     │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Operators (+, *, ^)       │ A     │ Typeclass instances work well                                 │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Calculus (diff, integral) │ C+    │ Derivative is clean; Integral/Sum need type ascriptions       │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Piecewise/Lambda          │ D     │ Too many inline type ascriptions                              │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Solvers                   │ B+    │ Clean calls, verbose result extraction                        │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Matrix ops                │ A     │ Dimension checking is a real win                              │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Assumptions               │ A-    │ assuming blocks are clean                                     │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Exploration (#sympy)      │ B+    │ Good auto-binding; limited for effectful ops                  │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Error messages            │ A-    │ Dimension/domain errors are clear                             │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Extensibility             │ A-    │ Registry + manifest is well-designed                          │
  ├───────────────────────────┼───────┼───────────────────────────────────────────────────────────────┤
  │ Overall ergonomics        │ B-    │ Core patterns work; structured args and literal coercion hurt │
  └───────────────────────────┴───────┴───────────────────────────────────────────────────────────────┘

  The architecture is solid and extensible. The main UX gap is at the coercion layer: SymDecl → Term coercion and tuple → structured arg coercion don't fire reliably in do    
  blocks, forcing verbose manual annotations. Fixing those coercion chains would move the overall grade from B- to A-.