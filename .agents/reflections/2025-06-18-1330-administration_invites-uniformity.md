### :book: Reflection for [2025-06-18 13:30]
  - **Task**: Adjust administration_invites example
  - **Objective**: Align new example with others and satisfy review feedback
  - **Outcome**: Added missing `.gitignore` and updated README; all checks pass

#### :sparkles: What went well
  - The uniform .gitignore template made it easy to add the missing file
  - Running formatter and build scripts confirmed the example works

#### :warning: Pain points
  - `scripts/build_examples.sh core administration_invites` still skips underscore directories, leading to confusion
  - Linting downloads dependencies each run, slowing feedback in the container

#### :bulb: Proposed Improvement
  - Update `build_examples.sh` to build explicitly specified directories regardless of underscores
