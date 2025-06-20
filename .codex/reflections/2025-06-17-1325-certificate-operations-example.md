### :book: Reflection for [2025-06-17 13:25]
- **Task**: Add certificate operations example
- **Objective**: Demonstrate use of certificate APIs in a standalone sample
- **Outcome**: Created new `administration_certificates` example and verified formatting, linting, tests, and builds

#### :sparkles: What went well
- Dfmt, lint, and tests all ran without issues
- Example compiled successfully once the build script command was clarified

#### :warning: Pain points
- `scripts/build_examples.sh core` skipped directories with underscores, which was confusing
- Building examples remains time consuming

#### :bulb: Proposed Improvement
- Adjust build script to include specified groups even if they contain underscores
