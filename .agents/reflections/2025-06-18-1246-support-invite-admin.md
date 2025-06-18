### :book: Reflection for [2025-06-18 12:46]
  - **Task**: Add invite administration methods
  - **Objective**: Implement list, create, retrieve and delete invite APIs
  - **Outcome**: Added client methods with URL builder and tests

#### :sparkles: What went well
  - Reused existing helper patterns for consistent query handling
  - Automated formatting and tests ensured code quality

#### :warning: Pain points
  - Linting downloads dependencies every run which is slow in the container
  - Numerous deprecation warnings during example builds clutter logs

#### :bulb: Proposed Improvement
  - Provide cached dscanner binaries and silence deprecation warnings in scripts
  - 
