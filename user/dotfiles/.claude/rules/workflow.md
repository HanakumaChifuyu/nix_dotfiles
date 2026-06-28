# Workflow

## Plan File Location (IMPORTANT)

When creating plan files, ALWAYS use the **project-local** `.claude/` directory (i.e. `<pwd>/.claude/`). NEVER write plans to the global `~/.claude/` directory. This is a **strict requirement** — the project-local directory is the sole authoritative location for all plan files.

## Feature Development

1. **Plan** - Use **planner** agent for complex features
2. **TDD** - Use **tdd-guide** agent (RED → GREEN → REFACTOR)

