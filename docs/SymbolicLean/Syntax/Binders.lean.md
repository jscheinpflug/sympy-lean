# `SymbolicLean/Syntax/Binders.lean`

## Source
- [`../../../SymbolicLean/Syntax/Binders.lean`](../../../SymbolicLean/Syntax/Binders.lean)

## Responsibilities
- Define binder sugar for repeated pure `SymDecl` and `FunDecl` creation inside `do` blocks.
- Keep binder meaning explicit by lowering to ordinary pure declaration constructors and the contextual default scalar domain.
- Translate carrier-based binder annotations such as `Rat`, `Mat Rat 2 2`, and `Rat → Rat` into symbolic sorts.
- Expose the v1 scalar-default hook that later session syntax can install from one domain value.

## Public Surface
- `DefaultScalarDomain`
- `mkDefaultSymbol`
- `mkDefaultFunction`
- `symbols ...`
- `functions ...`

## Change Triggers
- Default binder meaning changes.
- Supported declaration assumptions grow.
- Public carrier-annotation lowering changes.
- Session command syntax starts installing binder defaults automatically.

## Related Files
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
- [`../Decl/Assumptions.lean.md`](../Decl/Assumptions.lean.md)
- [`../Sort/Aliases.lean.md`](../Sort/Aliases.lean.md)
- [`Command.lean.md`](Command.lean.md)
