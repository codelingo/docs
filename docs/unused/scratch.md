```yaml
lexicons: # import any particular lexicons to be used in your tenets
  - codelingo/common
  - codelingo/csharp
tenets:
  - import: modica/default
  - import: modica/default/null-check
  - import: codelingo/default
  - name: find-funcs #name of the tenet
    doc: Example tenet that finds all functions.
    comment: This is a function, but you probably already knew that.
    match: |
      @ clair.comment
      csharp.method_declaration({depth: any})
  - name: same-other-tenet
    doc: Some documentation
    comment: This is the comment left by the bot
    bots:
      # bots here ...
    query:
      # query here ...
```


```yaml
tenets:
  - import: modica/default/null-check
    bots:
      - codelingo/review
          comment: "this overrides null-check default comment"
```

