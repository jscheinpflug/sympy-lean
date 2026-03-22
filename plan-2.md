 Plan: Infrastructure, UX, and First Coverage Wave      

 Context

 sympy-lean has ~55 registered entries covering ~10% of SymPy. The architecture
 (typed heads, registry, manifest dispatch) is sound. Before scaling to full
 coverage, we need infrastructure that makes adding functions cheap, registry
 cleanup that closes gaps in the existing surface, and then an immediate first
 wave of coverage to prove the infra works.

 ---
 Phase 1: Bulk scalar head registration macro

 Scope

 Pure unary and binary scalar→scalar functions only. This covers ~40 of SymPy's
 most common functions (trig, exp/log, rounding, complex parts). Does NOT cover
 effectful ops, custom result decoders, structured-arg constructs, or
 worker-special-cases — those stay as declare_op/declare_head with
 explicit schemas.

 Design

 New macros in SymbolicLean/Syntax/DeclareOp.lean:

 syntax "register_sympy_fn₁ " ident " => " str ((" doc " str)?) : command
 syntax "register_sympy_fn₂ " ident " => " str ((" doc " str)?) : command

 register_sympy_fn₁ sin => "sin" doc "Sine function." generates:
 1. A declare_head sinHead => "sin" doc "..." (registry + manifest entry)
 2. An ExtHeadSpec with schema [.scalar d] → .scalar d
 3. def sin (arg : Term (.scalar d)) : Term (.scalar d) := .headApp (.ext ...) (.singleton arg)
 4. def SymPy.sin := SymbolicLean.sin (namespace alias)

 register_sympy_fn₂ atan2 => "atan2" generates the same but for
 (Term (.scalar d), Term (.scalar d)) → Term (.scalar d).

 Python worker: no changes. Manifest dispatch already resolves any registered
 head via getattr(sp, backend_name)(*args).

 Files

 ┌────────────────────────────────────────────┬────────────────────────┐
 │                    File                    │         Change         │
 ├────────────────────────────────────────────┼────────────────────────┤
 │ SymbolicLean/Syntax/DeclareOp.lean         │ Add macros (~40 lines) │
 ├────────────────────────────────────────────┼────────────────────────┤
 │ docs/SymbolicLean/Syntax/DeclareOp.lean.md │ Update mirrored doc    │
 └────────────────────────────────────────────┴────────────────────────┘

 Verification

 register_sympy_fn₁ testSin => "sin"
 example : Term (Scalar Rat) := let x : SymDecl (Scalar Rat) := sym `x; testSin x
 lake build SymbolicLean
 python3 scripts/check_doc_harness.py --mode local --scope core

 ---
 Phase 2: Registry gap cleanup + doc quality

 Scope

 Ensure every public op is registry-backed so #sympy_hover and
 #sympy_search work for everything. Improve doc strings on the most
 confusing operations.

 What's missing from the registry

 rrefExpr (Ops/LinearAlgebra.lean:59) is hand-written — it calls
 applyOpRemote "rref" directly without going through declare_op, so it
 has no registry entry. #sympy_hover rref returns nothing.

 Audit all ops for the same pattern: any function that calls applyOpRemote
 or applyOpRemoteRef directly without a declare_op is a registry gap.

 Fix

 - Convert rrefExpr to use a declare_op variant that supports custom
 decoding (the decodes form already exists — see Solvers.lean:90).
 Or: keep the hand-written impl but add a manual addRegistryEntry call
 so the registry knows about it.
 - Audit subsExprJson (Algebra.lean:35) — same pattern, calls
 applyOpRemoteRef via a declare_op variant that already registers.
 Verify it appears in #sympy_hover subs.

 Doc string improvements

 Update doc strings on:
 - inv — "Requires a field domain (Rat, Real, Complex). Does not work on Int."
 - det — "Requires a commutative ring domain."
 - rref — "Requires a field domain. Returns reduced matrix and pivot columns."
 - dsolve — "Expects a boolean equation (use eq_). Returns an ODESolution."
 - solveset — "Returns a set expression. Use S.Reals or similar to inspect."

 Files

 ┌─────────────────────────────────────┬───────────────────────────────────────┐
 │                File                 │                Change                 │
 ├─────────────────────────────────────┼───────────────────────────────────────┤
 │ SymbolicLean/Ops/LinearAlgebra.lean │ Register rrefExpr, update docs        │
 ├─────────────────────────────────────┼───────────────────────────────────────┤
 │ SymbolicLean/Ops/Algebra.lean       │ Verify subs registration, update docs │
 ├─────────────────────────────────────┼───────────────────────────────────────┤
 │ SymbolicLean/Ops/Solvers.lean       │ Update docs                           │
 ├─────────────────────────────────────┼───────────────────────────────────────┤
 │ SymbolicLean/Ops/Calculus.lean      │ Update docs                           │
 ├─────────────────────────────────────┼───────────────────────────────────────┤
 │ docs/SymbolicLean/Ops/*.lean.md     │ Update mirrored docs                  │
 └─────────────────────────────────────┴───────────────────────────────────────┘

 Verification

 #sympy_hover rref   -- should show doc string
 #sympy_hover inv    -- should mention field requirement
 #sympy_search "determinant"  -- should find det
 lake build SymbolicLean
 python3 scripts/check_doc_harness.py --mode local --scope core

 ---
 Phase 3: Special functions (first coverage wave)

 Scope

 Register the ~25 most common SymPy functions using the Phase 1 macro.
 These are the functions that appear in nearly every SymPy tutorial.

 Content

 New file SymbolicLean/Term/SpecialFunctions.lean:

 -- Trigonometric
 register_sympy_fn₁ sin  => "sin"  doc "Sine."
 register_sympy_fn₁ cos  => "cos"  doc "Cosine."
 register_sympy_fn₁ tan  => "tan"  doc "Tangent."
 register_sympy_fn₁ asin => "asin" doc "Inverse sine."
 register_sympy_fn₁ acos => "acos" doc "Inverse cosine."
 register_sympy_fn₁ atan => "atan" doc "Inverse tangent."
 register_sympy_fn₂ atan2 => "atan2" doc "Two-argument arctangent."

 -- Hyperbolic
 register_sympy_fn₁ sinh => "sinh" doc "Hyperbolic sine."
 register_sympy_fn₁ cosh => "cosh" doc "Hyperbolic cosine."
 register_sympy_fn₁ tanh => "tanh" doc "Hyperbolic tangent."

 -- Exponential / logarithmic
 register_sympy_fn₁ exp  => "exp"  doc "Exponential function."
 register_sympy_fn₁ log  => "log"  doc "Natural logarithm."
 register_sympy_fn₁ sqrt => "sqrt" doc "Square root."

 -- Rounding / sign
 register_sympy_fn₁ Abs     => "Abs"     doc "Absolute value."
 register_sympy_fn₁ sign    => "sign"    doc "Sign function."
 register_sympy_fn₁ floor   => "floor"   doc "Floor function."
 register_sympy_fn₁ ceiling => "ceiling" doc "Ceiling function."

 -- Complex
 register_sympy_fn₁ re_       => "re"        doc "Real part."
 register_sympy_fn₁ im_       => "im"        doc "Imaginary part."
 register_sympy_fn₁ conjugate => "conjugate" doc "Complex conjugate."
 register_sympy_fn₁ arg_      => "arg"       doc "Complex argument."

 -- Min / Max
 register_sympy_fn₂ Max => "Max" doc "Symbolic maximum."
 register_sympy_fn₂ Min => "Min" doc "Symbolic minimum."

 Python: no changes. Manifest dispatch handles all of these.

 Files

 ┌─────────────────────────────────────────────────┬──────────────────┐
 │                      File                       │      Change      │
 ├─────────────────────────────────────────────────┼──────────────────┤
 │ SymbolicLean/Term/SpecialFunctions.lean         │ New (~25 lines)  │
 ├─────────────────────────────────────────────────┼──────────────────┤
 │ SymbolicLean.lean                               │ Add import       │
 ├─────────────────────────────────────────────────┼──────────────────┤
 │ docs/SymbolicLean/Term/SpecialFunctions.lean.md │ New mirrored doc │
 └─────────────────────────────────────────────────┴──────────────────┘

 Verification

 example : Term (Scalar Rat) :=
   let x : SymDecl (Scalar Rat) := sym `x
   sin (x ^ 2) + exp x

 #sympy Rat => sin x + cos x

 #eval do
   let result ← sympy Rat do
     symbols (x : Rat)
     let simplified ← simplify (sin x ^ 2 + cos x ^ 2)
     pretty simplified
   match result with
   | .ok text => IO.println text   -- should print: 1
   | .error err => IO.println (repr err)
 lake build SymbolicLean
 lake build SymbolicLean.Examples
 python3 scripts/check_doc_harness.py --mode local --scope core

 ---
 Phase 4: doit, evalf, latex

 Scope

 Three high-value effectful ops that unblock evaluation and rendering.

 Design

 New file SymbolicLean/Ops/Evaluation.lean:

 declare_op doitExpr => "doit"
   doc "Force evaluation of unevaluated objects (Integral, Sum, etc.)."

 declare_op evalfExprCore for (expr : SymExpr s σ) (precision : Nat) returns σ => "evalf"
   doc "Numerical evaluation to given decimal precision."

 declare_op latexExprCore => "latex"
   doc "Render expression as LaTeX string."

 For evalf, need a wrapper with default precision:
 def evalf [IntoSymExpr s α σ] (expr : α) (precision : Nat := 15) :
     SymPyM s (SymExpr s σ) := do
   evalfExprCore (← IntoSymExpr.intoSymExpr expr) precision

 For latex, the result is a string. Need a declare_op variant that returns
 string, or use decodes String form:
 declare_op latexExpr for (expr : SymExpr s σ) decodes String => "latex"
   doc "Render a realized expression as a LaTeX string."

 Public wrappers + method generation in Ops/Core.lean:
 def doit [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := ...
 def latex [IntoSymExpr s α σ] (expr : α) : SymPyM s String := ...

 generate_term_symexpr_methods doit ...
 generate_term_symexpr_methods evalf ...
 generate_term_symexpr_methods latex ...
 generate_sympy_alias doit ...
 generate_sympy_alias evalf ...
 generate_sympy_alias latex ...

 Python worker: evalf needs the precision arg passed through. The existing
 apply_op dispatch handles extra args, but verify evalf(50) translates
 correctly to target.evalf(50) via target_method dispatch.

 latex returns a string, not a ref. The apply_op code path already
 handles this: if the result is not sp.Basic, it returns "json" with
 the encoded value. But latex() returns a Python str, which encodes
 as {"value": "..."}. Need to verify the Lean decode path handles string
 payloads.

 Files

 ┌──────────────────────────────────────────┬───────────────────────────────────────────────────┐
 │                   File                   │                      Change                       │
 ├──────────────────────────────────────────┼───────────────────────────────────────────────────┤
 │ SymbolicLean/Ops/Evaluation.lean         │ New (~30 lines)                                   │
 ├──────────────────────────────────────────┼───────────────────────────────────────────────────┤
 │ SymbolicLean/Ops/Core.lean               │ Add public wrappers + method gen (~30 lines)      │
 ├──────────────────────────────────────────┼───────────────────────────────────────────────────┤
 │ SymbolicLean.lean                        │ Add import                                        │
 ├──────────────────────────────────────────┼───────────────────────────────────────────────────┤
 │ docs/SymbolicLean/Ops/Evaluation.lean.md │ New mirrored doc                                  │
 ├──────────────────────────────────────────┼───────────────────────────────────────────────────┤
 │ tools/sympy_worker.py                    │ Verify evalf/latex dispatch (may need no changes) │
 └──────────────────────────────────────────┴───────────────────────────────────────────────────┘

 Verification

 #eval do
   let result ← sympy Rat do
     symbols (x : Rat)
     let integral := SymPy.Integral (exp (-x ^ 2)) (x, 0, 1)
     let evaluated ← doit integral
     pretty evaluated
   match result with
   | .ok text => IO.println text
   | .error err => IO.println (repr err)

 #eval do
   let result ← sympy Rat do
     symbols (x : Rat)
     latex (sin x ^ 2 + cos x ^ 2)
   match result with
   | .ok text => IO.println text   -- \sin^{2}{\left(x \right)} + ...
   | .error err => IO.println (repr err)
 lake build SymbolicLean
 lake build SymbolicLean.Examples
 python3 scripts/check_doc_harness.py --mode local --scope core

 ---
 Phase 5: Set constructors + S.* constants

 Scope

 Make set algebra work. Make solveset results inspectable.

 Design

 New file SymbolicLean/Term/Sets.lean.

 Set constructors as extension heads. Most are binary (two-set ops):
 register_sympy_fn₂ Union        => "Union"        doc "Set union."
 register_sympy_fn₂ Intersection => "Intersection" doc "Set intersection."
 register_sympy_fn₂ Complement   => "Complement"   doc "Set complement."
 register_sympy_fn₂ Interval     => "Interval"     doc "Closed interval [a,b]."
 register_sympy_fn₂ ProductSet   => "ProductSet"    doc "Cartesian product of sets."

 Note: these need sort (.set σ) not (.scalar d) in their schema. The
 register_sympy_fn₂ macro generates (.scalar d, .scalar d) → .scalar d.
 Sets need a different schema: (.set σ, .set σ) → .set σ or
 (.scalar d, .scalar d) → .set (.scalar d)) for Interval.

 This means register_sympy_fn₂ is insufficient. Need either:
 - A more general register_sympy_head with explicit sort schema
 - Or hand-written declare_head + smart constructor for set ops

 The pragmatic approach: hand-write these ~10 set heads. They have
 non-uniform schemas (Interval takes two scalars, returns a set; Union takes
 two sets, returns a set; FiniteSet is variadic). A generic macro doesn't
 help here.

 -- Interval: scalar × scalar → set scalar
 def Interval (a b : Term (.scalar d)) : Term (.set (.scalar d)) :=
   .headApp (.ext ⟨`Interval⟩) (.pair a b)

 -- Union: set × set → set
 def Union (a b : Term (.set σ)) : Term (.set σ) :=
   .headApp (.ext ⟨`Union⟩) (.pair a b)

 S.* constants — these are nullary heads (zero args):
 def SymPy.S.Reals : Term (.set (Scalar Real)) :=
   .headApp (.ext ⟨`S.Reals⟩) .nil

 def SymPy.S.Integers : Term (.set (Scalar Int)) :=
   .headApp (.ext ⟨`S.Integers⟩) .nil

 -- etc.

 Python worker: getattr(sp, "Interval")(*args) works for Interval.
 For S.Reals, need to handle as sp.S.Reals — a singleton, not a call.
 The worker's eval_pure_head will need a special case for nullary S.*
 heads: getattr(sp.S, name) rather than getattr(sp, name)().

 Files

 ┌──────────────────────────────────────┬───────────────────────────────────────────┐
 │                 File                 │                  Change                   │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ SymbolicLean/Term/Sets.lean          │ New (~60 lines)                           │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ SymbolicLean/Term/RegistryHeads.lean │ Add set head declarations                 │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ SymbolicLean/Ops/Core.lean           │ Add SymPy.S.* constants                   │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ SymbolicLean.lean                    │ Add import                                │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ docs/SymbolicLean/Term/Sets.lean.md  │ New mirrored doc                          │
 ├──────────────────────────────────────┼───────────────────────────────────────────┤
 │ tools/sympy_worker.py                │ Handle S.* singleton dispatch (~10 lines) │
 └──────────────────────────────────────┴───────────────────────────────────────────┘

 Verification

 example : Term (.set (Scalar Rat)) :=
   let x : SymDecl (Scalar Rat) := sym `x
   Interval 0 1

 #eval do
   let result ← sympy Rat do
     symbols (x : Rat)
     let solved ← solveset (sin x) x
     pretty solved.setExpr
   match result with
   | .ok text => IO.println text
   | .error err => IO.println (repr err)
 lake build SymbolicLean
 lake build SymbolicLean.Examples
 python3 scripts/check_doc_harness.py --mode local --scope core

 ---
 Phase 6 (deferred): Collapse hybrid Term type

 This is a valuable architectural cleanup but not a prerequisite for anything
 above. The CoreView layer already insulates downstream code. Defer to a
 separate PR after phases 1-5 land.

 When executed:
 - Remove 20 constructors from Term, leaving 6
 - Smart constructors build headApp instead of dedicated constructors
 - Simplify Encode.lean, Decode.lean, Canon.lean, View.lean
 - All existing user code continues to work (uses smart constructors)
 - Must include full mirrored-doc updates

 ---
 Sequencing

 Phase 1 (bulk macro)          ─┐
 Phase 2 (registry gaps/docs)  ─┼─ can run in parallel
                                 │
 Phase 3 (special functions)   ─── depends on Phase 1
 Phase 4 (doit/evalf/latex)    ─── independent
 Phase 5 (sets)                ─── independent
 Phase 6 (Term collapse)       ─── deferred, independent

 After this plan

 Coverage goes from ~55 → ~100 registered entries. The bulk macro makes
 the next ~200 pure scalar functions mechanical (one line each). Effectful
 ops and custom result types remain manual but are a smaller population
 (~80 total across all of SymPy).

 All phases include mirrored-doc updates and doc-harness validation:
 lake build SymbolicLean
 lake build SymbolicLean.Examples
 python3 scripts/check_doc_harness.py --mode local --scope core