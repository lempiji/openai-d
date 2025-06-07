# AGENTS.md

## 1. Project Overview

* Repository: `https://github.com/lempiji/openai-d`
* Name: openai-d
* Description: An unofficial OpenAI API client library for the D programming language, supporting the Azure OpenAI Service.
* Installation: Published on Dub registry; install via `dub add openai-d`
* Language: D (100%)
* License: MIT

## 2. Development Setup

* Ensure `dmd` and `dub` are available using the stable installer script (`~/dlang/install.sh`).

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
4. If all checks pass, commit changes and open a pull request.

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
