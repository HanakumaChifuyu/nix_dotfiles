---
name: commit
description: Intelligently analyze and commit staged changes. Handles small changes directly, large changes in categorized batches, and large single-file diffs with special care. Triggers: 'commit', '提交代码', '帮我提交', 'commit changes'.
disable-model-invocation: true
---

# Smart Commit

## Current State

Branch: !`git branch --show-current 2>/dev/null || echo "detached HEAD"`
Staged: !`git diff --cached --stat`
Status: !`git status --short`

## Arguments

`$ARGUMENTS` can be:
- Empty: commit what's currently staged
- `all`: stage all changes first (`git add -A`), then commit
- Any other text: use as commit message hint

If `$ARGUMENTS` starts with `all` followed by a space, treat the rest as a message hint (e.g., "all fix login bug" → stage all, use "fix login bug" as hint).

## Phase 1: Pre-flight Checks

Execute in order. Stop immediately if any check fails.

1. **Git repository**: verify `git rev-parse --git-dir` succeeds. If not, report error and stop.
2. **Stage all** (if requested): if `$ARGUMENTS` starts with `all`, run `git add -A`, then refresh context with `git diff --cached --stat`.
3. **Nothing staged**: run `git diff --cached --name-only`. If empty, print "Nothing to commit." and stop.
4. **Sensitive files**: scan staged file names for patterns: `.env`, `credentials`, `secret`, `private_key`, `id_rsa`, `id_ed25519`, `.pem`, `*.key`. If found, unstage them (`git reset HEAD -- <file>`), warn the user, and continue with remaining files.
5. **Conflict markers**: run `git diff --cached | grep -c "^<<<<<<< "` (exit code from grep is OK, just check count). If count > 0, print "Merge conflict markers detected. Resolve conflicts first." and stop.
6. **Large binary check**: for staged files with extensions like `.png`, `.jpg`, `.gif`, `.svg`, `.woff`, `.woff2`, `.ttf`, `.ico`, `.pdf`, `.zip`, `.tar`, `.gz`, note them separately. Do not attempt `git diff` on them. Include them in commit messages by file name only.

## Phase 2: Analyze & Commit

Get the list of staged files: `git diff --cached --name-only`. Let N = number of staged files (excluding skipped sensitive files).

### Case A: N ≤ 3 (Small Change)

1. Run `git diff --cached` for the full diff.
2. Analyze the diff:
   - Determine change type (feat / fix / refactor / docs / test / chore / ci / style / perf / build)
   - Identify scope if clear (module, feature area)
   - Summarize the change in one imperative sentence
3. If `$ARGUMENTS` was provided (and not "all"), incorporate it as a hint into the commit message.
4. Generate commit message, execute commit, print result.

### Case B: N > 3 (Large Change)

1. **Overview**: run `git diff --cached --stat` for the big picture.
2. **Per-file analysis**: run `git diff --cached -- <file>` for each non-binary file to understand the nature of each change.
3. **Large file detection**: if any file has >100 lines of diff output:
   - Read the full diff carefully, section by section
   - If the file contains logically separate concerns (e.g., one function refactored + another function added), note this for potential splitting
   - If needed, read the file itself for additional context to understand the changes
4. **Categorize** all staged files into logical groups. Grouping priority:
   - **Same feature/domain**: files that implement the same feature or modify the same module
   - **Source + test pairs**: test files grouped with their corresponding source files
   - **Change type**: keep feat, fix, refactor in separate commits when they're unrelated
   - **Config/infra**: lock files, CI configs, build files → separate chore/ci commits
   - **Directory proximity**: files in the same directory tend to be related
   - **DO NOT** create groups with a single trivial line change unless it genuinely doesn't fit anywhere
5. **Record original state**: `git diff --cached --name-only` → save mentally.
6. **Unstage everything**: `git reset HEAD -- .`
7. **Batch commit** — for each group, in this order (dependencies first):
   - a. Stage the group's files: `git add <file1> <file2> ...`
   - b. Generate commit message following the rules below
   - c. Execute commit
   - d. Print: `[k/total] <type>(<scope>): <summary>`
8. **Verify completeness**: run `git diff --cached --name-only`. Should be empty. If files remain, commit them as a final group.
9. **Final summary**: run `git log --oneline -<total_commits>` to show all commits created.

### Special: Splitting a Large File's Changes

If a single file contains multiple logically independent changes that belong to different commits:

1. Stage the file: `git add <file>`
2. Unstage it: `git reset HEAD -- <file>` (so it's back to unstaged)
3. Use `git add -p <file>` to interactively stage only the relevant hunks for the first commit
   - If `git add -p` is not feasible (non-interactive), use `git add --patch` won't work in this environment — instead, read the hunks from `git diff <file>`, create a temporary patch file with only the relevant hunks, and apply it: `git apply --cached <temp.patch>`
4. Commit that group
5. Repeat for remaining hunks

If interactive patching is not possible, commit the large file as a single focused commit and note this in the output.

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body if needed>
```

**Type mapping**:
| Change | Type |
|---|---|
| New feature, new capability | `feat` |
| Bug fix, error handling | `fix` |
| Code restructuring, no behavior change | `refactor` |
| Documentation, README, comments | `docs` |
| Test additions, test fixes | `test` |
| Dependencies, tooling, configs | `chore` |
| CI/CD, pipeline changes | `ci` |
| Formatting, linting, whitespace | `style` |
| Performance optimization | `perf` |
| Build system, bundler | `build` |

**Rules**:
- Subject: imperative mood, lowercase, no trailing period, ≤72 characters
- Scope: omit if unclear; use the module/area name when obvious
- Body: explain *what* and *why*, not *how*. Wrap at 72 chars. Only include when the subject alone is insufficient.
- Language: default to English for all commit message content. However, before committing, check the project's rules files (e.g. `CLAUDE.md`, `.claude/rules/*.md`, `CONTRIBUTING.md`, `.commitlintrc*`) for any commit message requirements. If the project specifies a commit language or format convention, follow the project rules instead.
- If `$ARGUMENTS` provides a hint, weave it into the message naturally — do not use it verbatim if it doesn't fit the format

## Phase 3: Error Handling

- **Pre-commit hook failure**: read the error output carefully. If it's a linting/formatting issue, attempt to auto-fix (e.g., run the formatter, re-stage, retry). Retry at most once. If it still fails, report the full error to the user. **NEVER** use `--no-verify`.
- **`git reset HEAD` failure**: abort the entire operation, report the error. Do not attempt alternative approaches.
- **Empty commit**: if a group produces no actual diff after staging, skip it silently.
- **Unexpected git errors**: stop immediately, show the full error output, and suggest the user run the command manually.

## Phase 4: Post-commit

After all commits are created:
1. Run `git status --short` to show remaining state
2. If there are still unstaged/untracked changes, briefly note them: "Note: X unstaged files remain in working tree."
3. Do NOT push. Do NOT suggest pushing. The user decides when to push.
4. Do NOT add any `Co-Authored-By` trailer to commit messages.
