---
name: ci-check
description: Run the project's CI/CD checks locally to confirm the pipeline will pass before pushing — mirrors every job in .github/workflows/ (pre-commit/ruff, pytest, pip-audit, mypy if configured) and runs pre-commit if it is enabled. Use when the user says "run CI locally", "check CI will pass", "validate the pipeline", "run all the checks", "preflight", "make sure CI passes", or similar.
---

# Run CI/CD Checks Locally (Preflight)

Reproduce the repository's CI/CD pipeline on the local working tree so the user knows whether a push will pass **before** they push. The goal is fidelity to what CI actually runs and a clear pass/fail report — not to "fix" anything unasked.

This skill is **discovery-first**: read what CI is configured to do and run the local equivalents. Do not hardcode a fixed tool list — if the repo adds `mypy`, drops a tool, or changes a command, the skill must follow the config, not this document's examples.

## Procedure

### 1. Discover what CI runs

Inspect the repo's actual configuration so you mirror it faithfully:

- **GitHub Actions:** read every file under `.github/workflows/*.yml` / `*.yaml`. Enumerate each job and the exact shell commands in its `run:` steps. These are the source of truth for what "CI passing" means.
- **Pre-commit:** check for `.pre-commit-config.yaml`. If present, pre-commit is enabled — note every hook `id` (ruff, ruff-format, yamllint, pydocstyle, mypy, etc.).
- **Project config:** read `pyproject.toml` (and any `setup.cfg`, `tox.ini`, `mypy.ini`, `ruff.toml`) for tool config and dependency groups (e.g. the `dev` group, test command, configured linters/type-checkers).

Build a checklist of the distinct checks CI gates on. For the current template that is typically:

| CI job (ci.yml) | CI command | Local equivalent |
| --- | --- | --- |
| `lint` | `uvx pre-commit run --all-files` | `uvx pre-commit run --all-files` |
| `test` | `uv sync --group dev` + `uv run pytest --tb=short -q` | same |
| `security` | `uv sync` + `uvx pip-audit` | same |

Treat this table as an example of *how to map*, not a fixed script — regenerate it from the files you just read.

### 2. Run each check locally

Run the **same commands CI runs**, from the repo root, using the project's `uv` environment (per CLAUDE.md, always use `uv`):

- **Pre-commit / linters / formatters** (ruff, ruff-format, yamllint, pydocstyle, and mypy *if it appears as a hook*): `uvx pre-commit run --all-files`. This runs every configured hook exactly as the `lint` job does. If pre-commit is **not** installed/enabled, fall back to running the individual tools the repo configures (e.g. `uv run ruff check .`, `uv run ruff format --check .`, `uv run mypy <pkg>`), but only those that are actually configured.
- **Tests**: mirror the test job — `uv sync --group dev` then `uv run pytest --tb=short -q`. If CI uses a Python matrix, run on the default interpreter and note in the report that CI also covers the other versions (you generally can't span all interpreters locally; call that out rather than claiming full matrix coverage).
- **Security / audit**: `uv sync` then `uvx pip-audit`, matching the `security` job.
- **Any other job** you discovered in step 1: run its local equivalent the same way.

Run independent checks and capture each one's exit code and output. A non-zero exit is a FAIL.

### 3. Handle checks that can't run locally

Some CI jobs have no faithful local equivalent — e.g. **CodeQL** (`codeql.yml`) needs the GitHub CodeQL action/runner. Do not fake these. List them as `SKIPPED (not reproducible locally)` with a one-line reason so the report is honest about coverage.

### 4. Report

Produce one scannable summary:

```
## CI Preflight — will the pipeline pass?

Source: .github/workflows/{ci.yml, codeql.yml}, .pre-commit-config.yaml

| Check        | Mirrors          | Result |
| ------------ | ---------------- | ------ |
| pre-commit   | ci.yml: lint     | PASS   |
| pytest       | ci.yml: test     | FAIL   |
| pip-audit    | ci.yml: security | PASS   |
| codeql       | codeql.yml       | SKIPPED (needs GitHub CodeQL runner) |

Verdict: NOT READY — pytest failing.

### Failures
- pytest: tests/test_foo.py::test_bar — AssertionError: ...
  (paste the minimal failing output, with file:line)
```

End with a clear **verdict**: `READY TO PUSH` only if every reproducible check passed, otherwise `NOT READY` with the blocking checks named.

## Fixing (only if asked)

By default this skill is **diagnostic** — it runs checks and reports. Do not modify code unless the user asks you to fix the failures.

If the user does ask for fixes:
- **Safe to auto-apply:** formatting/lint autofixes already part of the pipeline (`uvx pre-commit run --all-files` applies ruff `--fix` and ruff-format; re-run to confirm clean), and obvious mechanical fixes (a forgotten import, trailing whitespace).
- **Stop and ask** before changing test logic, source behavior, dependency versions, or anything ambiguous. Per CLAUDE.md: surface tradeoffs, make surgical changes only, and don't refactor things that aren't broken.

## Guardrails

- **Mirror CI; don't invent checks.** Only run what the repo actually configures. If mypy isn't a configured hook or command, don't run mypy.
- **Use `uv`** for all Python execution (CLAUDE.md). Don't install global tools or new dependencies to make a check run — if a required tool is missing, report that instead.
- **Be honest about coverage:** clearly mark matrix interpreters you didn't run and jobs (CodeQL) you can't reproduce locally. Never report PASS for something you skipped.
- **Read-only by default.** Don't commit, push, or open a PR — that's `/ship`'s job. This skill stops at the verdict unless the user explicitly asks to fix or ship.
- **Don't swallow failures.** Report the first actionable lines of each failing check with `file:line` so the user can jump straight to the problem.
