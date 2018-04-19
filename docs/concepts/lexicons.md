# Lexicons
## Overview

The SDLC is built up of many different domains. With [CLQL](clql.md) patterns across all these domains are expressed as statements of facts. Those facts come from [Lexicons](concepts/lexicons.md), which are collections of terms about to a domain of knowledge. These domains include:
 
- Static facts about programming languages (AST): C#, Javascript, Java, PHP, Golang etc
- Dynamic facts about languages (Runtime): values, race conditions, tracing, profiling etc
- Facts about VCSs: perforce, git, hg, commits, comments, ownership etc
- Facts about databases, networking, CI, CD, business rules, HR etc
- Facts about running systems: logs, crash dumps, tracing etc

Explore existing lexicons via **[the hub](hub_url)** or CLI Tool

## Types
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

* via [the hub](insert url)

## Writing Lexicons

Lexicon SDK Requires License

