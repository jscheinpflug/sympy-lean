# `SymbolicLean/Ops/Algebra.lean`

## Source
- [`../../../SymbolicLean/Ops/Algebra.lean`](../../../SymbolicLean/Ops/Algebra.lean)

## Responsibilities
- Define the first effectful algebra operations over realized `SymExpr` values.
- Keep substitution typed by pairing source and replacement expressions with an explicit compatibility relation.
- Keep the low-level realized-object entry points separate from the later conversion layer in `Ops/Core`.

## Public Surface
- `SubstCompat`
- `SubstPair`
- `simplifyExpr`
- `factorExpr`
- `expandExpr`
- `cancelExpr`
- `subsExpr`

## Change Triggers
- Algebra op coverage changes.
- Worker op names or payload conventions change.
- The later front-door conversion layer starts routing pure inputs here.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Backend/Client.lean.md`](../Backend/Client.lean.md)
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
- [`../SymExpr/Core.lean.md`](../SymExpr/Core.lean.md)
