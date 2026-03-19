# `SymbolicLean/Domain/Desc.lean`

## Source
- [`../../../SymbolicLean/Domain/Desc.lean`](../../../SymbolicLean/Domain/Desc.lean)

## Responsibilities
- Define the recursive symbolic domain language.
- Represent ground domains, polynomial presentations, algebraic extensions, and quotients.

## Public Surface
- `GroundDom`
- `PolyPresentation`
- `AlgRelation`
- `IdealRelation`
- `DomainDesc`

## Change Triggers
- Recursive domain constructors change.
- Ground-domain coverage changes.
- Extension or quotient payload requirements change.

## Related Files
- [`Dim.lean.md`](Dim.lean.md)
- [`VarCtx.lean.md`](VarCtx.lean.md)
- [`Classes.lean.md`](Classes.lean.md)
