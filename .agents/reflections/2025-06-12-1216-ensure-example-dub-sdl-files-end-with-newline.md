<!-- reflection-template:start -->
### :book: Reflection for 2025-06-12 12:16
  - **Task**: Ensure example dub.sdl files end with newline
  - **Objective**: Maintain formatting consistency across examples
  - **Outcome**: Added trailing newlines, ran formatter, linter, tests, coverage and example builds

#### :sparkles: What went well
  - Automated tools made it easy to apply formatting and verify builds

#### :warning: Pain points
  - Extra binaries from example builds cluttered the worktree and needed manual cleanup

#### :bulb: Proposed Improvement
  - Add a clean step to the example build script to remove generated artifacts automatically
<!-- reflection-template:end -->
