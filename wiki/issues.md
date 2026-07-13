---
tags: [meta, maintenance]
created: 2026-07-04
updated: 2026-07-13
---

# Wiki Issues

Open issues requiring human judgment. Maintained by the linter — resolved items are removed on the next lint pass or by the curator. Use `wiki-curator` to work through these interactively.

Last updated: 2026-07-13

## Orphan Pages

Pages with no inbound links. Review: intentional, or does it need linking from a related page?

<!-- - [[Page Name]] — first flagged YYYY-MM-DD -->

## Ready to Archive

Pages with `superseded_by` set that are still in the active wiki.

<!-- - [[Old Page]] superseded by [[New Page]] -->
<!-- mv wiki/PATH/Old-Page/ wiki/4-Archives/PATH/Old-Page/ -->

## Broken Wikilinks

`[[Links]]` with no matching page. Curator auto-fixes confident, unambiguous matches on its next run; ambiguous ones stay here for review.

<!-- - [[Broken Link]] in [[Page Name]] — no confident match found -->

## Contradictions

Pages with conflicting claims. Recency and source count shown as resolution hints.

<!-- - [[Page A]] vs [[Page B]] — both claim X; Page A is newer (YYYY-MM-DD), Page B has more sources (3 vs 1) -->

## Missing Pages

Referenced in wikilinks but no page exists. Candidates for stub creation.

<!-- - [[Concept Name]] — referenced in [[Page A]], [[Page B]] -->

## Unreviewed Content

Pages with `confidence: unreviewed` older than 30 days.

<!-- - [[Page Name]] — created YYYY-MM-DD -->

## Stale Reviews

Pages where `reviewed` is more than 6 months ago.

<!-- - [[Page Name]] — last reviewed YYYY-MM-DD -->

## Skipped Heading Levels

A heading skips a level (e.g. `##` directly followed by `####`).

<!-- - [[Page Name]] — `##` followed by `####` under "Section Name" -->

## Duplicate Content

Paragraphs or bullets repeated verbatim across pages.

<!-- - [[Page A]] and [[Page B]] — shared passage: "..." -->
