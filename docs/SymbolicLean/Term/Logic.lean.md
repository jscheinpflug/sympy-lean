# `SymbolicLean/Term/Logic.lean`

## Source
- [`../../../SymbolicLean/Term/Logic.lean`](../../../SymbolicLean/Term/Logic.lean)

## Responsibilities
- Provide named helpers for boolean-valued pure terms.
- Keep boolean connective helpers separate from the core AST definition.
- Route boolean helpers through the `CoreHead`/`headApp` compatibility layer.

## Public Surface
- `verum`
- `falsum`
- `not_`
- `and_`
- `or_`
- `implies`
- `iff`

## Change Triggers
- Boolean connective surface changes.
- Additional logic helpers are added.
- Syntax elaboration starts depending on these helpers.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`Relations.lean.md`](Relations.lean.md)
