# `SymbolicLean/Syntax/Command.lean`

## Source
- [`../../../SymbolicLean/Syntax/Command.lean`](../../../SymbolicLean/Syntax/Command.lean)

## Responsibilities
- Define the session-opening `sympy d do ...` syntax.
- Install the v1 default scalar domain for binder sugar through `DefaultScalarDomain`.
- Define the narrow exploratory `#sympy d => expr` command with auto-created free scalar symbols.

## Public Surface
- `sympy d do ...`
- `#sympy d => expr`

## Change Triggers
- Session-opening defaults change.
- Session configuration becomes user-configurable through syntax.
- The exploratory `#sympy` scope widens beyond scalar symbol auto-creation.

## Related Files
- [`../Session/Monad.lean.md`](../Session/Monad.lean.md)
- [`Binders.lean.md`](Binders.lean.md)
- [`Term.lean.md`](Term.lean.md)
