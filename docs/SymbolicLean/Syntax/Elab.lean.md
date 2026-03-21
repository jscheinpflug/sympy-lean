# `SymbolicLean/Syntax/Elab.lean`

## Source
- [`../../../SymbolicLean/Syntax/Elab.lean`](../../../SymbolicLean/Syntax/Elab.lean)

## Responsibilities
- Provide the registry-aware `symcall%` symbolic application entrypoint.
- Offer plain-Lean capitalized builders for structured symbolic heads such as `Derivative`, `Integral`, `Limit`, `Sum`, `Product`, `Lambda`, and `Piecewise`.
- Centralize named-argument splitting and error routing for the symbolic call surface.

## Public Surface
- `symcall% name(...)`
- Builder defs:
  `Derivative`
  `Integral`
  `Limit`
  `Sum`
  `Product`
  `Lambda`
  `Piecewise`

## Change Triggers
- Update when new registry-backed structured heads need ordinary Lean builder coverage.
- Update when named-argument conventions or symbolic-call diagnostics change.
- Update when discoverability or schema validation should be shared with other syntax layers.

## Related Files
- [`../../../SymbolicLean/Syntax/Registry.lean`](../../../SymbolicLean/Syntax/Registry.lean)
- [`../../../SymbolicLean/Syntax/StructuredArgs.lean`](../../../SymbolicLean/Syntax/StructuredArgs.lean)
- [`../../../SymbolicLean/Term/Structured.lean`](../../../SymbolicLean/Term/Structured.lean)
- [`../../../docs/SymbolicLean/Examples/Scalars.lean.md`](../../../docs/SymbolicLean/Examples/Scalars.lean.md)
