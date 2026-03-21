# SymbolicLean Foundation Implementation

## Summary
- This plan tracks the first implementation slice of the corrected architecture.
- The current target now includes the first backend transport slice plus the first effectful algebra, calculus, linear-algebra, and solver ops over realized expressions, along with the pure-to-realized conversion layer, binder sugar for pure declarations, ordinary-term substitution sugar, the `sympy d do ...` session syntax, the ordinary-Lean `#sympy α => expr` and `#sympy α do ...` exploratory commands, the end-to-end example suite, and the registry-backed op generator slice with generated wrapper bodies, local encode/decode hooks, and attached docstrings.
- Broader generated wrappers, richer decode-aware wrapper generation, and larger syntax DSL follow-ups remain open work.

## Source Of Truth
- High-level architecture: [`../../plan.md`](../../plan.md)
- Execution checklist: [`../../todo.md`](../../todo.md)

## Current Slice
- Add `mathlib` immediately so the domain layer grows against real algebraic structure.
- Replace the bootstrap surface with the real `SymbolicLean/**` core module tree.
- Keep files small and mirrored into `/docs` in the same change set.
- Validate with `lake build` and the doc harness after each coherent batch.

## Current Status
- Public carrier aliases now exist in `SymbolicLean/Sort/Aliases.lean`.
- Pure declaration builders now expose `sym`, `symWith`, and `funSym`.
- Binder sugar accepts public carrier and matrix annotations such as `symbols (x : Rat | positive)` and `symbols (A : Mat Rat 2 2)`.
- Plain-Lean declaration ergonomics now cover `x + y`, `f x`, and `A * v` through declaration-to-term coercions and lifted operator/function instances.
- Public alias-head numerals now cover `Scalar Int` and `Scalar Rat`.
- Structured front-door builders now accept simpler tuple/decl inputs through dedicated conversion typeclasses.
- The `SymPy` namespace now covers bounded `Integral`, `Sum`, `Product`, and `Piecewise` forms on the same front door.
- Public matrix helpers now include `det`, `rref`, and `pretty` alongside the earlier `T` and `I` wrappers.
- Session syntax now accepts either `sympy d do ...` or `sympy α do ...`.
- The public scalar, matrix, and solver examples now use the carrier-based surface instead of the older internal sort/domain spellings.
- The typed head compatibility layer now exists in `SymbolicLean/Term/Head.lean`.
- Internal normalization now goes through `Term.coreView` and first projector helpers in `SymbolicLean/Term/View.lean`.
- Future encoder, reifier, and canonicalizer refactors should target `CoreView` and its projectors instead of matching directly on raw constructor packs.
- The symbolic registry foundation now exists in `SymbolicLean/Syntax/Registry.lean`.
- `declare_op` and `declare_head` now register Name-keyed metadata through the environment extension while `declare_sympy_op` remains as a compatibility surface.
- The package now builds from `lakefile.lean`.
- The default build graph now emits `.lake/build/sympy/manifest.json` from the registry through `ManifestMain.lean`.
- The backend protocol now includes manifest-version handshakes and a first `reify` request/response path.
- The Python worker now loads the generated manifest at startup and can return cached encoded terms through `reify`.
- Canonicalization now lives in `SymbolicLean/Term/Canon.lean`, and `Backend/Realize` reuses canonical remote refs for equivalent scalar terms.
- Arithmetic, logic, and relation helpers now route through the `CoreHead`/`headApp` compatibility layer while preserving the existing operator instances.
