# `SymbolicLean/Term/HeadBase.lean`

## Source
- [`../../../SymbolicLean/Term/HeadBase.lean`](../../../SymbolicLean/Term/HeadBase.lean)

## Responsibilities
- Define the schema-indexed symbolic head datatypes without depending on the recursive term layer.
- Provide the fixed `CoreHead` family for migrated pure symbolic operations.
- Provide the open `ExtHeadSpec` and `Head` wrappers used by `Term.headApp`.
- Publish stable extension-head names for the current calculus compatibility heads.

## Public Surface
- `HeadSchema`
- `CoreHead`
- `ExtHeadSpec`
- `Head`
- `diffHeadName`
- `integralHeadName`
- `limitHeadName`

## Change Triggers
- A migrated pure symbolic family needs a new schema-indexed core head.
- Extension-head identity or naming rules change.
- `Term.headApp` representation changes in a way that affects head identity.

## Related Files
- [`Head.lean.md`](Head.lean.md)
- [`Core.lean.md`](Core.lean.md)
- [`View.lean.md`](View.lean.md)
