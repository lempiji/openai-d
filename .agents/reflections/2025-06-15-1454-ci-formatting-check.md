<!-- reflection-template:start -->
### :book: Reflection for [2025-06-15 14:54]
  - **Task**: Add dfmt check to CI workflow
  - **Objective**: Ensure CI fails when code is not formatted
  - **Outcome**: Updated workflow to run dfmt on source and examples with git diff; documented step in AGENTS.md

#### :sparkles: What went well
  - YAML modifications were straightforward
  - Documentation update clarified formatting requirements

#### :warning: Pain points
  - Local: running dfmt touched many files that were not part of the task
  - CI setup may still be slow due to building dfmt each run

#### :bulb: Proposed Improvement
  - Cache dfmt build artifacts in CI to speed up formatting checks
<!-- reflection-template:end -->
