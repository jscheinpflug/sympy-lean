 What shipped

  Registry metadata enriched

  Registry.lean now has CallStyle (call/attr), PureSpec (args/result sorts), and backendPath on RegistryMetadata. This is the foundation for generic worker dispatch.

  Declaration macros — layered correctly

  - declare_pure_head — generic, explicit sorts. Used for complex signatures (re, im, conjugate, arg, Interval, Union, etc.)
  - declare_scalar_fn₁ / declare_scalar_fn₂ — sugar for the common case
  - register_op — metadata-only for hand-written ops (rref)

  The layering works: Sets.lean uses declare_pure_head with explicit sorts, SpecialFunctions.lean uses the scalar sugar, LinearAlgebra.lean uses register_op for rref.

  Special functions — 21 heads

  sin, cos, tan, asin, acos, atan, atan2, sinh, cosh, tanh, exp, log, sqrt, Abs, sign, floor, ceiling, re, im, conjugate, arg. All with sympy_alias generating SymPy.* names.

  Evaluation ops — doit, evalf, latex

  Clean declarations in Ops/Evaluation.lean. latex uses decodes String — the generic OpPayloadDecode path. Method generation in Ops/Core.lean gives .doit, .evalf 20, .latex on
   Term/SymExpr/SymDecl.

  Set constructors + S.* constants

  Interval, Union, Intersection, Complement with explicit sort schemas. S.Reals and S.Integers with call_style attr. Correctly uses declare_pure_head, not the scalar sugar.

  Solver UX

  solve as canonical alias for solveUnivariate. integrate as effectful counterpart. Both have method generation. solveUnivariate stays as compatibility.

  rref registered

  LinearAlgebra.lean:66: register_op rrefExpr => "rref". The hand-written body stays, but #sympy_hover rref now works.

  Worker generalized

  eval_pure_head (worker line 567-579): after exhausting the hard-coded core heads, falls through to resolve_backend_path + call_style dispatch. This is the generic path that
  makes all declare_pure_head and declare_scalar_fn₁ functions work without Python changes. callStyle.attr returns the resolved object directly (for S.Reals, S.Integers).
  callStyle.call calls it with args (for sin, cos, Interval, etc.).

  Reification (worker line 486-492): lookup_scalar_call_head finds registered scalar call-heads by SymPy class name and reifies them generically. This covers sin, cos, exp,
  etc. without per-function reification code.

  Proofs module

  Examples/Proofs.lean — kernel-level rfl proofs that SymPy.Derivative = diff, SymPy.Integral = Integral, etc. Good: proves the aliases are definitionally equal, not just
  wrappers.

  Examples comprehensive

  - SpecialFunctions.lean — pure construction, effectful simplification, reification round-trips for unary and binary heads
  - Evaluation.lean — doit, evalf, latex, integrate, hover/search verification
  - Solvers.lean — solve, solveset, dsolve, sets, intervals, S.Reals, assumption scoping

  ---
  Issues

  1. Special function examples need excessive type ascriptions

  Examples/SpecialFunctions.lean:10:
  SymPy.sin (x : Term (Scalar Rat)) + SymPy.cos (x : Term (Scalar Rat))

  and line 14:
  SymPy.sqrt ((x : Term (Scalar Rat)) + (1 : Term (Scalar Rat)))

  Every use of a special function on a SymDecl requires (x : Term (Scalar Rat)) ascription. This is because sin takes Term (.scalar d), not SymDecl (.scalar d), and the
  coercion from SymDecl to Term doesn't fire inside the function argument without a type hint.

  The #eval blocks (lines 45-56) show the same pattern. Compare to the goal from our earlier discussion:
  -- what we wanted:
  sin (x ^ 2) + exp x
  -- what we have:
  SymPy.sin (x : Term (Scalar Rat)) + SymPy.exp (x : Term (Scalar Rat))

  This is the same coercion issue that plagued the pre-refactor Piecewise. The declare_scalar_fn₁ macro generates def sin (arg : Term (.scalar d)) : Term (.scalar d), which
  requires the argument to already be Term. An overload taking SymDecl would fix it, or making declare_scalar_fn₁ generate both Term and SymDecl signatures.

  2. Set examples also need ascriptions

  Examples/Solvers.lean:7:
  SymPy.Interval (0 : Term (Scalar Rat)) x

  0 needs (0 : Term (Scalar Rat)) because Interval takes Term (.scalar d).

  3. Ops/Core.lean is now 407 lines with significant repetition

  The generate_sympy_alias block (lines 311-354) repeats the same pattern for every op — simplify, factor, expand, cancel, pretty, doit, latex, evalf, T, I, det. Each is ~3
  lines. This was flagged before and partially addressed with generate_term_symexpr_methods / generate_term_symexpr_symdecl_methods, but the generate_sympy_alias calls remain
  1-per-op. Not a bug, just growing linearly.

  4. Worker eval_pure_head still has 60 lines of hard-coded core heads

  Lines 512-566 are the same if-else chain for arithmetic, logic, relations, calculus. The generic backendPath dispatch (lines 567-579) only kicks in after these. This is
  correct — core heads need special Python behavior (operator dispatch, not function calls). But it means the plan's goal of "replace the current hard-coded worker bottleneck"
   is partially done: extension heads are generic, but core heads are still hard-coded. Fine for now.

  5. Recursion depth added — good

  Line 220: decode_value now takes depth parameter. Lines 508, 601: eval_pure_head and eval_term both check depth. This was a prior review item and it's fixed.

  ---
  What's clean

  - Set constructors use declare_pure_head with correct sort schemas. Interval takes (.scalar d, .scalar d) → .set (.scalar d), Union takes (.set (.scalar d), .set (.scalar
  d)) → .set (.scalar d). The generic mechanism handles both.
  - register_op for rref closes the registry gap without rewriting the implementation.
  - S.Reals and S.Integers use call_style attr — the worker resolves sp.S.Reals without calling it. Correct.
  - Proofs.lean confirms SymPy aliases are definitionally equal via rfl. This is a strong correctness guarantee.
  - Reification covers new heads generically via lookup_scalar_call_head. No per-function reification code for sin, cos, etc.
  - latex uses decodes String — the generic FromJson decode path, no custom decoder.

  Summary

  The plan was executed faithfully. Registry metadata, layered macros, generic worker dispatch, special functions, evaluation ops, set constructors, solver UX, and rref
  registration are all in place. The main remaining friction is the SymDecl → Term coercion not firing inside special function calls, causing verbose type ascriptions in
  examples. This is the same class of issue as before — not new, but more visible now that there are 21 more functions that take Term arguments.