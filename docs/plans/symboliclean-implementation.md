# SymbolicLean Foundation Implementation

## Summary
- This plan tracks the first implementation slice of the corrected architecture.
- The current target stops at the pure declaration, domain, sort, session, and `Term` layers.
- Backend transport, effectful SymPy operations, syntax DSLs, and examples remain follow-up work.

## Source Of Truth
- High-level architecture: [`../../plan.md`](../../plan.md)
- Execution checklist: [`../../todo.md`](../../todo.md)

## Current Slice
- Add `mathlib` immediately so the domain layer grows against real algebraic structure.
- Replace the bootstrap surface with the real `SymbolicLean/**` core module tree.
- Keep files small and mirrored into `/docs` in the same change set.
- Validate with `lake build` and the doc harness after each coherent batch.
