# AGENTS.md

## 1. Project Overview

* Repository: `https://github.com/lempiji/openai-d`
* Name: openai-d
* Description: An unofficial OpenAI API client library for the D programming language, supporting the Azure OpenAI Service.
* Installation: Published on Dub registry; install via `dub add openai-d`
* Language: D (100%)
* License: MIT

## 2. Development Setup

* Ensure `dmd` and `dub` are available using the stable installer script (`/workspace/dlang/install.sh`).

## 3. Testing

* Run all tests:

  ```bash
  dub test
  ```
* Guidelines:

  * Use `unittest` blocks; add tests for private methods when behavior is unclear.
  * After any code change, verify tests pass before committing.

## 4. Coverage Report

* Generate coverage data:

  ```bash
  dub test --coverage --coverage-ctfe
  ```
* Check results: Inspect the last two lines of each `source-openai-*.lst` file in the project root for coverage percentages.

## 5. Formatter

* Before running `dub run dfmt`, ensure the formatter is installed. One-line
  installation command:

  ```bash
  dub fetch dfmt && dub run dfmt -- --version
  ```
  Network access or a setup script is required for this step.

* Library source:

  ```bash
  dub run dfmt -- source
  ```
* Examples folder:

  ```bash
  dub run dfmt -- examples
  ```

## 6. Linter

* Run linter:

  ```bash
  dub lint --dscanner-config dscanner.ini
  ```

## 7. Development Workflow

1. Modify code.
2. Run formatter and linter
3. Run tests and coverage
4. Build examples individually or use the helper script:
   * Run `scripts/build_examples.sh fast` to compile only a small set of key examples.
   * Run `scripts/build_examples.sh` (or `scripts/build_examples.sh all`) to build them all.
   * Run `scripts/build_examples.sh chat` to build every example starting with `chat`.
   * Run `scripts/build_examples.sh fast audio` for a faster build of the `audio` group.
   Building individually with `dub build` remains valid when touching only a few examples.
   * Build examples that have been modified,
     depend on changed library modules, or
     are required for verifying new features.
   All examples should compile before major releases or when unsure.
   Example groups are determined by the API prefix before the underscore in each directory.
   **Quick guide**
   - Use a single group such as `chat` when only that example directory changed.
   - Provide multiple groups (`chat audio`) if several examples were modified.
   - Prefix with `fast` (`fast` or `fast <group>`) for quick iteration.
   - Use `all` to replicate CI builds or before a release.
5. If all checks pass, commit changes and open a pull request.

## 8. CI/CD & PR Guidelines

* CI: GitHub Actions workflows are defined in `.github/workflows/`.
* PR title format: `[<module>] <short description>`
* Commit messages: Follow Conventional Commits.
* Pre-merge checks: Formatter → Linter → Tests → Coverage report.

## 9. Directory Structure

```
/
├─ .github/     # GitHub Actions workflows
├─ source/      # Library source code
├─ examples/    # Sample usage code
├─ dub.json     # Dub package definitions
└─ AGENTS.md    # This document
```

## 10. Reflection & Improvement

After completing your tasks, the agent **must create** a new file in `.agents/reflections/` named `YYYY-MM-DD-hhmm-{task-summary}.md`. Start the file with the exact block found in `.agents/reflection-template.md`. The header must be in the format `### :book: Reflection for [YYYY-MM-DD HH:MM]` (note the required square brackets).

```
### :book: Reflection for [2025-06-13 14:28]
```

Existing reflections before mid-2025 may omit these brackets. Update their
headers when modifying or archiving those files to maintain consistency.

> **One Bold Change rule**: every reflection must propose **exactly one** high-leverage improvement that could eliminate the biggest pain point next time.

* Records are keyed by timestamp (to the minute). Use the current date and time as `YYYY-MM-DD HH:MM` in the template and file name.
* Replace `{task-summary}` with a short hyphenated summary of the task.
* When documenting pain points, include your environment (CI, local machine, OS, etc.) and specify which step or command was slow.
* After your proposed improvement is implemented, move the reflection to `.agents/archive/`. See [`.agents/reflections/AGENTS.md`](.agents/reflections/AGENTS.md) for the full archiving workflow.
