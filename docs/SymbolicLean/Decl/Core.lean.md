# `SymbolicLean/Decl/Core.lean`

## Source
- [`../../../SymbolicLean/Decl/Core.lean`](../../../SymbolicLean/Decl/Core.lean)

## Responsibilities
- Define pure symbolic declarations and function declarations.
- Provide the public declaration builders used by plain-Lean examples and binder sugar.
- Define stable declaration keys used for future session-local interning.

## Public Surface
- `SymDecl`
- `FunDecl`
- `symWith`
- `sym`
- `SymDecl.withAssumptions`
- `SymDecl.addAssumption`
- `funSym`
- `DeclKind`
- `DeclKey`
- `SymDecl.key`
- `FunDecl.key`

## Change Triggers
- Declaration identity changes.
- Sort-indexed declaration API changes.
- Public declaration-construction helpers change.
- Assumption-scoping helpers change.
- Session interning requirements.

## Related Files
- [`Assumptions.lean.md`](Assumptions.lean.md)
- [`../Sort/Base.lean.md`](../Sort/Base.lean.md)
- [`../Session/State.lean.md`](../Session/State.lean.md)
