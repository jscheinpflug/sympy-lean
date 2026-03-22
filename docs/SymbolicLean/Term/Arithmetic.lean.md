# `SymbolicLean/Term/Arithmetic.lean`

## Source
- [`../../../SymbolicLean/Term/Arithmetic.lean`](../../../SymbolicLean/Term/Arithmetic.lean)

## Responsibilities
- Define arithmetic capability classes for pure terms.
- Provide operator instances for scalar and matrix arithmetic that stays in the pure layer.
- Lift the arithmetic surface over declarations so plain-Lean code can write `x + y` and `A * v`.
- Route scalar mixed-domain `+`, `-`, and `*` through `UnifyDomain`.
- Provide the current safe rational-domain literal division slice so plain Lean can write forms such as `x / 2` and `(1 : Rat) / x` without explicit `Term` casts.
- Route arithmetic smart constructors through the `CoreHead`/`headApp` compatibility layer.

## Public Surface
- `CanNeg`
- `CanAdd`
- `CanSub`
- `CanMul`
- `CanDiv`
- `CanPow`
- lifted arithmetic instances for `SymDecl`

## Change Triggers
- Pure arithmetic coverage changes.
- Matrix arithmetic typing changes.
- `UnifyDomain` output rules or scalar coercion behavior changes.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Domain/Classes.lean.md`](../Domain/Classes.lean.md)
