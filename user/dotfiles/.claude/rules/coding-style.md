# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type

## Comments Language

ALL code comments MUST be written in English:
- Variable, function, and class comments
- Inline explanations
- Documentation strings (docstrings, JSDoc, etc.)
- TODO/FIXME notes
- Commit message bodies

Rationale: English is the universal language of code. It ensures consistency, enables collaboration across teams, and makes codebases accessible to a global audience.

## Error Handling

ALWAYS handle errors comprehensively:
- Handle errors explicitly at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Minimal Commits

One commit ≈ one small function. Decompose every task into the smallest meaningful unit.

**Decomposable tasks (new features)** — break into small-function-level steps:
```
WRONG:  One commit adds the entire "user registration" feature
CORRECT: Commit A: write hashPassword()
         Commit B: write validateEmail()
         Commit C: write createUser(), calling A and B
         Commit D: wire up the route/API
```

**Non-decomposable tasks (modifying existing code)** — inherently atomic, one commit:
- Bug fixes: locate the function, fix it, done
- Refactoring: renaming a variable across files is logically one change
- Config changes: changing a constant or config value

**Pragmatic exception**: when working on commit B you notice a minor issue in A (e.g., missing boundary check), fix it within commit B. Do not create a separate commit for trivial touch-ups.

Each commit message should describe the single function/behavior it introduces or changes.

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)
