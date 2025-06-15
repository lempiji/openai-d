### :book: Reflection for [2025-06-15 15:46]
  - **Task**: Create shared multipart helper
  - **Objective**: Reduce duplication in HTTP request construction
  - **Outcome**: Introduced `buildMultipartBody` and updated related methods

#### :sparkles: What went well
  - Consolidated four implementations into one helper
  - Added a focused unit test for the new method

#### :warning: Pain points
  - Linter output does not clearly indicate success
  - Example builds print numerous deprecation warnings which obscure results

#### :bulb: Proposed Improvement
  - Capture linter status explicitly and summarize to reduce noise
