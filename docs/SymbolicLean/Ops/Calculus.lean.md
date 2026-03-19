# `SymbolicLean/Ops/Calculus.lean`

## Source
- [`../../../SymbolicLean/Ops/Calculus.lean`](../../../SymbolicLean/Ops/Calculus.lean)

## Responsibilities
- Define the first effectful calculus operations over realized `SymExpr` values.
- Keep differentiation variables explicit as realized scalar symbols.
- Keep the effectful calculus names distinct from the pure term constructors where the namespace would otherwise collide.

## Public Surface
- `diffExpr`
- `integrate`
- `limitExpr`
- `seriesExpr`

## Change Triggers
- Calculus op coverage changes.
- Worker op names or payload conventions change.
- A later conversion layer starts accepting pure declarations or terms directly.

## Related Files
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
- [`../SymExpr/Refined.lean.md`](../SymExpr/Refined.lean.md)
- [`../Term/Calculus.lean.md`](../Term/Calculus.lean.md)
