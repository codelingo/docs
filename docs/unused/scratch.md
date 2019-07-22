```yaml
tenets:
  - import: modica/default
  - import: modica/default/null-check
  - import: codelingo/default
  - name: find-funcs #name of the tenet
    comment: This is a function, but you probably already knew that.
    query: |
    import: codelingo/csharp
      @ clair.comment
      csharp.method_declaration(depth = any)
  - name: same-other-tenet
    comment: This is the comment left by the flow
    actions:
      # functions here ...
    query:
      # query here ...
```


```yaml
tenets:
  - import: modica/default/null-check
    actions:
      - codelingo/review
          comment: "this overrides null-check default comment"
```

<pre>
<code>
...
tenets:
  - name: four-or-less
    actions:
      codelingo/docs:
        body: Functions in this module should take a maximum of four arguments.<mark class="code-impt" style="display:inline-block; width: 100%;backgroun">    query:
      import codelingo/ast/php              // import statement
      @review.comment                      // feature extraction decorator
      php.stmt_function(depth = any)       // the match statement</mark>
...
</code>
</pre>