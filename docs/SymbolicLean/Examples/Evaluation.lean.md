# `SymbolicLean/Examples/Evaluation.lean`

## Source
- [`../../../SymbolicLean/Examples/Evaluation.lean`](../../../SymbolicLean/Examples/Evaluation.lean)

## Responsibilities
- Demonstrate the canonical public evaluation/render front door on declarations, terms, and realized expressions.
- Smoke-test registry hover/search coverage for representative public effectful ops.
- Smoke-test end-to-end `integrate`, `doit`, `evalf`, `latex`, and `reify` workflows.

## Public Surface
- Registry commands `#sympy_hover "rref"`, `#sympy_hover "solve"`, and `#sympy_search "latex"`.
- Typechecking smoke coverage for `SymDecl.latex` and `SymExpr.evalf`.
- Executable examples for `integrate`, `doit`, `evalf`, `latex`, and a composed `doit`/`latex`/`reify` round-trip.

## Change Triggers
- Public evaluation/render wrappers change.
- Registry discoverability requirements change.
- Evaluation examples become broad enough to split again.

## Related Files
- [`../Ops/Evaluation.lean.md`](../Ops/Evaluation.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Search.lean.md`](../Syntax/Search.lean.md)
