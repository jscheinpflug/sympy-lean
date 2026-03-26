# `SymbolicLean/Term/Calculus.lean`

## Source
- [`../../../SymbolicLean/Term/Calculus.lean`](../../../SymbolicLean/Term/Calculus.lean)

## Responsibilities
- Reserve stable calculus extension-head identities for the migration.
- Provide the public pure calculus helpers.
- Build pure calculus terms directly as extension `headApp` nodes.
- Keep derivative and limit helpers out of the core term file.
- Share stable calculus head specs with decode/reify support.

## Public Surface
- `diffHeadSpec`
- `integralHeadSpec`
- `limitHeadSpec`
- `diff`
- `integral`
- `limitTerm`

## Change Triggers
- Pure calculus coverage changes.
- Generic extension-head decode or reify behavior changes.
- Differentiation variable restrictions change.
- Additional unevaluated calculus forms are added.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
- [`HeadBase.lean.md`](HeadBase.lean.md)
- [`Head.lean.md`](Head.lean.md)
