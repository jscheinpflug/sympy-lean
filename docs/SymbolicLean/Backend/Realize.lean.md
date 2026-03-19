# `SymbolicLean/Backend/Realize.lean`

## Source
- [`../../../SymbolicLean/Backend/Realize.lean`](../../../SymbolicLean/Backend/Realize.lean)

## Responsibilities
- Realize pure declarations into session-scoped backend refs using the declaration interning table.
- Provide the main `eval` bridge from pure `Term` values to live `SymExpr` handles.

## Public Surface
- `realizeDecl`
- `realizeFun`
- `eval`

## Change Triggers
- Declaration interning rules change.
- Backend client helpers change.
- Composite term evaluation starts using a more incremental realization strategy.

## Related Files
- [`Client.lean.md`](Client.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
- [`../Term/Core.lean.md`](../Term/Core.lean.md)
