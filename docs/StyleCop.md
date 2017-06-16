# StyleCop vs CodeLingo

## Overview

CodeLingo, like StyleCop, can express C# style rules and use them to analyze a project, file, repository, or pull request. CodeLingo, like StyleCop can customize a set of predefined rules to determine how they should apply to a given project, and both can define custom rules.

<!--reorder and rework pg so concepts are introduced before they are used-->
<!--Better word the whole system than CodeLingo, since CodeLingo refers to the company-->

StyleCop supports custom rules by providing a SourceAnalyzer class with CodeWalker methods. The rule author can iterate through elements of the document and raise violations when the code matches a certain pattern. 

Using CodeLingo, the author can express all the same rules in CLQL (CodeLingo Query Language).
By abstracting away the details of document walking, CLQL can express in 3 line, a rule that takes ~30 lines of StyleCop. 

[loc comparison]

## Examples

[This tutorial](https://github.com/Visual-Stylecop/Visual-StyleCop/wiki/Authoring-a-Custom-StyleCop-Rule) demonstrates the process for authoring simple StyleCop rules. The following examples will translate those rules into CLQL queries.

### Empty Block Statements

StyleCop can use a custom rule to raise a violation for all empty block statements. It takes approximately ~x lines of code to express this pattern:

```
[SourceAnalyzer(typeof(CsParser))]
public class EmptyBlocks : SourceAnalyzer
    {
    public EmptyBlocks()
    {
}

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
}

private bool VisitStatement(Statement statement, Expression parentExpression, Statement parentStatement, CsElement parentElement, object context)
{
    if (statement.StatementType == StatementType.Block && statement.ChildStatements.Count == 0)
    {
        this.AddViolation(parentElement, statement.LineNumber, "BlockStatementsShouldNotBeEmpty");
    }
}
```

```
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
<!--Assume that we have the ChildStatements.Count property of blockstatement-->

```
lexicons: 
  - codelingo/csharp/0.0.0 as cs
tenets:
  - Name: "EmptyBlock"
    Comment: "A block statement should always contain child statements."
    Doc: "Validates that the code does not contain any empty block statements."
    Match: 
        cs.block_stmt:
            depth(0):
                child_statements:
                    count: == 0
            cs.if_stmt
```
<!--TODO link to query generation, fact explanation, and query explanation.-->
The author can ![generate](clql.md) the [facts](clql.md) in the above query by selecting any block statement in their IDE.

### Access Modifier Declaration

The following rule (excluding document traversal boilerplate) raises a violation for all non-generated code that doesn't have a declared access modifier:
```
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

The same pattern can be expressed in CLQL as the following query:

```
cs.element:
    generated: "false"
    cs.declaration_stmt:
        cs.access_modifier: "false"
```


<!--[extending into different domains]-->





