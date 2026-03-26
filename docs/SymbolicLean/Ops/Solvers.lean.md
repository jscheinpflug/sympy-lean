# `SymbolicLean/Ops/Solvers.lean`

## Source
- [`../../../SymbolicLean/Ops/Solvers.lean`](../../../SymbolicLean/Ops/Solvers.lean)

## Responsibilities
- Define the first effectful solver and query operations over realized expressions.
- Use `declare_op` for the raw ref-returning ODE, solve-set, and finite-solve steps.
- Use the JSON-decoding `declare_op` path for satisfiability, assumption-query, and finite-solve payloads.
- Decode finite-solution, set-valued, ODE, satisfiability, and assumption-query results into typed Lean containers.
- Reuse the shared embedded-ref decode helpers for finite `solve` payloads instead of carrying a solver-local ref parser.
- Mark the structured solver payload entry points with manifest-visible `result_mode structured` so hover/manifest output matches the decoder path.
- Keep the low-level realized-object entry points separate from the later conversion layer in `Ops/Core`, where `solve` becomes the canonical public front door and `solveUnivariate` remains a compatibility alias.
- Encode the current `Assumption` vocabulary for `ask`, including the expanded sign, parity, primality, and finiteness-facing query set.

## Public Surface
- `solveUnivariateExpr`
- `solvesetExpr`
- `dsolveEquation`
- `dsolveExpr`
- `satisfiableExpr`
- `askSymbol`

## Change Triggers
- Solver op coverage changes.
- Worker op names or solver payload conventions change.
- The front-door conversion layer changes how `solve` compatibility aliases are routed.
- Result packaging for `declare_op`-generated solver entry points changes.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`Results.lean.md`](Results.lean.md)
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Backend/Decode.lean.md`](../Backend/Decode.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
