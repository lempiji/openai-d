# Changelog
## [v0.9.0] - Unreleased
### Added
- Added `OpenAIAdminClient` with comprehensive administration modules (projects, API keys, invites, users, service accounts, rate limits, certificates, audit logs, usage).
- Introduced `Responses` and `Images` API implementations.
- Added `Audio` API with speech, transcription, and translation support.
- Implemented `Files` API and lifecycle example program.
- Implemented `QueryParamsBuilder` helper for assembling query strings.
- Added `validate` method and environment-based creation in `OpenAIClientConfig`.
- Numerous example programs demonstrating new features.
- Integrated Codecov and improved CI caching of Dub packages.
- Added `ChatUserMessageFileContent` type and `userChatMessageWithFile` helper for attaching files in chat messages.
- Added `userChatMessageWithFiles` helper for attaching multiple files in one chat message.
- chat_files example now uploads multiple files and asks the model to analyze both.

### Changed
- Switched optional fields to `mir.algebraic.Nullable`.
- Standardized request and response structure names.
- Refactored URL helpers and removed redundant client functions.
- `ChatUserMessageContentItem` now includes `ChatUserMessageFileContent`. Code that pattern-matches on this alias must handle the new variant; exhaustive `match` expressions may fail to compile with older assumptions.

### Fixed
- Corrected numeric literal style and CI paths.
- Miscellaneous bug fixes and test refinements.

