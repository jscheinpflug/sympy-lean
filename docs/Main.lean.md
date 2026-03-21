# `Main.lean`

## Source
- [`../Main.lean`](../Main.lean)

## Responsibilities
- Define the minimal executable smoke entrypoint.
- Confirm the root library import builds into a runnable binary.

## Public Surface
- `main : IO Unit`

## Change Triggers
- Smoke output changes.
- Executable bootstrap changes.
- Root import behavior changes.

## Related Files
- [`SymbolicLean.lean.md`](SymbolicLean.lean.md)
- [`lakefile.lean.md`](lakefile.lean.md)
