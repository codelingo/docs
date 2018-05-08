C# Tenets

## Overview

A Tenet is a rule about a system written in [CLQL](#clql) and based on libraries of facts called [Lexicons](#lexicons). It is an underlying pattern or heuristic which provide deep analysis of software systems, and can be used to guide development and safeguard systems via [Flows and Bots](flows.md).

Some examples of Tenets:

- Anything a static linter expresses, with a fraction of the code
- Change management: large scale incremental refactoring
- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team
- Infrastructure specific guidelines / safeguards: learning from failures
- Packaging the author’s guidance with a library

CodeLingo Query Language (CLQL) is a simple, lightweight language built for writing Tenets. It allows high levels queries and patterns to be defined across various software domains with ease.

It’s full grammar is under [70 lines of code](../img/ebnf.png)!

Patterns in CLQL (Tenets), can be expressed as statements of facts imported from a particular lexicon.
<br/>

All Tenets are either written directly in `.lingo` files within your project, or imported from the CodeLingo Hub into your `.lingo` file. See the [Getting Started guide](getting-started.md) for more information on configuring your `.lingo` file.

<br/>

##  Structure
A Tenet is a CLQL Query, and consists of [Metadata](#metadata) (name and doc), [Bots](#bots), and the [Query](#query) itself.
```YAML
...
tenets:
  - name: ...
    doc: ...
    bots: ...
    query: ...
...
```

### Metadata

Metadata describes the Tenet. It is used for discovery, integration, and documentation. The two main fields are `name` and `doc`, for example:

```YAML
...
tenets:
  - name: four-or-less
    doc: Functions in this module should take a maximum of four arguments.
    bots: ...
    query: ...
    ...
...
```

<!-- Additional fields are:  -->


### Query
The query is made up of three parts:

- Import statement to include the relevant [Lexicon(s)](#lexicons)
- Decorators which extract features of interest to Bots
- A match statement

For example:

```YAML
...
tenets:
  - name: four-or-less
    doc: Functions in this module should take a maximum of four arguments.
    bots: ...
    query:
      import codelingo/ast/php              # import statement
      @ review.comment                      # feature extraction decorator
      php.stmt_function({depth: any})       # the match statement
...
```

Here we've imported the php lexicon and are looking for function statements at any depth, which is to say we're looking for functions defined anywhere in the target repository. Once one is found, the review bot is going to attach it's comment to the file and line number of that function.

Here is a more complex example:
```YAML
...
tenets:
  - name: debug-prints
    doc: ...
    bots: ...
    query: |
      import codelingo/ast/python36
      @ review.comment
      python36.expr({depth: any}):
        python36.call:
          python36.name:
            id: "print"
...
```

This particular Tenet looks for debug prints in python code.


Note, the decorator `@ review.comment` is what integrates the Tenet into the Review Flow, detailing where the comment should be made when the pattern matches. Generally speaking, query decorators are metadata on queries that bots use to extract named information from the query result.
<!-- TODO add more decorators example -->

### Bots

Bots are agents that integrate with your infrastructure. They are orchestrated in [Flows](flows) and extract features from Tenet queries.

In the example below, the review Bot builds a comment from a Tenet query which can be used by a Flow to comment on a pull request made to github, bitbucket, gitlab or the like. It does this by extracting the file name, start line and end line to attach the comment to via the `@ review.comment` query decorator. See [Query Decorators as Feature Extractors](#query_decorators) for more details.

```YAML
...
tenets:
  - name: four-or-less
    doc: Functions in this module should take a maximum of four arguments.
    bots:
      codelingo/review:
        comments: Please write functions that only take a maximum of four arguments.
    query:
      import codelingo/ast/php
      @ review.comment
      php.stmt_function({depth: any})
...
```

## Writing Custom Tenets

Follow these steps for writing Tenets for your own requirements:

1. Define metadata for the Tenet (`name`, `doc`)

2. Identify what Lexicon(s) will be required (view availlable Lexicons via [the Hub](https://codelingo.io/hub/lexicons))

3. Import the Lexicon(s) into your Tenet. (e.g.`import codelingo/ast/csharp`)

4. Write the specific `query` you are interested in using the facts provided by the Lexicon.

5. Integrate the relevant `bots`.

6. (_optional_) [Deploy your Tenet to the Hub](#deploying-tenets-to-the-hub).


<br/>
## Lexicons

All Tenets require the use of Lexicons. The SDLC is built up of many different domains and patterns across all these domains can be expressed as statements of facts. Those facts come from Lexicons, which are collections of terms about to a domain of knowledge.

More information about each particular lexicon can be found via [the hub](https://codelingo.io/hub/lexicons)

There are currently the following types of Lexicons:

### Source code (AST)

Abstract Syntax Tree (AST) lexicons are used to query static properties of source code. These are typically used to enforce project specific patterns such as layering violations as well as more general code smells.

### Version Control (VCS)

With Version Control System (VCS) lexicons, facts about the VCS itself can be queried: commit comments, commit SHAs, authorship and other metadata.

### Runtime

Runtime lexicons are used to query the runtime data of a program. These are typically used to identify performance issues and common runtime problems.

### Other
We are currently working to extend the Lexicons libraries to include:

- Lexicons for databases, networking, CI, CD, business rules, HR
- Lexicons for running systems: logs, crash dumps, tracing

If you are interested in any of these other types of Lexicons, or are interested in writing your own custom Lexicons please [contact us directly.](hello@codelingo.io)



## Importing Published Tenets

It is possible to import Tenets from other projects. All Published Tenets can be discovered via **[the hub](https://codelingo.io/hub/tenets)**.

To import an existing Tenet into your project, add the url of the Tenet (provided in the hub) in your lingo file. Here is an an example:

```YAML
...
tenets:
  - import: codelingo/go/bool-param
...
```
This imports the `bool-param` Tenet from the `codelingo/go` bundle.

Entire bundles of Tenets can also be imported. For example, to import all of the `codelingo/go` Tenets:
```YAML
...
tenets:
  - import: codelingo/go
...
```

Note: import statements and custom Tenets can exist within the same .lingo file.

Published Tenets to import into your projects can be found and discovered via [the Hub](https://codelingo.io/hub).


<br/>

## Deploying Tenets to the Hub

All public Tenets are stored in our [public GitHub repo](https://github.com/codelingo/hub). Please raise a Pull Request on this repo with your `.lingo` files, or [contact us directly](hello@codelingo.io)


<br/>

## IDE Integration

CodeLingo integrates with your IDE to provide support for writing and running CLQL queries (Tenets):

### Sublime

<a href="https://github.com/codelingo/ideplugins/tree/master/sublime" target="_blank">View Subline pulugin README</a>

CodeLingo's Integrated Development Environment (IDE) plugins can help build patterns in code by automatically generating queries to detect selected elements of programs. A generated query will describe the selected element and its position in the structure of the program:

![Query Generation](../img/queryGeneration.png)

In the above example string literal is selected. The generated CLQL query will match any literal directly inside an assignment statement, in a function declaration, matching the nested pattern of the selected literal.

### Vistual Studio

<a href="https://github.com/codelingo/ideplugins/tree/master/vs" target="_blank">View Visual Studio extension README</a>

### VIM

Vim has also full support for the Lingo syntax, including CLQL. To set it up:

- Download [lingo.vim](../resources/lingo.vim) 
- Copy to `~/.vim/syntax/lingo.vim`
- Enable in vim with `:set syntax=lingo`
- Auto enable on `.lingo` file open by adding the following line to `~/.vimrc`

```
au BufRead,BufNewFile *.lingo set syntax=lingo
```

Other than the match statement, written in CLQL, the rest of a .lingo file is written in YAML. As such, you can set .lingo files to YAML syntax in your IDE to get partial highlighting.





<br/>
## Examples

### Simple examples
#### Argument count
Below is an example of a query that returns all functions in a repository with more than 4 arguments:

```YAML

query:
  import codelingo/vcs/git
  import codelingo/ast/go
  git.repo:
    owner: "username"
    host: "myvcsgithost.com"
    name: "myrepo"
    git.commit:
      sha: "HEAD"
      go.project:
        @ review.comment
        go.func_decl:
          arg_count: > 4
```

Lexicons get data into the CodeLingo Platform and provide a list of facts to query that data. In the above example, the git Lexicon finds and clones the "myrepo" repository from the "myvcsgithost.com" VCS host. The "myrepo" repository must be publicly accessible for the git lexicon to access it.

To access a private repository, the git credentials need to be added to the query:

```YAML
...
query:
  git.repo:
    auth:
      token: "abctoken"
    owner: "username"
    host: "myvcsgithost.com"
    name: "myrepo"
...
```

The CodeLingo Platform can be queried directly with the the `$ lingo search` command or via [Bots](/concepts/flows.md) which use queries stored in Tenets.
#### Matching function name

```yaml
tenets:
- name: first-tenet
  doc: example doc
  bots:
    codelingo/review:
      comments: This is a function, name 'writeMsg', but you probably knew that.
  query:
    import codelingo/ast/go
    @ review.comment
    go.func_decl:
      name: "writeMsg"
```

This will find funcs named "writeMsg". Save and close the file, then run `lingo review`. Try adding another func called "readMsg" and run a review. Only the "writeMsg" func should be highlighted. Now, update the Tenet to find all funcs that end in "Msg":

```yaml
  query:
    import codelingo/ast/go
    @ review.comment
    go.func_decl:
      name: /.*Msg$/
```

### AST

#### CSharp

Iterative code, such as the following, can be more safely expressed declaratively using LINQ. For example:

```
decimal total = 0;
foreach (Account account in myAccounts) {
  if (account.Status == "active") {
  total += account.Balance;
  }
}
```

can be expressed with:

```
decimal total = (from account in myAccounts
          where account.Status == "active"
          select account.Balance).Sum();
```

The CLQL to match this pattern should find all variables that are declared before a foreach statement, and are incremented within the loop. The facts for incrementing inside a foreach loop, and declaring a variable can be generated in the IDE:

![C# example Generation](../img/cs_decl.png)

Note: the `csharp.variable_declarator` has the `identifier_token` field that can be used to identify the `total` variable, but it spans the whole third line, so the whole line must be selected to generate that fact. Since other elements are within that line, many extra facts are generated. This is largely a property of the C# parser used by the underlying [lexicon](#lexicons).

![C# example Generation](../img/cs_inc.png)

The generated code can be turned into a working query by combining the above queries under the same scope, removing extraneous facts, and using a CLQL variable to ensure that the `csharp.identifier_name` and `csharp.variable_declarator` facts refer to the same variable:

```
csharp.method_declaration:
  csharp.block:
    csharp.local_declaration_statement:
      csharp.variable_declaration:
        @ review.comment
        csharp.variable_declarator:
          identifier_token: $varName
    csharp.for_each_statement:
      csharp.add_assignment_expression({depth: any}):
        @ review.comment
        csharp.identifier_name:
          identifier_token: $varName
```

<br />

#### C++

The following tenet asserts that functions should not return local objects by reference. When the function returns and the stack is unwrapped, that object will be destructed, and the reference will not point to anything.

The following query finds this bug by matching all functions that return a reference type, and declare the returned value inside the function body:

```
import codelingo/ast/cpp
@ review.comment
cc.func_decl:
  cc.func_header:
    cc.return_type:
      cc.reference
  cc.block_stmt:
    cc.declaration_stmt:
      cc.variable:
        name: $returnedReference
    cc.return_stmt:
      cc.variable:
        name: $returnedReference
```


#### CLQL vs StyleCop

CLQL, like StyleCop, can express C# style rules and use them to analyze a project, file, repository, or pull request. CLQL, like StyleCop can customize a set of predefined rules to determine how they should apply to a given project, and both can define custom rules.

StyleCop supports custom rules by providing a SourceAnalyzer class with CodeWalker methods. The rule author can iterate through elements of the document and raise violations when the code matches a certain pattern. 

CLQL can express all rules that can be expressed in StyleCop. By abstracting away the details of document walking, CLQL can express in 9 lines,a rule that takes ~50 lines of StyleCop. In addition to being, on average, 5 times less code to express these patterns, CLQL queries can be generated by selecting the code code elements in an IDE.

CLQL is not limited to C# like StyleCop. CLQL can express logic about other domains of logic outside of the scope of StyleCop, like version control.

#### Empty Block Statements

StyleCop can use a custom rule to raise a violation for all empty block statements:

```cs
namespace Testing.EmptyBlockRule {
    using global::StyleCop;
    using global::styleCop.CSharp;

    [SourceAnalyzer(typeof(CsParser))]
    public class EmptyBlocks : SourceAnalyzer
    {
        public override void AnalyzeDocument(CodeDocument document)
        {
            CsDocument csdocument = (CsDocument)document;
            if (csdocument.RootElement != null &amp;&amp; !csdocument.RootElement.Generated)
            {
                csdocument.WalkDocument(
                    new CodeWalkerElementVisitor&lt;object&gt;(this.VisitElement),
                    null,
                    null);
            }
        }

        private bool VisitElement(CsElement element, CsElement parentElement, object context)
        {
            if (statement.StatementType == StatementType.Block && statement.ChildStatements.Count == 0)
            {
                this.AddViolation(parentElement, statement.LineNumber, "BlockStatementsShouldNotBeEmpty");
            }
        }


        private bool VisitStatement(Statement statement, Expression parentExpression, Statement parentStatement, CsElement parentElement, object context)
        {
            if (statement.StatementType == StatementType.Block && statement.ChildStatements.Count == 0)
            {
                this.AddViolation(parentElement, statement.LineNumber, "BlockStatementsShouldNotBeEmpty");
            }
        }
    }
}
```

```xml
<SourceAnalyzer Name="EmptyBlocks">
  <Description>
    Code blocks should not be empty.
  </Description>
  <Rules>
    <RuleGroup Name="Fun Rules You Will Love">
      <Rule Name="BlockStatementsShouldNotBeEmpty" CheckId="MY1000">
        <Context>A block statement should always contain child statements.</Context>
        <Description>Validates that the code does not contain any empty block statements.</Description>
      </Rule>
    </RuleGroup>
  </Rules>
</SourceAnalyzer>
```

The same rule can be expressed in CLQL as the following [tenet](tenets.md):

```clql
lexicons: 
  - codelingo/ast/csharp as cs
tenets:
  - Name: "EmptyBlock"
    Comment: "A block statement should always contain child statements."
    Doc: "Validates that the code does not contain any empty block statements."
    Match: 
      cs.block_stmt:
        exclude:
          cs.element
```

The VisitStatement function contains the core logic of this StyleCop rule:

```cs
private bool VisitStatement(Statement statement, Expression parentExpression, Statement parentStatement, CsElement parentElement, object context)
{
    if (statement.StatementType == StatementType.Block && statement.ChildStatements.Count == 0)
    {
        this.AddViolation(parentElement, statement.LineNumber, "BlockStatementsShouldNotBeEmpty");
    }
}
```

The VisitStatement method is run at every node of the AST tree, then a violation is added if the node is a block statement with no children.
In CLQL, the match statement expresses the logic of the query. Traversal is entirely abstracted away, and the tenet author only needs to express the condition for a "rule violation":

```clql
cs.block_stmt:
  exclude:
    cs.element
```

The above query will match against any block statement that does not contain anything at all. `cs.element` matches all C# elements, and the `exclude` operator performs [exclusion](#exclude).

#### Access Modifier Declaration

In this example, we'll exclude StyleCop's long setup and document traversal boilerplate and focus on the query, which raises a violation for all non-generated code that doesn't have a declared access modifier:

```cs
private bool VisitElement(CsElement element, CsElement parentElement, object context)
{
    // Make sure this element is not generated.
    if (!element.Generated)
    {
        // Flag a violation if the element does not have an access modifier.
        if (!element.Declaration.AccessModifier)
        {
            this.AddViolation(element, "AccessModifiersMustBeDeclared");
        }
    }
}
```

As in the [empty block statements example below](#empty-block-statements), to express the pattern in CLQL, the tenet author only needs to express conditions in the VisitElement body:

```clql
cs.element:
  generated: "false"
  cs.declaration_stmt:
    cs.access_modifier: "false"
```

The above query matches all C# elements that are not generated, whose declaration does not have an access modifier.


### Runtime

#### Detecting Memory Leaks

In the example below we have a database manager class that wraps up a third party library we use to return connections to a database.

From past profiles of our application, we expect the function `getDBCon` to use less than 10MB of memory. If it uses more than this, we want to be notified.

We can do this with the following Tenet:

```clql
csprof.session:
  csprof.exec:
      command: "./scripts/build.sh"
      args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    @ review.comment
    cs.method:
      name: "getDBCon"
      csprof.exit:
        memory_mb: >= 10
```
 
Sometime in the future we decide to update the underlying library to the latest version. After profiling our application again, CodeLingo catches that multiple instances of the `getDBCon` function have exceeded the `>= 10MB memory` Tenet.

As we iterate over the issues, we see a steady increase in the memory consumed by the `getDBCon` function. Knowing that this didn't happen with the older version of the library, we suspect a memory leak may have been introduced in the update and further investigation is required.

Note: CLQL is able to assist in pinpointing the source of memory leaks, but that is outside the scope of this use case.

<br />

#### Detecting Race Conditions
In the example below we have a database manager class that we use to update and read user records.

Our application has a number of different workers that operate asynchronously, making calls to the database manager at any time.

We need to know if our database manager is handling the asynchronous calls correctly, so we write a tenet below to catch potential race conditions between two functions used by the workers:


```clql
csprof.session:
  csprof.exec:
    command: "./scripts/build.sh"
    args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    cs.method:
      name: "updateUser"
      csprof.block_start:
        time: $startUpdate
      csprof.block_exit:
        time: $exitUpdate
    @ review.comment
    cs.method:
      name: "getUser"
      csprof.block_start:
        time: > $startUpdate
      csprof.block_start:
        time: < $exitUpdate
```

This query users [variables](#variables) If the `getUser` function is called while an instance of the `updateUser` function is in progress, the `getUser` function must return after the `updateUser` function to prevent a dirty read from the database. An issue will be raised if this does not hold true.

<br />

#### Detecting Deadlocks

In the example below, we have an application used for importing data into a database from a number of different sources asynchronously. The `importData` function is particularly resource heavy on our server due to the raw amount of data that needs to be processed. Knowing this, we decide to write a Tenet to catch any idle instances of the `importData` function:

```clql
cs.session:
  csprof.exec:
    command: "./scripts/build.sh"
    args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    @ review.comment
    cs.method:
      name: "importData"
      csprof.duration:
        time_min: >= 4
        average_cpu_percent: <= 1
        average_memory_mb: <= 10
```

If an instance of the `importData` runs for more than 4 minutes with unusually low resource usage, an issue will be raised as the function is suspect of deadlock.

<br />

## CLQL Reference

### Reference

#### Querying with Facts

<!--Should we include systems that CLQL does not *yet* support? -->
CLQL can query many types of software related systems. But assume for simplicity that all queries on this page are scoped to a single object oriented program.

<!--TODONOW link to fact definition section on lexicon page-->
Queries are made up of Facts. A CLQL query with just a single fact will match all elements of that type in the program. The following query matches and returns all classes in the queried program:

```
...
common.class({depth: any})
```

It consists of a single fact `common.class`. The name `class` indicates that the fact refers to a class, and the namespace `common` indicates that it may be a class from any language with classes. If the namespace were `csharp` this fact would only match classes from the C# lexicon. The depth range `{depth: any}` makes this fact match any class within the context of the query (a single C# program), no matter how deeply nested.
A comment is made on every class found as there is a decorator `@ review.comment` directly above the single fact `common.class`.

Note: for brevity we will omit the `common` namespace. This can be done in .lingo files by importing the common lexicon into the global namespace: `import codelingo/ast/common as _`.

<br />

#### Fact Properties

To limit the above query to match classes with a particular name, add a "name" property as an argument to the `method` fact:
 
```
method({depth: any}):
  name: "myFunc"
```
 
This query returns all methods with the name "myFunc". Note that the yield tag is still on the `method` fact - properties cannot be returned, only their parent facts. Also note that properties are not namespaced, as their namespace is implied from their parent fact.

Facts with arguments are preceded by a colon.

<br />

#### Floats and Ints
<!--TODO(blakemscurr) explain boolean properties once syntax has been added to the ebnf-->
Properties can be of type string, float, and int. The following finds all int literals with the value 8:
 
```
int_lit({depth: any}):
  value: 5
```
 
This query finds float literals with the value 8.7:
 
```
float_lit({depth: any}):
  value: 8.7
```

<br />

#### Comparison

The comparison operators >, <, ==, >=, and <= are available for floats and ints. The following finds all int literals above negative 3:
```
int_lit({depth: any}):
  value: > -3
```

<br />

#### Regex

Any string property can be queried with regex. The following finds methods with names longer than 25 characters:
 
```
method({depth: any}):
  name: /^.{25,}$/
```

<br />

#### Fact Nesting

Facts can be take arbitrarily many other facts as arguments, forming a query with a tree struct of arbitrary depth. A parent-child fact pair will match any parent element even if the child is not a direct descendant. The following query finds all the if statements inside a method called "myMethod", even those nested inside intermediate scopes (for loops etc):

```
method({depth: any}):
  name: "myMethod"
  if_stmt({depth: any})
```
 
Any fact in a query can be yielded. If `class` is yielded, this query returns all classes named "myClass", but only if it has at least one method:
 
```
class({depth: any}):
  name: “myClass”
  method({depth: any})
```
 
Any fact in a query can have properties. The following query finds all methods named "myMethod" on the all classes named "myClass":
 
```
class({depth: any}):
  name: “myClass”
  method({depth: any}):
    Name: “myMethod”
```

#### Depth

Facts use depth ranges to specify the depth at which they can be found below their parent. Depth ranges have two zero based numbers, representing the minimum and maximum depth to find the result at, inclusive and exclusive respectively. The following query finds any if statements that are direct children of their parent method, in other words, if statements at depth zero from methods:

```
method({depth: any}):
  if_stmt({depth: 0:1})
```

This query finds if statements at (zero based) depths 3, 4, and 5:

```
method({depth: any}):
  if_stmt({depth: 3:6})
```

A depth range where the maximum is not greater than the minimum, i.e. `({depth: 5:5})` or `({depth: 6:0})`, will give an error.

Depth ranges specifying a single depth can be described with a single number. This query finds direct children at depth zero:

```
method({depth: any}):
  if_stmt({depth: 0})
```

Indices in a depth range can range from 0 to positive infinity. Positive infinity is represented by leaving the second index empty. This query finds all methods, and all their descendant if_statements from depth 5 onwards:

```
method({depth: any}):
  if_stmt({depth: 5:})
```

Note: The depth range on top level facts, like `method` in the previous examples, determines the depth from the base context to that fact. In this case the base context contains a single program. However, it can be configured to refer to any context, typically a single repository or the root of the graph on which all queryable data hangs.

<br />

#### Branching

The following query will find a method with a foreach loop, a for loop, and a while loop in that order:
 
```
method({depth: any}):
  for_stmt
  foreach_stmt
  while_stmt
```

<!--TODO(blakemscurr): Explain the <lexicon>.element fact-->

<br />

#### Exclude

Exlude allows queries to match children that *do not* have a given property or child fact. Excluded facts and properties are children of an `exclude` operator. The following query finds all classes except those named "classA":

```
class({depth: any}):
  exclude:
    name: "classA"
```
 
This query finds all classes with a method that is not called String:

```
class({depth: any}):
  method:
    exclude:
      name: “String”
```

The placement of the exclude operator has a significant effect on the query's meaning - this similar query finds all classes without String methods:

```
class({depth: any}):
  exlude:
    method:
      name: “String”
```

The exclude operator in the above query can be read as excluding all methods with the name string - the `method` fact and `name` property combine to form a more complex pattern to be excluded. In the same way, arbitrarily many facts, properties, and operators can be added as children of the exclude operator to further specify the pattern to be excluded.

Excluding a fact does not affect its siblings. The following query finds all String methods that use an if statement, but don’t use a foreach statement:

```
method({depth: any}):
  name: “String”
  if_stmt
  exclude:
    foreach_stmt
```

An excluded fact will not return a result and therefore cannot be decorated.

<br />
#### Nested Exclude

Exclusions can be arbitrarily nested. The following query finds methods which only return nil or return nothing, that is, it finds all methods except those with non-nil values in their return statements:

```
method:
  exclude:
    return_stmt({depth: any}):
      literal:
        exclude:
          name: "nil"
```

Facts nested under multiple excludes still do not return results and cannot be decorated.

<br />
#### Include

Include allows queries to match patterns without a given parent. The following query is a simple attempt at finding infinitely recursing functions. It works by finding functions that call themselves without an if statement to halt recursion:

```
func:
  name: $funcName
  exclude:
    if_stmt:
      include:
        func_call:
          name: $funcName
```

It can be read as matching all functions that call themselves with no if statement between the definition and the call site. `$funcName` is a [variable](#variables) that ensures the definition and call site refer to the same function.

Include statements must have an exclude ancestor. Exclude/include pairs can be arbitrarily nested.

Results under include statements appear as children of the parent of the corresponding exclude statement, and therefore *can* be decorated. In the above example, the `func_call` result will appear as a direct child of the `func` result.

<br />
#### any_of

A fact with multiple children will match against elements of the code that have child1 *and* child2 *and* child3 etc. The `any_of` operator overrides the implicit "and". The following query finds all String methods that use basic loops:

```
method({depth: any}):
  name: “String”
  any_of:
    foreach_stmt
    while_stmt
    for_stmt
```
<!-- TODO(blakemscurr) n_of-->

<br />

#### Variables

Facts that do not have a parent-child relationship can be compared by assigning their properties to variables. Any argument starting with “$” defines a variable. A query with a variable will only match a pattern in the code if all properties representing that variable are equal.

The following query compares two classes (which do have a parent-child relationship) and returns the methods which both classes implement:

```
class({depth: any}):
  name: “classA”
  method:
    name: $methodName
class({depth: any}):
  name: “classB”
  method:
    name: $methodName
```

The query above will only return methods of classA for which classB has a corresponding method.

<br />

#### Interleaving

When writing a Tenet in a .lingo file read by CLAIR, only the AST lexicon facts are required:

```clql
tenets:
  - name: all-classes
    doc: Documentation for all-classes
    bots:
      codelingo/review:
        comments: This is a class, but you probably already knew that.
    query:
      import codelingo/ast/csharp as cs
      cs.project:
        @ review.comment
        cs.class
```

CLAIR adds the repository information to the query before searching the CodeLingo Platform:

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
        @ review.comment
        cs.class
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
        arg-num: $args
  git.commit:
    sha: “HEAD”    
    project:
      @ review.comment
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