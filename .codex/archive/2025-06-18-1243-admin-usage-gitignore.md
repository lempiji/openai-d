### :book: Reflection for [2025-06-18 12:43]
  - **Task**: adjust administration usage example
  - **Objective**: Remove unnecessary dub.sdl config and add gitignore entries
  - **Outcome**: Simplified the administration package to avoid build conflicts and added ignore rules for the new usage sample

#### :sparkles: What went well
  - The build script quickly confirmed multiple mains would fail
  - Restoring the original dub.sdl was straightforward with git checkout

#### :warning: Pain points
  - Manually cleaning the generated libopenai-d.a after test runs is easy to forget and clutters git status

#### :bulb: Proposed Improvement
  - Add a cleanup step to the build/test scripts that removes stray artifacts like libopenai-d.a
