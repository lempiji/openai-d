### :book: Reflection for [2025-06-15 12:06]
  - **Task**: Expand workflow docs for example build groups
  - **Objective**: Document new usage patterns for scripts/build_examples.sh
  - **Outcome**: Updated AGENTS.md with group examples and naming note

#### :sparkles: What went well
  - The script already supported grouped builds, so docs just required small tweaks

#### :warning: Pain points
  - Running dfmt and dub lint installed packages each time, slowing the feedback loop

#### :bulb: Proposed Improvement
  - Cache dfmt and dscanner binaries in CI to avoid repeated installations
