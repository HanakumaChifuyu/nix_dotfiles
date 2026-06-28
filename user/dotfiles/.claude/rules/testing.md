# Testing

## Human-Driven Testing

Tests should be written by humans (or AI-assisted with human review):
- **Unit Tests** - Individual functions, utilities, components
- **Integration Tests** - API endpoints, database operations

Coverage checks are handled by project CI/CD pipelines.

## Test File Structure

Preserve directory structure in `tests/`:
```
src/
  auth/
    login.ts
    session.ts
tests/
  auth/
    login.test.ts
    session.test.ts
```

Do NOT dump all tests into a single file.

## TDD Workflow

Use **tdd-guide** agent:
1. Write test first (RED)
2. Write minimal implementation (GREEN)
3. Refactor (IMPROVE)
