# `SymbolicLean/Syntax/Term.lean`

## Source
- [`../../../SymbolicLean/Syntax/Term.lean`](../../../SymbolicLean/Syntax/Term.lean)

## Responsibilities
- Define the first `term![...]` elaborator for the pure symbolic `Term` layer.
- Keep identifier resolution explicit by accepting only bound locals that already have `Term`, `SymDecl`, or `FunDecl` types.
- Mirror SymPy precedence for the supported v1 operators instead of inventing a local precedence table.

## Public Surface
- `term![...]`

## Change Triggers
- Supported pure term syntax grows.
- Identifier resolution policy changes.
- Binder syntax starts providing richer local declaration forms.

## Related Files
- [`../Term/Core.lean.md`](../Term/Core.lean.md)
- [`../Term/Arithmetic.lean.md`](../Term/Arithmetic.lean.md)
- [`../Term/Calculus.lean.md`](../Term/Calculus.lean.md)
- [`../Term/Relations.lean.md`](../Term/Relations.lean.md)
