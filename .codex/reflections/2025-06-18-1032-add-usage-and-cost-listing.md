### :book: Reflection for [2025-06-18 10:32]
  - **Task**: Add usage and cost listing methods
  - **Objective**: Implement new client APIs and tests
  - **Outcome**: Added methods with query builders and unit tests

#### :sparkles: What went well
  - The existing URL builder functions served as clear examples
  - Automated formatting and linting kept the code consistent

#### :warning: Pain points
  - Running `scripts/build_examples.sh` produced numerous deprecation warnings which slowed feedback
  - Coverage generation required manual inspection of many files

#### :bulb: Proposed Improvement
  - Add a makefile target to silence deprecation messages and summarize coverage
  - 
