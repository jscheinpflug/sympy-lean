# `SymbolicLean/Ops/Solvers.lean`

## Source
- [`../../../SymbolicLean/Ops/Solvers.lean`](../../../SymbolicLean/Ops/Solvers.lean)

## Responsibilities
- Define the first effectful solver and query operations over realized expressions.
- Use the generated unary-wrapper layer for the raw ref-returning ODE solve step.
- Decode finite-solution, set-valued, ODE, satisfiability, and assumption-query results into typed Lean containers.
- Keep the low-level realized-object entry points separate from the later conversion layer in `Ops/Core`.

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
- A later front-door conversion layer starts routing pure inputs here.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`Results.lean.md`](Results.lean.md)
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Backend/Decode.lean.md`](../Backend/Decode.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
