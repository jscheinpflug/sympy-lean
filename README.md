# symbolic-lean

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
