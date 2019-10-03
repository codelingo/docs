# Lexicons

CodeLingo Query Language (CLQL) queries are statements of Facts about a domain of knowledge. Those Facts come from Lexicons.

There are currently three domains of knowledge Lexicon types support:

## Source code (AST)

Abstract Syntax Tree (AST) Lexicons are used to query static properties of source code. These are typically used to enforce project specific patterns such as layering violations as well as more general code smells.

## Version Control (VCS)

With Version Control System (VCS) Lexicons, Facts about the VCS itself can be queried: commit comments, commit SHAs, authorship and other metadata.

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
CLQL can query many types of software related systems but assume for simplicity that all queries on this page are scoped to a single object oriented program.

<!--TODONOW link to fact definition section on lexicon page-->
Queries are made up of Facts. A CLQL query with just a single Fact will match all elements of that type in the program. The following query matches and returns all classes in the queried program:

```yaml
# ...
common.class(depth = any)
```

It consists of a single Fact `common.class`. The name `class` indicates that the Fact refers to a class, and the namespace `common` indicates that it may be a class from any language with classes. If the namespace were `csharp` this Fact would only match classes from the C# Lexicon. The depth range `depth = any` makes this Fact match any class within the context of the query (a single C# program), no matter how deeply nested.
A comment is made on every class found as there is a decorator `@review comment` directly above the single Fact `common.class`.

Note: For brevity we will omit the `common` namespace. This can be done in codelingo.yaml files by importing the common lexicon into the global namespace: `import codelingo/ast/common as _`.

<br />

## Fact Properties

To limit the above query to match classes with a particular name, add a "name" property as an argument to the `method` Fact:

```yaml
@review comment
method(depth = any):
  name == "myFunc"
```

This query returns all methods with the name "myFunc". Note that the query decorator is still on the `method` Fact - properties cannot be returned, only their parent Facts. Also note that properties are not namespaced, as their namespace is implied from their parent Fact.


<br />

## Strings, Floats and Integers
<!--TODO(blakemscurr) explain boolean properties once syntax has been added to the ebnf-->
Properties can be of type String, Float, and Integer. The following finds all Integer literals with the value 8:

```yaml
int_lit(depth = any):
  value == 8
```

This query finds float literals with the value 8.7:

```yaml
float_lit(depth = any):
  value: 8.7
```

<br />

## Equality

The equality operators == and != are avaliable for Strings, Floats and Integers. The following finds all methods that are not called "main":

```yaml
method(depth = any):
  name != "main"
```


<br />

## Comparison

The comparison operators >, <, >=, and <= are available for Floats and Integers. The following finds all Int literals above negative 3:

```yaml
int_lit(depth = any):
  value > -3
```

<br />

# Fact Nesting

Facts can take any number of facts and properties as children, forming a query with a tree struct of arbitrary depth. A parent-child Fact pair will match any parent element even if the child is not a direct descendant. The following query finds all the if statements inside a method called "myMethod", even those nested inside intermediate scopes (for loops etc):

```yaml
method(depth = any):
  name == "myMethod"
  if_stmt(depth = any)
```

Any Fact in a query can be decorated. If `class` is decorated, this query returns all classes named "myClass", but only if it has at least one method:

```yaml
class(depth = any):
  name == “myClass”
  method(depth = any)
```

Any Fact in a query can have properties. The following query finds all methods named "myMethod" that are inside classes named "myClass":

```yaml
class(depth = any):
  name == “myClass”
  method(depth = any):
    name == “myMethod”
```

## Depth

Facts use depth ranges to specify the depth at which they can be found below their parent. Depth ranges have two zero based numbers, representing the minimum and maximum depth to find the result at, inclusive and exclusive respectively. The following query finds any if statements that are direct children of their parent method, in other words, if statements at depth zero from methods:

```yaml
method(depth = any):
  if_stmt(depth = 0:1)
```

This query finds if statements at (zero based) depths 3, 4, and 5:

```yaml
method(depth = any):
  if_stmt(depth = 3:6)
```

Note: A depth range where the maximum is not greater than the minimum, i.e. `(depth = 5:5})` or `({depth: 6:0)`, will give an error.

Depth ranges specifying a single depth can be described with a single number. This query finds direct children at depth zero:

```yaml
method(depth = any):
  if_stmt(depth = 0)
```

Indices in a depth range can range from 0 to positive infinity. Positive infinity is represented by leaving the second index empty. This query finds all methods, and all their descendant if_statements from depth 5 onwards:

```yaml
method(depth = any):
  if_stmt(depth = 5:)
```

Note: The depth range on top level Facts, like `method` in the previous examples, determines the depth from the base context to that Fact. In this case the base context contains a single program. However, it can be configured to refer to any context, typically a single repository or the root of the graph on which all queryable data hangs.

<br />

## Branching

The following query will find a method with a foreach loop, a for loop, and a while loop in that order:

```yaml
method(depth = any):
  for_stmt
  foreach_stmt
  while_stmt
```

<!--TODO(blakemscurr): Explain the <lexicon>.element fact-->

<br />

# Exclude

Exclude allows queries to match children that *do not* have a given property or child Fact. Excluded Facts and properties are children of an `exclude` operator. The following query finds all classes except those named "classA":

```yaml
class(depth = any):
  exclude:
    name == "classA"
```

This query finds all classes with a method that is not called `helloWorld`:

```yaml
class(depth = any):
  method:
    exclude:
      name == "helloWorld"
```

The placement of the exclude operator has a significant effect on the query's meaning - this similar query finds all classes without `helloWorld` methods:

```yaml
class(depth = any):
  exclude:
    method:
      name == "helloWorld"
```

The exclude operator in the above query can be read as excluding all methods with the name `helloWorld` - the `method` Fact and `name` property combine to form a more complex pattern to be excluded. In the same way, an arbitrary amount of Facts, properties, and operators can be added as children of the exclude operator to further specify the pattern to be excluded.

Excluding a Fact does not affect its siblings. The following query finds all methods named `helloWorld` that use an if statement, but don’t use a foreach statement:

```yaml
method(depth = any):
  name == "helloWorld"
  if_stmt
  exclude:
    foreach_stmt
```

An excluded Fact will not return a result and therefore cannot be decorated.

<br />
## Nested Exclude

Exclusions can be arbitrarily nested. The following query finds methods which only return nil or return nothing, that is, it finds all methods except those with non-nil values in their return statement:

```yaml
method:
  exclude:
    return_stmt(depth = any):
      literal:
        exclude:
          name == "nil"
```

Note: Facts nested under multiple excludes still do not return results and cannot be decorated.

<br />
# Include

Include allows queries to match patterns without a given parent. The following query is a simple attempt at finding infinitely recursing functions. It works by finding functions that call themselves without an if statement to halt recursion:

```yaml
func:
  name as funcName
  exclude:
    if_stmt:
      include:
        func_call:
          name == funcName
```

It can be read as matching all functions that call themselves with no if statement between the definition and the call site. `funcName` is a [variable](#variables) that ensures the definition and call site refer to the same function.

Include statements must have an exclude ancestor. Exclude/include pairs can be arbitrarily nested.

Results under include statements appear as children of the parent of the corresponding exclude statement, and therefore *can* be decorated. In the above example, the `func_call` result will appear as a direct child of the `func` result.

<br />
# any_of

A Fact with multiple children will match against elements of the code that have child1 *and* child2 *and* child3 etc. The `any_of` operator overrides the implicit "and". The following query finds all methods named `helloWorld` that use basic loops:

```yaml
method(depth = any):
  name == "helloWorld"
  any_of:
    foreach_stmt
    while_stmt
    for_stmt
```
<!-- TODO(blakemscurr) n_of-->

<br />

# Edge

Facts in AST lexicons refer to nodes in an AST, and the parent/child relationship between facts refers to the parent/child relationship of nodes in the AST. These nodes can have other parent/child relationships that are orthogonal to AST, such as calls. These relationships can be queried with the `edge` keyword.

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

## Pathend

Suppose we wanted to match triply nested if statements with a function call inside the innermost if statement. Without paths our query looks like:

```clql
common.if_stmt:
  common.if_stmt:
    common.if_stmt:
      common.func_call
```

with paths our query looks like:

```clql
path(repeat = 3):
  common.if_stmt:
    pathcontinue
  pathend:
    common.func_call
```

## Caveats

Branching, where `path` statement has multiple `pathcontinue` statements is currently not supported.

Nested paths are not supported.

Using `any_of` inside a path statement is not supported.

## Decorators

Some decorators such as `@review comment` can only be used once per query. Using them in a repeated path will cause an error.

<br />

# Variables

Facts that do not have a parent-child relationship can be compared by assigning their properties to variables. A query with a variable will only match a pattern in the code if all properties representing that variable are equal.

The following query compares two classes (which do have a parent-child relationship) and returns the methods which both classes implement:

```yaml
class(depth = any):
  name == "classA"
  method:
    name as methodName
class(depth = any):
  name == "classB"
  method:
    name as methodName
```

The query above will only return methods of `classA` for which `classB` has a corresponding method.

<br />

# Functions

Functions allow users to execute arbitrary logic on variables. There are two types of functions: resolvers and asserters.

## Resolvers

A resolver function is used on the right hand side of a property assertion. In the following example, we assert that the name property of the method fact is equal to the value returned from the concat function:

```yaml
class(depth = any):
  name as className
  method:
    name == concat("New", className)
```

## Asserters

Asserter functions return a Boolean value and can only be called on their own line in a CLQL query.

The following query uses the inbuilt `regex` function to match methods with capitalised names:

```yaml
class(depth = any):
  method:
    name as methodName
    regex(/^[A-Z]/, methodName) // pass in the methodName variable to the regex function and assert that the name is capitalised.
```

## Builtin Functions

### UserInput

User input is a builtin function that allows users to define values in CLQL. For example, the following query matches any string literal containing "Hello, World" and replaces it with a string defined by the user which defaults to "Goodbye, World":
```yaml
vars:
  variableName: StringLiteral
  default: Goodbye, World
...
query:
  @rewrite --replace "{{userInput(variableName, default)}}"
  go.basic_lit:
    value as literalValue
    regex(/Hello, World/, literalValue)
```

If run in the CLI with `lingo run rewrite` the user is prompted with a prompt like:
```
StringLiteral["Goodbye, World"]:
```

If run with `lingo run rewrite --dump-comments=<file/path>` a JSON file is created that can be used to build interactive comments on Github.

Functions currently only accept variables as arguments, so `userInput("StringLiteral", "Goodbye, World")` is invalid.

### Resolvers

#### concat

`concat` returns the concatenation of an arbitrary number of strings:

```javascript
concat("H", "e", "l", "l", "o", "!") // Hello!
```

#### toUpper

`toUpper` returns a string in upper case:

```javascript
toUpper("Hello, World!") // HELLO, WORLD!
```

### Asserters

#### regex

`regex` is true if a given regex matches a given string:

```javascript
regex(/[A-Z][a-z]*/, "Hello") // true
```

#### shorterThan

`shorterThan` is true if the first string is shorter than the second:

```javascript
shorterThan("abc", "abcd") // true
```

#### containsOneOf

`containsOneOf` is true if its first string argument contains any of the following arguments:

```javascript
containsOneOf("Hello, World!", "Hello!") // false
containsOneOf("Hello, World!", "Hello") // true
```

## Custom Functions

JS functions are defined in codelingo.yaml files under the functions section. These functions can then be called in the query section of any [Tenets](/concepts/tenets.md) within the same codelingo.yaml file.

The following example defines and uses a custom concat function:

```yaml
funcs:
  - name: newConcat
    type: resolver
    body: |
      function (a, b) {
        c = a.concat(b)
        return c
      }
tenets:
  - actions:
      codelingo/review:
        comment: |
          This method appears to be a constructor
    name: constructor-finder
    query: |
      class(depth = any):
        name as className
        @review comment
        method:
          name == newConcat("New", className)
```

The following example defines and uses a custom string length asserter:

```yaml
funcs:
  - name: stringLengthGreaterThan
    type: asserter
    body: |
      function (str, minLen) {
        return str.length > minLen
      }
tenets:
  - actions:
      codelingo/review:
        comment: |
          This method has a long name
    name: long-method-name
    query: |
      method:
        name as methodName
        stringLengthGreaterThan(methodName, 15)
```

## Arguments

In addition to the string and regex literals shown above, functions can accept float, bool, and int arguments.

For the most part, variables defined anywhere in the query can be passed to functions anywhere else in the query. However, variables defined inside an `exclude` block cannot be passed to functions outside that exclude block and vice versa.

<br />


# Interleaving

When writing a Tenet in a codelingo.yaml file, only the AST lexicon Facts are required:

```yaml
tenets:
  - name: all-classes
    actions:
      codelingo/docs:
        body: Documentation for all-classes
      codelingo/review:
        comment: This is a class, but you probably already knew that.
    query:
      import codelingo/ast/csharp as cs
      @review comment
      cs.class(depth = any)
```

The Review Action adds the repository information to the query before searching the CodeLingo Platform:

```yaml
query:
  import codelingo/vcs/git
  import codelingo/ast/csharp as cs
  git.repo:
    name == "yourRepo"
    owner == "you"
    host == "local"
    git.commit:
      sha == "HEAD"
      cs.project:
        @review comment
        cs.class(depth = any)
```

Every query to the CodeLingo platform itself starts with VCS Facts to instruct the CodeLingo Platform on where to retrieve the source code from.

Git (and indeed any Version Control System) Facts can be used to query for changes in the code over time. For example, the following query checks if a given method has increased its number of arguments:

```yaml
git.repo:
  name == "yourRepo"
  owner == "you"
  host == "local"
  git.commit:
    sha == "HEAD^"
    project:
      method:
        arg-num as args
  git.commit:
    sha == "HEAD"
    project:
      @review comment
      method:
        arg-num > args
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