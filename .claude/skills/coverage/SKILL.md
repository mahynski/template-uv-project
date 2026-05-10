---
name: coverage
description: Measure unit test coverage and add new tests to increase it. Allowed to create new tests, run the test suite, and fix broken tests (new or existing). Must STOP and ask the user before refactoring source code to make it testable. Use when the user asks to "improve coverage", "add missing tests", "raise test coverage", "check coverage", or similar.
---

# Improve Unit Test Coverage

Measure the project's current unit test coverage, then write new unit tests that exercise the uncovered code paths. Operate within a tight set of allowed actions — never edit source code under test.

## Allowed Actions

You may:
- Create new test files and add new test functions/classes under `tests/`.
- Run the existing test suite and any newly added tests.
- Fix tests (new ones you wrote, or pre-existing ones) when they fail for reasons you introduced or that are clearly broken (wrong import, stale fixture, etc.).

You may NOT:
- Edit, refactor, rename, or delete any non-test source code (anything outside `tests/`).
- Change project configuration (`pyproject.toml`, `conftest.py` outside `tests/`, lockfiles, dependency versions, CI files).
- Add new runtime dependencies. Test-only helpers should use what's already in the dev group (`pytest`, `pytest-cov`).
- Disable, skip, or weaken existing tests to make them pass. If a pre-existing test is genuinely broken because of a bug in the source, report it — do not paper over it.

If covering a code path requires changes to the source (e.g. a function is impossible to call without monkey-patching internals, a hard-coded path blocks isolation, a class can't be instantiated in a test environment), **STOP and ask the user for permission to refactor**. Describe:
1. What you wanted to test.
2. Why it's not testable as written.
3. The minimum source change you would propose.
Then wait for an explicit go-ahead before touching any source file.

## Procedure

1. **Confirm the toolchain.** This project uses `uv` and has `pytest` + `pytest-cov` in the dev group. Run everything through `uv run` so the project's virtualenv is used. Do not install new tools.

2. **Locate the source under test.** Read `pyproject.toml` and the repo layout to determine the package(s) to measure. If the layout is ambiguous (e.g. multiple top-level packages, or source lives outside the obvious place), ask the user which package(s) coverage should target before running.

3. **Measure baseline coverage.** Run the test suite with coverage and capture a per-file, per-line report. A reasonable invocation:
   ```
   uv run pytest --cov=<package> --cov-report=term-missing --cov-report=xml
   ```
   If `<package>` is unclear, fall back to `--cov=.` scoped by `--cov-config` only if the project already provides one — do not create configuration files. Save or summarize the missing-line report; you'll need it to choose targets.

4. **Pick targets.** From the missing-line report, prioritize:
   - Pure functions and small classes (cheapest to test, highest signal).
   - Public API surface — functions/classes meant to be called from outside the module.
   - Branches with non-trivial logic (conditionals, loops, error paths).
   Skip:
   - Trivial getters/setters and `__repr__` unless they contain logic.
   - `if __name__ == "__main__":` guards and CLI entrypoints, unless the user asks for them.
   - Code that is only reachable via I/O or external services you cannot fake without changing the source.

5. **Write tests.** For each target:
   - Place tests in `tests/`, mirroring the source layout (`tests/test_<module>.py` for `package/<module>.py`, or a subdirectory that mirrors a subpackage).
   - Follow project conventions from `CLAUDE.md`: numpy-style docstrings, American English, concise code, no speculative abstractions.
   - One behavior per test. Name tests `test_<unit>_<behavior>` so failures read clearly.
   - Cover the happy path, the documented edge cases, and the error paths the source explicitly raises. Do not invent error paths the source doesn't actually have.
   - Prefer `pytest.parametrize` for tabular cases over copy-pasted tests.
   - Use `pytest.raises` with `match=` for error assertions, and `pytest.approx` for floating-point comparisons.
   - Do not test private helpers (`_name`) directly unless their behavior is non-obvious and not reachable via the public API; prefer to test through the public surface.
   - Do not assert on log messages, timestamps, or other incidental output unless that output is part of the documented contract.

6. **Run and iterate.** After each batch of new tests:
   - Re-run the suite: `uv run pytest`.
   - If new tests fail, debug and fix the *test* — not the source. If the test is correct and the source is wrong, that's a bug finding (see step 8).
   - Re-measure coverage and confirm the target lines are now covered.

7. **Fix broken pre-existing tests** only when the fix is mechanical and unambiguous (e.g. updated import path, renamed fixture, obvious typo). Anything that requires interpreting intent — pause and ask.

8. **Report.** Produce a single summary at the end:

   ```
   ## Coverage Report

   Baseline: <pct>%   After: <pct>%   Δ <+pct>%
   Files moved most: path/a.py (X% → Y%), path/b.py (X% → Y%)

   ### Tests added
   - tests/test_a.py — N tests covering <module>.<symbol>: <one-line summary>
   - tests/test_b.py — ...

   ### Tests fixed
   - tests/test_old.py::test_thing — <what was wrong, what was changed>

   ### Still uncovered (and why)
   - path/x.py:LN-LN — <reason: untestable without refactor / I/O-bound / requires permission>

   ### Source changes proposed (NOT applied)
   - path/y.py — <what would need to change to test it; user permission required>
   ```

   Keep it scannable. Numbers first, then what changed, then what's blocked.

## Guardrails

- **Stay in `tests/`.** Every file you create or edit must live under `tests/` (or be a pre-existing test file you're fixing). If you find yourself wanting to open a source file in edit mode, stop.
- **Don't game the metric.** Coverage that doesn't assert anything is worse than no coverage. Every test must make at least one meaningful assertion about behavior.
- **Don't add dependencies.** If a test seems to need `hypothesis`, `freezegun`, `responses`, etc., either find a way without them or report it as blocked.
- **Don't introduce flakiness.** No tests that depend on wall-clock time, network, randomness without a fixed seed, or filesystem state outside `tmp_path`.
- **Use `tmp_path` and `monkeypatch`** for filesystem and environment isolation. Never write into the repo from a test.
- **Match project style.** Numpy-style docstrings, American English, concise. No emojis.
- **Run via `uv run`.** Do not invoke a system Python or pip.
- **One pass, then report.** Don't loop indefinitely chasing the last few percent — diminishing returns hit fast. When the remaining uncovered lines all require either refactors or new dependencies, stop and report.
