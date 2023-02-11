# Proposal to migrate Apache Kafka docs to Markdown/Hugo

## Convert HTML to Markdown

```shell
pandoc -f html content/configuration.html -t markdown > content/configuration.md
```