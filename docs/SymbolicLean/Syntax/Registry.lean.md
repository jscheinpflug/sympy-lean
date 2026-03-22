# `SymbolicLean/Syntax/Registry.lean`

## Source
- [`../../../SymbolicLean/Syntax/Registry.lean`](../../../SymbolicLean/Syntax/Registry.lean)

## Responsibilities
- Define the symbolic registry entry schema and environment extension.
- Track registry entries by declaration name for elaboration-time lookup.
- Provide the shared metadata layer for heads and effectful ops, including backend dispatch paths, call style, optional pure-head specs, aliases, and search categories.

## Public Surface
- `RegistryKind`
- `SurfaceRole`
- `DispatchMode`
- `ReifyMode`
- `ResultMode`
- `CallStyle`
- `PureSpec`
- `RegistryMetadata`
- `RegistryEntry`
- `addRegistryEntry`
- `findRegistryEntry?`
- `registryEntries`

## Change Triggers
- Registry metadata grows beyond the current manifest-backed dispatch slice.
- Elaboration starts reading richer schema data out of the environment extension.
- Build-manifest generation begins consuming the registry directly.

## Related Files
- [`DeclareOp.lean.md`](DeclareOp.lean.md)
- [`../Term/Head.lean.md`](../Term/Head.lean.md)
- [`../../plans/symboliclean-implementation.md`](../../plans/symboliclean-implementation.md)
