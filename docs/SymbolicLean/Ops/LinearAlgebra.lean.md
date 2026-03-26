# `SymbolicLean/Ops/LinearAlgebra.lean`

## Source
- [`../../../SymbolicLean/Ops/LinearAlgebra.lean`](../../../SymbolicLean/Ops/LinearAlgebra.lean)

## Responsibilities
- Define the first effectful linear-algebra operations over realized matrix expressions.
- Keep the realized-only matrix ops separate from the broader front-door wrappers exported elsewhere.
- Enforce the field-only matrix constraints for inversion and row reduction at the Lean type level.
- Expose method-backed matrix operations whose outputs already fit or can be cheaply adapted to the current transport layer, including integer-valued `rank` and square-matrix `adjugate`.
- Decode SymPy's structured `rref` result into a typed Lean container.
- Re-realize JSON scalar matrix results such as `rank` back into ordinary symbolic refs when the backend does not return a handle directly.
- Reuse the shared `(Ref × α)` effectful-payload decode path for the `[matrixRef, pivots]` worker payload.
- Register the hand-written `rrefExpr` decoder in the symbolic registry so it participates in manifest-driven discoverability, including `result_mode structured`.
- Keep the registry-visible matrix op docs aligned with the public `det`, `trace`, `I`, and `rref` front doors.

## Public Surface
- `RRefResult`
- `detExpr`
- `traceExpr`
- `rankExpr`
- `inv`
- `adjugateExpr`
- `rrefExpr`

## Change Triggers
- Matrix realization changes.
- Worker payloads for structured matrix operations change.
- The split between raw realized-only names and public front-door wrappers changes.
- Additional matrix operations or result containers are added.

## Related Files
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Backend/Decode.lean.md`](../Backend/Decode.lean.md)
- [`../Domain/Classes.lean.md`](../Domain/Classes.lean.md)
- [`../SymExpr/Core.lean.md`](../SymExpr/Core.lean.md)
