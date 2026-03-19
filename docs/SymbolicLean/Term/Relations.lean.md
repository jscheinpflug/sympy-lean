# `SymbolicLean/Term/Relations.lean`

## Source
- [`../../../SymbolicLean/Term/Relations.lean`](../../../SymbolicLean/Term/Relations.lean)

## Responsibilities
- Define typed comparison helpers for pure terms.
- Keep relation-building logic separate from arithmetic and boolean helpers.

## Public Surface
- `CanCompare`
- `compare`
- `eq_`
- `ne_`
- `lt`
- `le`
- `gt`
- `ge`
- `mem`

## Change Triggers
- Relation typing rules change.
- New comparison forms are added.
- Set-membership behavior changes.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Sort/Relations.lean.md`](../Sort/Relations.lean.md)
