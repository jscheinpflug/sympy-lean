# `SymbolicLean/Backend/Encode.lean`

## Source
- [`../../../SymbolicLean/Backend/Encode.lean`](../../../SymbolicLean/Backend/Encode.lean)

## Responsibilities
- Encode pure `Term` values into the JSON term language understood by the SymPy worker.
- Provide typed request constructors for the common worker commands.
- Attach sort metadata when symbol atoms or symbol-realization requests need non-scalar backend objects.

## Public Surface
- `encodeTruth`
- `encodeRelKind`
- `encodeAtom`
- `encodeTerm`
- `encodeArgs`
- `encodeRefArg`
- `encodeTermArg`
- `pingRequest`
- `mkSymbolRequest`
- `mkFunctionRequest`
- `evalTermRequest`
- `applyOpRequest`
- `prettyRequest`
- `releaseRequest`

## Change Triggers
- Pure term constructors change.
- Worker term-tag conventions change.
- Backend client code starts depending on richer request helpers.

## Related Files
- [`Protocol.lean.md`](Protocol.lean.md)
- [`../Term/Core.lean.md`](../Term/Core.lean.md)
- [`../../../tools/sympy_worker.py`](../../../tools/sympy_worker.py)
