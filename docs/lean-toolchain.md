# `lean-toolchain`

## Source
- [`../lean-toolchain`](../lean-toolchain)

## Responsibilities
- Pin Lean toolchain version for deterministic local and CI builds.

## Public Surface
- Toolchain selector string consumed by `elan`/`lake`.

## Change Triggers
- Lean version upgrades.
- Compatibility fixes across local and CI environments.

## Related Files
- [`lakefile.lean.md`](lakefile.lean.md)
- [`.github/workflows/lean_action_ci.yml.md`](.github/workflows/lean_action_ci.yml.md)
