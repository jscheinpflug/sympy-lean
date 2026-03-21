# `SymbolicLean/Examples/Proofs.lean`

## Source
- [`../../../SymbolicLean/Examples/Proofs.lean`](../../../SymbolicLean/Examples/Proofs.lean)

## Responsibilities
- Demonstrate the current proof-facing boundary of the library.
- Show that pure `SymPy.*` builders can be used directly inside ordinary Lean proofs because they build `Term`s.
- Keep the distinction clear between pure symbolic builders and effectful `SymPyM` calls that still belong in executable examples.

## Public Surface
- Proof examples for `SymPy.Derivative`, `SymPy.Integral`, `SymPy.Sum`, `SymPy.Product`, and `SymPy.Piecewise`.
- Proof examples that use a `SymPy.*`-built term as a subterm inside a larger proposition.

## Change Triggers
- The pure `SymPy.*` builder surface changes.
- The proof boundary between pure terms and effectful backend calls changes.
- New proof-oriented examples are added or reorganized.

## Related Files
- [`Scalars.lean.md`](Scalars.lean.md)
- [`Solvers.lean.md`](Solvers.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Elab.lean.md`](../Syntax/Elab.lean.md)
