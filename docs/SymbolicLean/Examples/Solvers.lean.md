# `SymbolicLean/Examples/Solvers.lean`

## Source
- [`../../../SymbolicLean/Examples/Solvers.lean`](../../../SymbolicLean/Examples/Solvers.lean)

## Responsibilities
- Demonstrate the main solver-facing workflows over the carrier-based plain-Lean front door.
- Smoke-test the `SymPy` namespace aliases that feed into solver-oriented workflows.
- Smoke-test solver field notation on the public front door.
- Smoke-test scoped assumptions through ordinary Lean `assuming [...] do ...`.

## Public Surface
- Executable examples for `solveUnivariate`, `solveset`, `dsolve`, `satisfiable`, and `ask`, including `SymPy.Derivative`, `SymPy.S.true_`, `SymPy.Q.positive`, solver field notation such as `.solveUnivariate`, `.satisfiable`, and `.ask`, and scoped assumptions via `assuming [...] do ...`.

## Change Triggers
- Solver result containers change.
- Solver front-door APIs change.

## Related Files
- [`../Ops/Solvers.lean.md`](../Ops/Solvers.lean.md)
- [`../Ops/Results.lean.md`](../Ops/Results.lean.md)
- [`../Syntax/Binders.lean.md`](../Syntax/Binders.lean.md)
- [`../Sort/Aliases.lean.md`](../Sort/Aliases.lean.md)
