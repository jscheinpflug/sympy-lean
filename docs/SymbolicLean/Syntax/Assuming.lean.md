# `SymbolicLean/Syntax/Assuming.lean`

## Source
- [`../../../SymbolicLean/Syntax/Assuming.lean`](../../../SymbolicLean/Syntax/Assuming.lean)

## Responsibilities
- Define ordinary-Lean `assuming [x ↦ SymPy.Q.positive] do ...` syntax for scoped declaration assumptions.
- Shadow existing `SymDecl` binders with additional `AssumptionFact`s inside nested monadic `do` blocks.
- Keep assumption scoping on the same session/evaluation surface rather than introducing a second expression language.

## Public Surface
- `assuming [...] do ...`

## Change Triggers
- Assumption-scoping syntax changes.
- `SymDecl` assumption extension helpers change.
- Session-scoped symbolic evaluation starts carrying richer assumption metadata.

## Related Files
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
- [`Command.lean.md`](Command.lean.md)
- [`../Examples/Solvers.lean.md`](../Examples/Solvers.lean.md)
