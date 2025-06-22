### :book: Reflection for [2025-06-15 15:22]
  - **Task**: Run dfmt and update AGENTS instructions
  - **Objective**: Ensure repository formatting is up to date and discourage manual tweaks
  - **Outcome**: dfmt run successfully, AGENTS now strongly warns against editing formatting

#### :sparkles: What went well
  - dfmt ran without issues
  - Tests passed on first try

#### :warning: Pain points
  - Running linter took some time to download dependencies

#### :bulb: Proposed Improvement
  - Cache dscanner and dfmt dependencies to speed up linting and formatting
