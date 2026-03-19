# `SymbolicLean/Syntax/DeclareOp.lean`

## Source
- [`../../../SymbolicLean/Syntax/DeclareOp.lean`](../../../SymbolicLean/Syntax/DeclareOp.lean)

## Responsibilities
- Define the first `declare_sympy_op` generator command.
- Generate narrow unary sort-preserving realized wrappers from a compact declaration.

## Public Surface
- `declare_sympy_op name => "opName"`

## Change Triggers
- Generated wrapper shapes grow beyond unary sort-preserving operations.
- The project starts generating decode-heavy or pure-expression helpers from the same declaration surface.

## Related Files
- [`../Ops/Algebra.lean.md`](../Ops/Algebra.lean.md)
- [`Command.lean.md`](Command.lean.md)
