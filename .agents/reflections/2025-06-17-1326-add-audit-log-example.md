### :book: Reflection for [2025-06-17 13:26]
- **Task**: Add administration audit log example
- **Objective**: Provide sample usage of `listAuditLogs` with filters
- **Outcome**: Created new example folder and verified it builds alongside tests

#### :sparkles: What went well
- The existing example structure made duplication straightforward
- Formatter and linter ran without issues

#### :warning: Pain points
- `build_examples.sh core` skipped the new folder because it contains an underscore
- Example builds reinstall dependencies, slowing iteration

#### :bulb: Proposed Improvement
- Adjust the build script to respect explicit group arguments even in core mode
