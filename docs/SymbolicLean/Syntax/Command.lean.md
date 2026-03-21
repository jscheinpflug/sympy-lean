# `SymbolicLean/Syntax/Command.lean`

## Source
- [`../../../SymbolicLean/Syntax/Command.lean`](../../../SymbolicLean/Syntax/Command.lean)

## Responsibilities
- Define the session-opening `sympy d do ...` syntax.
- Install the v1 default scalar domain for binder sugar through `DefaultScalarDomain`.
- Define the exploratory `#sympy α => expr` and `#sympy α do ...` commands over ordinary Lean syntax.
- Auto-create simple scalar symbols and unary scalar functions for the command-level exploration path.
- Warn on unresolved constructor-like or qualified heads before falling back to undefined symbolic function calls.
- Render final `Term`, `SymExpr`, and monadic results through a single command-level printer.

## Public Surface
- `sympy d do ...`
- `#sympy α => expr`
- `#sympy α do ...`

## Change Triggers
- Session-opening defaults change.
- Session configuration becomes user-configurable through syntax.
- The exploratory `#sympy` scope widens beyond scalar auto-binding and result rendering.

## Related Files
- [`../Session/Monad.lean.md`](../Session/Monad.lean.md)
- [`Assuming.lean.md`](Assuming.lean.md)
- [`Binders.lean.md`](Binders.lean.md)
- [`../Examples/Scalars.lean.md`](../Examples/Scalars.lean.md)
