# `SymbolicLean/Session/Errors.lean`

## Source
- [`../../../SymbolicLean/Session/Errors.lean`](../../../SymbolicLean/Session/Errors.lean)

## Responsibilities
- Define the typed error surface for session and backend failures.
- Separate worker, decode, protocol, and user-facing errors.

## Public Surface
- `WorkerError`
- `DecodeError`
- `ProtocolError`
- `SymPyError`

## Change Triggers
- Backend protocol requirements change.
- Error taxonomy changes.
- User-facing session APIs need richer diagnostics.

## Related Files
- [`State.lean.md`](State.lean.md)
- [`Monad.lean.md`](Monad.lean.md)
