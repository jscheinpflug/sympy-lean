# `SymbolicLean/Decl/Assumptions.lean`

## Source
- [`../../../SymbolicLean/Decl/Assumptions.lean`](../../../SymbolicLean/Decl/Assumptions.lean)

## Responsibilities
- Define the pure assumption vocabulary attached to symbolic declarations.
- Provide typed assumption facts that are stable before any backend session exists.
- Keep declaration assumptions serializable across the backend protocol boundary.

## Public Surface
- `Assumption`
- `Polarity`
- `AssumptionFact`

## Change Triggers
- Assumption vocabulary changes.
- Declaration identity changes that require richer assumption facts.
- Backend realization requirements for assumptions.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../../standards/lean-engineering.md`](../../standards/lean-engineering.md)
