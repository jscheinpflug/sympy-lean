# `SymbolicLean/Examples/Scalars.lean`

## Source
- [`../../../SymbolicLean/Examples/Scalars.lean`](../../../SymbolicLean/Examples/Scalars.lean)

## Responsibilities
- Demonstrate end-to-end scalar algebra workflows on the carrier-based plain-Lean surface.
- Smoke-test the generated `declare_pure_head` / `declare_scalar_fn₁` / `declare_scalar_fn₂` command surface at compile time.
- Smoke-test the ordinary-Lean `#sympy` command path.
- Smoke-test alias-head numeral support for the public `Scalar Int` and `Scalar Rat` surface.
- Smoke-test structured symbolic argument tuple coercions, including both literal and symbolic bounds on the public `Integral` / `Sum` / `Product` surface.
- Smoke-test literal endpoint and fallback inference on the public `Limit` / `Piecewise` builder surface.
- Smoke-test the current safe rational mixed-division surface on both sides of `/`.
- Smoke-test method-form scalar wrappers through Lean field notation.
- Smoke-test namespace-form `SymPy.*` wrappers on the same surface.
- Smoke-test structured pure heads for bounded calculus, products, lambdas, relation builders like `gt x 0`, and a simple piecewise form.
- Smoke-test the registry-backed `symcall%` entrypoint and capitalized structured builders.
- Smoke-test dictionary and indexing surface syntax at the typechecked pure-term layer.
- Keep the main scalar example fast enough to run standalone, leaving deeper runtime smoke to `Examples/ScalarsRuntime.lean`.

## Public Surface
- Typechecking examples for `x + y`, mixed scalar expressions like `x + 1`, rational mixed division like `x / 2` and `(1 : Rat) / x`, symmetric relation builders like `lt 0 x` / `eq_ x 0`, unary `f x`, direct numerals over `Scalar Int`/`Scalar Rat`, bounded `Integral`/`Sum`/`Product` with literal or symbolic bounds, literal-friendly `Limit`, and `Piecewise`.
- Generated smoke declarations under `SymbolicLean.Smoke` for unary and binary scalar pure heads backed by `sympy.sin` and `sympy.atan2`, plus the string-decoding effectful smoke op `sreprText`.
- Executable scalar examples for `#sympy`, `sympy Rat do`, structured-argument tuples, symbolic-bound `Integral`, `symcall%`, capitalized structured builders, `SymPy.Integral`/`SymPy.Sum`/`SymPy.Product`/`SymPy.Piecewise`, and dictionary/indexing syntax, with the heavier runtime and reify checks split into `Examples/ScalarsRuntime.lean`.

## Change Triggers
- Scalar front-door APIs change.
- Plain-Lean scalar elaboration changes.
- Example output expectations change.

## Related Files
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Subst.lean.md`](../Syntax/Subst.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
- [`ScalarsRuntime.lean.md`](ScalarsRuntime.lean.md)
