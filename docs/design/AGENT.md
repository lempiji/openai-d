# Repository Documentation Guidelines for Proposals and ADRs

This document defines the structure, naming conventions, templates, and workflows for managing **Proposals** and **Architectural Decision Records (ADRs)** in the code repository.

---

## 1. Directory Layout

Organize all design documents under a top‑level `docs/` folder:

```
/docs
  └── design/
      ├── proposals/
      │     ├── 0001-add-search-feature.md
      │     └── 0002-improve-auth-flow.md
      └── adr/
          ├── 0001-use-postgresql.md
          └── 0002-introduce-microservices.md
```

* **proposals/**: high‑level feature or enhancement proposals.
* **adr/**: detailed architecture decisions that affect design or infrastructure.

---

## 2. Naming Conventions

* **Proposal files**: `NNNN-short-kebab-title.md` (zero‑padded sequential number).
* **ADR files**: `NNNN-short-kebab-title.md` (separate sequence from proposals).

Examples:

* `docs/proposals/0003-enable-ssl.md`
* `docs/adr/0004-deprecate-legacy-auth.md`

---

## 3. Document Templates

Standardize frontmatter and structure to ensure consistency.

### 3.1 Proposal Template

```markdown
---
title: Add Search Feature
date: 2025-06-27
status: Draft        # [Draft | Under Review | Approved | Rejected]
---

# Proposal: Add Search Feature

## Motivation
Describe the user need or business goal.

## Goals
List success criteria.

## Non-Goals
Clarify what is out of scope.

## Solution Sketch
Outline UI, API, data changes.

## Alternatives
- Option A: …
- Option B: …

## Impact & Risks
- Performance
- Security

## Next Steps
- Review by @team/product
- Implementation plan
```

### 3.2 ADR Template

```markdown
---
title: Use PostgreSQL as Primary Data Store
date: 2025-06-27
status: Proposed     # [Proposed | Accepted | Deprecated]
---

# ADR 0001: Use PostgreSQL as Primary Data Store

## Context
Current system uses SQLite which cannot scale horizontally.

## Decision
Adopt PostgreSQL 14 for OLTP workloads.

## Consequences
- Pros: ACID compliance, rich ecosystem
- Cons: Operational overhead, higher cost
```

---

## 4. Workflow

1. **Draft Proposal** in `docs/design/proposals/`.
2. **Review & Iterate** with stakeholders; update `status` to `Under Review`.
3. On **approval**, change `status` to `Approved` and tag the PR.
4. **Implementation**: link PR to Proposal (e.g., “Implements Proposal 0001”).
5. When an architectural decision is needed as a result, **create ADR** in `docs/design/adr/`, referencing the Proposal.
6. **Review ADR** with architecture team; update `status` to `Accepted`.
7. Tag implementation PRs with `This change implements ADR-XXXX`.

---

## 5. Linking & Traceability

* In a **Proposal**, add:

  ```markdown
  Related ADR: docs/adr/0002-introduce-microservices.md
  ```
* In an **ADR**, add:

  ```markdown
  Originating Proposal: docs/proposals/0003-add-search-feature.md
  ```
* In **Pull Requests**, reference docs:

  > This PR implements ADR-0001 and addresses Proposal-0003.

---

## 6. Status Management

* Keep frontmatter `status` up to date.
* For ADRs, if a decision is later reversed, mark as `Deprecated` and create a new ADR.
* Maintain an `INDEX.md` in each folder to list and link all documents with their statuses.

---

## 7. Review & Approval Process

* Assign reviewers based on document type:

  * Proposals: product owner + feature team
  * ADRs: architecture committee + impacted teams
* Use GitHub labels (`proposal`, `adr`, `design-doc`) to filter and track.
* Enforce that any merged code touching core architecture must be backed by an **Accepted** ADR.

---

## 8. Best Practices

* Keep proposals concise; elaborate only as needed.
* Only create an ADR for decisions with system‑wide impact.
* Regularly audit `docs/adr/` for deprecated entries.
* Use cross‑references to maintain a clear history of decisions.

---

*By following this structure and workflow, teams can ensure transparent decision‑making, easy onboarding for new members, and a traceable evolution of both features and architecture.*
