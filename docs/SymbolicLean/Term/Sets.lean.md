# `SymbolicLean/Term/Sets.lean`

## Source
- [`../../../SymbolicLean/Term/Sets.lean`](../../../SymbolicLean/Term/Sets.lean)

## Responsibilities
- Define the minimal pure set vocabulary needed for the current solver-facing surface.
- Use registry-driven pure-head declarations for set constructors and `call_style attr` for `SymPy.S.*` constants.
- Keep the current set wave narrow to interval/set-combinator helpers, a homogeneous variadic `FiniteSet`, and typed scalar-set constants such as `Reals`, `Complexes`, `Rationals`, `Integers`, `Naturals`, `Naturals0`, `EmptySet`, and `UniversalSet`.

## Public Surface
- Set constructors: `Interval`, `Union`, `Intersection`, `Complement`, `FiniteSet`
- Set constants: `Reals`, `Complexes`, `Rationals`, `Integers`, `Naturals`, `Naturals0`, `EmptySet`, `UniversalSet`
- `SymPy.Interval`, `SymPy.Union`, `SymPy.Intersection`, `SymPy.Complement`, `SymPy.FiniteSet`
- `SymPy.S.Reals`, `SymPy.S.Complexes`, `SymPy.S.Rationals`, `SymPy.S.Integers`, `SymPy.S.Naturals`, `SymPy.S.Naturals0`, `SymPy.S.EmptySet`, `SymPy.S.UniversalSet`

## Change Triggers
- Solver-facing set vocabulary grows beyond the current minimal slice.
- Set-valued reification support grows beyond pretty-printing and pure-term construction.
- Public `SymPy.S.*` constant coverage changes.

## Related Files
- [`../Syntax/DeclareOp.lean.md`](../Syntax/DeclareOp.lean.md)
- [`../Examples/Solvers.lean.md`](../Examples/Solvers.lean.md)
- [`../../SymbolicLean.lean.md`](../../SymbolicLean.lean.md)
