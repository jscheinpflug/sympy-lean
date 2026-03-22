# `SymbolicLean/Examples/SpecialFunctions.lean`

## Source
- [`../../../SymbolicLean/Examples/SpecialFunctions.lean`](../../../SymbolicLean/Examples/SpecialFunctions.lean)

## Responsibilities
- Demonstrate the first public special-function wave on the carrier-based plain-Lean front door.
- Smoke-test pure special-function term construction, `SymPy.*` aliases, and `#sympy` exploration without helper-local `Term` ascriptions for ordinary `SymDecl` inputs in direct pure-head calls.
- Smoke-test registry-driven worker evaluation for the production special-function heads.
- Smoke-test composed exponential/logarithm examples and complex-part rendering through the generic pure-head path.
- Smoke-test generic worker-side reification fallback for representative unary and binary special-function heads.

## Public Surface
- Typechecking examples for trigonometric, logarithmic, square-root, exponential, and complex-part pure heads.
- `#sympy` examples for exploratory special-function term construction.
- Executable examples covering effectful simplification / pretty-printing for rational and complex heads plus round-trip `reify` checks for `sin` and `atan2`.

## Change Triggers
- The special-function coverage wave changes.
- Generic scalar-head evaluation or reification support changes.
- Special-function examples become too broad for one file and need splitting.

## Related Files
- [`../Term/SpecialFunctions.lean.md`](../Term/SpecialFunctions.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
