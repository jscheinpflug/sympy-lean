# `SymbolicLean/Backend/Realize.lean`

## Source
- [`../../../SymbolicLean/Backend/Realize.lean`](../../../SymbolicLean/Backend/Realize.lean)

## Responsibilities
- Realize pure declarations into session-scoped backend refs using the declaration interning table.
- Provide the main `eval` bridge from pure `Term` values to live `SymExpr` handles.
- Canonicalize composite terms for cache keys while preserving the original term representation for remote evaluation.
- Reuse canonical refs within a session.
- Expose the `reify` bridge from realized expressions back to pure terms.

## Public Surface
- `realizeDecl`
- `realizeFun`
- `eval`
- `reify`

## Change Triggers
- Declaration interning rules change.
- Backend client helpers change.
- Composite term evaluation starts using a more incremental realization strategy.
- Canonical caching or reification behavior changes.
- Round-trip reification guarantees or test coverage change.

## Related Files
- [`Client.lean.md`](Client.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
- [`../Term/Canon.lean.md`](../Term/Canon.lean.md)
- [`../Term/Core.lean.md`](../Term/Core.lean.md)
