<!-- reflection-template:start -->
### :book: Reflection for [2025-06-13 11:56]
  - **Task**: add docs-only GitHub Actions workflow
  - **Objective**: ensure docs changes trigger a lightweight CI job
  - **Outcome**: created workflow and documented its usage

#### :sparkles: What went well
  - Workflow uses path filters and a shell check to verify no code files changed
  - Formatter and linter steps run quickly without compiling the library

#### :warning: Pain points
  - CI, Ubuntu: fetching dfmt and dscanner added noticeable setup time

#### :bulb: Proposed Improvement
  - Prebuild and cache dfmt and dscanner binaries to speed up formatting and linting
<!-- reflection-template:end -->
