# `SymbolicLean/Ops/Core.lean`

## Source
- [`../../../SymbolicLean/Ops/Core.lean`](../../../SymbolicLean/Ops/Core.lean)

## Responsibilities
- Define the thin front-door conversion layer between pure declarations/terms and realized operation APIs.
- Accept pure declarations and small scalar literals directly where the public op layer expects realized expressions.
- Generate the front-door wrappers that back type-namespaced Lean field notation for unary methods, multi-argument methods, receiver properties, and pure `SymPy` heads.
- Carry those method/property-style wrappers across algebra, linear algebra, and solver-facing front-door APIs.
- Generate the scoped `SymPy`, `SymPy.Q`, and `SymPy.S` namespace surface so short names do not leak into the global namespace.
- Keep the conversion logic explicit and reusable without collapsing the pure/effectful architecture.
- Close the public-surface gap between raw realized-only ops and the pure-input front door used by the examples.

## Public Surface
- `IntoSymExpr`
- `IntoSymSymbol`
- `IntoSymFun`
- `substPair`
- `substTermPair`
- `subs`
- `simplify`
- `factor`
- `expand`
- `cancel`
- `pretty`
- `solveUnivariate`
- `solveset`
- `dsolve`
- `satisfiable`
- `ask`
- `T`
- `I`
- `det`
- `rref`
- `SymPy.pretty`
- `SymPy.simplify`
- `SymPy.factor`
- `SymPy.expand`
- `SymPy.cancel`
- `SymPy.T`
- `SymPy.I`
- `SymPy.det`
- `SymPy.rref`
- `SymPy.Derivative`
- `SymPy.Integral`
- `SymPy.Sum`
- `SymPy.Product`
- `SymPy.Limit`
- `SymPy.Piecewise`
- `SymPy.Q.*`
- `SymPy.S.true_`
- `SymPy.S.false_`
- `Term.pretty`
- `Term.det`
- `Term.rref`
- `Term.solveUnivariate`
- `Term.solveset`
- `Term.dsolve`
- `Term.satisfiable`
- `SymExpr.pretty`
- `SymExpr.det`
- `SymExpr.rref`
- `SymExpr.solveUnivariate`
- `SymExpr.solveset`
- `SymExpr.dsolve`
- `SymExpr.satisfiable`
- `SymDecl.pretty`
- `SymDecl.det`
- `SymDecl.rref`
- `SymDecl.ask`

## Change Triggers
- New high-frequency APIs need pure-input overloads.
- Realization entry points change.
- The generated receiver-wrapper commands or supported wrapper shapes change.
- Structured `SymPy.*` alias coverage changes.
- Conversion policy between pure and realized values changes.

## Related Files
- [`Algebra.lean.md`](Algebra.lean.md)
- [`Solvers.lean.md`](Solvers.lean.md)
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
