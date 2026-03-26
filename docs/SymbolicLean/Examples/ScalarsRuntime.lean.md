# `SymbolicLean/Examples/ScalarsRuntime.lean`

## Source
- [`../../../SymbolicLean/Examples/ScalarsRuntime.lean`](../../../SymbolicLean/Examples/ScalarsRuntime.lean)

## Responsibilities
- Batch the deeper scalar runtime smoke tests into two backend sessions so the main `Examples/Scalars.lean` file stays fast enough to run standalone.
- Exercise public scalar runtime fronts such as `factor`, field-notation methods, `SymPy.*` wrappers, cancellation, substitution, and rational mixed division through actual worker calls.
- Exercise the generic `[FromJson String]` effectful decode path with `Smoke.sreprText`.
- Exercise cache reuse, `realize`, and `reify` round trips for arithmetic, relations, unevaluated calculus heads, effectful simplification, and registry-backed smoke heads, including the duplicate-backend pure-head identity path.

## Public Surface
- Executable runtime smoke for `factor`, `expr.factor`, `SymPy.simplify`, `pretty`, `cancel`, substitution, `Smoke.smokeUnary`, `Smoke.smokeBinary`, `Smoke.sreprText`, and mixed rational division.
- Executable reify/cache-reuse smoke for `realize`, `reify`, `SymPy.Integral`, `simplify`, and the registry-backed smoke heads, including duplicate-backend unary declarations that both lower to `sin`.

## Change Triggers
- Scalar runtime example latency regresses.
- Public scalar runtime or reify behavior changes.
- The main `Examples/Scalars.lean` file needs to stay small/fast.

## Related Files
- [`Scalars.lean.md`](Scalars.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Backend/Decode.lean.md`](../Backend/Decode.lean.md)
