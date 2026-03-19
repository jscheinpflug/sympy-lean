# `SymbolicLean/SymExpr/Refined.lean`

## Source
- [`../../../SymbolicLean/SymExpr/Refined.lean`](../../../SymbolicLean/SymExpr/Refined.lean)

## Responsibilities
- Define thin refinement wrappers over runtime symbolic handles.
- Reserve type-level distinctions for symbols, function symbols, booleans, and relations.

## Public Surface
- `SymSymbol`
- `SymFun`
- `SymBool`
- `SymRel`

## Change Triggers
- Refined runtime API requirements change.
- Relation or function wrapper shapes change.
- Higher-level ops start requiring more specific wrappers.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Sort/Base.lean.md`](../Sort/Base.lean.md)
