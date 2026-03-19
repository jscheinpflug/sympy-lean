# `SymbolicLean/Syntax/DeclareOp.lean`

## Source
- [`../../../SymbolicLean/Syntax/DeclareOp.lean`](../../../SymbolicLean/Syntax/DeclareOp.lean)

## Responsibilities
- Define the first `declare_sympy_op` generator command.
- Generate unary realized wrappers from compact declarations.
- Generate the wrapper body, a small encode hook, a small decode hook, and an attached docstring from one declaration.
- Keep the scope intentionally narrow to unary realized wrappers, with one sort-preserving form and one explicit-output form.

## Public Surface
- `declare_sympy_op name => "opName"`
- `declare_sympy_op name => "opName" doc "..." `
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName"`
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName" doc "..."`

## Change Triggers
- Generated wrapper shapes grow beyond unary realized operations.
- The project starts generating decode-heavy or pure-expression helpers from the same declaration surface.

## Related Files
- [`../Ops/Algebra.lean.md`](../Ops/Algebra.lean.md)
- [`Command.lean.md`](Command.lean.md)
