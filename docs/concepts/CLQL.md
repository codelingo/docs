# Lexicons

CLQL queries are statements of facts about a domain of knowledge. Those facts come from Lexicons.

There are currently three domains of knowledge Lexicon types support:

## Source code (AST)

Abstract Syntax Tree (AST) Lexicons are used to query static properties of source code. These are typically used to enforce project specific patterns such as layering violations as well as more general code smells.

## Version Control (VCS)

With Version Control System (VCS) Lexicons, facts about the VCS itself can be queried: commit comments, commit SHAs, authorship and other metadata.

## Runtime

Runtime Lexicons are used to query the runtime data of a program. These are typically used to identify performance issues and common runtime problems.

## Roadmap

We plan to extend the Lexicons libraries to include:

- Lexicons for databases, networking, CI, CD, business rules, HR
- Lexicons for running systems: logs, crash dumps, tracing

## Lexicon SDK

If you are interested in writing your own custom Lexicons please see the **[Lexicon SDK](https://github.com/codelingo/lexiconsdk)**.

# Querying with Facts

<!--Should we include systems that CLQL does not *yet* support? -->
CLQL can query many types of software related systems. But assume for simplicity that all queries on this page are scoped to a single object oriented program.

<!--TODONOW link to fact definition section on lexicon page-->
Queries are made up of Facts. A CLQL query with just a single fact will match all elements of that type in the program. The following query matches and returns all classes in the queried program:

```
# ...
common.class(depth = any)
```

It consists of a single fact `common.class`. The name `class` indicates that the fact refers to a class, and the namespace `common` indicates that it may be a class from any language with classes. If the namespace were `csharp` this fact would only match classes from the C# lexicon. The depth range `depth = any` makes this fact match any class within the context of the query (a single C# program), no matter how deeply nested.
A comment is made on every class found as there is a decorator `@review.comment` directly above the single fact `common.class`.

Note: for brevity we will omit the `common` namespace. This can be done in codelingo.yaml files by importing the common lexicon into the global namespace: `import codelingo/ast/common as _`.

<br />

## Fact Properties

To limit the above query to match classes with a particular name, add a "name" property as an argument to the `method` fact:

```
@review.comment
common.method(depth = any):
  name == "myFunc"
```

This query returns all methods with the name "myFunc". Note that the query decorator is still on the `method` fact - properties cannot be returned, only their parent facts. Also note that properties are not namespaced, as their namespace is implied from their parent fact.


<br />

## Floats and Ints
<!--TODO(blakemscurr) explain boolean properties once syntax has been added to the ebnf-->
Properties can be of type string, float, and int. The following finds all int literals with the value 8:

```
common.int_lit(depth = any):
  value == 8
```

This query finds float literals with the value 8.7:

```
common.float_lit(depth = any):
  value: 8.7
```

<br />

## Comparison

The comparison operators >, <, >=, and <= are available for floats and ints. The following finds all int literals above negative 3:
```
common.int_lit(depth = any):
  value: > -3
```

<br />

# Fact Nesting

Facts can take any number of facts and properties as children, forming a query with a tree struct of arbitrary depth. A parent-child fact pair will match any parent element even if the child is not a direct descendant. The following query finds all the if statements inside a method called "myMethod", even those nested inside intermediate scopes (for loops etc):

```
common.method(depth = any):
  name == "myMethod"
  common.if_stmt(depth = any)
```

Any fact in a query can be decorated. If `class` is decorated, this query returns all classes named "myClass", but only if it has at least one method:

```
common.class(depth = any):
  name: “myClass”
  common.method(depth = any)
```

Any fact in a query can have properties. The following query finds all methods named "myMethod" on the all classes named "myClass":

```
common.class(depth = any):
  name: “myClass”
  common.method(depth = any):
    name: “myMethod”
```

## Depth

Facts use depth ranges to specify the depth at which they can be found below their parent. Depth ranges have two zero based numbers, representing the minimum and maximum depth to find the result at, inclusive and exclusive respectively. The following query finds any if statements that are direct children of their parent method, in other words, if statements at depth zero from methods:

```
common.method(depth = any):
  common.if_stmt(depth = 0:1)
```

This query finds if statements at (zero based) depths 3, 4, and 5:

```
common.method(depth = any):
  common.if_stmt(depth = 3:6)
```

A depth range where the maximum is not greater than the minimum, i.e. `(depth = 5:5})` or `({depth: 6:0)`, will give an error.

Depth ranges specifying a single depth can be described with a single number. This query finds direct children at depth zero:

```
common.method(depth = any):
  common.if_stmt(depth = 0)
```

Indices in a depth range can range from 0 to positive infinity. Positive infinity is represented by leaving the second index empty. This query finds all methods, and all their descendant if_statements from depth 5 onwards:

```
common.method(depth = any):
  common.if_stmt(depth = 5:)
```

Note: The depth range on top level facts, like `method` in the previous examples, determines the depth from the base context to that fact. In this case the base context contains a single program. However, it can be configured to refer to any context, typically a single repository or the root of the graph on which all queryable data hangs.

<br />

## Branching

The following query will find a method with a foreach loop, a for loop, and a while loop in that order:

```
common.method(depth = any):
  common.for_stmt
  common.foreach_stmt
  common.while_stmt
```

<!--TODO(blakemscurr): Explain the <lexicon>.element fact-->

<br />

# Exclude

Exlude allows queries to match children that *do not* have a given property or child fact. Excluded facts and properties are children of an `exclude` operator. The following query finds all classes except those named "classA":

```
common.class(depth = any):
  exclude:
    name == "classA"
```

This query finds all classes with a method that is not called String:

```
common.class(depth = any):
  common.method:
    exclude:
      name: “String”
```

The placement of the exclude operator has a significant effect on the query's meaning - this similar query finds all classes without String methods:

```
common.class(depth = any):
  exlude:
    common.method:
      name: “String”
```

The exclude operator in the above query can be read as excluding all methods with the name string - the `method` fact and `name` property combine to form a more complex pattern to be excluded. In the same way, arbitrarily many facts, properties, and operators can be added as children of the exclude operator to further specify the pattern to be excluded.

Excluding a fact does not affect its siblings. The following query finds all String methods that use an if statement, but don’t use a foreach statement:

```
common.method(depth = any):
  name: “String”
  common.if_stmt
  exclude:
    common.foreach_stmt
```

An excluded fact will not return a result and therefore cannot be decorated.

<br />
## Nested Exclude

Exclusions can be arbitrarily nested. The following query finds methods which only return nil or return nothing, that is, it finds all methods except those with non-nil values in their return statements:

```
common.method:
  exclude:
    common.return_stmt(depth = any):
      common.literal:
        exclude:
          name == "nil"
```

Facts nested under multiple excludes still do not return results and cannot be decorated.

<br />
# Include

Include allows queries to match patterns without a given parent. The following query is a simple attempt at finding infinitely recursing functions. It works by finding functions that call themselves without an if statement to halt recursion:

```
common.func:
  name as funcName
  exclude:
    common.if_stmt:
      include:
        common.func_call:
          name as funcName
```

It can be read as matching all functions that call themselves with no if statement between the definition and the call site. `$funcName` is a [variable](#variables) that ensures the definition and call site refer to the same function.

Include statements must have an exclude ancestor. Exclude/include pairs can be arbitrarily nested.

Results under include statements appear as children of the parent of the corresponding exclude statement, and therefore *can* be decorated. In the above example, the `func_call` result will appear as a direct child of the `func` result.

<br />
# any_of

A fact with multiple children will match against elements of the code that have child1 *and* child2 *and* child3 etc. The `any_of` operator overrides the implicit "and". The following query finds all String methods that use basic loops:

```
common.method(depth = any):
  name: “String”
  any_of:
    common.foreach_stmt
    common.while_stmt
    common.for_stmt
```
<!-- TODO(blakemscurr) n_of-->

<br />

# Edge

Facts in AST lexicons refer to nodes in an AST, and the parent/child relationship between facts refers to the parent/child relationship of nodes in the AST. Nodes can have other parent/child relationships that are orthogonal to AST, such as calls. These relationships can be queried with the `edge` keyword.

The following query finds function calls at the top level of a file and follows the `calls` edge to their definition:

```
common.func_call:
  edge("calls"):
    common.func
```

<br />

# Path

Path statements encapsulate CLQL trees. These subtrees can be repeated with a single argument allowing succint repition of complex patterns. Branched paths can rejoin allowing a fact to match nodes with different kinds of parents.

## Linear

Say we wanted to find triply nested if statements, our query would look like the following:

```clql
common.if_stmt:
  common.if_stmt:
    common.if_stmt
```

With paths, we can express the same thing like so:

```clql
path(repeat = 3):
  common.if_stmt:
    pathcontinue
```

Once a query reaches a `pathcontinue` statement it continues from the `path` statement until the path has been repeated the specified number of times.

## Repeat range

Some queries cannot be written with `path` statements. Say we wanted to find all functions called by `someFunc()` and an arbitrarily long chain of calls. Our query would have to explicitly match either directly called functions, or functions with 1, 2, 3 etc intermediaries to infinity.

```clql
common.func:
  name == "someFunc"
  any_of:
    common.func_call(depth = any):
      edge("calls"):
        common.func
    common.func_call(depth = any):
      edge("calls"):
        common.func:
          common.func_call(depth = any):
            edge("calls"):
              common.func
    ...
    common.func_call(depth = any):
      edge("calls"):
        common.func:
          common.func_call(depth = any):
            edge("calls"):
              common.func:
                ...
```

With paths the same query is trivial:

```clql
common.func:
  name == "someFunc"
  path(repeat = 1:):
    common.func_call(depth = any):
      edge("calls"):
        common.func:
          pathcontinue
```

`repeat = 1:` is a range specifying that the path should be repeated one or more times.

## Complex subtrees

Say we wanted to match triply nested if statements that all check the same value, our query would look like the following:

```clql
common.if_stmt:
  common.condition:
    common.var:
      name as varName
  common.if_stmt:
    common.condition:
      common.var:
        name == varName
    common.if_stmt:
      common.condition:
        common.var:
          name == varName
```

With paths our query has much less repitition:

```clql
common.func:
  path(repeat = 3):
    common.if_stmt:
      common.condition:
        common.var:
          name as varName
      pathcontinue
```

Note that CLQL elements that are children of `path`, not just the `if_stmt`. Also note that repeated definitions of `varName` are replaced with assertions.

## Branching

A `path` statement can have multiple `pathcontinue` statements. This allows multiple parents to have the same children. These children are defined under a `pathend` statment, rather than as children of the `pathcontinue` statements. It is often used with an `any_of` to match classes of simlar facts such as methods, closures, and functions, for example.

Say we wanted to find functions or methods with doubly nested for loops. Without `pathend` we would need to repeat the doubly nested for loop facts under `func` and `method`:

```
common.file:
  any_of:
    common.func:
      common.for_stmt:
        common.for_stmt
    common.method
      common.for_stmt:
        common.for_stmt
```

With `pathend` there is no repitition:

```
common.file:
  path:
    any_of:
      common.func:
        pathcontinue
      common.method
        pathcontinue
    pathend:
      common.for_stmt:
        common.for_stmt
```

Say we wanted to find functions with function calls inside doubly nested for/while statements, our query would have to handle all combinations of for/for for/while, while/for, and while/while:

```clql
common.func:
  any_of:
    common.for_stmt:
      any_of:
        common.for_stmt:
          common.func_call
        common.while_stmt:
          common.func_call
    common.while_stmt:
      any_of:
        common.for_stmt:
          common.func_call
        common.while_stmt:
          common.func_call
```

With paths, we can express the same thing like so:

```clql
common.func:
  path(repeat = 2):
    any_of:
      common.for_stmt:
        pathcontinue
      common.while_stmt:
        pathcontinue
    pathend:
      common.func_call
```

## Nested paths

Nested paths are not yet valid CLQL. The following query is intended to follow the callgraph from `someFunc` and via function calls with multiply nested for loops. It will currently give a parse error.

```clql
common.func:
  name == "someFunc"
  path(repeat = any):
    path(repeat = 2:):
     common.for_stmt:
       pathcontinue:
        common.func_call(depth = any):
          edge("calls"):
            common.func:
              pathcontinue
```

## Decorators

Some decorators such as `@review.comment` can only be used once per query. Using them in a repeated path will cause an error.

<br />

# Variables

Facts that do not have a parent-child relationship can be compared by assigning their properties to variables. Any argument starting with “$” defines a variable. A query with a variable will only match a pattern in the code if all properties representing that variable are equal.

The following query compares two classes (which do have a parent-child relationship) and returns the methods which both classes implement:

```
common.class(depth = any):
  name: “classA”
  common.method:
    name as methodName
common.class(depth = any):
  name: “classB”
  common.method:
    name as methodName
```

The query above will only return methods of classA for which classB has a corresponding method.

<br />

# Functions

Functions allow users to execute arbitrary logic on variables. There are two types of functions: resolvers and asserters.

## Resolvers

A resolver function is used on the right hand side of a property assertion. In the following example, we assert that the name property of the method fact is equal to the value returned from the concat function:

```
common.class(depth = any):
  name as className
  common.method:
    name == concat("New", className)
```

## Asserters

Asserter functions return a Boolean value and can only be called on their own line in a CLQL query.

The following query uses the inbuilt `regex` function to match methods with capitalised names:

```
common.class(depth = any):
  common.method:
    name as methodName
    regex(/^[A-Z]/, methodName) // pass in the methodName variable to the regex function and assert that the name is capitalised.
```

## Custom Functions

JS functions are defined in codelingo.yaml files under the functions section. These functions can then be called in the query section of any [Tenets](/concepts/tenets.md) within the same codelingo.yaml file.

The following example defines and uses a custom concat function:

```yaml
functions:
  - name: newConcat
    type: resolver
    body: |
      function (a, b) {
        c = a.concat(b)
        return c
      }
tenets:
  - flows:
      codelingo/review:
        comment: |
          This method appears to be a constructor
    name: constructor-finder
    query: |
      common.class(depth = any):
        name as className
        @review.comment
        common.method:
          name == newConcat("New", className)
```

The following example defines and uses a custom string length asserter:

```yaml
functions:
  - name: stringLengthGreaterThan
    type: resolver
    body: |
      function (str, minLen) {
        return str.length > minLen
      }
tenets:
  - flows:
      codelingo/review:
        comment: |
          This method has a long name
    name: long-method-name
    query: |
      common.method:
        name as methodName
        stringLengthGreaterThan(methodName, 15)
```

## Arguments

In addition to the string and regex literals shown above, functions can accept float, bool, and int arguments.

For the most part, variables defined anywhere in the query can be passed to functions anywhere else in the query. However, variables defined inside an `exclude` block cannot be passed to functions outside that exclude block and vice versa.

<br />


# Interleaving

When writing a Tenet in a codelingo.yaml file, only the AST lexicon facts are required:

```clql
tenets:
  - name: all-classes
    doc: Documentation for all-classes
    flows:
      codelingo/review:
        comment: This is a class, but you probably already knew that.
    query:
      import codelingo/ast/csharp as cs
      @review.comment
      cs.class(depth = any)
```

The review Flow adds the repository information to the query before searching the CodeLingo Platform:

```clql
query:
  import codelingo/vcs/git
  import codelingo/ast/csharp as cs
  git.repo:
    name: “yourRepo”
    owner: “you”
    host: “local”
    git.commit:
      sha: “HEAD”
      cs.project:
        @review.comment
        cs.class(depth = any)
```

Every query to the CodeLingo platform itself starts with VCS facts to instruct the CodeLingo Platform on where to retrieve the source code from.

Git (and indeed any Version Control System) facts can be used to query for changes in the code over time. For example, the following query checks if a given method has increased its number of arguments:

```
git.repo:
  name: “yourRepo”
  owner: “you”
  host: “local”
  git.commit:
    sha: “HEAD^”
    project:
      method:
        arg-num as args
  git.commit:
    sha: “HEAD”
    project:
      @review.comment
      method:
        arg-num: > $args
```



<!---
TODO(BlakeMScurr) fully fill out template

We can write the same Tenet with the Common AST lexicon, which would catch the pattern in both languages as the Common lexicon lets us express facts that apply commonly across all languages:

[common lexicon example]

A Tenet can be made of interleaved facts from different lexicons.


[update imports to begin with lexicon type: codelingo/ast/common]
[add name matching to funcs above]

[Explain above query]. In a similar fashion, a runtime fact can be interleaved with an AST fact:

[example of code blocks that have > x memory allocated (run golang’s pprof to get an idea)]

Further examples can be found in the [link to Tenet examples directory].


-->