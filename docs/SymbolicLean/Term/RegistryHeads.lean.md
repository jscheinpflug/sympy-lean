# `SymbolicLean/Term/RegistryHeads.lean`

## Source
- [`../../../SymbolicLean/Term/RegistryHeads.lean`](../../../SymbolicLean/Term/RegistryHeads.lean)

## Responsibilities
- Register manifest-backed pure symbolic heads through the shared registry extension.
- Keep pure-head manifest identities close to the term-layer backend names.
- Provide the manifest entries consumed by the Python worker for generic pure-head evaluation.

## Public Surface
- registry entries for the pure scalar, matrix, boolean, relation, membership, and calculus heads

## Change Triggers
- New pure heads are added to the term layer.
- Backend-facing head names change.
- The manifest starts carrying richer pure-head metadata.

## Related Files
- [`Head.lean.md`](Head.lean.md)
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../../ManifestMain.lean.md`](../../ManifestMain.lean.md)
