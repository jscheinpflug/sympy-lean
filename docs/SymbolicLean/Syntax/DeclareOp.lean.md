# `SymbolicLean/Syntax/DeclareOp.lean`

## Source
- [`../../../SymbolicLean/Syntax/DeclareOp.lean`](../../../SymbolicLean/Syntax/DeclareOp.lean)

## Responsibilities
- Define the registry-aware generator commands for symbolic ops and heads.
- Generate realized wrappers from compact op declarations, including the current extra-argument compatibility slice.
- Generate pure extension-head helpers from compact declarations, including typed `ExtHeadSpec` declarations and optional `SymPy.*` aliases.
- Generate homogeneous variadic pure-head helpers from compact declarations through `declare_variadic_pure_head`, using list-based input on the Lean side and manifest-visible variadic `PureSpec` metadata.
- Attach manifest-visible `PureSpec` metadata for both closed pure-head declarations and the current supported generic binder slice, using serializable sort templates instead of raw syntax strings.
- Provide the reusable `IntoPureTerm` conversion layer so generated pure-head helpers can accept plain `Term` values, `SymDecl`s, and the currently supported scalar literal inputs.
- Generate both ref-returning wrappers and JSON-decoding wrappers from the same `declare_op` command family.
- Provide small keyword-argument helpers for hand-written effectful wrappers through `OpKwArg`, `opKwArg`, and `encodeKwArgs`.
- Encode the full public `Assumption` vocabulary as op arguments so effectful wrappers like `ask` stay aligned with binder/query surface growth.
- Provide shared embedded-ref decode helpers (`OpJsonRef`, `decodeEmbeddedRef`, `decodeEmbeddedRefList`, `decodeJsonArray2`) plus small session bookkeeping helpers (`rememberLiveRef`, `rememberLiveRefs`) for effectful payload decoders.
- Provide a low-priority generic `OpPayloadDecode` fallback for payload types with `[FromJson α]`, along with generic `Ref`, `List Ref`, and `(Ref × α)` payload instances, while leaving bespoke structured decoders available for richer semantic payloads.
- Let effectful registrations override coarse manifest-visible `result_mode` classification without changing the typed Lean decoder that actually consumes the payload.
- Register generated heads and ops in the symbolic environment extension while preserving the existing wrapper surface.
- Provide a metadata-only `register_op` command for hand-written effectful implementations such as structured payload decoders, including effectful dispatch overrides for method-vs-namespace routing.
- Keep the shorthand declaration forms macro-expanded onto the general elaboration paths instead of maintaining duplicate shorthand elaborators.
- Keep the wrapper-generation scope intentionally narrow to the current realized-wrapper compatibility slice.

## Public Surface
- `declare_pure_head ...`
- `declare_variadic_pure_head ...`
- `declare_scalar_fn₁ ...`
- `declare_scalar_fn₂ ...`
- `declare_head ...`
- `declare_op ...`
- `register_op name => "opName"`
- `register_op name => "opName" dispatch_method`
- `register_op name => "opName" dispatch_namespace`
- `register_op name => "opName" call_style call|attr`
- `register_op name => "opName" result_mode direct|transformed|structured`
- `register_op name => "opName" doc "..."`
- `OpKwArg`
- `opKwArg`
- `encodeKwArgs`
- `OpJsonRef`
- `decodeEmbeddedRef`
- `decodeEmbeddedRefList`
- `decodeJsonArray2`
- `rememberLiveRef`
- `rememberLiveRefs`
- `IntoPureTerm`
- `OpPayloadDecode` with the default `[FromJson α]` fallback instance
- `declare_sympy_op name => "opName"`
- `declare_sympy_op name => "opName" doc "..." `
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName"`
- `declare_sympy_op name {binders*} for (arg : SymExpr s inSort) returns outSort => "opName" doc "..."`

## Change Triggers
- Pure extension heads stop being generated as thin `headApp` builders.
- Generated wrapper shapes grow beyond the current fixed-arity realized operations or the current homogeneous variadic pure-head path.
- Registry metadata starts driving elaboration, manifest generation, or reification.
- Closed or generic pure-head declarations start emitting richer manifest metadata, especially when the supported binder-to-sort-template encoding changes.
- The project starts generating decode-heavy or pure-expression helpers from the same declaration surface.
- Generated pure-head helpers need to accept a broader pure-input conversion surface than `Term` / `SymDecl` / current numeric literals.
- The generic payload-decoding fallback needs to understand richer worker payload shapes than plain `FromJson`.
- Effectful dispatch metadata grows beyond the current method/namespace plus call/attr slice.
- The coarse manifest-side result classification stops matching the `OpPayloadDecode` helper policy.
- More metadata-only registration commands are added for pure heads or public front-door wrappers.
- The macro-expanded shorthand forms stop being equivalent to the general elaboration paths.
- Target-ref extraction or JSON payload decoding rules change.

## Related Files
- [`Registry.lean.md`](Registry.lean.md)
- [`../Ops/Algebra.lean.md`](../Ops/Algebra.lean.md)
- [`Command.lean.md`](Command.lean.md)
