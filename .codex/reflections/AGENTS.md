# Reflection Archiving Workflow

To keep the `reflections` directory tidy, archive a reflection once its improvement is implemented.

1. Review the reflection and locate the **Proposed Improvement**.
2. Verify through commit history or existing features that the improvement was made.
3. Run `rdmd scripts/archive_reflection.d <file>` to move the file to `.codex/archive/` and record a brief entry in `.codex/archive/REFLECTION_HISTORY.md`.
4. Commit the move (and note) with message `docs: add reflection archiving workflow`.

Each reflection's `Proposed Improvement` section must contain exactly one bullet describing the improvement. Remove any placeholder bullets before committing.
Include notes on the `Learning & Insights` and `Reference Info` sections before archiving a reflection.
