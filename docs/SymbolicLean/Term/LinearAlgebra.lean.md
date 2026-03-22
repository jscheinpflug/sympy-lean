# `SymbolicLean/Term/LinearAlgebra.lean`

## Source
- [`../../../SymbolicLean/Term/LinearAlgebra.lean`](../../../SymbolicLean/Term/LinearAlgebra.lean)

## Responsibilities
- Define the current pure linear-algebra extension-head slice.
- Keep matrix-valued pure vocabulary separate from realized matrix operations in `Ops/LinearAlgebra`.
- Expose a registry-backed pure matrix trace head that participates in manifest-driven eval, hover, and reify.

## Public Surface
- `Trace`
- `SymPy.Trace`

## Change Triggers
- Pure linear-algebra head coverage grows.
- Matrix-head eval or reify support changes.

## Related Files
- [`../Ops/LinearAlgebra.lean.md`](../Ops/LinearAlgebra.lean.md)
- [`../Examples/Matrices.lean.md`](../Examples/Matrices.lean.md)
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
