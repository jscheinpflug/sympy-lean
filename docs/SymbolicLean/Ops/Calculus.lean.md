# `SymbolicLean/Ops/Calculus.lean`

## Source
- [`../../../SymbolicLean/Ops/Calculus.lean`](../../../SymbolicLean/Ops/Calculus.lean)

## Responsibilities
- Define the registry-backed effectful calculus operations over realized `SymExpr` values.
- Keep differentiation variables explicit as realized scalar symbols.
- Keep the raw realized calculus names distinct from the canonical public front-door names exported by `Ops/Core`.

## Public Surface
- `diffExpr`
- `integrateExpr`
- `limitExpr`
- `seriesExpr`

## Change Triggers
- Calculus op coverage changes.
- Worker op names, payload conventions, or generated op argument encoding change.
- A later conversion layer starts accepting pure declarations or terms directly.

## Related Files
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
- [`../Term/Calculus.lean.md`](../Term/Calculus.lean.md)
