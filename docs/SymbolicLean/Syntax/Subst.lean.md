# `SymbolicLean/Syntax/Subst.lean`

## Source
- [`../../../SymbolicLean/Syntax/Subst.lean`](../../../SymbolicLean/Syntax/Subst.lean)

## Responsibilities
- Define substitution bracket sugar over the ordinary effectful substitution API.
- Accept ordinary Lean terms on both sides of each substitution rule.

## Public Surface
- `expr[x ↦ y, ...]`

## Change Triggers
- The substitution front-door API changes.
- The accepted term-level substitution inputs change.
- Additional substitution forms are added beyond the v1 bracket notation.

## Related Files
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`Command.lean.md`](Command.lean.md)
