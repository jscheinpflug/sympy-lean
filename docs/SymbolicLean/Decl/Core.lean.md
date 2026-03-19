# `SymbolicLean/Decl/Core.lean`

## Source
- [`../../../SymbolicLean/Decl/Core.lean`](../../../SymbolicLean/Decl/Core.lean)

## Responsibilities
- Define pure symbolic declarations and function declarations.
- Define stable declaration keys used for future session-local interning.

## Public Surface
- `SymDecl`
- `FunDecl`
- `DeclKind`
- `DeclKey`
- `SymDecl.key`
- `FunDecl.key`

## Change Triggers
- Declaration identity changes.
- Sort-indexed declaration API changes.
- Session interning requirements.

## Related Files
- [`Assumptions.lean.md`](Assumptions.lean.md)
- [`../Sort/Base.lean.md`](../Sort/Base.lean.md)
- [`../Session/State.lean.md`](../Session/State.lean.md)
