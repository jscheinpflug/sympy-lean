# `SymbolicLean/Backend/Client.lean`

## Source
- [`../../../SymbolicLean/Backend/Client.lean`](../../../SymbolicLean/Backend/Client.lean)

## Responsibilities
- Manage the session-local Python worker process.
- Send typed requests through the worker and decode typed responses back into Lean values.
- Verify worker startup metadata, including manifest compatibility.
- Expose the remote reification request used by `Backend/Realize`.

## Public Surface
- `startWorker`
- `stopWorker`
- `sendRequest`
- `pingWorker`
- `mkSymbolRemote`
- `mkFunctionRemote`
- `evalTermRemote`
- `applyOpRemote`
- `applyOpRemoteRef`
- `prettyRemote`
- `releaseRemote`
- `reifyRemote`

## Change Triggers
- Worker process configuration changes.
- Session state starts tracking more worker metadata.
- Realization or ops layers need additional client helpers.
- Startup compatibility checks or reification payloads change.

## Related Files
- [`Decode.lean.md`](Decode.lean.md)
- [`Encode.lean.md`](Encode.lean.md)
- [`../Session/State.lean.md`](../Session/State.lean.md)
- [`../../../tools/sympy_worker.py`](../../../tools/sympy_worker.py)
