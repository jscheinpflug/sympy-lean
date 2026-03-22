# `SymbolicLean/Ops/Evaluation.lean`

## Source
- [`../../../SymbolicLean/Ops/Evaluation.lean`](../../../SymbolicLean/Ops/Evaluation.lean)

## Responsibilities
- Define the registry-backed realized evaluation and rendering operations over `SymExpr` values.
- Keep `doit`, `evalf`, and `latex` as raw backend-facing ops that the public front door in `Ops/Core` can lift over pure inputs.
- Use the generic `declare_op ... decodes String` path for string-returning rendering results.

## Public Surface
- `doitExpr`
- `evalfExpr`
- `latexText`

## Change Triggers
- Evaluation or rendering op coverage changes.
- Worker op names or string-payload conventions change.
- The public front-door wrappers in `Ops/Core` stop being thin adapters over these raw ops.

## Related Files
- [`Core.lean.md`](Core.lean.md)
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Examples/Evaluation.lean.md`](../Examples/Evaluation.lean.md)
