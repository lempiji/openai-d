<!-- reflection-template:start -->
### :book: Reflection for [2025-06-13 14:14]
  - **Task**: fix docs-only workflow checkout depth
  - **Objective**: ensure git diff for doc detection works reliably
  - **Outcome**: added fetch-depth 0 to the checkout step and documented the behavior

#### :sparkles: What went well
  - YAML update was straightforward and tests passed

#### :warning: Pain points
  - CI, Ubuntu: initial checkout lacked necessary history causing git diff to fail

#### :bulb: Proposed Improvement
  - Use a helper action that automatically fetches the correct base and head commits for diffing
<!-- reflection-template:end -->
