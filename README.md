# symbolic-lean

# SymbolicLean Project Plan

## Project Motivation

SymbolicLean exists to make symbolic computation inside Lean typed, ergonomic, and explicit.

Today, a Lean user who wants SymPy-level symbolic power usually ends up in one of three bad positions:
- drop to Python and lose Lean-side structure,
- move symbolic expressions through raw strings and hope they stay aligned,
- or try to rebuild large parts of a CAS inside Lean.

This project takes a narrower and more practical route. SymPy remains the computation engine, but Lean gets a typed interface around it so that:
- symbolic expressions can be built in Lean without stringly glue,
- illegal operations are rejected before they reach SymPy,
- common workflows stay concise enough to feel like normal symbolic mathematics,
- the boundary between Lean structure and backend computation stays explicit.

The project is not trying to prove every SymPy computation correct, and it is not trying to reimplement SymPy inside Lean. The goal is a disciplined bridge:
- Lean checks expression formation, domain discipline, matrix dimensions, declaration identity, and session safety.
- SymPy performs the actual symbolic computation.

## Documentation Harness

This project uses a docs-first agentic harness:
- `AGENTS.md` and `CLAUDE.md` are index files only.
- Canonical guidance lives in [`docs/index.md`](docs/index.md).
- Core source files are mirrored into `/docs` with the same relative path plus `.md`.

## Validate Doc Contracts

```bash
python3 scripts/check_doc_harness.py --mode local --scope core
```

CI runs the same checker in warn mode (`--mode ci`) and reports drift as annotations.
