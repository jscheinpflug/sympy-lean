# `SymbolicLean/Syntax/Dict.lean`

## Source
- [`../../../SymbolicLean/Syntax/Dict.lean`](../../../SymbolicLean/Syntax/Dict.lean)

## Responsibilities
- Provide `dict{ ... }` syntax for typed symbolic map terms.
- Lower dictionary entries into repeated pure map-insert helpers.
- Keep dictionary parsing independent from worker/runtime concerns.

## Public Surface
- `dictEntry`
- scoped syntax for `dict{}`
- scoped syntax for `dict{ k ↦ v, ... }`

## Change Triggers
- Dictionary literal syntax changes.
- Map construction stops being modeled as repeated inserts.
- Generic elaboration begins owning dictionary construction.

## Related Files
- [`../Term/Containers.lean.md`](../Term/Containers.lean.md)
- [`Indexing.lean.md`](Indexing.lean.md)
- [`../Examples/Scalars.lean.md`](../Examples/Scalars.lean.md)
