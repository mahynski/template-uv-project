---
name: bug-review
description: Review the codebase like a senior software engineer, focusing on potential bugs. Presents an analysis only — does NOT write or modify code. Use when the user asks to "review for bugs", "do a bug review", "senior engineer review", "find potential bugs", or similar.
---

# Senior Engineer Bug Review

Review the codebase from the perspective of a senior software engineer with one job: surface **potential bugs** before they bite. Produce an analysis. Do **not** write, edit, or fix code.

## Scope

By default, review the working tree on the current branch (uncommitted changes plus committed-but-unmerged work). If the user names a path, file, or commit range, restrict the review to that scope.

Determine the diff to review:
- Uncommitted changes: `git status` and `git diff HEAD`
- Branch changes vs. main: `git diff $(git merge-base HEAD main)...HEAD`
- If neither produces a meaningful diff, fall back to a whole-codebase review and tell the user that's what you're doing.

## What to Look For

Focus on **bugs and bug-prone constructs**, not style. Categories to scan deliberately:

1. **Correctness**
   - Off-by-one errors, wrong loop bounds, wrong comparison operators
   - Incorrect math, units, or unit conversions; sign errors
   - Mutated arguments or shared mutable defaults (e.g. `def f(x=[])`)
   - Wrong order of arguments in calls; positional/keyword mix-ups
   - Operator precedence, truthiness on `0`/`""`/`None`, `is` vs `==`

2. **State and concurrency**
   - Race conditions, unsynchronized shared state, non-atomic read-modify-write
   - Resource leaks: files, sockets, locks, DB connections not closed
   - Iteration over a collection while mutating it
   - Stale caches, invalidation bugs

3. **Error handling**
   - Bare `except:` or over-broad `except Exception:` swallowing real errors
   - Errors caught and ignored; failures returned as success
   - Missing handling at boundaries (network, filesystem, parsing)
   - Exceptions raised in `finally` masking the original

4. **Boundary conditions**
   - Empty inputs, single-element inputs, very large inputs
   - `None`/`null` where a value is assumed
   - Floating-point comparisons with `==`, NaN propagation
   - Integer overflow (where relevant), division by zero

5. **API and contract mismatches**
   - Function called with wrong types/shapes
   - Return type doesn't match what callers expect
   - Public API change without updating callers
   - Tests that don't actually exercise the code path they claim to

6. **Security-adjacent bugs**
   - Untrusted input concatenated into shell, SQL, paths, URLs
   - Path traversal, missing authentication checks on a new endpoint
   - Secrets logged or committed
   - Insecure deserialization, weak crypto defaults

7. **Performance bugs that change behavior**
   - Quadratic loops on inputs that can grow unboundedly
   - N+1 queries, repeated work inside hot loops
   - Unbounded memory growth

8. **Project-specific contracts** (read `CLAUDE.md` and any nested ones)
   - Violations that are likely to *manifest as bugs* (not pure style). Examples: missing tests for new code, math without derivation, wrong virtualenv usage.

## Procedure

1. **Identify the diff.** Use `git` to find what changed. Read the changed files in full — not just the hunks — so context is preserved.
2. **Read tests alongside source.** A new function with no test, or a test that doesn't assert the behavior, is itself a finding.
3. **Trace data flow for risky changes.** For each non-trivial change, follow inputs from caller to callee and outputs back. Ask: *what input would break this?*
4. **Cross-check against `CLAUDE.md`.** Note contract violations that are bug-shaped.
5. **Prioritize.** Rank findings by likelihood × impact:
   - `HIGH` — likely to cause incorrect behavior, data loss, security issue, or crash on realistic input
   - `MEDIUM` — plausible bug under uncommon input or edge case
   - `LOW` — possible bug, or smells that warrant a second look
6. **Report.** Use the format below.

## Report Format

```
## Bug Review

Scope: <files / commits reviewed>
Findings: <H high, M medium, L low>

### High
1. path/to/file.py:LN — <one-line summary>
   Why it's a bug: <2-3 sentences. Concrete failure mode. What input triggers it.>
   Suggested direction: <one line, no code>

### Medium
...

### Low
...

### Looks fine, but worth a second pair of eyes
- <terse note>

### Out of scope but noticed
- <briefly mention non-bug issues — style, refactors, docs — without elaborating>
```

Keep each finding tight: file:line, the failure mode, and a hint at the fix direction. No code blocks. No "here's the patch."

## Guardrails

- **Read-only.** Do not edit files. Do not run formatters or linters that modify code. If the user wants fixes after the report, treat that as a separate task.
- **No code in the report.** Suggested directions are prose only ("guard against empty input before indexing"), never patches. The point is to hand the analysis to a human or a follow-up task.
- **Be specific.** "This might have bugs" is not a finding. A finding names the file, the line, the failure mode, and an input that triggers it.
- **Don't pad.** If there are no high-severity findings, say so. Five real bugs beats fifty nitpicks.
- **Don't moralize style.** Naming, formatting, and taste belong in a different review. Mention them only under "Out of scope but noticed."
- **Honesty about uncertainty.** If a code path is too tangled to judge from reading alone, say so under "Looks fine, but worth a second pair of eyes" rather than guessing.
- **Don't run the test suite or services** unless the user asks. Static reading is the contract here.
