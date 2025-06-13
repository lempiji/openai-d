<!-- reflection-template:start -->
### :book: Reflection for [2025-06-13 12:21]
  - **Task**: refine CI triggers for docs-only workflow
  - **Objective**: avoid running main CI when only docs change
  - **Outcome**: added paths-ignore to main CI and clarified documentation

#### :sparkles: What went well
  - YAML changes were small and easy to test with linter

#### :warning: Pain points
  - CI, Ubuntu: fetching dscanner during `dub lint` took over a minute

#### :bulb: Proposed Improvement
  - Cache dscanner binaries in a shared layer to speed up linter steps
<!-- reflection-template:end -->
