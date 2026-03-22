# `SymbolicLean/Term/SpecialFunctions.lean`

## Source
- [`../../../SymbolicLean/Term/SpecialFunctions.lean`](../../../SymbolicLean/Term/SpecialFunctions.lean)

## Responsibilities
- Define the first production pure-head wave for scalar special functions.
- Use the registry-driven `declare_scalar_fn₁`, `declare_scalar_fn₂`, and `declare_pure_head` machinery instead of hand-written helpers.
- Expose both plain `SymbolicLean.*` helpers and `SymPy.*` aliases for the supported special-function surface.
- Keep the current wave focused on unary/binary scalar heads, a small homogeneous variadic scalar slice (`Min` / `Max`), and the minimal complex-part extraction slice.

## Public Surface
- Trigonometric heads: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`
- Hyperbolic heads: `sinh`, `cosh`, `tanh`
- Exponential/logarithmic heads: `exp`, `log`, `sqrt`
- Scalar utility heads: `Abs`, `sign`, `floor`, `ceiling`
- Homogeneous variadic scalar heads: `Min`, `Max`
- Complex heads: `re`, `im`, `conjugate`, `arg`
- `SymPy.*` aliases for the same declarations

## Change Triggers
- The special-function coverage wave grows or changes.
- Generic scalar pure-head evaluation or reification support changes.
- Some heads need richer sort information than the current unary/binary scalar slice can express.

## Related Files
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Examples/SpecialFunctions.lean.md`](../Examples/SpecialFunctions.lean.md)
- [`../../SymbolicLean.lean.md`](../../SymbolicLean.lean.md)
