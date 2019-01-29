# Overview

A Flow is an automated development workflow that leverages Tenets to do some task, for example automating code reviews. While a Tenet lives next to your code in a codelingo.yaml file, it is inert until a Flow uses it.

Under the hood, a Flow is a pipeline of serverless functions, called Flow Functions. Flow Functions allow Flows to integrate with your existing tools and infrastructure. Flow Functions are also what glue Tenets and Flows together, with the use of query decorators. Let's walk through the following Tenet to see how this works:

```yaml
tenets:
    - name: example-tenet
      flows:
        codelingo/docs:
          title: Find functions named helloWorld.
        codelingo/review:
          comment: "This is a function named helloWorld."
      query: |
        import codelingo/ast/go
        
        @review comment 
        go.func_decl:
          go.ident:
            value == "helloWorld"
```

## Import & Config

Flows that can be used with the above Tenet are configured under the `flows` section:

```yaml
# ...
flows:
  codelingo/review:
    comment: "This is a function named helloWorld."
# ...
```

Here we are importing the `review` flow from the `codelingo` owner and configuring it to comment "This is a function named helloWorld." on any query matches. 

## Flow Function Decorators

The Tenet query searches for all Go functions named "helloWorld":

```yaml
# ...
query: |
  import codelingo/ast/go

  @review comment
  go.func_decl (depth = any):
    go.ident:
      name == "helloWorld"
# ...
```

 Tenet queries are decorated with Flow Function decorators which extract the results of the query to be used by the Flow. In this case, `@review comment` is the decorator for the comment Flow Function of the Review Flow:

```yaml
# ...
  @review comment
  go.func_decl:
# ...
```

By decorating the `go.func_decl` fact with `@review comment` the Review Flow's comment function extracts the file and line from the query result, to be used by the review Flow to comment on that line.

<div class="alert alert-info">
  <p style="font-size:16px;">
  Documentation on how to compose custom Flows is coming soon. In the mean time, please see the <a href="/docs/concepts/tenets/">Tenets</a> documention to understand how Flows work with Tenets. 
</p>
</div>
