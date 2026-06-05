---
name: ship
description: Commit all current changes, push to a feature branch, open (or reuse) a PR against main, and subscribe to that PR's CI so failures are auto-corrected. Use when the user says "ship it", "ship this", "/ship", or asks to commit + push + open a PR and babysit CI in one step.
---

# Ship

Take the current working tree from "uncommitted changes" to "open PR with CI watched and self-correcting" in one command. CI in this repo (`.github/workflows/ci.yml`) only runs on PRs to `main` and pushes to `main`, and the auto-correct loop is PR-based, so shipping always goes through a PR against `main`.

## Prerequisites

- **GitHub MCP server must be available** (`mcp__github__*` tools). If it isn't, stop and tell the user to enable it — without it you cannot open a PR or subscribe to CI.
- A clean understanding of the remote: the repo must have an `origin` and a `main` branch.

## Procedure

1. **Pre-flight.**
   - Run `git status --porcelain` and `git branch --show-current`.
   - If there is nothing to commit *and* the branch is already pushed with an open PR, don't make an empty commit — skip to step 6 (resubscribe) and report.

2. **Stage everything (this is the "forgotten files" guard).**
   - Run `git add -A`. This stages every new, modified, and deleted file, so nothing is left out of the commit. The only files it cannot catch are those excluded by `.gitignore` — if a brand-new source file or directory is gitignored unexpectedly, flag it to the user rather than silently shipping without it.
   - Print a short summary of what was staged (`git diff --cached --stat`).
   - **Never stage secrets.** If staged changes include `.env`, credentials, tokens, or keys, stop and ask before continuing.

3. **Pick the branch (never commit straight to `main`).**
   - If the current branch is `main`, create a feature branch first: `git switch -c ship/<short-slug>` where the slug is derived from the change.
   - Otherwise keep the current branch.

4. **Commit with an auto-generated message.**
   - Summarize the staged diff into a concise, conventional commit message (subject line ≤ ~70 chars, optional body explaining the "why"). Do not ask the user for the message.
   - Commit.

5. **Push with retry/backoff.**
   - `git push -u origin <branch>`.
   - On network failure only, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s). Never force-push.

6. **Open or reuse the PR against `main`.**
   - Check for an existing open PR for this branch with `mcp__github__list_pull_requests`.
   - If none exists, create one with `mcp__github__create_pull_request` targeting `main`. Auto-generate the title from the commit/diff and write a short body describing what changed and why. Do **not** create a PR if the user only wanted a commit — but `/ship` implies a PR.
   - If one exists, the new push already updated it; just note the PR number/URL.

7. **Subscribe and hand off to the auto-correct loop.**
   - Call `mcp__github__subscribe_pr_activity` for the PR.
   - End the turn. Do **not** poll with `sleep` — CI/review events wake the session as `<github-webhook-activity>` messages.
   - Report to the user: branch, PR URL, what was committed, and that CI is now being watched.

## Auto-correction policy (when CI events arrive)

This skill subscribes; the session's standing instructions then drive the fix loop. Apply this policy:

- **Auto-fix safe failures** and push without asking: linting/formatting (`pre-commit`), import errors, obviously-broken or forgotten files surfaced by a failing test, trivial test breakages.
- **Stop and ask** (via `AskUserQuestion`) before anything ambiguous, architecturally significant, or that could be interpreted multiple ways.
- Re-diagnose on each failure and re-push; one round is not the task. Refresh a short status checklist on each event.
- The loop ends when the PR is **merged or closed**, or the user says stop (then call `mcp__github__unsubscribe_pr_activity`).

## Guardrails

- Never push to `main` directly; always go through a feature branch + PR.
- Never force-push and never rewrite published history.
- Never commit secrets or files the user didn't intend; respect `.gitignore` and surface surprises.
- Keep replies frugal during the CI loop — push fixes and update the checklist; only message the user when a question or the final green/merge state warrants it.
