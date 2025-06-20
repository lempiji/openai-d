# Reflection Archiving Workflow

To keep the `reflections` directory tidy, archive a reflection once its improvement is implemented.

1. Review the reflection and locate the **Proposed Improvement**.
2. Verify through commit history or existing features that the improvement was made.
3. Move the file to `.codex/archive/` using `git mv`.
4. Optionally append a short note in `.codex/archive/REFLECTION_HISTORY.md` describing the archive.
5. Commit the move (and note) with message `docs: add reflection archiving workflow`.
