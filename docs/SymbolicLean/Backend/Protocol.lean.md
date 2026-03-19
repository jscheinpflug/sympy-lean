# `SymbolicLean/Backend/Protocol.lean`

## Source
- [`../../../SymbolicLean/Backend/Protocol.lean`](../../../SymbolicLean/Backend/Protocol.lean)

## Responsibilities
- Define the typed JSON wire protocol for the Python SymPy worker.
- Keep request and response payloads versioned and explicit on the Lean side.
- Carry enough symbol metadata for the worker to realize non-scalar declarations like matrices.

## Public Surface
- `WireRef`
- `protocolVersion`
- `SymbolSpec`
- `FunctionSpec`
- `EvalTermReq`
- `ApplyOpReq`
- `PrettyReq`
- `ReleaseReq`
- `WorkerRequestPayload`
- `WorkerRequest`
- `PongInfo`
- `RefInfo`
- `JsonInfo`
- `PrettyInfo`
- `ReleasedInfo`
- `ErrorInfo`
- `WorkerResponsePayload`
- `WorkerResponse`

## Change Triggers
- Worker command set changes.
- JSON payload layout changes.
- Backend client or encoder work starts depending on more specific payload types.

## Related Files
- [`../Decl/Assumptions.lean.md`](../Decl/Assumptions.lean.md)
- [`../Session/Errors.lean.md`](../Session/Errors.lean.md)
- [`../../../tools/sympy_worker.py`](../../../tools/sympy_worker.py)
