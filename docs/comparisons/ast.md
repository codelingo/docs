# AST

CLQL (CodeLingo Query Language) is able to perform static analysis using AST (abstract syntax tree) [lexicons](/lexicons). 

## CLQL vs StyleCop

CLQL, like StyleCop, can express C# style rules and use them to analyze a project, file, repository, or pull request. CLQL, like StyleCop can customize a set of predefined rules to determine how they should apply to a given project, and both can define custom rules.

StyleCop supports custom rules by providing a SourceAnalyzer class with CodeWalker methods. The rule author can iterate through elements of the document and raise violations when the code matches a certain pattern. 

CLQL can express all rules that can be expressed in StyleCop. By abstracting away the details of document walking, CLQL can express in 9 lines, [a rule](/style-enforcers/#empty-block-statements) that takes ~50 lines of StyleCop. In addition to being, on average, 5 times less code to express these patterns, CLQL queries can be [generated](/clql.md/#query-generation) by selecting the code code elements in an IDE.

CLQL is not limited to C# like StyleCop. CLQL can express logic about other domains of logic otuside of the scope of StyleCop, like version control.

### Empty Block Statements

StyleCop can use a custom rule to raise a violation for all empty block statements:

```cs
namespace Testing.EmptyBlockRule {
    using global::StyleCop;
    using global::styleCop.CShapr;

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

### Access Modifier Declaration

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


