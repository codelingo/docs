# Tenets
## Overview

A Tenet is a rule about a system written in [CLQL](/clql) and based on libaries of facts called Lexicons. It is an underlying pattern or heurestic which the CodeLingo Platform can use to guide development and safeguard systems via [Flows and Bots](concepts/flows.md).

Tenets can be added directly to Bots or embedded in the resources they monitor.

Examples:

- Anything a static linter expresses, with a fraction of the code
- Change management: large scale incremental refactoring
- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team
- Infrastructure specific guidelines / safeguards: learning from failures
- Packaging the author’s guidance with a library

## Importing Existing Tenets
Tenets are written in CLQL and are including in a project either directly in the .lingo file, or via an include statement from an external bundle.

**[Existing Tenets can be discovered via the hub](https://codelingo.io/hub/tenets)**

To import an exiseting Tenet into your project, import the bundle via the url provided in the hub in your lingo file.

TODO: add example of tenet import
```YAML
...
...
```

<br/>

## Running a Tenet
TODO
```bash
$ lingo run
```
<br/>

## Writing Custom Tenets
TODO

<br/>
## IDE Integration
Vim has full support for the Lingo syntax, including CLQL. To set it up, [see here](scripts/lingo.vim.readme). Other than the match statement, written in CLQL, the rest of a .lingo file is written in YAML. As such, you can set .lingo files to YAML syntax in your IDE to get partial highlighting.

CodeLingo's Integrated Development Environment (IDE) plugins can help build patterns in code by automatically generating queries to detect selected elements of programs. A generated query will describe the selected element and its position in the structure of the program:

![Query Generation](img/queryGeneration.png)

In the above example string literal is selected. The generated CLQL query will match any literal directly inside an assignment statement, in a function declaration, matching the nested pattern of the selected literal.

<br/>
## Lexicons

The SDLC is built up of many different domains. With [CLQL](#clql) patterns across all these domains are expressed as statements of facts. Those facts come from Lexicons, which are collections of terms about to a domain of knowledge.

Lexicon SDK Requires License

### Source code (AST)

Abstract Syntax Tree (AST) [lexicons](/lexicons) are used to query static properties of source code. These are typically used to enforce project specific patterns such as layering violations as well as more general code smells.

### VCS

With Version Control System (VCS) lexicons, facts about the VCS itself can be queried: commit comments, commit SHAs, authorship and other metadata.

### Runtime

Runtime lexicons are used to query the runtime data of a program. These are typically used to identify performance issues and common runtime problems.

CodeLingo currently supports the follwing runtimes:
- TODO
- TODO

More information about each particular lexicon can be found:

* via the CLI tool


   `lingo list-facts codelingo/lexicons/runtime/finish`

* via [the hub](https://codelingo.io/hub/lexicons)


## CLQL

### Overview

CodeLingo Query Language (CLQL) is a simple, lightweight language built for querying patterns across various software domains. It is what is used to write Tenets.

It’s full grammar is under [70 lines of code](img/ebnf.png).

Patterns in CLQL (Tenets), can be expressed as statements of facts from a particular lexicon. [Lexicons](concepts/lexicons.md) are libraries of facts about to a domain of knowledge. These domains include:

- Static facts about programming languages (AST): C#, Javascript, Java, PHP, Golang etc
- Dynamic facts about languages (Runtime): values, race conditions, tracing, profiling etc
- Facts about VCSs: perforce, git, hg, commits, comments, ownership etc
- Facts about databases, networking, CI, CD, business rules, HR etc
- Facts about running systems: logs, crash dumps, tracing etc

### Reference

#### Match
The minimum requirement for a Tenet is the `match` statement. Extra metadata can be added to the Tenet to be used by the Bots that apply the Tenet:

```YAML
...
tenets:
  - name: four-or-less
    match:
...
```
#### Metadata
The `comment` metadata above can be used by a [Bot](/concepts/flows.md) to comment on a pull request review, for example.
```YAML
...
tenets:
  - name: four-or-less
    comment: "Please keep functions arguments to four or less"
    match:
...
```


#### Querying with Facts

<!--Should we include systems that CLQL does not *yet* support? -->
CLQL can query many types of software related systems. But assume for simplicity that all queries on this page are scoped to a single object oriented program.

<!--TODONOW link to fact definition section on lexicon page-->
Queries are made up of [Facts](lexicons.md). A CLQL query with just a single fact will match all elements of that type in the program. The following query matches and returns all classes in the queried program:

```
common.class({depth: any})
```

It consists of a single fact `common.class`. The name `class` indicates that the fact refers to a class, and the namespace `common` indicates that it may be a class from any language with classes. If the namespace were `csharp` this fact would only match classes from the C# [lexicon](lexicons.md). The depth range `{depth: any}` makes this fact match any class within the context of the query (a single C# program), no matter how deeply nested.
The decorator `@ clair.comment` tells [CLAIR](/concepts/flows.md) (CodeLingo AI Reviewer) to make a comment on every class found.

Note: for brevity we will omit the `common` namespace. This can be done in .lingo files by importing the common lexicon into the global namespace: `import codelingo/ast/common/0.0.0 as _`.

<br />

#### Fact Properties

To limit the above query to match classes with a particular name, add a "name" property as an argument to the `method` fact:
 
```
method({depth: any}):
  name: "myFunc"
```
 
This query returns all methods with the name "myFunc". Note that the yield tag is still on the `method` fact - properties cannot be returned, only their parent facts. Also note that properties are not namespaced, as their namespace is implied from their parent fact.

Facts with arguments are proceeded by a colon.

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

A depth range where the maximum is not larger than the minimum, i.e., `({depth: 5:5})` or `({depth: 6:0})`, will give an error.

Depth ranges specifying a single depth can be described with a single number. This query finds direct children at depth zero:

```
method({depth: any}):
  if_stmt({depth: 0})
```

Indicies in a depth range can range from 0 to positive infinity. Positive infinity is represented by leaving the second index empty. This query finds all methods, and all their descendant if_statements from depth 5 onwards:

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

#### Negation

Negation allows queries to match children that *do not* have a given property or child fact. Negated facts and properties are prepended by "!". The following query finds all classes except those named "classA":

```
class({depth: any}):
  !name: "classA"
```
 
This query finds all classes with String methods:

```
class({depth: any}):
  !method:
    name: “String”
```
 
The placement of the negation operator has a significant effect on the query's meaning - this similar query finds all methods with a method that is not called String:

```
class({depth: any}):
  method:
    !name: “String”
```
 
Negating a fact does not affect its siblings. The following query finds all String methods that use an if statement, but don’t use a foreach statement:

```
method({depth: any}):
  name: “String”
  if_stmt
  !foreach_stmt
```
 
A fact cannot be both yielded and negated.

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
lexicons:
- vcs/codelingo/git
- ast/codelingo/cs

tenets:
  - name: all-classes
    match: 
      project:
        @ clair.comment
        class
```

CLAIR adds the repository information to the query before searching the CodeLingo Platform:

```clql
lexicons:
- vcs/codelingo/git
- ast/codelingo/cs

query:
  git.repo:
    name: “yourRepo”
    owner: “you”
    host: “local”
    git.commit: 
      sha: “HEAD”    
      project:
        @ clair.comment
        class
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
      @ clair.comment
      method:
        arg-num: > $args
```



<!--- 
TODO(BlakeMScurr) fully fill out template
 
We can write the same Tenet with the Common AST lexicon, which would catch the pattern in both languages as the Common lexicon lets us express facts that apply commonly across all languages:
 
[common lexicon example]
 
A Tenet can be made of interleaved facts from different lexicons.
 

[update imports to begin with lexicon type: ast/codelingo/common]
[add name matching to funcs above]
 
[Explain above query]. In a similar fashion, a runtime fact can be interleaved with an AST fact:
 
[example of code blocks that have > x memory allocated (run golang’s pprof to get an idea)]
 
Further examples can be found in the [link to Tenet examples directory].


-->

## Examples
### basic
#### Argument count
Below is an example of a query that returns all functions in a repository with more than 4 arguments:

```YAML
lexicons:
  - codelingo/vcs/git
  - codelingo/ast/golang as go

match:
  git.repo:
    owner: "username"
    host: "myvcsgithost.com"
    name: "myrepo"
    git.commit:
      sha: "HEAD"
      go.project:
        @ clair.comment
        go.func_decl:
          arg_count: > 4
```

The query is made up of two sections: a list of [Lexicons](#lexicons) and a match statement. Lexicons get data into the CodeLingo Platform and provide a list of facts to query that data. In the above example, the git Lexicon finds and clones the "myrepo" repository from the "myvcsgithost.com" VCS host. The "myrepo" repository must be publicly accessible for the git lexicon to access it.

To access a private repository, the git credentials need to be added to the query:

```YAML
...
match:
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
  comment: This is a function, name 'writeMsg', but you probably knew that.
  match:
    @ clair.comment
    func:
      name: "writeMsg"
```

This will find funcs named "writeMsg". Save and close the file, then run `lingo review`. Try adding another func called "readMsg" and run a review. Only the "writeMsg" func should be highlighted. Now, update the Tenet to find all funcs that end in "Msg":

```yaml
  match:
    @ clair.comment
    func:
      name: /.*Msg$/
```

<!-- 
## CLQL

CLQL is the query language under the `match:` section of a Tenet. It stands for CodeLingo Query Language. The full spec can be found [here](https://docs.google.com/document/d/1NIw1J9u2hiez9ZYZ0S1sV8lJamdE9eyqWa8R9uho0MU/edit), but a practical to get acquainted with the language is to review the [examples](_examples).

## Running Examples

All examples under [examples/php](_examples/php) are working. The other examples have varying levels of completeness and serve as an implementation roadmap. To run the examples, copy the directory out of the repository and follow the same steps as in the tutorial above.

-->
</br>


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

![C# example Generation](img/cs_decl.png)

Note: the `csharp.variable_declarator` has the `identifier_token` field that can be used to identify the `total` variable, but it spans the whole thrid line, so the whole line must be selected to generate that fact. Since other elements are within that line, many extra facts are generated. This is largely a property of the C# parser used by the underlying [lexicon](lexicons.md).

![C# example Generation](img/cs_inc.png)

The generated code can be turned into a working query by combining the above queries under the same scope, removing extraneous facts, and using a CLQL variable to ensure that the `csharp.identifier_name` and `csharp.variable_declarator` facts refer to the same variable:

```
csharp.method_declaration:
  csharp.block:
    csharp.local_declaration_statement:
      csharp.variable_declaration:
        @ clair.comment
        csharp.variable_declarator:
          identifier_token: $varName
    csharp.for_each_statement:
      csharp.add_assignment_expression({depth: any}):
        @ clair.comment
        csharp.identifier_name:
          identifier_token: $varName
```

<br />

#### C++

The following tenet asserts that functions should not return local objects by reference. When the function returns and the stack is unwrapped, that object will be destructed, and the reference will not point to anything.

The following query finds this bug by matching all functions that return a reference type, and declare the returned value inside the function body:

```
@ clair.comment
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

CLQL can express all rules that can be expressed in StyleCop. By abstracting away the details of document walking, CLQL can express in 9 lines, [a rule](/style-enforcers/#empty-block-statements) that takes ~50 lines of StyleCop. In addition to being, on average, 5 times less code to express these patterns, CLQL queries can be [generated](/clql.md/#query-generation) by selecting the code code elements in an IDE.

CLQL is not limited to C# like StyleCop. CLQL can express logic about other domains of logic otuside of the scope of StyleCop, like version control.

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
  - ast/codelingo/csharp as cs
tenets:
  - Name: "EmptyBlock"
    Comment: "A block statement should always contain child statements."
    Doc: "Validates that the code does not contain any empty block statements."
    Match: 
      cs.block_stmt:
        !cs.element
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
  !cs.element
```

The above query will match against any block statement that does not contain anything at all. `cs.element` [matches all](/clql/#the-element-fact) C# elements, and the "!" operator performs [negation](/clql/#negation). 

#### Access Modifier Declaration

In this example, we'll exclude StyleCop's long setup and document traversal boilerplace and focus on the query, which raises a violation for all non-generated code that doesn't have a declared access modifier:

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

As in the [empty block statements](/comparison/ast/#empty-block-statements) example, to express the pattern in CLQL, the tenet author only needs to express conditions in the VisitElement body:

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
    @ clair.comment
    cs.method:
      name: "getDBCon"
      csprof.exit:
        memory_mb: >= 10
```
 
Sometime in the future we decide to update the underlying library to the latest version. After profiling our application again, CodeLingo catches that multiple instances of the `getDBCon` function have exceeded the `>= 10MB memory` Tenet.

As we iterate over the issues, we see a steady increase in the memory consumed by the `getDBCon` function. Knowing that this didn't happen with the older version of the library, we suspect a memory leak may have been introduced in the update and further investigation is required.

Note: CLQL is able to assist in pin-pointing the source of memory leaks, but that is outside the scope of this use case.

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
    @ clair.comment
    cs.method:
      name: "getUser"
      csprof.block_start:
        time: > $startUpdate
      csprof.block_start:
        time: < $exitUpdate
```

This query users [variables](clql.md#variables) If the `getUser` function is called while an instance of the `updateUser` function is in progress, the `getUser` function must return after the `updateUser` function to prevent a dirty read from the database. An issue will be raised if this does not hold true.

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
    @ clair.comment
    cs.method:
      name: "importData"
      csprof.duration:
        time_min: >= 4
        average_cpu_percent: <= 1
        average_memory_mb: <= 10
```

If an instance of the `importData` runs for more than 4 minutes with unusually low resource usage, an issue will be raised as the function is suspect of deadlock.

<br />





