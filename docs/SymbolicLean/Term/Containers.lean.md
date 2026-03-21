# `SymbolicLean/Term/Containers.lean`

## Source
- [`../../../SymbolicLean/Term/Containers.lean`](../../../SymbolicLean/Term/Containers.lean)

## Responsibilities
- Define pure extension-head helpers for indexing, slicing, and map-like symbolic container terms.
- Keep missing surface syntax lowering targets separate from parser macros.
- Provide typed builders that let syntax remain thin and purely translational.

## Public Surface
- `indexHeadName`
- `index2HeadName`
- `sliceAtHeadName`
- `sliceRangeHeadName`
- `dictEmptyHeadName`
- `dictInsertHeadName`
- `index1`
- `index2`
- `sliceAt`
- `sliceRange`
- `dictEmpty`
- `dictInsert`

## Change Triggers
- Indexing or slicing surface forms change.
- Symbolic map or dictionary support grows richer than repeated inserts.
- Worker/runtime support begins interpreting these heads directly.

## Related Files
- [`../Syntax/Indexing.lean.md`](../Syntax/Indexing.lean.md)
- [`../Syntax/Dict.lean.md`](../Syntax/Dict.lean.md)
- [`RegistryHeads.lean.md`](RegistryHeads.lean.md)
