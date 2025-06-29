# Changelog
## v0.9.0 - 2025-06-29
### Added
- Added `OpenAIAdminClient` with comprehensive administration modules (projects, API keys, invites, users, service accounts, rate limits, audit logs, usage).
- Introduced `Responses` and `Images` API implementations.
- Added `Audio` API with speech, transcription, and translation support.
- Implemented `Files` API and lifecycle example program.
- Implemented `QueryParamsBuilder` helper for assembling query strings.
- Added `validate` method and environment-based creation in `OpenAIClientConfig`.
- Numerous example programs demonstrating new features.
- Integrated Codecov and improved CI caching of Dub packages.
- Added `ChatUserMessageFileContent` type and helper functions for attaching files in chat messages.
- Added `messageContentItemFromFile` and `messageContentItemFromFileData` helpers for creating file content items.
- `chat_files` example demonstrates how to upload files and create messages with file attachments.

### Changed
- Switched optional fields to `mir.algebraic.Nullable`.
- Standardized request and response structure names.
- Refactored URL helpers and removed redundant client functions.
- `ChatUserMessageContentItem` now includes `ChatUserMessageFileContent`. Code that pattern-matches on this alias must handle the new variant; exhaustive `match` expressions may fail to compile with older assumptions.

### Fixed
- Corrected numeric literal style and CI paths.
- Miscellaneous bug fixes and test refinements.

