# `SymbolicLean/Backend/Decode.lean`

## Source
- [`../../../SymbolicLean/Backend/Decode.lean`](../../../SymbolicLean/Backend/Decode.lean)

## Responsibilities
- Parse raw worker JSON into typed protocol responses.
- Convert common worker response payloads into typed Lean values and `SymPyError`s.
- Decode worker-side reified JSON back into typed `Term` trees.
- Decode the post-migration `headApp` transport for symbolic heads.
- Preserve calculus extension heads as stored `headApp` terms when they arrive through generic reification.
- Decode generic fixed-arity extension heads into `Term.headApp` values using the emitted result sort plus decoded argument sorts.
- Keep core arithmetic, logic, relation, and calculus heads on explicit decode branches so malformed core payloads still fail loudly.
- Support nullary attr constants and the current set-returning generic extension slice through the same fallback.
- Keep homogeneous variadic and broader matrix/container extension-head decode out of the generic fallback until that public surface exists.

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
- Reserved core-head names or generic extension-head arity policy changes.

## Related Files
- [`Protocol.lean.md`](Protocol.lean.md)
- [`Encode.lean.md`](Encode.lean.md)
- [`../Term/Canon.lean.md`](../Term/Canon.lean.md)
- [`../Session/Errors.lean.md`](../Session/Errors.lean.md)
