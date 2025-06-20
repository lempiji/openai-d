### :book: Reflection for [2025-06-20 11:20]
  - **Task**: Implement QueryParamsBuilder and refactor helper functions
  - **Objective**: Reduce repetitive query string code
  - **Outcome**: Added new helper module and simplified existing URL builders

#### :sparkles: What went well
  - The existing tests provided good coverage and ensured refactoring correctness
  - The build scripts offered a quick way to verify example compilation

#### :warning: Pain points
  - The build_examples script modified `dub.selections.json` files which required cleanup
  - Waiting for package dependencies during lint and example builds was time consuming in the container environment

#### :bulb: Proposed Improvement
  - Add a clean step to `build_examples.sh` to avoid leaving build artifacts in the repository
  - Cache common dependencies to speed up CI and local workflows
