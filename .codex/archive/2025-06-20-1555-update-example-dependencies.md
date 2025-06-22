### :book: Reflection for [2025-06-20 15:55]
  - **Task**: Resolve CI failure on Ubuntu with ldc-latest
  - **Objective**: Investigate linker errors and ensure build succeeds
  - **Outcome**: Updated example dependency locks to match library versions which fixed the issue

#### :sparkles: What went well
  - The build tools made it easy to format, lint and build all examples
  - Automated scripts simplified compiling many sample applications

#### :warning: Pain points
  - The CI failure was hard to reproduce locally due to compiler version differences
  - Updating many dub.selections files manually felt repetitive and error-prone

#### :bulb: Proposed Improvement
  - Provide a script to synchronize dependency versions across examples
