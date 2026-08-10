# AGENTS.md

Base guidelines for AI agents. These apply to all projects.

## Git and commits

1. Always commit atomically. Each commit should contain one logical change, with all related files included.
2. Always ask before pushing to any remote.
3. When changing branches, if a local file would be lost by the switch, stash it first.
4. If a commit fails because no git author is configured, ask which email to use. The email varies by project. Once provided, set it as the local git committer email with `git config user.email`.

## Writing

1. Write in ASD-STE100 Simplified Technical English: short sentences, one meaning per word, active voice.
2. Apply Zinsser's four principles: clarity, simplicity, brevity, humanity.
3. Keep Issue and PR descriptions concise: just enough information, no waffling.

## Secrets and data

1. Never display a secret value. Instead, name the secret and state which file or location holds it.
2. Never send secrets or private customer data outside the local file area.
