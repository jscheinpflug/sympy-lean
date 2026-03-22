# `SymbolicLean/Syntax/StructuredArgs.lean`

## Source
- [`../../../SymbolicLean/Syntax/StructuredArgs.lean`](../../../SymbolicLean/Syntax/StructuredArgs.lean)

## Responsibilities
- Define the first structured symbolic argument records used by later surface elaboration work.
- Provide tuple-shaped compatibility aliases for common binder-style symbolic inputs.
- Let ordinary Lean tuples coerce into `BoundSpec`, `DerivSpec`, and `PieceBranch`.
- Provide the conversion typeclasses used by the public wrapper layer when coercion propagation alone is not enough.
- Keep bound tuples generic over `IntoScalarTerm`, so both literal and symbolic endpoints can feed `Integral`, `Sum`, and `Product`.

## Public Surface
- `BoundSpec`
- `DerivSpec`
- `PieceBranch`
- `BoundVar`
- `BoundUpper`
- `BoundRange`
- `DerivVar`
- `DerivOrder`
- `PieceCase`
- `PieceDeclCase`
- `IntoBoundSpec`
- `IntoDerivSpec`
- `IntoPieceBranch`
- Generic `IntoBoundSpec` instances for `(x, upper)` and `(x, lower, upper)` whenever the endpoint values already support `IntoScalarTerm`.

## Change Triggers
- Structured symbolic argument shapes change.
- Later elaboration or front-door wrapper code starts consuming these records directly.
- Additional tuple coercions are needed for higher-level symbolic heads.
- Bound endpoints need to accept a broader or narrower scalar-input slice.

## Related Files
- [`Binders.lean.md`](Binders.lean.md)
- [`../Examples/Scalars.lean.md`](../Examples/Scalars.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
