# `SymbolicLean/Term/Canon.lean`

## Source
- [`../../../SymbolicLean/Term/Canon.lean`](../../../SymbolicLean/Term/Canon.lean)

## Responsibilities
- Normalize typed `Term` trees before backend realization.
- Fold selected integer and rational literals, eliminate simple identities, and flatten associative cores.
- Produce stable fingerprints for the session-level canonical ref cache.

## Public Surface
- `Term.canonicalize`
- `Term.fingerprint`

## Change Triggers
- Canonical equivalence rules change.
- Backend interning starts depending on stronger normalization guarantees.
- Additional head families need canonical ordering or literal folding.

## Related Files
- [`../Backend/Realize.lean.md`](../Backend/Realize.lean.md)
- [`../Backend/Encode.lean.md`](../Backend/Encode.lean.md)
- [`Core.lean.md`](Core.lean.md)
