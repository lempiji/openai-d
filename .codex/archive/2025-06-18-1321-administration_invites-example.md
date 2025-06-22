### :book: Reflection for [2025-06-18 13:21]
  - **Task**: Add administration_invites example
  - **Objective**: Provide a sample showing invite management
  - **Outcome**: New example compiled successfully after running all checks

#### :sparkles: What went well
  - Following existing examples made creating the new one straightforward
  - Formatter, linter, tests, and coverage all ran without issues

#### :warning: Pain points
  - `build_examples.sh core` ignored the underscore-named directory, leading to confusion
  - Linting downloads dependencies each run, which slows feedback in the container

#### :bulb: Proposed Improvement
  - Update `build_examples.sh` to include explicitly provided directories even in core mode
  - Cache linter dependencies to speed up repeated runs
