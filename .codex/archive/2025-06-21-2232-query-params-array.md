### :book: Reflection for [2025-06-21 22:32]
  - **Task**: Implement bracketed query parameter handling
  - **Objective**: Allow QueryParamsBuilder to emit repeated keys when the key ends with []
  - **Outcome**: Added feature with tests and documentation

#### :sparkles: What went well
  - Automated formatter and linter kept code consistent
  - Coverage tools confirmed new tests hit all lines

#### :warning: Pain points
  - Remembering to clean example artifacts required an extra build step
  - dfmt and dscanner downloads slowed down the workflow

#### :bulb: Proposed Improvement
  - Cache build tool binaries between runs to avoid repeated downloads
