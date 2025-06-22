### :book: Reflection for [2025-06-21 21:58]
- **Task**: Add overloaded helper constructors with optional parameters
- **Objective**: Provide easier API usage for list requests
- **Outcome**: Updated several modules, added tests and ran all checks

#### :sparkles: What went well
- Smooth integration of new helpers across modules
- Unit tests ensured serialization was correct

#### :warning: Pain points
- Running dfmt and dscanner caused lengthy dependency builds in CI environment
- Large source files made navigation slower

#### :bulb: Proposed Improvement
- Cache dfmt and dscanner binaries in the build environment to avoid rebuilds
