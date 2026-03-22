# `SymbolicLean/Syntax/Registry.lean`

## Source
- [`../../../SymbolicLean/Syntax/Registry.lean`](../../../SymbolicLean/Syntax/Registry.lean)

## Responsibilities
- Define the symbolic registry entry schema and environment extension.
- Track registry entries by declaration name for elaboration-time lookup.
- Provide the shared metadata layer for heads and effectful ops, including backend dispatch paths, call style, explicit effectful method-vs-namespace dispatch, coarse result-mode classification, optional pure-head specs, aliases, and search categories.
- Carry closed and supported generic pure-head argument/result sort metadata into the manifest so hover/search and later runtime consumers can see both concrete and parameterized extension-head signatures, including homogeneous variadic heads.
- Keep `ResultMode` intentionally coarse: the manifest says whether an op is direct, transformed, or structured, while Lean-side `OpPayloadDecode` instances still own the exact payload transport details.

## Public Surface
- `RegistryKind`
- `SurfaceRole`
- `DispatchMode`
- `ReifyMode`
- `ResultMode`
- `CallStyle`
- `EffectfulDispatch`
- `PureSpec`
- `RegistryMetadata`
- `RegistryEntry`
- `PureSpec.variadic?` for homogeneous variadic pure heads
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
