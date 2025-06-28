### :book: Reflection for [2025-06-28 02:50]
  - **Task**: Improve AGENT docs for design workflow
  - **Objective**: Prevent implementation before proposals and ADRs are finalized
  - **Outcome**: Added explicit gating rules in AGENTS.md and docs/design/AGENT.md

#### :sparkles: What went well
  - Sed patching allowed quick insertion of new section headings
  - Root guidelines clarified that tests were unnecessary for doc-only changes

#### :warning: Pain points
  - Inserting multi-line text with sed was error prone and required multiple attempts
  - Lost a closing paragraph during edits and had to recover from git

#### :bulb: Proposed Improvement
  - Provide helper scripts for appending or inserting Markdown snippets to avoid formatting mistakes

#### :mortar_board: Learning & Insights
  - Use `git show HEAD:file` to recover original content when a patch goes wrong
  - Always check for trailing blank lines after sed insertions

#### :link: References
  - `.codex/reflection-template.md`
