# `SymbolicLean/Term/Literals.lean`

## Source
- [`../../../SymbolicLean/Term/Literals.lean`](../../../SymbolicLean/Term/Literals.lean)

## Responsibilities
- Provide small literal helpers for common scalar domains.
- Bridge ordinary Lean numerals onto the public scalar carrier aliases that map to existing core literals.
- Keep literal convenience out of the core `Term` definition file.

## Public Surface
- `zz`
- `qq`
- `instOfNatZZTerm`
- `instOfNatQQTerm`
- `instOfNatScalarInt`
- `instOfNatScalarRat`

## Change Triggers
- Literal defaults change.
- Additional scalar literal helpers or alias-head numeral instances are introduced.
- Ordinary-Lean symbolic elaboration starts depending on richer literal support.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`Arithmetic.lean.md`](Arithmetic.lean.md)
