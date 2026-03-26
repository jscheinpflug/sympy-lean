# `SymbolicLean/Examples/Matrices.lean`

## Source
- [`../../../SymbolicLean/Examples/Matrices.lean`](../../../SymbolicLean/Examples/Matrices.lean)

## Responsibilities
- Demonstrate dimension-checked matrix workflows and the public linear-algebra front door on carrier-based aliases.
- Smoke-test registry hover/search coverage for representative matrix APIs.
- Smoke-test pure matrix trace construction plus effectful determinant, rank, trace, inverse, adjugate, and row-reduction execution from the public front door.

## Public Surface
- Registry commands `#sympy_hover "SymbolicLean.Trace"` and `#sympy_search "trace"`.
- Typechecking examples for `A * v` and `SymPy.Trace A`.
- Executable matrix-vector multiplication, determinant, pure `Trace`, effectful `trace`, integer-valued `rank`, inverse, matrix-valued `adjugate`, and row-reduction examples.

## Change Triggers
- Matrix declaration or realization flows change.
- Linear algebra operation surfaces change.

## Related Files
- [`../Ops/LinearAlgebra.lean.md`](../Ops/LinearAlgebra.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
