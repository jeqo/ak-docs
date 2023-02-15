# Proposal to migrate Apache Kafka docs to Markdown/Hugo

## TODO

- [x] Convert HTML to Markdown
- [ ] Fix cross-references
- [ ] Fix versioned links
- [ ] Integration with Kafka-site
- [ ] Code highlighting

## How to run

```shell
hugo serve -b http://localhost:1313/documentation
```

## Convert HTML to Markdown

```shell
pandoc -f html content/configuration.html -t markdown > content/configuration.md
```