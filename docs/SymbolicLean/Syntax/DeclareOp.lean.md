# `SymbolicLean/Syntax/DeclareOp.lean`

## Source
- [`../../../SymbolicLean/Syntax/DeclareOp.lean`](../../../SymbolicLean/Syntax/DeclareOp.lean)

## Responsibilities
- Define the registry-aware generator commands for symbolic ops and heads.
- Generate realized wrappers from compact op declarations, including the current extra-argument compatibility slice.
- Generate both ref-returning wrappers and JSON-decoding wrappers from the same `declare_op` command family.
- Register heads and ops in the symbolic environment extension while preserving the existing wrapper surface.
- Keep the wrapper-generation scope intentionally narrow to the current realized-wrapper compatibility slice.

## Public Surface
- `declare_head ...`
- `declare_op ...`
- `declare_sympy_op name => "opName"`
- `declare_sympy_op name => "opName" doc "..." `
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName"`
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName" doc "..."`

## Change Triggers
- Generated wrapper shapes grow beyond the current fixed-arity realized operations.
- Registry metadata starts driving elaboration, manifest generation, or reification.
- The project starts generating decode-heavy or pure-expression helpers from the same declaration surface.
- Target-ref extraction or JSON payload decoding rules change.

## Related Files
- [`Registry.lean.md`](Registry.lean.md)
- [`../Ops/Algebra.lean.md`](../Ops/Algebra.lean.md)
- [`Command.lean.md`](Command.lean.md)
