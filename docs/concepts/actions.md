# Overview

An Action is an automated development workflow that leverages Tenets to do some task, for example automating code reviews. While a Tenet lives next to your code in a codelingo.yaml file, it is inert until an Action uses it.

Under the hood, an Action is a pipeline of serverless functions, called Action Functions. Action Functions allow Actions to integrate with your existing tools and infrastructure. Action Functions are also what glue Tenets and Actions together, with the use of query decorators. Let's walk through the following Tenet to see how this works:

```yaml
tenets:
    - name: example-tenet
      actions:
        codelingo/docs:
          title: Find functions named helloWorld.
        codelingo/review:
          comment: "This is a function named helloWorld."
      query: |
        import codelingo/ast/go
        
        @review comment 
        go.func_decl(depth = any):
          go.ident:
            name == "helloWorld"
```

## Import & Config

Actions that can be used with the above Tenet are configured under the `actions` section:

```yaml
# ...
actions:
  codelingo/review:
    comment: "This is a function named helloWorld."
# ...
```

Here we are importing the `review` action from the `codelingo` owner and configuring it to comment "This is a function named helloWorld." on any query matches. 

## Action Function Decorators

The Tenet query searches for all Go functions named "helloWorld":

```yaml
# ...
query: |
  import codelingo/ast/go

  @review comment
  go.func_decl(depth = any):
    go.ident:
      name == "helloWorld"
# ...
```

 Tenet queries are decorated with Action Function decorators which extract the results of the query to be used by the Action. In this case, `@review comment` is the decorator for the comment Action Function of the Review Action:

```yaml
# ...
  @review comment
  go.func_decl:
# ...
```

By decorating the `go.func_decl` fact with `@review comment` the Review Action's comment function extracts the file and line from the query result, to be used by the Review Action to comment on that line.

#### Note:

We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly.

<div class="alert alert-info">
  <p style="font-size:16px;">
  Documentation on how to compose custom Actions is coming soon. In the mean time, please see the <a href="/docs/concepts/tenets/">Tenets</a> documention to understand how Actions work with Tenets. 
</p>
</div>
