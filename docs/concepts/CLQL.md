# Lexicons

CodeLingo Query Language (CLQL) queries are statements of Facts about a domain of knowledge (e.g. an AST). In the case of an AST lexicon, the lexicon provides Facts about the syntatic structure of a codebase, which can then be queried to identify arbitrary patterns in code.

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

If you are interested in writing your own custom Lexicons, please reach out via  **hello@codelingo.io** or ping the team on [Slack](https://codelingo.slack.com/join/shared_invite/enQtNTE5MTAyNTAxMTU4LTg2ZWRkYTI3NGMzOTM5ZjYwMWE4MjY0ODg3M2E4NzAxNDUxNjU4YTNkYzA4NGJjMDU3YjY5OTQwNjZkYWQ1ZGI)

# Querying with Facts

<!--Should we include systems that CLQL does not *yet* support? -->
CLQL can query many types of software-related systems but assume for simplicity that all queries on this page are scoped to a single object oriented program.

<!--TODONOW link to fact definition section on lexicon page-->
Queries are made up of Facts. A CLQL query with just a single Fact will match all elements of that type in the program. The following query matches and returns all classes in the queried program:

```yaml
@review comment
common.class(depth = any)
```

It consists of a single Fact `common.class`. The name `class` indicates that the Fact refers to a class, and the namespace `common` indicates that it may be a class from any language with classes. If the namespace were `csharp` this Fact would only match classes from the C# Lexicon. The depth range `depth = any` makes this Fact match any class within the context of the query (a single C# program), no matter how deeply nested.
A comment is made on every class found as there is a decorator `@review comment` directly above the single Fact `common.class`.

Note: For brevity we will omit the `common` namespace. This can be done in codelingo.yaml files by importing the common lexicon into the global namespace: `import codelingo/ast/common as _`. For comparison a lexicon import normally looks like: `import codelingo/ast/common` and require us to prefix any fact such as `method` like so: `common.method`.

<br />

## Fact Properties

Each fact has a number of properties which we can access to further refine our queries. For example the method fact in the example below has a "name" property. To limit the query to match classes with a particular name, utilize the "name" property as an argument to the `method` Fact:

```yaml
@review comment
method(depth = any):
  name == "myFunc"
```

This query returns all methods with the name "myFunc". Note that the query decorator is still on the `method` Fact. The decorator indicates what we want to return, while the properties allow us to specify conditions for which Facts will be matched. Also note that properties are not namespaced, as their namespace is implied from their parent Fact.


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
  value == 8.7
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
@review comment
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

Note: The child Facts do not need to be contiguous, other facts can occur in-between and CLQL will ignore them, however the child Facts must be on the same level of the AST (Have the same immediate parent).

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

More examples of nested exclusion can be found [here](https://www.codelingo.io/docs/concepts/examples/#nested-exclusion).

Note: Facts nested under multiple excludes still do not return results and cannot be [decorated.](https://www.codelingo.io/docs/concepts/actions/#action-function-decorators)

<br />
# Include

Include allows queries to match patterns without a given parent. The following query is a simple attempt at finding infinitely recursing functions. It works by finding functions that call themselves without an if statement to halt recursion:

```yaml
func:
  name as funcName
  exclude:
    if_stmt:
      include:
        func_call(depth = any):
          name == funcName
```

It can be read as matching all functions that call themselves with no if statement between the definition and the call site. `funcName` is a [variable](#variables) that ensures the definition and call site refer to the same function.

Include statements must have an exclude ancestor. Exclude/include pairs can be arbitrarily nested.

Results under include statements appear as children of the parent of the corresponding exclude statement, and therefore *can* be decorated. In the above example, the `func_call` result will appear as a direct child of the `func` result.

<br />
# any_of

A Fact with multiple children will match against elements of the code that have child1 *and* child2 *and* child3 etc. The `any_of` operator overrides the implicit "and" with an "or". The following query finds all methods named `helloWorld` that use basic loops:

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
    name == methodName
```

The query above will only return methods of `classA` for which `classB` has a corresponding method.

For the most part, variables defined anywhere in the query can be passed to functions anywhere else in the query. However, variables defined inside an `exclude` block cannot be passed to functions outside that exclude block and vice versa.

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

JS functions are defined in codelingo.yaml files under the functions section. These functions can then be called in the query section of any [Rules](/concepts/rules.md) within the same codelingo.yaml file.

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
rules:
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
rules:
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


<br />


# Interleaving

Although a query usually begins with a class or method Fact the root of the tree is actually the repository itself. The repository, along with other version control information, is added automatically to the query by the Review Action before searching the CodeLingo Platform:

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

This means when writing a Rule in a codelingo.yaml file, only the AST Lexicon Facts are required:

```yaml
rules:
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

We can write the same Rule with the Common AST lexicon, which would catch the pattern in both languages as the Common lexicon lets us express facts that apply commonly across all languages:

[common lexicon example]

A Rule can be made of interleaved facts from different lexicons.


[update imports to begin with lexicon type: codelingo/ast/common]
[add name matching to funcs above]

[Explain above query]. In a similar fashion, a runtime fact can be interleaved with an AST fact:

[example of code blocks that have > x memory allocated (run golang’s pprof to get an idea)]

Further examples can be found in the [link to Rule examples directory].


-->
