### :book: Reflection for [2025-06-20 15:53]
  - **Task**: fix ldc link error
  - **Objective**: ensure CI builds succeed with ldc-latest
  - **Outcome**: Rewrote query list builder to avoid heavy std.format templates, builds now link with ldc

#### :sparkles: What went well
  - dfmt and linter quickly validated style
  - Example build script caught leftover build artifacts

#### :warning: Pain points
  - Installing ldc-latest from the official script was blocked by network restrictions
  - Building all examples takes several minutes locally

#### :bulb: Proposed Improvement
  - Provide cached compiler installs in the environment to avoid network installs
