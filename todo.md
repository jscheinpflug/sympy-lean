# SymPy Import Platform Todo

This checklist tracks the platform-first SymPy import feature described in `plan.md`.

Execution rules that governed this feature:

- Do not start broad import waves until the generic platform steps are complete.
- Do not land a new family with known missing eval, reify, or wrapper support for that family.
- Keep docs and mirrored docs in sync with every source change.

Current status: all items in this feature are complete.

## Phase 0. Baseline And Acceptance Harness

Progress note:

- Final manifest inventory after the latest rebuild:
  - `102` registry entries total
  - `76` pure heads
  - `26` effectful ops
  - `100` `call` entries and `2` `attr` entries
- Final worker pure-head special cases intentionally kept in `tools/sympy_worker.py`:
  - scalar arithmetic core: `scalarNeg`, `scalarAdd`, `scalarSub`, `scalarMul`, `scalarDiv`, `scalarPow`
  - matrix arithmetic core: `matrixAdd`, `matrixSub`, `matrixMul`
  - logic core: `truth`, `not`, `and`, `or`, `implies`, `iff`
  - relation core: `relation`
  - calculus core constructors: `diff`, `integral`, `limit`
- Final worker effectful special cases intentionally kept:
  - bespoke structured decode for `rref`
  - bespoke semantic query handling for `ask`
  - small output-sort repair branches for `transpose` and `det`
- Platform delta delivered by this feature:
  - manifest-driven pure-head eval/reify/decode for fixed-arity, nullary attr, and homogeneous variadic extension heads
  - manifest-driven effectful dispatch with explicit namespace/method metadata
  - cleaner public builder UX through `IntoPureTerm`, `IntoScalarTerm`, and `realize`
  - broader example/docs coverage for scalar, set, matrix, and calculus families

- [x] Rebuild the current baseline with `lake build SymbolicLean`.
- [x] Rebuild manifest generation with `lake build sympyManifest`.
- [x] Rebuild the examples target with `lake build SymbolicLean.Examples`.
- [x] Run `python3 scripts/check_doc_harness.py --mode local --scope core`.
- [x] Record the current registry entry inventory by kind (`pureHead`, `effectfulOp`, core-only special cases).
- [x] Record the current worker pure-head special cases and classify them into:
  - core built-ins to keep
  - extension-family special cases to eliminate
- [x] Record the current worker effectful-op special cases and classify them into:
  - structured results to keep bespoke
  - dispatch paths to generalize
- [x] Record the current reify support boundaries:
  - scalar extension heads
  - set heads
  - matrix heads
  - structured calculus heads
- [x] Record the current public UX gaps visible in examples and README:
  - cast-heavy syntax
  - constructor-first calculus examples
  - missing set/matrix/predicate coverage
- [x] Add a short developer note to the checklist or commit notes describing the baseline limits that this feature is expected to remove.

## Phase 1. Complete The Registry And Manifest Contract

Progress note:

- Closed binder-free pure heads now emit concrete `pureSpec` metadata into the registry, manifest, and hover output.
- Binder-dependent pure heads in the supported binder slice now emit serializable parameterized `pureSpec` templates.
- The supported generic binder slice in this feature is:
  - `DomainDesc`
  - `Dim`
  - `SSort`
- `PureSpec.variadic?` now records homogeneous variadic head structure for manifest-driven eval/reify/decode.
- The final manifest contract covers:
  - fixed-arity pure heads
  - nullary attr constants
  - homogeneous variadic pure heads
  - effectful ops with positional args only
  - effectful ops with positional plus keyword args
  - explicit result/dispatch metadata for effectful ops
- Representative final entries:
  - `re`, `conjugate`, `Interval`, `Trace`
  - `S.Reals`, `S.Integers`
  - `Min`, `Max`, `FiniteSet`
  - `latex`, `diff`, `trace`

- [x] Inspect `SymbolicLean/Syntax/Registry.lean` and write down the exact target metadata contract needed by:
  - pure-head eval
  - pure-head reify
  - effectful dispatch
  - hover/search/docs
- [x] Decide the canonical manifest representation for:
  - fixed-arity pure heads
  - nullary attr constants
  - homogeneous variadic pure heads
  - effectful ops with positional args only
  - effectful ops with positional plus keyword args
- [x] Extend `RegistryMetadata` so the manifest carries complete runtime metadata rather than placeholders.
- [x] Make `pureSpec?` actual source-of-truth metadata instead of reserved future data.
- [x] Ensure `backendPath` is always emitted in a normalized dotted-path form.
- [x] Ensure `callStyle` is emitted and consumed consistently for both pure heads and effectful ops.
- [x] Add any missing metadata fields needed to distinguish result-shape expectations for effectful ops.
- [x] Update `ManifestMain.lean` so manifest generation serializes the new contract completely.
- [x] Rebuild `.lake/build/sympy/manifest.json` and inspect it manually for a representative set of entries.
- [x] Update hover/search rendering in `SymbolicLean/Syntax/Search.lean` so it reflects the real manifest contract.
- [x] Make sure aliases, categories, docs, and dispatch/reify/result modes remain visible in hover output.
- [x] Add at least one new smoke registry entry per metadata shape that will matter later:
  - nullary attr head
  - fixed-arity call head
  - variadic head
  - effectful op with metadata-only registration
- [x] Update mirrored docs for the registry and manifest files.

## Phase 2. Generalize Pure-Head Declaration Infrastructure

Progress note:

- `declare_pure_head` remains the canonical fixed-arity declaration path.
- `declare_variadic_pure_head` now covers homogeneous variadic call heads with a list-based public helper shape.
- The declaration layer now emits typed `ExtHeadSpec` values and consistent metadata/doc/alias output for:
  - fixed-arity call heads
  - nullary attr constants
  - homogeneous variadic call heads
  - non-scalar return sorts such as sets and matrices where supported
- Compile-time declaration coverage now includes unary, binary, attr, variadic, scalar, set, and matrix examples.

- [x] Review the current `declare_pure_head` implementation in `SymbolicLean/Syntax/DeclareOp.lean`.
- [x] Keep the existing fixed-arity declaration path as the canonical path for ordinary functions.
- [x] Extend the declaration machinery so `pureSpec?` is derived and attached for every generated pure head that should participate in generic reify.
- [x] Add or design a companion declaration path for homogeneous variadic pure heads.
- [x] Decide the Lean-side public helper shape for variadic pure heads:
  - list-based helper
  - array-based helper
  - thin convenience wrappers for the most common short arities
- [x] Generate typed `ExtHeadSpec` values for the new variadic path as well as the fixed-arity path.
- [x] Ensure generated pure-head helpers attach docstrings, aliases, and optional `SymPy.*` aliases consistently.
- [x] Ensure declaration-time metadata generation is identical for `call` and `attr` heads.
- [x] Add compile-only smoke declarations covering:
  - unary scalar call head
  - binary scalar call head
  - nullary attr constant
  - variadic homogeneous head
  - non-scalar return sort if supported by metadata
- [x] Verify that generated declarations appear in hover/search with the expected metadata.
- [x] Update mirrored docs for `DeclareOp.lean`.

## Phase 3. Make Worker Pure-Head Evaluation Fully Manifest-Driven

Progress note:

- Extension pure-head eval is now manifest-driven.
- Manifest lookup is dispatch-mode aware, so pure and effectful entries can safely share one SymPy backend name.
- Supported generic pure-head worker eval now includes:
  - nullary attr constants
  - fixed-arity call heads of arbitrary arity
  - homogeneous variadic call heads
  - dotted backend paths
- Explicit worker branches now remain only for intended term-core heads, not extension families.
- Bad metadata and unsupported backend paths now fail with explicit `ProtocolError`s.

- [x] Inspect `tools/sympy_worker.py` and list the remaining extension pure-head branches that should be removed.
- [x] Keep explicit worker branches only for true term-core heads:
  - scalar arithmetic
  - matrix arithmetic
  - logic heads
  - relation heads
  - built-in calculus constructors
  - other core typed heads that are not extension metadata
- [x] Build manifest indexes in the worker for:
  - pure call heads by backend path
  - pure attr heads by backend path
  - reify lookup by callable/object identity where possible
- [x] Generalize pure-head eval so extension heads dispatch only through manifest metadata.
- [x] Support nullary attr constants with zero positional args.
- [x] Support fixed-arity call heads of arbitrary arity.
- [x] Support homogeneous variadic call heads.
- [x] Validate that bad metadata fails loudly with a useful `ProtocolError`.
- [x] Keep recursion-depth protections intact for generic head evaluation.
- [x] Add worker-side smoke coverage for:
  - dotted backend path resolution
  - attr dispatch
  - variadic dispatch
  - unsupported backend path errors
- [x] Rebuild manifest and test the new worker behavior against the smoke declarations.

## Phase 4. Make Worker Reify Manifest-Driven For Supported Families

Progress note:

- Worker-side generic reify now consults manifest `pureSpec` metadata instead of the old scalar-only callable table.
- Covered generic reify slice at feature close:
  - scalar heads such as `sin`, `atan2`, `Min`, `Max`
  - set heads such as `Interval`, `Union`, `FiniteSet`
  - pure matrix heads such as `Trace`
  - nullary attr constants such as `SymPy.S.Reals`
- Core arithmetic/logic/calculus heads remain explicitly handled as intended.
- Failure boundaries remain explicit for unsupported broader families rather than silently inventing ad hoc reify behavior.

- [x] Review the current reify path in `tools/sympy_worker.py`.
- [x] Separate core built-in reify from extension-family reify.
- [x] Keep hard-coded reify only for:
  - arithmetic and logic core heads
  - structured calculus core heads
  - any other term-core shape that is not an extension head
- [x] Build reverse manifest lookup for extension pure heads.
- [x] Reify nullary attr constants through manifest metadata.
- [x] Reify fixed-arity extension call heads through manifest metadata.
- [x] Reify homogeneous variadic extension call heads through manifest metadata.
- [x] Extend reify support beyond the current scalar-only slice to the supported sorts in the manifest contract:
  - boolean
  - set
  - matrix
  - tuple or sequence, if those sorts are added in this feature
- [x] Verify that reify preserves the declared backend name rather than inventing ad hoc names.
- [x] Add round-trip smoke tests:
  - `eval -> reify` for pure heads
  - `simplify/doit -> reify` for extension heads that claim reify support
- [x] Add failure tests for values that cannot yet be reified generically and ensure the error is explicit.

## Phase 5. Generalize Lean-Side Decode For Extension Heads

Progress note:

- Lean-side decode now rebuilds fixed-arity and homogeneous-variadic extension heads from manifest-compatible `pureSpec` data.
- Covered generic decode slice at feature close:
  - scalar-returning extension heads
  - set-returning extension heads
  - matrix-returning extension heads imported in this feature
  - nullary attr constants
- Core arithmetic/logic/calculus decode stays on explicit branches.

- [x] Review `SymbolicLean/Backend/Decode.lean` and identify the generic extension-head decode path.
- [x] Extend `decodeTermAny` / `decodeTermAs` so extension heads are rebuilt from manifest-compatible `pureSpec?` data rather than special-casing only a narrow scalar slice.
- [x] Make generic decode work for all supported fixed-arity extension heads.
- [x] Make generic decode work for nullary attr constants.
- [x] Make generic decode work for homogeneous variadic heads if that path is added.
- [x] Preserve explicit decode branches for core calculus heads such as `diff`, `integral`, and `limit`.
- [x] Add decode smoke tests for:
  - scalar-returning extension heads
  - set-returning extension heads
  - matrix-returning extension heads if imported in this feature
  - nullary attr constants
- [x] Ensure malformed worker payloads still produce good decode errors.
- [x] Update mirrored docs for `Decode.lean` if the public behavior changed materially.

## Phase 6. Generalize Effectful Op Declaration And Worker Dispatch

Progress note:

- Effectful ops now carry explicit manifest-visible dispatch metadata:
  - `effectfulDispatch = method | namespace`
  - normalized `backendPath`
  - existing `callStyle`
  - coarse `resultMode`
- `register_op` now works as the metadata-only override path for hand-written wrappers.
- Keyword arguments have a Lean-side helper surface through `OpKwArg`, `opKwArg`, and `encodeKwArgs`.
- The worker now dispatches audited effectful ops through manifest metadata instead of backend-name flattening.
- Error surfacing for bad keyword names and bad dotted paths is explicit and op-aware.

- [x] Review the existing `declare_op` and `register_op` surface in `SymbolicLean/Syntax/DeclareOp.lean`.
- [x] Decide the canonical metadata representation for effectful ops with:
  - instance-method dispatch
  - namespace-function dispatch
  - dotted backend paths
  - keyword arguments
  - optional trailing arguments
- [x] Extend declaration metadata so the worker can dispatch effectful ops without flattening everything to one `backendName`.
- [x] Add Lean-side syntax or helper support for keyword arguments where broad SymPy coverage needs it.
- [x] Extend `OpArgEncode` or companion helpers so common keyword/value argument shapes encode cleanly.
- [x] Update `tools/sympy_worker.py` `apply_op` to use manifest metadata for effectful dispatch.
- [x] Support dotted backend paths for effectful ops.
- [x] Support dispatch to instance methods and top-level namespace functions.
- [x] Support keyword argument forwarding.
- [x] Preserve custom worker branches only for genuinely special structured results such as `rref`.
- [x] Add worker-side smoke ops covering:
  - method call with positional args
  - method call with kwargs
  - namespace function with positional args
  - namespace function with kwargs
- [x] Add good error messages for bad keyword names and bad dispatch paths.

## Phase 7. Broaden Effectful Decode And Result Modes

Progress note:

- Final audited effectful result inventory:
  - direct worker `Ref` payloads for ordinary realized-expression results
  - plain JSON scalars/strings/bools through `[FromJson α]`
  - embedded `List Ref` payloads such as finite `solve`
  - embedded `(Ref × α)` payloads such as `rref`
  - bespoke semantic JSON payloads such as satisfiable models and truth-like values
- Shared decode helpers for embedded refs now live in the declaration layer and are reused by solver/matrix structured decoders.
- Stable split for this feature:
  - manifest `resultMode` for discoverability and coarse runtime contract
  - generic decode helpers for reusable transport shapes
  - bespoke decoders only for semantically structured results

- [x] Inventory current effectful result shapes returned by algebra, calculus, solver, matrix, and evaluation operations.
- [x] Keep the low-priority `[FromJson α]` fallback for direct JSON results.
- [x] Add generic decode helpers for common result shapes that broad import will need:
  - direct `Ref`
  - list of refs
  - tuple of refs
  - mixed JSON payload with embedded refs
  - plain strings and booleans
- [x] Decide whether these generic result shapes live in:
  - metadata result modes
  - helper decoders
  - small typed wrappers
- [x] Refactor existing bespoke decoders to use the generic helpers where possible.
- [x] Keep bespoke decoders only for semantically structured results such as:
  - finite solve results
  - satisfiable models
  - `rref`
  - other structured solver payloads
- [x] Add validation for each new generic result mode.
- [x] Update mirrored docs for the op declaration layer if public extension guidance changed.

## Phase 8. Finish The Pure-Term Ergonomic Layer

Progress note:

- The stable responsibility split is now documented and used in examples:
  - `IntoTerm` for generic sort-directed conversion
  - `IntoPureTerm` for pure-head helper inputs
  - `IntoScalarTerm` for scalar builders/operators/relations
- Builder-side ergonomic improvements now include:
  - `Integral (x ^ 2) (x, a, b)`
  - `Sum x (x, n)`
  - `Limit ... x 1`
  - `Piecewise (x, gt x 0) 0`
- Relation builders now accept converted inputs on both sides.
- The public pure/effectful boundary now uses `realize` instead of raw `eval` in user-facing examples.
- The safe scalar-literal slice now includes mixed rational division.
- Domain ambiguity remains explicit by design, and negative examples preserve that boundary.

- [x] Review the current `IntoTerm`, `IntoPureTerm`, and `IntoScalarTerm` split.
- [x] Decide the stable responsibility of each conversion class and document it in code comments/docs.
- [x] Expand the scalar mixed-arithmetic support beyond the current narrow slice where safe.
- [x] Add the remaining common literal/operator combinations that users expect in ordinary symbolic math.
- [x] Improve relation-builder ergonomics so imported predicate families inherit the same convenience surface.
- [x] Improve structured-builder inference for:
  - bounds
  - limits
  - piecewise branches
  - other tuple-shaped symbolic builders that new coverage will use
- [x] Decide whether `Piecewise ... 0` should become inference-friendly in this feature or remain an explicit documented limitation.
- [x] Decide whether the pure/effectful boundary should gain a more ergonomic helper than raw `eval` for declarations.
- [x] Keep domain ambiguity failures explicit rather than adding unsafe implicit coercions.
- [x] Add compile-time examples covering the final ergonomic guarantees.
- [x] Update mirrored docs for the affected term and syntax modules.

## Phase 9. Refactor And Generate The Public Wrapper Surface

Progress note:

- The existing small generator inventory in `SymbolicLean/Ops/Core.lean` is now the accepted wrapper-generation surface for this feature.
- New public front doors landed on that generator surface rather than introducing a second abstraction layer:
  - `realize`
  - `differentiate`
  - `trace`
- Hand-written wrappers remain only where they add stronger typing, better defaults, or genuinely better UX than the generic generators.

- [x] Inventory the current manual repetition in `SymbolicLean/Ops/Core.lean`.
- [x] Group wrappers into categories that can share one generator:
  - pure namespace aliases
  - pure method forms
  - effectful namespace aliases
  - effectful method forms
  - constant namespaces such as `SymPy.Q` and `SymPy.S`
- [x] Design one small set of generator commands/macros that can emit those wrapper categories from declarative input.
- [x] Preserve existing wrapper names where they are already the intended public API.
- [x] Move repetitive current wrappers onto the new generators.
- [x] Keep hand-written wrappers only where they add:
  - stronger typing
  - good default arguments
  - materially better UX than the generic generator would provide
- [x] Ensure generated wrappers attach docs consistently.
- [x] Ensure generated wrappers keep hover/search metadata discoverable.
- [x] Update mirrored docs for `Ops/Core.lean`.

## Phase 10. Canonicalize The Calculus And Evaluation UX

Progress note:

- README and `docs/project-guide.md` now teach eager operations as the ordinary workflow.
- Capitalized calculus forms remain documented as pure symbolic builders.
- The eager public front-door gap is closed with `differentiate`, so users no longer have to infer an eager path from `Derivative`.
- Evaluation examples now present the intended public story:
  - build pure terms where appropriate
  - `realize` when crossing to realized expressions
  - use eager ops such as `integrate`, `differentiate`, `latex`, `doit`, and `evalf`
  - reify only when a pure term is actually needed again

- [x] Audit README, project guide, and example files for constructor-first calculus workflows.
- [x] Make eager operations the canonical documented path where they are the natural user action:
  - `integrate`
  - `solve`
  - `doit`
  - `evalf`
  - `latex`
- [x] Keep pure builders documented as typed symbolic constructors for kernel-level and proof-adjacent use.
- [x] Decide whether `diff` should get a more explicit eager public front door in addition to `Derivative`.
- [x] Ensure examples explain when a value is still pure `Term` and when it becomes a realized `SymExpr`.
- [x] Update calculus examples to avoid making `.doit` look mandatory for ordinary workflows.
- [x] Update evaluation examples so they demonstrate the cleanest public story.
- [x] Re-run all calculus/evaluation example files after the docs update.

## Phase 11. Coverage Wave A - Scalar Functions And Predicates

Progress note:

- High-value scalar coverage in this feature closes with:
  - existing unary fixed-arity functions such as `sin`, `cos`, `log`, `exp`, `sqrt`, `conjugate`, `re`, `im`
  - existing binary fixed-arity functions such as `atan2`
  - new homogeneous variadics `Min` and `Max`
  - predicate-facing relation ergonomics that integrate cleanly with `ask` workflows
- Representative compile/runtime/hover/reify coverage lives in `Examples/SpecialFunctions.lean` and `Examples/Scalars.lean`.

- [x] Inventory the highest-value top-level scalar pure heads still missing from the current surface.
- [x] Split them into shape-compatible batches:
  - unary fixed-arity call heads
  - binary fixed-arity call heads
  - homogeneous variadic call heads
  - attr constants
- [x] Import the unary fixed-arity batch through the generic declaration path.
- [x] Import the binary fixed-arity batch through the generic declaration path.
- [x] Import any needed homogeneous variadic scalar constructors through the variadic path.
- [x] Import common predicate/query-facing pure helpers needed by `ask` and relation-heavy workflows.
- [x] Add compile-time and runtime examples for each batch.
- [x] Add hover/search checks for representative imported names.
- [x] Add reify round-trip coverage for representative imported names.
- [x] Update README and the special-functions examples only after the runtime path is green.

## Phase 12. Coverage Wave B - Sets And Assumption-Facing Vocabulary

Progress note:

- Supported set slice at feature close:
  - attr constants `SymPy.S.Reals`, `SymPy.S.Integers`
  - fixed-arity constructors such as `Interval`
  - homogeneous variadics such as `FiniteSet`
  - existing generic-path set heads such as `Union`, `Intersection`, and `Complement`
- Solver examples now compose this set vocabulary directly in runtime code instead of only printing opaque solver results.

- [x] Inventory the high-value set constructors and constants needed for realistic solver workflows.
- [x] Import nullary attr constants such as `SymPy.S.Reals` and `SymPy.S.Integers` through the generic attr path.
- [x] Import fixed-arity set constructors such as `Interval` through the generic path.
- [x] Import homogeneous variadic set constructors such as `FiniteSet` and `Union` if the variadic platform is ready.
- [x] Add any missing set relation or membership helpers needed for user-facing examples.
- [x] Validate pretty-printing, eval, and reify for the supported set slice.
- [x] Update solver examples so they compose the new set vocabulary rather than only printing opaque results.
- [x] Add hover/search checks for representative set constructors and constants.
- [x] Update README and project guide set examples.

## Phase 13. Coverage Wave C - Matrix And Linear-Algebra Expansion

Progress note:

- This feature added the next clean matrix slice on top of the existing determinant/inverse/transpose/`rref` coverage:
  - pure matrix head `Trace`
  - effectful matrix op `trace`
- `rref` remains bespoke only where the structured result genuinely requires it.
- Matrix docs/examples now show both pure and effectful paths explicitly.

- [x] Inventory the next matrix/linear-algebra operations after the current determinant, inverse, transpose, and `rref` slice.
- [x] Separate pure matrix heads from effectful matrix ops.
- [x] Import the pure matrix heads that fit the generic extension path cleanly.
- [x] Import effectful matrix ops that can use the generalized op-dispatch path.
- [x] Keep bespoke decoding only for structured matrix results that genuinely need it.
- [x] Add matrix examples that exercise:
  - pure matrix term construction
  - effectful matrix operations
  - any matrix reify claims made by the new platform
- [x] Update hover/search for the imported matrix ops and heads.
- [x] Update matrix docs/examples after the runtime path is green.

## Phase 14. Coverage Wave D - Calculus Builders And Eager Calculus Surface

Progress note:

- Final calculus split:
  - pure symbolic constructors: `Derivative`, `Integral`, `Sum`, `Product`, `Limit`
  - eager realized operations: `integrate`, `differentiate`, `doit`, `evalf`, `latex`
  - structured builder sugar: tuple/bound convenience through the final builder path for this feature
- Example coverage now shows:
  - build pure term
  - evaluate effectfully
  - render or reify the result

- [x] Inventory the calculus constructors and eager operations that should be part of the broad public surface.
- [x] Separate:
  - pure symbolic constructors
  - eager realized operations
  - structured builder sugar
- [x] Import any missing calculus names only after the wrapper and dispatch platform can support them cleanly.
- [x] Ensure bounded integrals, sums, products, and limits use the final intended structured-argument UX.
- [x] Ensure representative calculus results can be pretty-printed and, where claimed, reified.
- [x] Add examples that show the recommended workflow for:
  - build pure term
  - evaluate effectfully
  - render or reify result
- [x] Update docs so calculus no longer feels split-brain.

## Phase 15. Coverage Wave E - Remaining High-Value Top-Level Families

Progress note:

- This feature deliberately stops after proving the platform on the intended high-value families:
  - scalar functions and predicates
  - sets and assumption-facing vocabulary
  - matrix trace on top of the existing linear-algebra slice
  - eager calculus front doors
- Low-value and niche subpackages remain out of scope for this feature and belong in the next explicit import backlog.

- [x] Identify the next broad, high-value SymPy families that fit the new generic platform.
- [x] Explicitly exclude low-value or niche subpackages from this wave unless they become product goals.
- [x] For each candidate family, confirm before starting that:
  - pure/effectful shape is already supported
  - wrapper generation already supports the public surface
  - docs/examples can be added without inventing a one-off UX
- [x] Import the family through declarations first, wrappers second, docs/examples third.
- [x] Add representative runtime examples and hover/search coverage.
- [x] Add at least one reify or structured decode validation per family where that claim is part of the surface.

## Phase 16. Docs, Examples, And Discoverability Sweep

Progress note:

- README, `docs/project-guide.md`, mirrored docs, and examples were updated through the final platform surface.
- Newly imported public heads/ops are discoverable through examples and hover/search, including:
  - `Min`, `Max`
  - `FiniteSet`, `Reals`
  - `Trace`, `trace`
  - `differentiate`
- The negative example remains intact to teach the intentional scalar-domain boundary around real literals.

- [x] Audit README for outdated syntax, cast-heavy examples, and non-canonical workflows.
- [x] Audit `docs/project-guide.md` for outdated architecture claims after the platform changes.
- [x] Audit mirrored docs for every touched `SymbolicLean/**` file.
- [x] Update example modules to match the final intended UX by family.
- [x] Add new example modules if an existing file becomes a dumping ground.
- [x] Ensure every newly imported public head/op is reachable through:
  - at least one example
  - hover or search
  - one docs mention in the relevant family docs
- [x] Keep negative examples and proof-boundary examples intact where they still teach a real boundary.

## Phase 17. Final Acceptance Gate

Progress note:

- Final green checks in this workspace:
  - `lake build SymbolicLean`
  - `lake build sympyManifest`
  - `lake build SymbolicLean.Examples`
  - `python3 scripts/check_doc_harness.py --mode local --scope core`
  - representative `lake env lean` runs for `SpecialFunctions`, `Solvers`, `Matrices`, `Evaluation`, and `Negative`
- Final representative manifest inspection confirms:
  - variadic `pureSpec` for `Min`, `Max`, and `FiniteSet`
  - fixed-arity matrix pure-head metadata for `Trace`
  - dispatch-mode-aware coexistence of pure `diff` / effectful `diff` and pure `Trace` / effectful `trace`
- Platform conclusion:
  - the repo can now continue broad import family-by-family without reopening the worker, manifest, or wrapper architecture questions that motivated this feature

- [x] Run `lake build SymbolicLean`.
- [x] Run `lake build sympyManifest`.
- [x] Run `lake build SymbolicLean.Examples`.
- [x] Run the key example files individually with `lake env lean` so runtime output is visible.
- [x] Run `python3 scripts/check_doc_harness.py --mode local --scope core`.
- [x] Inspect hover/search for a representative sample from each imported family.
- [x] Inspect the generated manifest for representative entries from each supported metadata shape.
- [x] Verify that the new platform removed, rather than increased, manual worker and wrapper code in the targeted areas.
- [x] Confirm that broad import can now proceed family-by-family without reopening architecture questions.
- [x] Only after that, start the next explicit import backlog using the same grouped-wave discipline.
