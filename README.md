# Proposal to migrate Apache Kafka docs to Markdown/Hugo

## TODO

- [x] Convert HTML to Markdown
- [ ] Fix cross-references
- [ ] Fix versioned links
- [ ] Integration with Kafka-site
- [ ] Code highlighting
- [ ] Fix tables

## Goals

- Progressing KAFKA-2967[1] and move Kafka documentation into a more manageable language.
- Use Markdown as markup language and Hugo as static-site generator (similar to Flink).

References:

- https://issues.apache.org/jira/browse/KAFKA-2967

No-goals:

- Migrate kafka-site website. It will require larger effort to replace all dynamics and include logic.

## Changes

### Single-page into multiple pages

It may be possible to build a single-page with hugo, 
though including Markdown pages into a single one is not supported out-of-the-box.

Because of this, 
and as the single page is getting quite long and harder to navigate,
I'm migrating sections into its own page.
So, instead of `documentation#intro`, Introduction section will be located at `documentation/introduction`.
