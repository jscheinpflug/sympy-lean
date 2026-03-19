# `SymbolicLean.lean`

## Source
- [`../SymbolicLean.lean`](../SymbolicLean.lean)

## Responsibilities
- Define the root library module for `SymbolicLean`.
- Aggregate the public foundation modules for declarations, domains, sorts, sessions, runtime handles, and pure terms.

## Public Surface
- Re-exports from the current `SymbolicLean/**` foundation modules.

## Change Triggers
- Library module layout changes.
- Public import surface changes.
- New high-level submodule integration.

## Related Files
- [`SymbolicLean/Decl/Core.lean.md`](SymbolicLean/Decl/Core.lean.md)
- [`SymbolicLean/Domain/Desc.lean.md`](SymbolicLean/Domain/Desc.lean.md)
- [`SymbolicLean/Sort/Base.lean.md`](SymbolicLean/Sort/Base.lean.md)
- [`SymbolicLean/Session/Monad.lean.md`](SymbolicLean/Session/Monad.lean.md)
- [`SymbolicLean/Term/Core.lean.md`](SymbolicLean/Term/Core.lean.md)
- [`Main.lean.md`](Main.lean.md)
