### :book: Reflection for [2025-06-18 13:52]
  - **Task**: Add administration_usage example
  - **Objective**: Provide sample usage of the administration Usage API
  - **Outcome**: Created new example and verified build script covers it

#### :sparkles: What went well
  - Simple code reuse from existing examples
  - Build and tests all ran without issues

#### :warning: Pain points
  - The build script's `core` mode skips directories with underscores, so running
    it as instructed did not build the new example at first.
  - Fetching packages for formatter and linter still adds noticeable time.

#### :bulb: Proposed Improvement
  - Document that examples with underscores require using the `all` mode when
    calling `build_examples.sh`.
