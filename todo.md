# Execution Todo

This checklist turns the production UX/extensibility plan into an implementation sequence. Each phase is meant to leave the repo in a green, shippable state before moving on.

## Phase 1: Registry Metadata Foundation

- [x] Extend `RegistryMetadata` with:
  - `backendPath : List String`
  - `callStyle : call | attr`
  - `pureSpec? : Option { args : List SSort, result : SSort }`
- [x] Add any required JSON derivations so the enriched metadata reaches the generated manifest.
- [x] Add a metadata-only `register_op` command for hand-written effectful implementations.
- [x] Keep existing `declare_op` / `declare_head` behavior working on top of the same registry path.
- [x] Update mirrored docs for the registry and declaration layer.
- [x] Validate:
  - `lake build SymbolicLean`
  - `python3 scripts/check_doc_harness.py --mode local --scope core`

## Phase 2: Generic Pure-Head Declaration Commands

- [x] Implement `declare_pure_head` in the syntax/registry layer.
- [x] Make it generate:
  - registry entry
  - typed `ExtHeadSpec`
  - Lean term helper
  - optional `SymPy.*` alias
- [x] Add scalar sugar:
  - `declare_scalar_fn₁`
  - `declare_scalar_fn₂`
- [x] Keep the existing core arithmetic/logic/calculus heads unchanged.
- [x] Add one compile-only smoke declaration:
  - a unary scalar head
  - a binary scalar head
- [x] Update mirrored docs for the declaration command surface.
- [x] Validate:
  - `lake build SymbolicLean`
  - smoke examples typecheck
  - doc harness passes

## Phase 3: Worker Generic Pure-Head Evaluation

- [x] Replace the current hard-coded pure-head fallback in `tools/sympy_worker.py` with registry-driven dispatch.
- [x] Implement dotted-path resolution for `backendPath`.
- [x] Implement `callStyle.call` and `callStyle.attr`.
- [x] Preserve the existing custom behavior for core arithmetic/logic/calculus heads.
- [x] Add runtime smoke coverage for a test unary head and a test binary head.
- [x] Validate:
  - evaluating a declared scalar pure head works
  - `pretty` on the evaluated result works
  - build and doc harness stay green

## Phase 4: Worker Reify Support For The New Public Surface

- [x] Add generic reify fallback for registered unary/binary scalar call-heads.
- [x] Add reify support for the small public nullary attribute constants needed in this slice.
- [x] Do not broaden reify to unsupported variadic or general set/tensor shapes yet.
- [x] Add round-trip tests:
  - `eval` → `reify` for representative scalar heads
  - `eval` → `pretty` for public constants used in solver UX
- [x] Update docs to state what generic reify now covers and what remains deferred.
- [x] Validate:
  - round-trip tests pass
  - build and doc harness pass

## Phase 5: Effectful Op Decode Cleanup

- [x] Add a generic `OpPayloadDecode` fallback for `[FromJson α]`.
- [x] Keep explicit instances only where `FromJson` is not enough.
- [x] Verify that string-returning ops can use the `decodes` path cleanly.
- [x] Update mirrored docs for the effectful declaration layer.
- [x] Validate:
  - a `String`-decoding smoke op compiles and runs
  - existing structured decoders still compile
  - build and doc harness pass

## Phase 6: Registry Coverage For Public Effectful Ops

- [x] Convert the current `rref` gap to a registry-backed path using `register_op`.
- [x] Audit public effectful ops and ensure none remain outside the registry.
- [x] Improve doc strings for:
  - `inv`
  - `det`
  - `rref`
  - `solve`
  - `solveset`
  - `integrate`
  - `latex`
- [x] Add hover/search checks for the updated entries.
- [x] Validate:
  - `#sympy_hover rref`
  - `#sympy_hover solve`
  - `#sympy_search "latex"`
  - build and doc harness pass

## Phase 7: Public Front Doors And Naming Cleanup

- [x] Add public wrappers for:
  - `integrate`
  - `doit`
  - `evalf`
  - `latex`
  - `solve`
- [x] Keep `solveUnivariate` as a compatibility alias in this slice.
- [x] Prefer SymPy-like canonical names in docs/examples without broadly reshaping current signatures.
- [x] Generate term/symexpr/symdecl methods and `SymPy.*` aliases where appropriate.
- [x] Update docs to distinguish:
  - pure constructors: `Integral`, `Sum`, `Product`, `Piecewise`
  - effectful ops: `integrate`, `doit`, `evalf`, `latex`
- [x] Validate:
  - new wrappers compile from `Term`, `SymDecl`, and `SymExpr` where intended
  - example snippets run
  - build and doc harness pass

## Phase 8: First Coverage Wave - Scalar Special Functions

- [x] Create `SymbolicLean/Term/SpecialFunctions.lean`.
- [x] Register and expose:
  - `sin`, `cos`, `tan`
  - `asin`, `acos`, `atan`, `atan2`
  - `sinh`, `cosh`, `tanh`
  - `exp`, `log`, `sqrt`
  - `Abs`, `sign`, `floor`, `ceiling`
  - `re`, `im`, `conjugate`, `arg`
- [x] Add the mirrored doc for the new module.
- [x] Import the module from `SymbolicLean.lean`.
- [x] Add example coverage showing:
  - pure use
  - `#sympy` exploration
  - effectful simplification / pretty-printing
  - round-trip `reify` for representative heads
- [x] Do not add variadic functions like `Max`, `Min`, or `FiniteSet` in this phase.
- [x] Validate:
  - build
  - new examples compile and run
  - doc harness passes

## Phase 9: Eval/Render UX

- [x] Add `SymbolicLean/Ops/Evaluation.lean`.
- [x] Implement:
  - `doit`
  - `evalf`
  - `latex`
- [x] Add public front doors and generated methods/aliases in `Ops/Core`.
- [x] Update README and docs with canonical eval/render examples.
- [x] Add runtime tests for:
  - `doit` on an unevaluated integral or sum
  - `evalf` with explicit precision
  - `latex` string output
- [x] Validate:
  - build
  - examples run
  - doc harness passes

## Phase 10: Solver And Set UX Follow-Up

- [x] Create `SymbolicLean/Term/Sets.lean`.
- [x] Add the minimal set vocabulary needed for production solver workflows:
  - `Interval`
  - `Union`
  - `Intersection`
  - `Complement`
  - `SymPy.S.Reals`
  - `SymPy.S.Integers`
- [x] Use the same registry-driven pure-head machinery plus `callStyle.attr` where needed.
- [x] Add the mirrored doc for the new module.
- [x] Import it from `SymbolicLean.lean`.
- [x] Update solver examples so `solveset` is shown both as a pretty-printed result and in terms of the new pure set constants.
- [x] Validate:
  - build
  - solver examples run
  - doc harness passes

## Phase 11: Documentation And Example Consolidation

- [x] Refresh `README.md` to present the canonical production surface.
- [x] Refresh `docs/project-guide.md` extension guidance so it matches the new registry-driven workflow.
- [x] Update mirrored docs for every touched module in the same change set.
- [x] Add a dedicated example module for special functions if the scalar example file becomes too noisy.
- [x] Add a dedicated example module for eval/render UX if needed.
- [x] Validate:
  - `lake build SymbolicLean`
  - `lake build SymbolicLean.Examples`
  - `lake env lean` on all example modules
  - `python3 scripts/check_doc_harness.py --mode local --scope core`

## Final Acceptance Gate

- [x] A new unary or binary scalar SymPy function can be added with one declaration plus docs/examples.
- [x] New pure scalar heads evaluate, pretty-print, and reify in the supported slice.
- [x] Public effectful ops are registry-backed and searchable.
- [x] Canonical docs/examples use SymPy-aligned naming and valid Lean syntax.
- [x] The repo is green on build, examples, and doc harness.
