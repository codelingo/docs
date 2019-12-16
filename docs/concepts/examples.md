# AST

## Argument count

Below is an example of a query that returns all functions in a repository with more than four arguments:

```yaml

query:
  import codelingo/vcs/git
  import codelingo/ast/go
  git.repo:
    owner == "username"
    host == "myvcsgithost.com"
    name == "myrepo"
    git.commit:
      sha == "HEAD"
      go.project:
        @review comment
        go.func_type(depth = any):
          go.field_list:
            child_count > 4
```

Lexicons get data into the CodeLingo Platform and provide a list of Facts to query that data. In the above example, the Git Lexicon finds and clones the "myrepo" repository from the "myvcsgithost.com" VCS host. The "myrepo" repository must be publicly accessible for the Git Lexicon to access it.

The CodeLingo Platform can be queried directly with the `$ lingo run search` command or via [Functions](actions.md) which use queries stored in Specs.

## Matching a function name

```yaml
specs:
- name: first-spec
  actions:
    codelingo/docs:
      body: example doc
    codelingo/review:
      comment: This is a function, name 'writeMsg', but you probably knew that.
  query:
    import codelingo/ast/go
    @review comment
    go.func_decl(depth = any):
      name == "writeMsg"
```

This will find funcs named "writeMsg". Save and close the file, then run `lingo run review`. Try adding another func called "readMsg" and run a review. Only the "writeMsg" func should be highlighted. Now, update the Spec to find all funcs that end in "Msg":

```yaml
  query:
    import codelingo/ast/go
    @review comment
    go.func_decl:
      name as funcName
      regex(/.*Msg$/, funcName)
```

## CSharp

Iterative code, such as the following, can be more safely expressed declaratively using LINQ. For example:

```csharp
decimal total = 0;
foreach (Account account in myAccounts) {
  if (account.Status == "active") {
  total += account.Balance;
  }
}
```

can be expressed with:

```csharp
decimal total = (from account in myAccounts
          where account.Status == "active"
          select account.Balance).Sum();
```

The CLQL to match this pattern should find all variables that are declared before a foreach statement, and are incremented within the loop. The Facts for incrementing inside a foreach loop, and declaring a variable can be generated in the IDE:

![C# example Generation](../img/cs_decl.png)

Note: the `csharp.variable_declarator` has the `identifier_token` field that can be used to identify the `total` variable, but it spans the whole third line, so the whole line must be selected to generate that Fact. Since other elements are within that line, many extra Facts are generated. This is largely a property of the C# parser used by the underlying [lexicon](CLQL.md#lexicons).

![C# example Generation](../img/cs_inc.png)

The generated code can be turned into a working query by combining the above queries under the same scope, removing extraneous Facts, and using a CLQL variable to ensure that the `csharp.identifier_name` and `csharp.variable_declarator` Facts refer to the same variable:

```yaml
csharp.method_declaration:
  csharp.block:
    csharp.local_declaration_statement:
      csharp.variable_declaration:
        @review.comment
        csharp.variable_declarator:
          identifier_token as varName
    csharp.for_each_statement:
      csharp.add_assignment_expression(depth = any):
        @review comment
        csharp.identifier_name:
          identifier_token as varName
```

<br />

## C++

The following Spec asserts that functions should not return local objects by reference. When the function returns and the stack is unwrapped, that object will be destructed, and the reference will not point to anything.

The following query finds this bug by matching all functions that return a reference type, and declare the returned value inside the function body:

```
import codelingo/ast/cpp
@review.comment
cc.func_decl:
  cc.func_header:
    cc.return_type:
      cc.reference
  cc.block_stmt:
    cc.declaration_stmt:
      cc.variable:
        name as returnedReference
    cc.return_stmt:
      cc.variable:
        name as returnedReference
```

## Access Modifier Declaration

In this example, we'll exclude StyleCop's long setup and document traversal boilerplate and focus on the query, which raises a violation for all non-generated code that doesn't have a declared access modifier:

```csharp
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

As in the [empty block statements example below](#empty-block-statements), to express the pattern in CLQL, the Spec author only needs to express conditions in the VisitElement body:

```yaml
cs.element:
  generated == "false"
  cs.declaration_stmt:
    access_modifier == "false"
```

The above query matches all C# elements that are not generated, whose declaration does not have an access modifier.


# Runtime

## Detecting Race Conditions
In the example below we have a database manager class that we use to update and read user records.

Our application has a number of different workers that operate asynchronously, making calls to the database manager at any time.

We need to know if our database manager is handling the asynchronous calls correctly, so we write a Spec below to catch potential race conditions between two functions used by the workers:


```yaml
csprof.session:
  csprof.exec:
    command == "./scripts/build.sh"
    args == "-o ./bin/program.exe"
  csprof.exec:
    command == "./bin/program.exe"
    args == "/host:127.0.0.1 /db:testing"
  cs.file:
    filename == "./db/manager.cs"
    cs.method:
      name == "updateUser"
      csprof.block_start:
        time as startUpdate
      csprof.block_exit:
        time as exitUpdate
    @review comment
    cs.method:
      name == "getUser"
      csprof.block_start:
        time > $startUpdate
      csprof.block_start:
        time < $exitUpdate
```

This query uses [variables](#variables). If the `getUser` function is called while an instance of the `updateUser` function is in progress, the `getUser` function must return after the `updateUser` function to prevent a dirty read from the database. An issue will be raised if this does not hold true.

<br />

## Detecting Deadlocks

In the example below, we have an application used for importing data into a database from a number of different sources asynchronously. The `importData` function is particularly resource heavy on our server due to the raw amount of data that needs to be processed. Knowing this, we decide to write a Spec to catch any idle instances of the `importData` function:

```yaml
cs.session:
  csprof.exec:
    command == "./scripts/build.sh"
    args == "-o ./bin/program.exe"
  csprof.exec:
    command == "./bin/program.exe"
    args == "/host:127.0.0.1 /db:testing"
  cs.file:
    filename == "./db/manager.cs"
    @review comment
    cs.method:
      name == "importData"
      csprof.duration:
        time_min >= 4
        average_cpu_percent <= 1
        average_memory_mb <= 10
```

If an instance of the `importData` runs for more than 4 minutes with unusually low resource usage, an issue will be raised as the function is suspect of deadlock.


# Additional Examples

To see more examples of what can be done with CLQL see our currenlty available [**Specs**](https://www.codelingo.io/specs)
