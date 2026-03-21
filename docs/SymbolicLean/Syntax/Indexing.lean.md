# `SymbolicLean/Syntax/Indexing.lean`

## Source
- [`../../../SymbolicLean/Syntax/Indexing.lean`](../../../SymbolicLean/Syntax/Indexing.lean)

## Responsibilities
- Provide bracket-based symbolic indexing and slicing macros.
- Lower parsing forms like `A[i, j]`, `A[:, j]`, and `A[i:j]` into typed pure container helpers.
- Keep parsing thin so the real symbolic meaning lives in the term layer.

## Public Surface
- scoped syntax for `expr[idx]`
- scoped syntax for `expr[i, j]`
- scoped syntax for `expr[:, j]`
- scoped syntax for `expr[i:j]`

## Change Triggers
- The indexing surface gains more slice forms.
- Container helper names or arities change.
- Generic elaboration starts owning these forms instead of direct macros.

## Related Files
- [`../Term/Containers.lean.md`](../Term/Containers.lean.md)
- [`Dict.lean.md`](Dict.lean.md)
- [`Subst.lean.md`](Subst.lean.md)
