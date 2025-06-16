### :book: Reflection for [2025-06-16 22:58]
  - **Task**: Update example build script and docs
  - **Objective**: Replace fast mode with core mode and ensure tooling still passes
  - **Outcome**: Adjusted build script and docs, linter/tests pass though dfmt cannot format non-D files

#### :sparkles: What went well
  - Simple sed patches updated script and documentation quickly
  - Automated tests ran successfully confirming functionality

#### :warning: Pain points
  - dfmt failed on bash and Markdown files producing long error logs
  - Waiting for dependencies during linter execution slowed feedback

#### :bulb: Proposed Improvement
  - Add a shell and Markdown formatter to handle non-D files so dfmt step can be skipped when irrelevant
