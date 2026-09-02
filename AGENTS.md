# Commit discipline

You MUST commit every logical step before moving on. Do not batch multiple changes into a single commit.

## When to commit

You MUST run `git add -A && git commit -m "message"` after completing any of the following:

- Editing a file (create, modify, delete)
- Running a command that produces a meaningful result
- Completing a subtask or subgoal
- Any point where `git status` shows unstaged or uncommitted changes and you are about to start something new

## Commit message rules

- Use the **conventional commits** format: `type(scope): description`
- Keep the description under 72 characters
- Use the imperative mood ("add feature" not "added feature")
- Types: `feat`, `fix`, `refactor`, `style`, `docs`, `BRAKING_CHANGES!`, `test`, `chore`, `perf`

## Verification

Before each commit, run `git diff --stat` to verify only intended files are staged. Never commit generated files, secrets, or unrelated changes.

## Exceptions

Only skip a commit if the change is trivially revertible (e.g., a single `git checkout .` would undo it) AND you are immediately proceeding to the next step in the same train of thought.
