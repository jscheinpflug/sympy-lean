# `SymbolicLean/Ops/LinearAlgebra.lean`

## Source
- [`../../../SymbolicLean/Ops/LinearAlgebra.lean`](../../../SymbolicLean/Ops/LinearAlgebra.lean)

## Responsibilities
- Define the first effectful linear-algebra operations over realized matrix expressions.
- Enforce the field-only matrix constraints for inversion and row reduction at the Lean type level.
- Decode SymPy's structured `rref` result into a typed Lean container.

## Public Surface
- `RRefResult`
- `det`
- `inv`
- `rref`

## Change Triggers
- Matrix realization changes.
- Worker payloads for structured matrix operations change.
- Additional matrix operations or result containers are added.

## Related Files
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Backend/Decode.lean.md`](../Backend/Decode.lean.md)
- [`../Domain/Classes.lean.md`](../Domain/Classes.lean.md)
- [`../SymExpr/Core.lean.md`](../SymExpr/Core.lean.md)
