# Tenets 
#### Rules to Guide Software Development

<br/>

### Overview
 
A Tenet is a rule about a system written in [CLQL](/clql). It is an underlying pattern which the CodeLingo [Bots](concepts/bots.md) follow to guide development and safeguard systems. Tenets can be added directly to Bots or embedded in the resources they monitor. For example, CLAIR reads .lingo files that live along side source code in a code repository.

Below is an example of a Tenet created from the search query [example](concepts/search.md):

```YAML
lexicons:
  - codelingo/vcs/git
  - codelingo/ast/golang as go

tenets:
  - match:
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

The minimum requirement for a Tenet is the `match` statement. Extra metadata can be added to the Tenet to be used by the Bots that apply the Tenet:

```YAML
...
tenets:
  - comment: "Please keep functions arguments to four or less"
    match:
...
```

The `comment` metadata above can be used by a [Bot](/concepts/bots.md) to comment on a pull request review, for example.

<!-- TODO(JENNA) Can you think of a visual representation/diagram to explain how bots, tenets and lexicons fit together/work? -->

<!-- [cascading Tenets] -->

<!--TODO(JENNA) If you could explain more about these examples for my own knowledge, that would be great! :) -->
 
Examples of Tenets include:
 
- Anything a static linter expresses, with a fraction of the code
- Change management: large scale incremental refactoring
- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team
- Infrastructure specific guidelines / safeguards: learning from failures
- Packaging the author’s guidance with a library