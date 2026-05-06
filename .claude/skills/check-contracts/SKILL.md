---
name: check-contracts
description: Audit the codebase for adherence to the code contracts, conventions, and other instructions declared in CLAUDE.md (and any nested CLAUDE.md files). Use when the user asks to "check contracts", "audit CLAUDE.md compliance", "verify the repo follows our conventions", or similar — and proactively before opening a pull request that touches conventions covered in CLAUDE.md.
---

# Check Contracts Against CLAUDE.md

Audit the working tree for violations of the rules declared in `CLAUDE.md` (and any nested `**/CLAUDE.md` scoped to subdirectories). The goal is a precise, actionable report — not a rewrite. Do not modify code unless the user explicitly asks you to fix the findings.

## Procedure

1. **Locate the contract documents.** Search from the repository root:
   - `rg --files -g 'CLAUDE.md' -g 'Claude.md' -g 'claude.md'`
   - If none exist, stop and tell the user no CLAUDE.md was found, and offer to scaffold one with `/init` or by hand. Do not invent rules.

2. **Determine scope.** A `CLAUDE.md` at the repo root applies repo-wide. A nested `CLAUDE.md` (e.g. `projects/foo/CLAUDE.md`) applies only to files under that directory. When auditing a file, the effective contract is the union of all `CLAUDE.md` files on the path from the repo root to that file, with nested rules overriding broader ones on conflict.

3. **Extract the contracts.** Read each `CLAUDE.md` and enumerate every rule into a checklist. Capture:
   - **Rule text** (verbatim, short quote)
   - **Source** (`path/to/CLAUDE.md` and section heading)
   - **Scope** (which paths it covers)
   - **Verification strategy** (how to check it: grep pattern, file presence, command output, manual read)

   Group rules by category, e.g.:
   - Repository structure / file layout
   - Coding style (imports, type hints, docstrings, naming)
   - Build / dependency rules (uv, lockfiles, pinned versions)
   - Testing requirements (coverage, fixtures, framework)
   - Documentation requirements
   - Commit / branch / PR conventions
   - Tooling (linters, formatters, pre-commit hooks)
   - Security / secrets handling
   - Anything else explicitly stated

4. **Verify each rule.** Choose the cheapest reliable check for each rule:
   - **Mechanical** (preferred): `rg`/`grep`, `find`, file existence, parsing `pyproject.toml`, running the project's own linter (`pre-commit run --all-files`, `ruff check`, `mypy`, `pytest --collect-only`, etc.). Use the tools the repo already configures — do not install new ones.
   - **Structural**: read representative files end-to-end when a rule is about overall shape (e.g., "every project has a README").
   - **Judgmental**: when a rule is qualitative (e.g., "keep functions small"), spot-check a sample and flag clear violations only — do not nitpick.

   Run independent checks in parallel. Cap scans at the directories the rule actually covers.

5. **Classify findings.** For each rule, record one of:
   - `PASS` — verified, no violations found
   - `FAIL` — concrete violation(s) found; list each with `path:line` and a one-line description
   - `UNCHECKABLE` — the rule is too vague to verify mechanically, or requires runtime context you don't have; explain why
   - `N/A` — rule applies to a scope not present in this repo

6. **Report.** Produce a single structured summary:

   ```
   ## CLAUDE.md Contract Audit

   Sources: <list of CLAUDE.md files inspected>
   Rules checked: <N>   Pass: <p>   Fail: <f>   Uncheckable: <u>   N/A: <na>

   ### Failures
   1. <Rule, quoted briefly> — <source>
      Violations:
      - path/to/file.py:42  — <what's wrong>
      - path/to/other.py:7  — <what's wrong>
      Suggested fix: <one line>

   ### Uncheckable
   - <Rule> — <why it can't be mechanically verified; what manual review would settle it>

   ### Passed (summary)
   - <count> rules verified clean. Expand on request.
   ```

   Keep the report scannable. Failures first, with file:line references so the user can jump to them. Do not pad with passing rules unless asked.

## Guardrails

- **Read-only by default.** Do not edit files. If the user asks for fixes after seeing the report, address them as a separate task.
- **Quote, don't paraphrase, the rules.** A rule's exact wording matters; rewording can change its meaning.
- **Don't invent rules.** If the user's expectation isn't actually written in CLAUDE.md, say so — recommend they add it rather than enforcing a phantom contract.
- **Respect scope.** A nested CLAUDE.md does not govern siblings. A root rule applies only where the wording reasonably reaches.
- **Be honest about uncheckable rules.** It is better to mark a rule UNCHECKABLE with a reason than to fabricate a verification.
- **Don't re-run the project's full test suite** unless CLAUDE.md explicitly demands tests pass as part of the contract. Static checks are usually enough; running tests is the user's call.
- **Skip generated and ignored paths.** Honor `.gitignore`, `.ignore/`, `node_modules/`, `.venv/`, build artifacts, lockfiles unless a rule specifically targets them.
