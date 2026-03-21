# `SymbolicLean/Session/State.lean`

## Source
- [`../../../SymbolicLean/Session/State.lean`](../../../SymbolicLean/Session/State.lean)

## Responsibilities
- Define session configuration, environment, and mutable runtime state.
- Reserve storage for the worker handle, timeout configuration, live refs, declaration interning, and caches.
- Track worker readiness and canonical-expression ref reuse within a session.

## Public Surface
- `WorkerChild`
- `WorkerProcess`
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
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
