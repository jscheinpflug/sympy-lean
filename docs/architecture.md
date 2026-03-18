# Architecture and Doc Harness

## Core Principle
Repository state is the system of record. Documentation is versioned in `/docs` and discovered progressively through short index files.

## Entry Points
- `AGENTS.md` and `CLAUDE.md` are index-only documents.
- Deep guidance lives in `/docs` and is linked, not duplicated.

## Mirror Contract
- Core source files must have mirrored docs under `/docs` with the same relative path and `.md` suffix.
- Mapping rule: `<source/path.ext>` -> `docs/<source/path.ext>.md`.
- This harness currently scopes mirror enforcement to:
  - `SymbolicLean/**`
  - `.github/workflows/**`
  - `Main.lean`
  - `SymbolicLean.lean`
  - `lakefile.toml`
  - `lean-toolchain`
  - `lake-manifest.json`

## Required Sections for Mirrored Docs
Each mirrored doc must contain these level-2 headings:
- `## Source`
- `## Responsibilities`
- `## Public Surface`
- `## Change Triggers`
- `## Related Files`

## Mechanical Enforcement
The checker script (`scripts/check_doc_harness.py`) validates:
- missing mirrored docs
- orphaned mirrored docs
- required section coverage
- broken internal links in `/docs`

CI currently runs the checker in warn mode to surface drift without blocking merges.
