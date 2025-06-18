### :book: Reflection for [2025-06-18 13:54]
- **Task**: document invite API
- **Objective**: update README with invites snippet and example directory
- **Outcome**: README now shows how to list invites and references the new example

#### :sparkles: What went well
- Formatting and tests ran smoothly
- Build examples script confirmed unchanged functionality

#### :warning: Pain points
- `build_examples.sh` spewed deprecation warnings, slowing logs
- linter initialization required repeated downloads, taking time

#### :bulb: Proposed Improvement
- Cache dependencies for tooling to reduce wait time
