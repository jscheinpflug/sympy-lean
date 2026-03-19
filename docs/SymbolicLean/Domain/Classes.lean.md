# `SymbolicLean/Domain/Classes.lean`

## Source
- [`../../../SymbolicLean/Domain/Classes.lean`](../../../SymbolicLean/Domain/Classes.lean)

## Responsibilities
- Define the Lean-side typeclass bridge for symbolic domains.
- Provide the initial `UnifyDomain` skeleton used by arithmetic APIs.

## Public Surface
- `DomainCarrier`
- `InterpretsDomain`
- `UnifyDomain`

## Change Triggers
- Mathlib integration changes.
- Carrier interpretation requirements grow beyond the current scaffold.
- Mixed-domain arithmetic rules are added.

## Related Files
- [`Desc.lean.md`](Desc.lean.md)
- [`../Term/Arithmetic.lean.md`](../Term/Arithmetic.lean.md)
- [`../../lakefile.toml.md`](../../lakefile.toml.md)
