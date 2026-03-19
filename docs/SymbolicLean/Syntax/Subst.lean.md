# `SymbolicLean/Syntax/Subst.lean`

## Source
- [`../../../SymbolicLean/Syntax/Subst.lean`](../../../SymbolicLean/Syntax/Subst.lean)

## Responsibilities
- Define substitution bracket sugar over the ordinary effectful substitution API.
- Reuse `symterm` on the substitution sides so bare symbolic names and numerals elaborate the same way as `term![...]`.

## Public Surface
- `expr[x ↦ y, ...]`

## Change Triggers
- The substitution front-door API changes.
- `symterm` support grows and substitution sugar should track it.
- Additional substitution forms are added beyond the v1 bracket notation.

## Related Files
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`Term.lean.md`](Term.lean.md)
