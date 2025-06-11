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
   Building individually with `dub build` remains valid when touching only a few examples.
   * Build examples that have been modified,
     depend on changed library modules, or
     are required for verifying new features.
   All examples should compile before major releases or when unsure.
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

After completing your tasks, the agent **must append** one entry to `.agents/REFLECTION_HISTORY.md` using the exact `<!-- reflection-template:start --> … <!-- reflection-template:end -->` block that already exists in that file.

> **One Bold Change rule**: every reflection must propose **exactly one** high-leverage improvement that could eliminate the biggest pain point next time.

* Before appending, check `.agents/REFLECTION_HISTORY.md` for existing entries on the same date or with the same content and consolidate them to avoid duplication.
* If earlier records are out of order or redundant, reorganize them so the newest reflection always appears at the bottom of the file.
