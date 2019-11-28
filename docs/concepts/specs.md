# Overview

Specs live in codelingo.yaml files in your repository and are used by Actions to automate tasks. You can think of a Spec as an underlying principle guiding a workflow.

In the Golang Spec [sprintf](https://www.codelingo.io/specs/codelingo/go/sprintf) below, the Review Action uses the Spec to make sure `errors.New` is being used correctly and attaches a comment to the line where the `go.call_expr` is found, using the `@review comment` decorator:

```yaml
specs:
  - name: sprintf
    actions:
      codelingo/docs:
        body: Find instances of 'errors.New(fmt.Sprintf(...))'.
      codelingo/review:
        comment: Should replace errors.New(fmt.Sprintf(...)) with errors.Errorf(...).
    query: |
      import codelingo/ast/go
  
      @review comment
      go.call_expr(depth = any)
        go.selector_expr:
          go.ident:
            name == "errors"
          go.ident:
            name == "New"
        go.args:
          go.call_expr:
            go.selector_expr:
              go.ident:
                name == "fmt"
              go.ident:
                name == "Sprintf"
```

Examples of problems that can be solved with Specs & Actions include:

- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team.
- Infrastructure specific guidelines / safeguards: learning from failures.
- Change management: large scale incremental refactoring.
- Packaging the author’s guidance with a library.
- Anything a static linter expresses, with a fraction of the code.

# Adding Specs

There are four ways to add Specs to your project:

1. The easiest is to use the CodeLingo Dashboard:

Navigate to the [Dashboard](https://www.codelingo.io/dashboard) and, assuming you already have at least one public repository on GitHub, follow the tutorial.

2. The second is to import a bundle of Specs by writing directly to a codelingo.yaml file in one of your repositories:

```yaml
specs:
  - import: codelingo/go
```

In the example above `codelingo` is the Bundle owner and `go` is the Bundle name. More Spec bundles from the CodeLingo community can be found [here](https://www.codelingo.io/specs).

3. The third way is to import individual Specs from a Bundle:

```yaml
specs:
  - import: codelingo/go/goto
  - import: codelingo/go/sprintf
```

4. The final way is to write a new Spec directly in the codelingo.yaml file:

```yaml
specs:
  - name: find-funcs
    actions:
      codelingo/docs:
        title: "Example Spec that finds all func decls"
      codelingo/review:
        comment: "This is a function."

    query:
      import codelingo/ast/go
  
      @review comment
      go.func_decl
```

<br/>

# Structure of a Spec

A Spec consists of [Metadata](#metadata), [Actions](#actions), and the [Query](#query) itself.

```yaml
# ...
specs:
  - name: # ...
    actions: # ...
    query: # ...
# ...
```

## Metadata

Metadata describes the Spec. It is used for discovery and documentation. The `name` uniquely names the Spec within the Bundle and the other Specs that may be in the same codelingo.yaml, for example:

```yaml
# ...
specs:
  - name: four-or-less
    actions: 
    # ...
    query:
# ...
```

## Actions

Specs on their own do nothing until a Action uses it. The Action section configures the Actions that can use this Spec, for example:

```yaml
# ...
actions:
  codelingo/review:
    comment: "This is a function."
# ...
```

#### Note:

We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly.

## Query

The query is made up of three parts:

- Import statement to include the relevant [Lexicon(s)](CLQL.md#lexicons)
- The statement of CLQL Facts
- Decorators which extract features of interest to Action Functions

For example:

```yaml
# ...
specs:
  - # ...
    query:
      import codelingo/ast/php         # import statement

      @review comment                  # Action Function decorator
      php.stmt_function(depth = any)  # the CLQL fact statement
# ...
```

Here we've imported the PHP Lexicon and are looking for function statements at any depth, which is to say we're looking for functions defined anywhere in the target repository. Once one is found, the Review Action is going to attach it's comment to the file and line number of that function.

Here is a more complex example:

```yaml
# ...
specs:
  - name: debug-prints
    actions: # ...
    query: |
      import codelingo/ast/python36

      @review comment
      python36.expr(depth = any):
        python36.call:
          python36.name:
            id == "print"
# ...
```

This particular Spec looks for debug prints in Python code.

Note: The decorator `@review comment` is what integrates the Spec into the Review Action, detailing where the comment should be made when the pattern matches. Generally speaking, query decorators are metadata on queries that functions use to extract named information from the query result.
<!-- TODO add more decorators example -->

## Action Functions

Actions are made up of a pipeline of serverless functions, called Action Functions.

In the example below, the review function builds a comment from a Spec query which can be used by a Action to comment on a Pull Request made to Github, Bitbucket, Gitlab or the like. It does this by extracting the file name, start line and end line to attach the comment to via the `@review comment` Action Function query decorator. See [Query Decorators as Feature Extractors](#query) for more details.

```yaml
# ...
specs:
  - name: four-or-less
    actions:
      codelingo/review:
        comment: Please write functions that only take a maximum of four arguments.
    query:
      import codelingo/ast/php
      @review comment
      php.stmt_function(depth = any)
# ...
```

