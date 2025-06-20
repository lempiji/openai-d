### :book: Reflection for [2025-06-16 23:01]
  - **Task**: Add optional parameters to audit log request and tests
  - **Objective**: Extend audit log search to filter by actor emails, resource IDs and effective time range
  - **Outcome**: Implemented new struct, updated client serialization and added coverage tests

#### :sparkles: What went well
  - Refactoring query logic into a helper made it simple to test
  - Existing project guidelines streamlined formatting and linting

#### :warning: Pain points
  - Building dependencies during lint took noticeable time on the CI container
  - Understanding DUB single-file execution for quick debugging was not obvious

#### :bulb: Proposed Improvement
  - Provide a lightweight script to print constructed URLs for debugging without running full tests
  - …
