# `SymbolicLean.lean`

## Source
- [`../SymbolicLean.lean`](../SymbolicLean.lean)

## Responsibilities
- Define the root library module for `SymbolicLean`.
- Aggregate the public foundation modules for declarations, backend transport, domains, sorts, sessions, runtime handles, and pure terms.
- Aggregate the public evaluation/render op layer plus the special-function, set, and pure linear-algebra head modules.
- Re-export the public carrier-based sort alias layer.

## Public Surface
- Re-exports from the current `SymbolicLean/**` foundation modules.

## Change Triggers
- Library module layout changes.
- Public import surface changes.
- New high-level submodule integration.

## Related Files
- [`SymbolicLean/Decl/Core.lean.md`](SymbolicLean/Decl/Core.lean.md)
- [`SymbolicLean/Backend/Client.lean.md`](SymbolicLean/Backend/Client.lean.md)
- [`SymbolicLean/Backend/Decode.lean.md`](SymbolicLean/Backend/Decode.lean.md)
- [`SymbolicLean/Backend/Encode.lean.md`](SymbolicLean/Backend/Encode.lean.md)
- [`SymbolicLean/Backend/Protocol.lean.md`](SymbolicLean/Backend/Protocol.lean.md)
- [`SymbolicLean/Backend/Realize.lean.md`](SymbolicLean/Backend/Realize.lean.md)
- [`SymbolicLean/Domain/Desc.lean.md`](SymbolicLean/Domain/Desc.lean.md)
- [`SymbolicLean/Sort/Aliases.lean.md`](SymbolicLean/Sort/Aliases.lean.md)
- [`SymbolicLean/Sort/Base.lean.md`](SymbolicLean/Sort/Base.lean.md)
- [`SymbolicLean/Session/Monad.lean.md`](SymbolicLean/Session/Monad.lean.md)
- [`SymbolicLean/Ops/Algebra.lean.md`](SymbolicLean/Ops/Algebra.lean.md)
- [`SymbolicLean/Ops/Calculus.lean.md`](SymbolicLean/Ops/Calculus.lean.md)
- [`SymbolicLean/Ops/Core.lean.md`](SymbolicLean/Ops/Core.lean.md)
- [`SymbolicLean/Ops/Evaluation.lean.md`](SymbolicLean/Ops/Evaluation.lean.md)
- [`SymbolicLean/Ops/LinearAlgebra.lean.md`](SymbolicLean/Ops/LinearAlgebra.lean.md)
- [`SymbolicLean/Ops/Results.lean.md`](SymbolicLean/Ops/Results.lean.md)
- [`SymbolicLean/Ops/Solvers.lean.md`](SymbolicLean/Ops/Solvers.lean.md)
- [`SymbolicLean/Syntax/Binders.lean.md`](SymbolicLean/Syntax/Binders.lean.md)
- [`SymbolicLean/Syntax/Command.lean.md`](SymbolicLean/Syntax/Command.lean.md)
- [`SymbolicLean/Syntax/Registry.lean.md`](SymbolicLean/Syntax/Registry.lean.md)
- [`SymbolicLean/Syntax/DeclareOp.lean.md`](SymbolicLean/Syntax/DeclareOp.lean.md)
- [`SymbolicLean/Syntax/Search.lean.md`](SymbolicLean/Syntax/Search.lean.md)
- [`SymbolicLean/Syntax/Subst.lean.md`](SymbolicLean/Syntax/Subst.lean.md)
- [`SymbolicLean/Term/Core.lean.md`](SymbolicLean/Term/Core.lean.md)
- [`SymbolicLean/Term/PureHeadSmoke.lean.md`](SymbolicLean/Term/PureHeadSmoke.lean.md)
- [`SymbolicLean/Term/LinearAlgebra.lean.md`](SymbolicLean/Term/LinearAlgebra.lean.md)
- [`SymbolicLean/Term/SpecialFunctions.lean.md`](SymbolicLean/Term/SpecialFunctions.lean.md)
- [`SymbolicLean/Term/Sets.lean.md`](SymbolicLean/Term/Sets.lean.md)
- [`SymbolicLean/Term/Head.lean.md`](SymbolicLean/Term/Head.lean.md)
- [`SymbolicLean/Term/View.lean.md`](SymbolicLean/Term/View.lean.md)
- [`SymbolicLean/Term/Canon.lean.md`](SymbolicLean/Term/Canon.lean.md)
- [`Main.lean.md`](Main.lean.md)
