<!-- reflection-template:start -->
### :book: Reflection for 2025-06-11 00:00
  - **Task**: Add example build script
  - **Objective**: Speed up building numerous example projects
  - **Outcome**: Created `scripts/build_examples.sh` with fast and all modes and documented its usage in AGENTS.md. Verified formatting, linting, tests, coverage and builds.

#### :sparkles: What went well
  - The helper script compiles selected examples with one command.

#### :warning: Pain points
  - Sequential example builds remain time-consuming and parallel builds caused dub cache conflicts.

#### :bulb: Proposed Improvement
  - Investigate caching compiled dependencies or using `dub`'s built-in package cache to allow safe parallel builds.
<!-- reflection-template:end -->
