# `SymbolicLean/Term/Sets.lean`

## Source
- [`../../../SymbolicLean/Term/Sets.lean`](../../../SymbolicLean/Term/Sets.lean)

## Responsibilities
- Define the minimal pure set vocabulary needed for the current solver-facing surface.
- Use registry-driven pure-head declarations for set constructors and `call_style attr` for `S.Reals` / `S.Integers`.
- Keep the current set wave narrow to interval/set-combinator helpers and the two public `SymPy.S.*` constants.

## Public Surface
- Set constructors: `Interval`, `Union`, `Intersection`, `Complement`
- Set constants: `Reals`, `Integers`
- `SymPy.Interval`, `SymPy.Union`, `SymPy.Intersection`, `SymPy.Complement`
- `SymPy.S.Reals`, `SymPy.S.Integers`

## Change Triggers
- Solver-facing set vocabulary grows beyond the current minimal slice.
- Set-valued reification support grows beyond pretty-printing and pure-term construction.
- Public `SymPy.S.*` constant coverage changes.

## Related Files
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Examples/Solvers.lean.md`](../Examples/Solvers.lean.md)
- [`../../SymbolicLean.lean.md`](../../SymbolicLean.lean.md)
