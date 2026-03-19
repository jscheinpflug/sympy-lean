# `SymbolicLean/Domain/VarCtx.lean`

## Source
- [`../../../SymbolicLean/Domain/VarCtx.lean`](../../../SymbolicLean/Domain/VarCtx.lean)

## Responsibilities
- Define ordered variable contexts for polynomial-like domains.
- Provide normalization helpers and well-formedness checks for variable lists.

## Public Surface
- `VarCtx`
- `VarCtx.empty`
- `VarCtx.ofList`
- `VarCtx.isWellFormed`

## Change Triggers
- Polynomial-domain representation changes.
- Variable-ordering requirements change.
- Stronger normalization or invariant enforcement is introduced.

## Related Files
- [`Desc.lean.md`](Desc.lean.md)
- [`../../standards/lean-engineering.md`](../../standards/lean-engineering.md)
