# `SymbolicLean/Sort/Aliases.lean`

## Source
- [`../../../SymbolicLean/Sort/Aliases.lean`](../../../SymbolicLean/Sort/Aliases.lean)

## Responsibilities
- Provide the public carrier-based sort aliases used by the plain-Lean surface.
- Bridge public carrier types such as `Rat` and `Complex` back to symbolic domains.
- Re-expose the domain-interpretation instances needed by carrier-based aliases.

## Public Surface
- `SymCarrier`
- `carrierDomain`
- `Scalar`
- `Mat`
- `MatD`
- `Vec`

## Change Triggers
- Public sort naming changes.
- Carrier-backed domain lookup changes.
- Alias-based examples or binders need additional sort families.

## Related Files
- [`Base.lean.md`](Base.lean.md)
- [`../Domain/Classes.lean.md`](../Domain/Classes.lean.md)
- [`../Syntax/Binders.lean.md`](../Syntax/Binders.lean.md)
