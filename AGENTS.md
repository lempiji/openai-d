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
* **Run dfmt immediately before committing and never alter its output by hand.**

* Library source:

  ```bash
  dub run dfmt -- source
  ```
* Examples folder:

  ```bash
  dub run dfmt -- examples
  ```

* CI runs dfmt on `source` and `examples` and fails if `git diff --exit-code` detects changes.
* **Never edit dfmt output manually. Commit formatting changes exactly as produced.**

## 6. Linter

* Run linter:

  ```bash
  dub lint --dscanner-config dscanner.ini
  ```

## 7. Development Workflow

1. Modify code.
2. Run formatter and linter
3. Run tests and coverage
4. Build examples

   1. If you’ve modified any example group (e.g. `chat`, `audio`, `administration`), build **core** plus those groups:

      ```bash
      scripts/build_examples.sh core <modified-group>[ <another-group> …]
      ```

      * Example: you fixed something in the administration examples

        ```bash
        scripts/build_examples.sh core administration
        ```
   2. If you haven’t touched any example-specific code, just run **core** (always required):

      ```bash
      scripts/build_examples.sh core
      ```
      * `core` intentionally skips directories containing underscores. Use the
        `all` mode to build them manually. For example, to build the
        `administration_invites` examples:

        ```bash
        scripts/build_examples.sh all administration_invites
        ```
   3. To mirror CI or prepare a full release, you can still build **all**:

      ```bash
      scripts/build_examples.sh all
      ```
5. If all checks pass, commit changes and open a pull request.

## 8. CI/CD & PR Guidelines

* CI: GitHub Actions workflows are defined in `.github/workflows/`.
* PR title format: `[<module>] <short description>`
* Commit messages: Follow Conventional Commits.
* Pre-merge checks: Formatter → Linter → Tests → Coverage report. CI fails if formatting changes are needed.

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

After completing your tasks, the agent **must create** a new file in `.codex/reflections/` named `YYYY-MM-DD-hhmm-{task-summary}.md`. Start the file with the exact block found in `.codex/reflection-template.md`. The header must be in the format `### :book: Reflection for [YYYY-MM-DD HH:MM]` (note the required square brackets).

```
### :book: Reflection for [2025-06-13 14:28]
```

Existing reflections before mid-2025 may omit these brackets. Update their
headers when modifying or archiving those files to maintain consistency.

> **One Bold Change rule**: every reflection must propose **exactly one** high-leverage improvement that could eliminate the biggest pain point next time.

* Records are keyed by timestamp (to the minute). Use the current date and time as `YYYY-MM-DD HH:MM` in the template and file name.
* Replace `{task-summary}` with a short hyphenated summary of the task.
* When documenting pain points, include your environment (CI, local machine, OS, etc.) and specify which step or command was slow.
* After your proposed improvement is implemented, move the reflection to `.codex/archive/`. See [`.codex/reflections/AGENTS.md`](.codex/reflections/AGENTS.md) for the full archiving workflow.
