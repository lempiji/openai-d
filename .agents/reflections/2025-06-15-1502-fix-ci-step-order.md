### :book: Reflection for [2025-06-15 15:02]
  - **Task**: Adjust dfmt step ordering in CI
  - **Objective**: Ensure dfmt runs after dependencies are installed
  - **Outcome**: Moved formatting check after cache step in both CI jobs

#### :sparkles: What went well
  - Reviewer feedback clarified where to add dfmt execution
  - YAML changes were straightforward

#### :warning: Pain points
  - Re-running dfmt locally modified unrelated files

#### :bulb: Proposed Improvement
  - Provide a preconfigured docker image with dfmt installed to avoid rebuilds each CI run
