# `SymbolicLean/Term/Structured.lean`

## Source
- [`../../../SymbolicLean/Term/Structured.lean`](../../../SymbolicLean/Term/Structured.lean)

## Responsibilities
- Define structured pure symbolic helpers that consume `BoundSpec`, `DerivSpec`, and `PieceBranch`.
- Extend the pure term surface beyond basic calculus with bounded integrals, summations, products, lambdas, and a simple piecewise form.
- Keep these higher-level builders as extension `headApp` terms rather than new primitive constructors.

## Public Surface
- `integralUpperHeadName`
- `integralLowerHeadName`
- `integralRangeHeadName`
- `sumUpperHeadName`
- `sumLowerHeadName`
- `sumRangeHeadName`
- `productUpperHeadName`
- `productLowerHeadName`
- `productRangeHeadName`
- `lambdaHeadName`
- `piecewiseHeadName`
- `diffWith`
- `integralWith`
- `summation`
- `productTerm`
- `lambdaTerm`
- `piecewise`

## Change Triggers
- Structured symbolic argument records change.
- Additional bounded calculus or higher-order pure heads are added.
- These helpers move from compatibility builders to registry-driven elaboration output.

## Related Files
- [`../Syntax/StructuredArgs.lean.md`](../Syntax/StructuredArgs.lean.md)
- [`Calculus.lean.md`](Calculus.lean.md)
- [`RegistryHeads.lean.md`](RegistryHeads.lean.md)
