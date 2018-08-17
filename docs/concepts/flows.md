# Overview

A Flow is an automated development workflow that leverages Tenets to do some task, for example automating code reviews. While a Tenet lives next to your code in a codelingo.yaml file, it is inert until a Flow uses it.

Under the hood, a Flow is a pipeline of serverless functions, called Flow Functions. Flow Functions allow Flows to integrate with your existing tools and infrastructure. Flow Functions are also what glue Tenets and Flows together, with the use of query decorators. Let's walk through the following Tenet to see how this works:

```yaml
tenets:
    - name: example-tenet
      doc: find functions named someName
      flows:
        codelingo/review:
          comment: "this is a func"
      query: |
        import codelingo/ast/go
        
        @review.comment 
        go.func_decl:
          go.ident:
            value == "someName"
```

## Import & Config

Flows that can be used with the above Tenet are configured under the `flows` section:

```yaml
# ...
flows:
  codelingo/review:
    comment: "this is a func"
# ...
```

Here we are importing the `review` flow from the `codelingo` owner and configuring it to comment "this is a func" on any query matches. 

## Flow Function Decorators

The Tenet query searches for all Go functions named "someName":

```yaml
# ...
query: |
  import codelingo/ast/go

  @review.comment
  go.func_decl:
    go.ident:
    value == "someName"
# ...
```

 Tenet queries are decorated with Flow Function decorators which extract the results of the query to be used by the Flow. In this case, `@review.comment` is the decorator for the comment Flow Function of the review Flow:

```
# ...
  @review.comment
  go.func_decl:
# ...
```

By decorating the `go.func_decl` fact with `@review.comment` the review Flow's comment Function extracts the file and line from the query result, to be used by the review Flow to comment on that line.


<div class="alert alert-info">
  <p style="font-size:16px;">
  Documentation on how to compose custom Flows is coming soon. In the mean time, please see the <a href="/docs/concepts/tenets/">Tenets</a> documention to understand how Flows work with Tenets. 
</p>
</div>