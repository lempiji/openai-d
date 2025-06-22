### :book: Reflection for [2025-06-12 13:36]
  - **Task**: Stream file chunks in audio methods
  - **Objective**: Use File.byChunk so large audio files don't load fully in memory
  - **Outcome**: Updated transcription and translation to append chunks. Tests and builds pass.

#### :sparkles: What went well
  - D's byChunk API was straightforward to integrate

#### :warning: Pain points
  - Running dub tools takes significant time due to dependencies

#### :bulb: Proposed Improvement
  - Automate dependency caching in CI to speed up lint/test steps

