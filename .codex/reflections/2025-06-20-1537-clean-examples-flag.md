### :book: Reflection for [2025-06-20 15:37]
  - **Task**: Add cleanup option to build script
  - **Objective**: Provide an easy way to remove example build artifacts
  - **Outcome**: Implemented `--clean` flag and documented its use

#### :sparkles: What went well
  - Dfmt kept formatting consistent
  - Cleaning removed all unwanted files as expected

#### :warning: Pain points
  - Linter and coverage steps were slow due to repeated dependency compilation
  - `dub clean` didn't remove binaries, requiring manual deletion

#### :bulb: Proposed Improvement
  - Cache dependencies for tooling like dfmt and dscanner to speed up checks
