# `SymbolicLean/Term/View.lean`

## Source
- [`../../../SymbolicLean/Term/View.lean`](../../../SymbolicLean/Term/View.lean)

## Responsibilities
- Normalize legacy `Term` constructors into a smaller internal view.
- Represent migrated operator families through typed heads while keeping atoms, literals, calculus binders, and application primitive.
- Provide small projector helpers for backend and canonicalization work.
- Keep the compatibility projectors stable while migrated families move from legacy constructors to stored heads.

## Public Surface
- `BinaryView`
- `IntegralView`
- `CoreView`
- `Term.coreView`
- `Term.asAdd?`
- `Term.asIntegral?`
- `Term.asPiecewise?`

## Change Triggers
- Internal term normalization strategy changes.
- Projector coverage grows beyond the first compatibility slice.
- Backend encode/reify/canonicalization code starts consuming `CoreView` directly.

## Related Files
- [`Head.lean.md`](Head.lean.md)
- [`Core.lean.md`](Core.lean.md)
- [`Calculus.lean.md`](Calculus.lean.md)
