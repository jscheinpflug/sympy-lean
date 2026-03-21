# `SymbolicLean/Term/Application.lean`

## Source
- [`../../../SymbolicLean/Term/Application.lean`](../../../SymbolicLean/Term/Application.lean)

## Responsibilities
- Provide explicit helpers for applying pure function terms.
- Keep unary function-call ergonomics separate from the core AST definition.
- Make declared unary functions callable in plain Lean syntax.

## Public Surface
- `applyN`
- `apply1`
- `apply2`
- unary `CoeFun` instance for `Term (.fn [σ] ret)`
- unary `CoeFun` instance for `FunDecl [σ] ret`

## Change Triggers
- Function-application ergonomics change.
- Higher-arity helper coverage changes.
- Syntax elaboration starts targeting different application helpers.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Decl/Core.lean.md`](../Decl/Core.lean.md)
