# `SymbolicLean/Term/Relations.lean`

## Source
- [`../../../SymbolicLean/Term/Relations.lean`](../../../SymbolicLean/Term/Relations.lean)

## Responsibilities
- Define typed comparison helpers for pure terms.
- Keep relation-building logic separate from arithmetic and boolean helpers.
- Route comparison and membership helpers through the `CoreHead`/`headApp` compatibility layer.
- Accept converted inputs symmetrically on both sides of equality, order, and membership helpers so ordinary scalar literals and declarations compose without explicit `Term` casts.

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
