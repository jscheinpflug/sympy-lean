# `SymbolicLean/Session/State.lean`

## Source
- [`../../../SymbolicLean/Session/State.lean`](../../../SymbolicLean/Session/State.lean)

## Responsibilities
- Define session configuration, environment, and mutable runtime state.
- Reserve storage for live refs, declaration interning, caches, and dynamic shape metadata.

## Public Surface
- `SessionConfig`
- `SessionEnv`
- `SessionState`

## Change Triggers
- Backend worker configuration changes.
- Declaration interning requirements change.
- Session-local cache or metadata needs expand.

## Related Files
- [`Errors.lean.md`](Errors.lean.md)
- [`Monad.lean.md`](Monad.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
