# `ManifestMain.lean`

## Source
- [`../ManifestMain.lean`](../ManifestMain.lean)

## Responsibilities
- Load the `SymbolicLean` environment with extensions enabled.
- Collect registry entries into a stable manifest order.
- Emit the build artifact `.lake/build/sympy/manifest.json` with manifest version data.
- Provide the manifest consumed by the Python worker at startup.
- Build the manifest environment through a synthetic `runFrontend` import so extension state is populated.

## Public Surface
- `manifestVersion`
- `RegistryManifest`
- executable entrypoint `main`

## Change Triggers
- Manifest JSON schema changes.
- Registry entry serialization changes.
- The manifest emitter needs additional build metadata.
- Extension-collection behavior changes across imported versus frontend-built environments.

## Related Files
- [`lakefile.lean.md`](lakefile.lean.md)
- [`SymbolicLean/Syntax/Registry.lean.md`](SymbolicLean/Syntax/Registry.lean.md)
- [`SymbolicLean/Backend/Protocol.lean.md`](SymbolicLean/Backend/Protocol.lean.md)
