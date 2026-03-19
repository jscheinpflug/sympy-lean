# `SymbolicLean/Backend/Decode.lean`

## Source
- [`../../../SymbolicLean/Backend/Decode.lean`](../../../SymbolicLean/Backend/Decode.lean)

## Responsibilities
- Parse raw worker JSON into typed protocol responses.
- Convert common worker response payloads into typed Lean values and `SymPyError`s.

## Public Surface
- `parseResponseJson`
- `parseResponseText`
- `ensureSuccess`
- `decodePong`
- `decodeRef`
- `decodeJsonInfo`
- `decodeJsonAs`
- `decodePretty`
- `decodeReleased`

## Change Triggers
- Worker response payload shapes change.
- Error-mapping policy changes.
- Backend client work needs more structured response projections.

## Related Files
- [`Protocol.lean.md`](Protocol.lean.md)
- [`Encode.lean.md`](Encode.lean.md)
- [`../Session/Errors.lean.md`](../Session/Errors.lean.md)
