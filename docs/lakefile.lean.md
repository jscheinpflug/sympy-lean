# `lakefile.lean`

## Source
- [`../lakefile.lean`](../lakefile.lean)

## Responsibilities
- Define the Lake package in Lean DSL form.
- Declare the library, executable, and manifest-emitter executable targets.
- Make `.lake/build/sympy/manifest.json` part of the default build graph.

## Public Surface
- Package identity and dependency declarations.
- Default build targets for `SymbolicLean`, `symbolic-lean`, and the manifest file.
- The `sympyManifest` target that emits `.lake/build/sympy/manifest.json`.

## Change Triggers
- Package structure or dependencies change.
- Manifest build wiring or output path changes.
- The build needs additional generated artifacts.

## Related Files
- [`ManifestMain.lean.md`](ManifestMain.lean.md)
- [`lake-manifest.json.md`](lake-manifest.json.md)
- [`SymbolicLean/Syntax/Registry.lean.md`](SymbolicLean/Syntax/Registry.lean.md)
