# Overview

Tenets live in .lingo.yaml files in your repository and are used by Flows to automate tasks. You can think of a Tenet as an underlying principle guiding a workflow. 

In the sprintf-error Tenet below, the Review Flow uses the Tenet to make sure `errors.New` is being used correctly and attaches a comment to the line where the `go.call_expr` is found, using the `@review.comment` decorator:

```yaml
tenets:
  - name: sprintf-error
    doc: |
      Find instances of 'errors.New(fmt.Sprintf(...))'.
    flows:
      codelingo/review:
        comments: Should replace errors.New(fmt.Sprintf(...)) with errors.Errorf(...).
    query: |
      import codelingo/ast/go
  
      @review.comment
      go.call_expr({depth: any}):
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

Examples of problems that can be solved with Tenets & Flows include:

- Anything a static linter expresses, with a fraction of the code
- Change management: large scale incremental refactoring
- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team
- Infrastructure specific guidelines / safeguards: learning from failures
- Packaging the author’s guidance with a library

# Adding Tenets

There are three ways to add Tenets to a .lingo.yaml file:

1. The easist is to import a bundle of Tenets:

```yaml
tenets:
  - import: codelingo/go
```

In the example above `codelingo` is the bundle owner and `go` is the bundle name. More Tenet bundles from the community can be found [here](https://github.com/codelingo/hub/tree/master/tenets).https://github.com/codelingo/hub/tree/master/tenets

2. The second way is to import individual Tenets from a bundle:

```yaml
tenets:
  - import: codelingo/go/goto
  - import: codelingo/go/sprintf
```

3. The third way is to write a new Tenet directly in the .lingo.yaml file:

```
tenets:
  - name: find-funcs
    doc == "example Tenet that finds all func decls"
    flows:
      codelingo/review:
        comment == "this is a function"

query:
  import go
  
  @review.comment
  go.func_decl
```

# Publishing a Tenet Bundle

To publish a Tenet Bundle, make a pull request to github.com/codelingo/hub and add a folder under:

```
tenets/
  <your-codelingo-username>/
    <bundle-name>/
      <tenet-name>/
        .lingo.yaml
```

<br/>

# Structure of a Tenet

A Tenet consists of [Metadata](#metadata), [Flows](#flows), and the [Query](#query) itself.
```YAML
...
tenets:
  - name: ...
    doc: ...
    flows: ...
    query: ...
...
```

## Metadata

Metadata describes the Tenet. It is used for discovery and documentation. The two main fields are `name`, uniquely naming the Tenet and `doc`, describing the Tenet's purpose, for example:

```YAML
# ...
tenets:
  - name: four-or-less
    doc: Functions in this module should take a maximum of four arguments.
    flows == 
    # ...
    query:
# ...
```

## Flows

Tenets on their own do nothing until a Flow uses it. The flow section configures the Flows that can use this Tenet, for example:

```yaml
# ...
flows:
  codelingo/review:
    comment == "this is a func"
# ...
```

## Query

The query is made up of three parts:

- Import statement to include the relevant [Lexicon(s)](CLQL.md#lexicons)
- Decorators which extract features of interest to Flow Functions
- The statement of CLQL facts

For example:

```YAML
# ...
tenets:
  - # ...
    query:
      import codelingo/ast/php              # import statement

      @review.comment                      # Flow Function decorator
      php.stmt_function({depth: any})       # the CLQL fact statement
# ...
```

Here we've imported the php lexicon and are looking for function statements at any depth, which is to say we're looking for functions defined anywhere in the target repository. Once one is found, the review Flow is going to attach it's comment to the file and line number of that function.

Here is a more complex example:

```YAML
...
tenets:
  - name: debug-prints
    doc: ...
    flows: ...
    query: |
      import codelingo/ast/python36

      @review.comment
      python36.expr({depth: any}):
        python36.call:
          python36.name:
            id == "print"
...
```

This particular Tenet looks for debug prints in python code.


Note, the decorator `@review.comment` is what integrates the Tenet into the Review Flow, detailing where the comment should be made when the pattern matches. Generally speaking, query decorators are metadata on queries that functions use to extract named information from the query result.
<!-- TODO add more decorators example -->

## Flow Functions

Flows are made up of a pipeline of serverless functions, called Flow Functions.

In the example below, the review Function builds a comment from a Tenet query which can be used by a Flow to comment on a pull request made to github, bitbucket, gitlab or the like. It does this by extracting the file name, start line and end line to attach the comment to via the `@review.comment` Flow Function query decorator. See [Query Decorators as Feature Extractors](#query_decorators) for more details.

```YAML
# ...
tenets:
  - name: four-or-less
    doc: Functions in this module should take a maximum of four arguments.
    flows:
      codelingo/review:
        comments: Please write functions that only take a maximum of four arguments.
    query:
      import codelingo/ast/php
      @review.comment
      php.stmt_function({depth: any})
# ...
```

# Writing Custom Tenets

Follow these steps for writing Tenets for your own requirements:

1. Define metadata for the Tenet (`name`, `doc`)

2. Identify what Lexicon(s) will be required (view availlable Lexicons via [the Codelingo repo](https://github.com/codelingo/codelingo/tree/master/lexicons))

3. Import the Lexicon(s) into your Tenet. (e.g.`import codelingo/ast/csharp`)

4. Write the specific `query` you are interested in using the facts provided by the Lexicon.

5. Integrate the relevant `functions`.

6. (_optional_) [Deploy your Tenet to the Hub](#deploying-tenets-to-the-hub).


<br/>

# IDE Integration

CodeLingo integrates with your IDE to provide support for writing and running CLQL queries (Tenets):

## Sublime

<a href="https://github.com/codelingo/ideplugins/tree/master/sublime" target="_blank">View Subline pulugin README</a>

CodeLingo's Integrated Development Environment (IDE) plugins can help build patterns in code by automatically generating queries to detect selected elements of programs. A generated query will describe the selected element and its position in the structure of the program:

![Query Generation](../img/queryGeneration.png)

In the above example, a string literal is selected. The generated CLQL query will match any literal directly inside an assignment statement, in a function declaration, matching the nested pattern of the selected literal.

## Vistual Studio

<a href="https://github.com/codelingo/ideplugins/tree/master/vs" target="_blank">View Visual Studio extension README</a>

## VIM

Vim has also full support for the Lingo syntax, including CLQL. To set it up:

- Download [lingo.vim](../resources/lingo.vim)
- Copy to `~/.vim/syntax/lingo.vim`
- Enable in vim with `:set syntax=lingo`
- Auto enable on `.lingo` file open by adding the following line to `~/.vimrc`

```
au BufRead,BufNewFile *.lingo set syntax=lingo
```

Other than the match statement, written in CLQL, the rest of a .lingo file is written in YAML. As such, you can set .lingo files to YAML syntax in your IDE to get partial highlighting.
