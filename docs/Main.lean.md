# `Main.lean`

## Source
- [`../Main.lean`](../Main.lean)

## Responsibilities
- Define the executable entrypoint.
- Wire top-level library imports into a runnable binary.

## Public Surface
- `main : IO Unit`

## Change Triggers
- CLI behavior changes.
- Startup flow or initialization changes.
- Output format changes for executable smoke runs.

## Related Files
- [`SymbolicLean.lean.md`](SymbolicLean.lean.md)
- [`lakefile.toml.md`](lakefile.toml.md)
