# `SymbolicLean/Domain/Classes.lean`

## Source
- [`../../../SymbolicLean/Domain/Classes.lean`](../../../SymbolicLean/Domain/Classes.lean)

## Responsibilities
- Define the Lean-side typeclass bridge for symbolic domains.
- Interpret common symbolic domains through mathlib carrier types and algebraic capabilities.
- Expose the carrier-to-domain bridge used by the public alias layer.
- Provide the `UnifyDomain` rules used by mixed-domain scalar arithmetic.

## Public Surface
- `DomainCarrier`
- `CarrierOf`
- `CarrierDomain`
- `InterpretsDomain`
- `InterpretsCommRing`
- `InterpretsIntegralDomain`
- `InterpretsField`
- `UnifyDomain`

## Change Triggers
- Mathlib integration changes.
- Carrier interpretation requirements grow beyond the current placeholder scaffold for `algExt` and `quotient`.
- Mixed-domain arithmetic rules are added.

## Related Files
- [`Desc.lean.md`](Desc.lean.md)
- [`../Sort/Aliases.lean.md`](../Sort/Aliases.lean.md)
- [`../Term/Arithmetic.lean.md`](../Term/Arithmetic.lean.md)
- [`../../lakefile.lean.md`](../../lakefile.lean.md)
