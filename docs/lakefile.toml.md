# `lakefile.toml`

## Source
- [`../lakefile.toml`](../lakefile.toml)

## Responsibilities
- Define Lake package metadata.
- Declare external dependencies.
- Declare Lean library and executable targets.

## Public Surface
- Package identity (`name`, `version`, `defaultTargets`).
- Dependencies such as `mathlib`.
- Build targets (`lean_lib`, `lean_exe`).

## Change Triggers
- Target renames or additions.
- Package structure changes.
- Build pipeline configuration changes.

## Related Files
- [`lean-toolchain.md`](lean-toolchain.md)
- [`lake-manifest.json.md`](lake-manifest.json.md)
- [`Main.lean.md`](Main.lean.md)
