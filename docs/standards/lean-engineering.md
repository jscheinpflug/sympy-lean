# Lean Engineering Standards

## Style Baseline
- Prefer a functional-first design with explicit data flow.
- Encode invariants in types before adding runtime checks.
- Prefer small composable definitions over monolithic tactics or giant functions.

## File Structure
- Target roughly 80-150 LOC per Lean file.
- Split modules before they turn into 200+ LOC kitchen-sink files.
- Keep one primary responsibility per file.
- Organize folders by concern so source and mirrored docs stay local and self-documenting.

## Type System Usage
- Keep interfaces polymorphic over the weakest required structure (`Semiring`, `Ring`, `Field`, etc.).
- Use typeclasses to express algebraic capability requirements precisely.
- Prefer explicit structure and dependent typing when it clarifies legal transformations.

## Import Discipline
- Do not use `import Mathlib` in ordinary project files.
- Import the narrowest `Mathlib/...` modules that the file actually needs.
- If a file typechecks without mathlib, do not add a mathlib import preemptively.
- Treat broad umbrella imports as a performance regression, especially for Lean LSP restart-file workflows in editors.

## Proof and API Design
- Keep theorem statements stable and intention-revealing.
- Place key specifications close to APIs so behavior is machine-checkable.
- Prefer total functions and typed error channels over partial functions.

## Metaprogramming
- Use notation, macros, and elaborators when they remove ambiguity and improve proof ergonomics.
- Keep metaprogramming surfaces documented and minimal.
- Treat custom syntax as API: design for readability first, then convenience.

## Documentation Contract
- Every core module has a mirrored `/docs/...md` file.
- Mirrored docs define responsibilities and change triggers so agents can localize edits without broad context expansion.
