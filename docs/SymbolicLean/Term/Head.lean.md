# `SymbolicLean/Term/Head.lean`

## Source
- [`../../../SymbolicLean/Term/Head.lean`](../../../SymbolicLean/Term/Head.lean)

## Responsibilities
- Provide utility functions over the schema-indexed head layer.
- Map `CoreHead` and `Head` values to stable backend-facing names.
- Keep the representation split between `HeadBase` and the recursive term layer shallow.

## Public Surface
- `CoreHead.backendName`
- `Head.backendName`

## Change Triggers
- Backend naming or manifest identity rules change.
- New core heads are added and need stable names.
- Extension heads start carrying richer identity metadata.

## Related Files
- [`HeadBase.lean.md`](HeadBase.lean.md)
- [`Core.lean.md`](Core.lean.md)
- [`View.lean.md`](View.lean.md)
- [`Arithmetic.lean.md`](Arithmetic.lean.md)
