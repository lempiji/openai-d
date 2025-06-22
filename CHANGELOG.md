# Changelog

## [v0.9.0] - 2025-06-22
### Added
- Added `OpenAIAdminClient` with comprehensive administration modules (projects, API keys, invites, users, service accounts, rate limits, certificates, audit logs, usage).
- Introduced `Responses` and `Images` API implementations.
- Added `Audio` API with speech, transcription, and translation support.
- Implemented `Files` API and lifecycle example program.
- Implemented `QueryParamsBuilder` helper for assembling query strings.
- Added `validate` method and environment-based creation in `OpenAIClientConfig`.
- Numerous example programs demonstrating new features.
- Integrated Codecov and improved CI caching of Dub packages.

### Changed
- Switched optional fields to `mir.algebraic.Nullable`.
- Standardized request and response structure names.
- Refactored URL helpers and removed redundant client functions.

### Fixed
- Corrected numeric literal style and CI paths.
- Miscellaneous bug fixes and test refinements.

