# `SymbolicLean/Backend/Decode.lean`

## Source
- [`../../../SymbolicLean/Backend/Decode.lean`](../../../SymbolicLean/Backend/Decode.lean)

## Responsibilities
- Parse raw worker JSON into typed protocol responses.
- Convert common worker response payloads into typed Lean values and `SymPyError`s.
- Decode worker-side reified JSON back into typed `Term` trees.
- Decode the post-migration `headApp` transport for symbolic heads.
- Preserve calculus extension heads as stored `headApp` terms when they arrive through generic reification.
- Decode generic unary and binary scalar extension heads into `Term.headApp` values when they arrive through worker-side reification fallback.
- Keep broader variadic, set, and tensor extension-head decode out of the generic fallback until that public surface exists.

## Public Surface
- `parseResponseJson`
- `parseResponseText`
- `ensureSuccess`
- `decodePong`
- `decodeRef`
- `decodeJsonInfo`
- `decodeJsonPayloadAs`
- `decodePretty`
- `decodeReleased`
- `decodeSort`
- `decodeTermAs`

## Change Triggers
- Worker response payload shapes change.
- Error-mapping policy changes.
- Backend client work needs more structured response projections.
- Worker-side reification or `headApp` transport changes term JSON shape.
- Additional extension-head families decode through the generic `headApp` path.

## Related Files
- [`Protocol.lean.md`](Protocol.lean.md)
- [`Encode.lean.md`](Encode.lean.md)
- [`../Term/Canon.lean.md`](../Term/Canon.lean.md)
- [`../Session/Errors.lean.md`](../Session/Errors.lean.md)
