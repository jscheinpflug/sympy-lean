# `SymbolicLean/Examples/Evaluation.lean`

## Source
- [`../../../SymbolicLean/Examples/Evaluation.lean`](../../../SymbolicLean/Examples/Evaluation.lean)

## Responsibilities
- Demonstrate the canonical public evaluation/render front door on declarations, terms, and realized expressions.
- Demonstrate `realize` as the public pure/effectful boundary helper when examples need an explicit realized handle before a later op.
- Smoke-test registry hover/search coverage for representative public effectful ops.
- Smoke-test end-to-end `integrate`, `differentiate`, `doit`, `evalf`, `latex`, and `reify` workflows.
- Smoke-test manifest-driven effectful dispatch beyond the flat legacy path, including dotted namespace calls and keyword-bearing method/namespace calls.

## Public Surface
- Registry commands `#sympy_hover "rref"`, `#sympy_hover "solve"`, `#sympy_hover "satisfiable"`, `#sympy_hover "ask"`, `#sympy_hover "Smoke.latexModeText"`, `#sympy_hover "differentiate"`, and `#sympy_search "latex"`.
- Typechecking smoke coverage for `SymDecl.latex` and `SymExpr.evalf`.
- Executable examples for `integrate`, `differentiate`, `doit`, `evalf`, `latex`, `realize`, a dotted `srepr` call, method and namespace kwargs dispatch, and an eager `integrate`/`latex`/`reify` round-trip.

## Change Triggers
- Public evaluation/render wrappers change.
- Registry discoverability requirements change.
- Evaluation examples become broad enough to split again.

## Related Files
- [`../Ops/Evaluation.lean.md`](../Ops/Evaluation.lean.md)
- [`../Ops/Core.lean.md`](../Ops/Core.lean.md)
- [`../Syntax/Search.lean.md`](../Syntax/Search.lean.md)
