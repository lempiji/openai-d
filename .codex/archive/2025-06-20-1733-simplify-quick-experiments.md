### :book: Reflection for [2025-06-20 17:33]
  - **Task**: Remove DUB single-file instructions
  - **Objective**: Keep quick experiment guidance focused on rdmd
  - **Outcome**: Updated AGENTS.md accordingly

#### :sparkles: What went well
  - Direct edit kept the documentation concise
  - Tests and formatting ran without issues

#### :warning: Pain points
  - Building dfmt every run is slow on this container

#### :bulb: Proposed Improvement
  - Cache dfmt binaries to avoid rebuilding during formatting
