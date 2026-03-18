# Lean Engineering Standards

## Style Baseline
- Prefer a functional-first design with explicit data flow.
- Encode invariants in types before adding runtime checks.
- Prefer small composable definitions over monolithic tactics or giant functions.

## Type System Usage
- Keep interfaces polymorphic over the weakest required structure (`Semiring`, `Ring`, `Field`, etc.).
- Use typeclasses to express algebraic capability requirements precisely.
- Prefer explicit structure and dependent typing when it clarifies legal transformations.

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
