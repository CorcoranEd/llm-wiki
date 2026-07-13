---
name: wiki-quality-check
description: Score a wiki page's coverage, clarity, and structure and either revise it in place (draft mode) or produce a findings list without editing (audit mode). Used by wiki-ingestor before saving new or substantially rewritten pages, and by wiki-curator when auditing pages a human edited directly. Not for structural/frontmatter/convention checks — those are vault-specific and stay with the calling agent.
---

# Wiki Quality Check

A generic editorial pass, independent of this vault's PARA/frontmatter conventions. It scores writing quality only — coverage, clarity, structure — never vault schema. Two modes, selected by the caller via `args` (`"draft"` or `"audit"`).

## Rubric

Silently score the page 1–5 on each dimension:

- **Coverage** — does it capture the key points/facts from its source(s), or for an existing page, its own stated topic? Are there gaps a reader would expect covered?
- **Clarity** — clear, neutral, encyclopedic prose? Any ambiguous, redundant, or padded passages?
- **Structure** — do the expected sections exist in a sensible order, and is heading hierarchy correct (no skipped levels, no orphaned subheadings)?

Note concrete, specific issues for any dimension scoring below 4 — not just the number.

## Draft mode (`args: "draft"`)

Used before a page is first saved, or after a substantial rewrite. Given the drafted content:

1. Score it against the rubric.
2. If every dimension scores 4–5, keep the draft as-is.
3. If any dimension scores below 4, revise the content directly to address the noted issues.
4. Hand back the final (possibly revised) version for the caller to save. Don't surface the scores — this is a silent pass, not a report.

## Audit mode (`args: "audit"`)

Used on an existing page the caller wants reviewed, not a fresh draft. Given the current page content:

1. Score it against the rubric.
2. Produce a findings list: dimension, score, specific issue — for any dimension below 4. If everything scores 4–5, the findings list is empty.
3. Don't edit the page. The caller (`wiki-curator`) presents findings to the user via `AskUserQuestion` and applies any confirmed fixes itself.

## Out of scope

This skill only judges generic writing quality. It does not check:

- Frontmatter validity or fileClass conventions
- Presence of required sections (`## Tasks`, `## Outcomes`, `## Relationships`)
- Wikilink validity
- PARA placement

Those are vault-specific and stay with the calling agent (`wiki-ingestor`, `wiki-curator`, `wiki-linter`).
