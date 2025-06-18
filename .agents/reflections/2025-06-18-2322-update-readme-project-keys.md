### :book: Reflection for [2025-06-18 23:22]
  - **Task**: Update README to document project API keys example
  - **Objective**: Reflect new functionality and show how to use project API keys
  - **Outcome**: README now marks the feature complete and references a sample
    project API key usage snippet

#### :sparkles: What went well
  - README changes were small and straightforward
  - Automated formatting and linting quickly confirmed no issues

#### :warning: Pain points
  - Building examples still triggers many deprecation warnings, obscuring real
    problems
  - Linting downloads dependencies each run, slowing feedback

#### :bulb: Proposed Improvement
  - Cache D dependencies in CI and local development to speed up linting
  - Address library deprecations to clean up build logs
