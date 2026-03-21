# `SymbolicLean/Examples/Matrices.lean`

## Source
- [`../../../SymbolicLean/Examples/Matrices.lean`](../../../SymbolicLean/Examples/Matrices.lean)

## Responsibilities
- Demonstrate dimension-checked matrix workflows and the public linear-algebra front door on carrier-based aliases.
- Smoke-test determinant, inverse, and row-reduction execution from the public front door.

## Public Surface
- Typechecking example for `A * v`.
- Executable matrix-vector multiplication, determinant, inverse, and row-reduction examples.

## Change Triggers
- Matrix declaration or realization flows change.
- Linear algebra operation surfaces change.

## Related Files
- [`../Ops/LinearAlgebra.lean.md`](../Ops/LinearAlgebra.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
