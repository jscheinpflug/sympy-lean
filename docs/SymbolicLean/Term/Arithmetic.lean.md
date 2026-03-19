# `SymbolicLean/Term/Arithmetic.lean`

## Source
- [`../../../SymbolicLean/Term/Arithmetic.lean`](../../../SymbolicLean/Term/Arithmetic.lean)

## Responsibilities
- Define arithmetic capability classes for pure terms.
- Provide operator instances for scalar and matrix arithmetic that stays in the pure layer.
- Route scalar mixed-domain `+`, `-`, and `*` through `UnifyDomain`.

## Public Surface
- `CanNeg`
- `CanAdd`
- `CanSub`
- `CanMul`
- `CanDiv`
- `CanPow`

## Change Triggers
- Pure arithmetic coverage changes.
- Matrix arithmetic typing changes.
- `UnifyDomain` output rules or scalar coercion behavior changes.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Domain/Classes.lean.md`](../Domain/Classes.lean.md)
