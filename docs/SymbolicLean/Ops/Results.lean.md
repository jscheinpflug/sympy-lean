# `SymbolicLean/Ops/Results.lean`

## Source
- [`../../../SymbolicLean/Ops/Results.lean`](../../../SymbolicLean/Ops/Results.lean)

## Responsibilities
- Define the small typed result containers shared by effectful solver-style APIs.
- Keep structured solver outputs out of raw JSON and ad hoc tuples.

## Public Surface
- `FiniteSolve`
- `EvalOr`
- `ODESolution`
- `SolveSetResult`
- `SatAssignment`
- `SatisfiableResult`

## Change Triggers
- Solver result shapes change.
- More structured result types are introduced.
- Front-door APIs start sharing additional result containers.

## Related Files
- [`Solvers.lean.md`](Solvers.lean.md)
- [`../SymExpr/Core.lean.md`](../SymExpr/Core.lean.md)
