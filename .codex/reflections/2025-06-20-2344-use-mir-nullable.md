### :book: Reflection for [2025-06-20 23:44]
  - **Task**: Replace std.typecons.Nullable with mir.algebraic.Nullable
  - **Objective**: Remove leftover std imports and unify optional handling
  - **Outcome**: All modules now import mir.algebraic and tests pass with coverage

#### :sparkles: What went well
  - Search and replace made it easy to clean up imports
  - Formatter and linter found no further issues

#### :warning: Pain points
  - Coverage generation spawns many .lst files which clutter the workspace
  - Building dfmt and dscanner on first run took noticeable time

#### :bulb: Proposed Improvement
  - Add a helper script to purge coverage files automatically after verification
