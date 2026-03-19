# `SymbolicLean/Ops/Core.lean`

## Source
- [`../../../SymbolicLean/Ops/Core.lean`](../../../SymbolicLean/Ops/Core.lean)

## Responsibilities
- Define the thin front-door conversion layer between pure declarations/terms and realized operation APIs.
- Keep the conversion logic explicit and reusable without collapsing the pure/effectful architecture.

## Public Surface
- `IntoSymExpr`
- `IntoSymSymbol`
- `IntoSymFun`
- `simplify`
- `factor`
- `expand`
- `cancel`
- `solveUnivariate`
- `solveset`
- `dsolve`
- `satisfiable`
- `ask`

## Change Triggers
- New high-frequency APIs need pure-input overloads.
- Realization entry points change.
- Conversion policy between pure and realized values changes.

## Related Files
- [`Algebra.lean.md`](Algebra.lean.md)
- [`Solvers.lean.md`](Solvers.lean.md)
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
