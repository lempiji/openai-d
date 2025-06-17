### :book: Reflection for [2025-06-17 13:26]
  - **Task**: Add administration API keys example
  - **Objective**: Provide a sample demonstrating admin API key operations
  - **Outcome**: Created new example folder with dub config and sample code; formatted, linted, tested, and built successfully.

#### :sparkles: What went well
  - Followed repository workflow to run formatter, linter, tests, and example build without issues.
  - Understanding of existing examples made it straightforward to craft the new sample.

#### :warning: Pain points
  - `build_examples.sh core` skipped the new underscore-named example, requiring extra investigation.
  - Running lint downloads dependencies each time, slowing iteration in the container environment.

#### :bulb: Proposed Improvement
  - Update `build_examples.sh` to build explicitly specified directories even when `core` mode is used, preventing confusion when working with underscore-named examples.
