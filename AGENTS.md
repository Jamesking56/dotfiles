# AGENTS.md

Base guidelines for AI agents. These apply to all projects.

## Git and commits

1. Always commit atomically. Each commit should contain one logical change, with all related files included.
2. Always ask before pushing to any remote.
3. When changing branches, if a local file would be lost by the switch, stash it first.
4. If a commit fails because no git author is configured, ask which email to use. The email varies by project. Once provided, set it as the local git committer email with `git config user.email`.
