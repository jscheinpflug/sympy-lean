# `SymbolicLean/Domain/Dim.lean`

## Source
- [`../../../SymbolicLean/Domain/Dim.lean`](../../../SymbolicLean/Domain/Dim.lean)

## Responsibilities
- Define dimension descriptors shared by matrix and tensor sorts.
- Distinguish static dimensions from named dynamic dimensions.

## Public Surface
- `Dim`

## Change Triggers
- Matrix or tensor sort changes.
- Dynamic shape metadata changes.
- Domain-level shape encoding changes.

## Related Files
- [`Desc.lean.md`](Desc.lean.md)
- [`../Sort/Base.lean.md`](../Sort/Base.lean.md)
- [`../Session/State.lean.md`](../Session/State.lean.md)
