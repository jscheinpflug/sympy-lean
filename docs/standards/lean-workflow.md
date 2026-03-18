# Lean Workflow and Tooling Contract

## Lean 4 Skill
When a task involves `.lean` files, Lean proofs, Lake builds, or mathlib search, use:

`/home/scheinpflug/symbolic-lean/tools/lean4-skills/plugins/lean4/skills/lean4/SKILL.md`

## Environment Shim
Before running helper scripts from the Lean 4 plugin:

```bash
source /home/scheinpflug/symbolic-lean/.agents/lean4-env.sh
```

## Environment Variables
- `LEAN4_PLUGIN_ROOT=/home/scheinpflug/symbolic-lean/tools/lean4-skills/plugins/lean4`
- `LEAN4_SCRIPTS=/home/scheinpflug/symbolic-lean/tools/lean4-skills/plugins/lean4/lib/scripts`
- `LEAN4_REFS=/home/scheinpflug/symbolic-lean/tools/lean4-skills/plugins/lean4/skills/lean4/references`
