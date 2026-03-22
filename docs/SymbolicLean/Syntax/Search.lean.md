# `SymbolicLean/Syntax/Search.lean`

## Source
- [`../../../SymbolicLean/Syntax/Search.lean`](../../../SymbolicLean/Syntax/Search.lean)

## Responsibilities
- Provide a registry-backed `#sympy_search "keyword"` command.
- Search symbolic registry entries over declaration names, backend names, aliases, categories, and attached docs.
- Provide registry-backed hover-style and completion-style command surfaces for generated heads and ops.
- Render richer hover output from registry metadata including backend dispatch path, call style, and optional pure-head spec data.

## Public Surface
- command `#sympy_search "keyword"`
- command `#sympy_hover "name"`
- command `#sympy_complete "prefix"`

## Change Triggers
- Registry metadata shape changes.
- Search matching or rendering policy changes.
- Discoverability moves from ad hoc command output to richer widgets.

## Related Files
- [`Registry.lean.md`](Registry.lean.md)
- [`DeclareOp.lean.md`](DeclareOp.lean.md)
