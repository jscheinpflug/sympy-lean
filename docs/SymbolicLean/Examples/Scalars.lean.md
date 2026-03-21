# `SymbolicLean/Examples/Scalars.lean`

## Source
- [`../../../SymbolicLean/Examples/Scalars.lean`](../../../SymbolicLean/Examples/Scalars.lean)

## Responsibilities
- Demonstrate end-to-end scalar algebra workflows on the carrier-based plain-Lean surface.
- Smoke-test the ordinary-Lean `#sympy` command path.
- Smoke-test alias-head numeral support for the public `Scalar Int` and `Scalar Rat` surface.
- Smoke-test structured symbolic argument tuple coercions.
- Smoke-test method-form scalar wrappers through Lean field notation.
- Smoke-test namespace-form `SymPy.*` wrappers on the same surface.
- Smoke-test structured pure heads for bounded calculus, products, lambdas, and a simple piecewise form.
- Smoke-test the registry-backed `symcall%` entrypoint and capitalized structured builders.
- Smoke-test dictionary and indexing surface syntax at the typechecked pure-term layer.
- Smoke-test canonical cache reuse for scalar expressions during the example build.
- Smoke-test `reify(eval(t))` against canonicalized pure terms for migrated arithmetic, relation, and unevaluated calculus heads.
- Smoke-test worker-side fallback reification for effectful scalar algebra results.

## Public Surface
- Typechecking examples for `x + y`, unary `f x`, direct numerals over `Scalar Int`/`Scalar Rat`, bounded `Integral`/`Sum`/`Product`, and `Piecewise`.
- Executable scalar examples for `#sympy`, `sympy Rat do`, structured-argument tuples, `symcall%`, capitalized structured builders, `SymPy.Integral`/`SymPy.Sum`/`SymPy.Product`/`SymPy.Piecewise`, field-notation factorization, `pretty`, cancellation, substitution, dictionary/indexing syntax, cache reuse, and both pure and effectful reification checks.

## Change Triggers
- Scalar front-door APIs change.
- Plain-Lean scalar elaboration changes.
- Example output expectations change.

## Related Files
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Subst.lean.md`](../Syntax/Subst.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
