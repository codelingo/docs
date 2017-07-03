# Search
#### Find Patterns Across the SDLC

<br/>

### Overview

At the heart of the CodeLingo Platform is a search engine for the full Software Development Lifecycle (SDLC). Patterns that cross disperse domains can be easily expressed in one query with [CodeLingo Query Language (CLQL)](/clql.md). Below is an example of a query that returns all functions in a repository with more than 4 arguments:

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
        <go.func_decl:
          arg_count: > 4
```

The query is made up of two sections: a list of [Lexicons](/concepts/lexicons.md) and a match statement. Lexicons get data into the CodeLingo Platform and provide a list of facts to query that data. In the above example, the git Lexicon finds and clones the "myrepo" repository from the "myvcsgithost.com" VCS host. The "myrepo" repository must be publicly accessible for the git lexicon to access it.

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

The CodeLingo Platform can be queried directly with the the `$ lingo search` command or via [Bots](/concepts/bots.md) which use queries stored in [Tenets](/concepts/tenets.md).
