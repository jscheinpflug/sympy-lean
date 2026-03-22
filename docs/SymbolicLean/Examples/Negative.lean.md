# `SymbolicLean/Examples/Negative.lean`

## Source
- [`../../../SymbolicLean/Examples/Negative.lean`](../../../SymbolicLean/Examples/Negative.lean)

## Responsibilities
- Pin representative compile-time rejection cases with `#guard_msgs`.

## Public Surface
- Negative examples for dimension mismatch, non-field inversion, invalid differentiation variables, removed `term!`, rejected raw-domain binder syntax, missing implicit real-literal coercions, unresolved qualified-head fallback warnings, and worker startup version mismatches.

## Change Triggers
- Error surfaces or failure modes change.
- The type-level legality checks move.

## Related Files
- [`../Ops/LinearAlgebra.lean.md`](../Ops/LinearAlgebra.lean.md)
- [`../Term/Calculus.lean.md`](../Term/Calculus.lean.md)
- [`../Syntax/Command.lean.md`](../Syntax/Command.lean.md)
