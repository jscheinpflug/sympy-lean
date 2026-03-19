# `SymbolicLean/Term/Calculus.lean`

## Source
- [`../../../SymbolicLean/Term/Calculus.lean`](../../../SymbolicLean/Term/Calculus.lean)

## Responsibilities
- Provide the initial pure calculus helpers that elaborate to unevaluated `Term` forms.
- Keep derivative and limit helpers out of the core term file.

## Public Surface
- `diff`
- `integral`
- `limit`

## Change Triggers
- Pure calculus coverage changes.
- Differentiation variable restrictions change.
- Additional unevaluated calculus forms are added.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
