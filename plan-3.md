# Production UX and Extensibility Backbone

  ## Summary

  - Make the registry and manifest the single source of truth for extension, dispatch, reification, hover/search, and generated public surface.
  - Remove the current hard-coded worker bottlenecks so adding most new SymPy pure functions becomes declarative instead of multi-file manual work.
  - Raise the public UX to production quality by standardizing naming toward SymPy, closing current registry/documentation gaps, and adding the missing high-value effectful
    front doors.
  - Land one immediate coverage wave for scalar special functions, then a small solver/set wave that makes solveset workflows usable instead of just pretty-printable.
  - Explicitly defer the Term constructor collapse; it is not required for this slice.

  ## Public Interfaces

  - Extend RegistryMetadata with a pure-head spec field that records argument sorts and result sort, plus backend dispatch metadata:
      - backendPath : List String
      - callStyle : call | attr
      - pureSpec? : Option { args : List SSort, result : SSort }
  - Add a metadata-only effectful registration command for hand-written ops:
      - register_op ... => ...
  - Add a generic pure-head declaration command that generates the typed helper plus registry entry:
      - declare_pure_head ...
  - Add scalar sugar on top of that generic command:
      - declare_scalar_fn₁
      - declare_scalar_fn₂
  - Add canonical public front doors:
      - solve
      - integrate
      - doit
      - evalf
      - latex
  - Keep existing wrappers such as solveUnivariate as compatibility aliases in this slice unless they actively block consistency.
  - Add public solver/set constants:
      - SymPy.S.Reals
      - SymPy.S.Integers

  ## Key Changes

  - Registry-first extension model
      - Refactor the declaration machinery so registry registration is a first-class primitive, not just a side effect of declare_op.
      - Make every public head and every public effectful op registry-backed.
      - Replace the current rref metadata gap with a proper register_op path instead of a hand-written unregistered exception.
      - Keep hover/search output driven entirely from registry metadata, including docs, aliases, categories, and error templates.
  - Generic pure-head declaration pipeline
      - Implement declare_pure_head in the syntax/registry layer, not as ad hoc code in term modules.
      - declare_pure_head must generate:
          - the registry entry
          - the typed ExtHeadSpec
          - the Lean term helper
          - the optional SymPy.* alias when requested
      - Build declare_scalar_fn₁ and declare_scalar_fn₂ as thin sugar on top of declare_pure_head.
      - Keep the existing core arithmetic/logic/calculus constructors unchanged; this slice only generalizes extension heads.
  - Worker eval and reify generalization
      - Replace the current hard-coded “unsupported manifest-dispatched pure head” fallback with registry-driven evaluation in tools/sympy_worker.py.
      - Evaluation rules:
          - callStyle.call: resolve backendPath and call the target with evaluated args
          - callStyle.attr: resolve the attribute object directly with no call
      - Reification rules in this slice:
          - required: registered unary/binary scalar call-heads
          - required: public nullary attribute constants used by solver UX
          - out of scope: broad variadic/set/tensor reification beyond the explicitly added public surface
      - Preserve the existing special cases for core heads and structured calculus heads where custom behavior already exists.
  - Effectful op framework
      - Add a generic OpPayloadDecode fallback for any [FromJson α].
      - Add explicit decode instances only when FromJson is insufficient.
      - Use that path to support latex as a string-returning op without bespoke command syntax.
      - Keep custom hand-written bodies only for truly structured results such as rref, but require them to register metadata through register_op.
  - Production UX cleanup
      - Canonical docs and examples should prefer SymPy-aligned public names.
      - Add solve as the documented public name for the current finite univariate solve surface, with docs stating the current scope explicitly.
      - Add integrate as the effectful counterpart to pure Integral.
      - Add doit, evalf, and latex to the public front door and SymPy namespace.
      - Keep current wrapper shapes unless changing them is necessary for SymPy naming parity or typing; prefer aliases and documentation canon over broad signature
        reshaping.
      - Update hover/search docs so operations such as inv, det, rref, solve, solveset, integrate, and latex explain domain requirements and result shape.
  - First coverage wave: scalar special functions
      - Add a dedicated pure-head module for special functions and use it as the reference implementation pattern.
      - Include:
          - sin, cos, tan
          - asin, acos, atan, atan2
          - sinh, cosh, tanh
          - exp, log, sqrt
          - Abs, sign, floor, ceiling
          - re, im, conjugate, arg
      - Do not add variadic names such as Max, Min, or FiniteSet in this slice; they need a variadic schema story and should not be misrepresented by fixed-arity wrappers.
  - Solver/set UX follow-up
      - Add the minimal set vocabulary needed for actual solveset workflows using the same registry-driven pure-head machinery:
          - Interval
          - Union
          - Intersection
          - Complement
          - SymPy.S.Reals
          - SymPy.S.Integers
      - Make solveset examples show both pretty solved.setExpr and usage of the new pure set constants.
      - Treat broader set algebra and variadic set constructors as the next wave, not this slice.
  - Docs and examples
      - Every touched SymbolicLean/** file must land with its mirrored /docs update in the same change set.
      - Refresh README and the project guide so the documented canonical surface is:
          - SymPy-like in naming
          - valid Lean syntax
          - explicit about pure constructors vs effectful ops
      - Add one dedicated example module for special functions and one for eval/render ops if the existing files become too noisy.

  ## Test Plan

  - lake build SymbolicLean
  - lake build SymbolicLean.Examples
  - lake env lean SymbolicLean/Examples/Scalars.lean
  - lake env lean SymbolicLean/Examples/Matrices.lean
  - lake env lean SymbolicLean/Examples/Solvers.lean
  - lake env lean on the new special-function and eval/render example modules
  - Add runtime eval + pretty tests for representative new heads: sin, exp, sqrt, atan2.
  - Add effectful decode tests for latex, evalf, doit, and rref.
  - Add hover/search checks for solve, rref, integrate, latex, sin, and S.Reals.
  - Add solver/set tests showing solveset constrained or compared against SymPy.S.Reals and interval/set constructors.

  ## Assumptions

  - Canonical naming should move toward SymPy, but current wrappers should mostly remain available as compatibility aliases in this slice.
  - The Term representation collapse is deferred entirely.
  - Generic reify support is required only for the new scalar special functions and the small set of public constants introduced for solver UX; broader reify coverage
    follows later.
  - The production-ready extension target for this slice is:
      - a new unary or binary scalar SymPy function should usually require one declaration plus docs/examples
      - it should not require bespoke worker eval code or manual front-door wrapper duplication