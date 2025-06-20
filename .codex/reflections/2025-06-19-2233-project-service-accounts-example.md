### :book: Reflection for [2025-06-19 22:33]
  - **Task**: add project service accounts example and update docs
  - **Objective**: demonstrate service account operations in a new sample and document them
  - **Outcome**: example added, README updated, all checks succeeded

#### :sparkles: What went well
  - Reused existing project API key sample structure for quick development
  - Automated formatting and linting ensured consistent style

#### :warning: Pain points
  - `dub` modified `dub.selections.json` files during example builds, requiring manual resets
  - Example build script only builds minimal projects, so new samples aren't verified automatically

#### :bulb: Proposed Improvement
  - Adjust build script to optionally include underscore directories when groups are specified
  - This would compile new examples without modifying selection files unexpectedly
