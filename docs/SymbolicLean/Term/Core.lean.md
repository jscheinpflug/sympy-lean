# `SymbolicLean/Term/Core.lean`

## Source
- [`../../../SymbolicLean/Term/Core.lean`](../../../SymbolicLean/Term/Core.lean)

## Responsibilities
- Define pure symbolic atoms, heterogeneous argument lists, and the typed `Term` AST.
- Keep the pure expression layer separate from runtime handles and backend effects.

## Public Surface
- `Atom`
- `Args`
- `Term`
- `Atom.ofDecl`
- `Atom.ofFun`
- `Args.singleton`
- `Args.pair`

## Change Triggers
- Pure term constructors change.
- Declaration-to-term boundaries change.
- New pure expression forms are added.

## Related Files
- [`Literals.lean.md`](Literals.lean.md)
- [`Arithmetic.lean.md`](Arithmetic.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
