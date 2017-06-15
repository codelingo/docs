# Overview
 
The CodeLingo platform guide's software teams to build better code, faster. CodeLingo has been built to integrate with the unique workflows and existing tooling of software development teams and their unique software development life-cycle (SDLC). With CodeLingo you can query patterns in any domain of the SDLC and automate tasks based on the patterns found. From static to runtime analysis, to timelines and logs - powerful Tenets can be written to: automate code reviews, provide real-time crash reporting, performance tune systems, migrate architectures and so on.


There are three key concepts to CodeLingo: [Bots](/bots), [Tenets](tenets), and [Lexicons](/lexicons).
 
 
## The lingo Client
 
The lingo client is a command line interface (CLI) tool used to manage the Lexicons, Tenets and Bots. The lingo client will help you find, create and run these resources. For example, to list available lexicons run `$ lingo lexicon list`. You will see output similar to the following:
 
```bash
ast/codelingo/cs
ast/codelingo/php
ast/codelingo/golang
vcs/codelingo/git
vcs/codelingo/perforce
...
```

 
To see a description of a lexicon run  `$ lingo lexicon describe`. For example:
 
```bash
$ lingo lexicon describe ast/codelingo/cs
 
C# AST Lexicon
 
This lexicon is a list of facts about the c# AST.
```
 
To list the lexicon’s facts:
 
```bash
$ lingo lexicon list-facts ast/codelingo/cs
 
name: cs.func_decl
properties:
  name
 
```
 
To see the full list of commands available, please run `$ lingo --help`. The lingo CLI tool also powers IDE plugins, such as the CLQL generation example above.
