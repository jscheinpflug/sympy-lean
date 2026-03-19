# `SymbolicLean/SymExpr/Core.lean`

## Source
- [`../../../SymbolicLean/SymExpr/Core.lean`](../../../SymbolicLean/SymExpr/Core.lean)

## Responsibilities
- Define session tokens, backend refs, and typed runtime symbolic handles.
- Establish the runtime side of the pure `Term` / realized `SymExpr` split.

## Public Surface
- `SessionTok`
- `Ref`
- `SymExpr`

## Change Triggers
- Session-safety encoding changes.
- Runtime handle representation changes.
- Backend client integration work starts.

## Related Files
- [`Refined.lean.md`](Refined.lean.md)
- [`../Session/Monad.lean.md`](../Session/Monad.lean.md)
- [`../Term/Core.lean.md`](../Term/Core.lean.md)
