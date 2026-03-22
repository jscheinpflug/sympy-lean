# `SymbolicLean/Examples/Solvers.lean`

## Source
- [`../../../SymbolicLean/Examples/Solvers.lean`](../../../SymbolicLean/Examples/Solvers.lean)

## Responsibilities
- Demonstrate the main solver-facing workflows over the carrier-based plain-Lean front door.
- Smoke-test the `SymPy` namespace aliases that feed into solver-oriented workflows.
- Smoke-test solver field notation on the public front door.
- Smoke-test `sympy Rat do` on effectful solver workflows.
- Smoke-test the minimal pure set vocabulary that complements the current solver UX, including direct `Interval 0 x`-style construction, signed literal bounds, and homogeneous variadic `FiniteSet`.
- Smoke-test manifest-driven reify for the current set extension slice, including set-returning call heads, homogeneous variadic set constructors, and nullary `S.*` attr constants.
- Smoke-test scoped assumptions through ordinary Lean `assuming [...] do ...`.

## Public Surface
- Typechecking examples for `SymPy.Interval`, `SymPy.Union`, `SymPy.FiniteSet`, `SymPy.S.Reals`, and `SymPy.S.Integers`, including signed literal interval bounds.
- Executable examples for canonical `solve`, compatibility `solveUnivariate`, `solveset`, `dsolve`, `satisfiable`, and `ask`, including `sympy Rat do`, `SymPy.Derivative`, `SymPy.S.true_`, `SymPy.Q.positive`, pure set pretty-printing for symbolic and concrete intervals/unions/finite sets, manifest-driven `reify` round-trips for `Interval`, `FiniteSet`, and `SymPy.S.Reals`, solver field notation such as `.solve`, `.satisfiable`, and `.ask`, and scoped assumptions via `assuming [...] do ...`.

## Change Triggers
- Solver result containers change.
- Solver front-door APIs change.

## Related Files
- [`../Ops/Solvers.lean.md`](../Ops/Solvers.lean.md)
- [`../Ops/Results.lean.md`](../Ops/Results.lean.md)
- [`../Syntax/Binders.lean.md`](../Syntax/Binders.lean.md)
- [`../Sort/Aliases.lean.md`](../Sort/Aliases.lean.md)
