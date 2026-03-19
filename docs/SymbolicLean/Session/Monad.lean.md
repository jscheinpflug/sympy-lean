# `SymbolicLean/Session/Monad.lean`

## Source
- [`../../../SymbolicLean/Session/Monad.lean`](../../../SymbolicLean/Session/Monad.lean)

## Responsibilities
- Define the session monad stack for effectful symbolic work.
- Provide the `withSession` entrypoint used to scope runtime handles.

## Public Surface
- `SymPyM`
- `withSession`

## Change Triggers
- Session monad composition changes.
- Runtime handle scoping changes.
- Backend client integration starts using real session resources.

## Related Files
- [`Errors.lean.md`](Errors.lean.md)
- [`State.lean.md`](State.lean.md)
- [`../SymExpr/Core.lean.md`](../SymExpr/Core.lean.md)
