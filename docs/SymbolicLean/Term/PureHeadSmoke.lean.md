# `SymbolicLean/Term/PureHeadSmoke.lean`

## Source
- [`../../../SymbolicLean/Term/PureHeadSmoke.lean`](../../../SymbolicLean/Term/PureHeadSmoke.lean)

## Responsibilities
- Define library-imported smoke declarations for generated pure heads.
- Keep one unary and one binary scalar declaration available to exercise registry-backed pure-head evaluation end to end.
- Keep one string-decoding effectful smoke op available to exercise the generic `[FromJson α]` payload path end to end.
- Expose a minimal `SymPy.*` alias smoke path without committing to the broader special-function surface yet.

## Public Surface
- `SymbolicLean.Smoke.smokeUnary`
- `SymbolicLean.Smoke.smokeBinary`
- `SymbolicLean.Smoke.sreprText`
- `SymPy.smokeUnary`

## Change Triggers
- Generated pure-head declarations move out of smoke coverage and into production modules.
- Worker-side generic pure-head evaluation requirements change.
- Generic effectful payload decoding moves beyond plain `FromJson`-driven results.
- The project replaces smoke declarations with first-wave special-function coverage.

## Related Files
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Examples/Scalars.lean.md`](../Examples/Scalars.lean.md)
- [`../../SymbolicLean.lean.md`](../../SymbolicLean.lean.md)
