### :book: Reflection for [2025-06-15 11:54]
  - **Task**: Extend build_examples.sh to support groups
  - **Objective**: Allow faster builds of targeted example categories
  - **Outcome**: Updated script parses group names, filters fast mode within them and updated documentation

#### :sparkles: What went well
  - Script logic remained simple while gaining flexibility

#### :warning: Pain points
  - Local Linux: building grouped examples still fetched dependencies for each run

#### :bulb: Proposed Improvement
  - Cache example builds or use incremental compilation to reduce repeated dependency fetches
