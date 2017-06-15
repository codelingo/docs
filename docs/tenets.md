# Tenets 
#### Rules to Guide Software Development

### Overview
 
A Tenet is a rule about a system. It is written in [CLQL](/clql/index.html). They are underlying patterns which the CodeLingo Bots follow to guide development and safeguard systems. Tenets can be added directly to Bots or embedded in the resources they monitor. For example, CLAIR reads .lingo files that live along side source code in a code repository.

<!-- TODO(JENNA) Can you think of a visual representation/diagram to explain how bots, tenets and lexicons fit together/work? -->

<!-- [cascading Tenets] -->

<!--TODO(JENNA) If you could explain more about these examples for my own knowledge, that would be great! :) -->
 
Examples of Tenets include:
 
- Anything a static linter expresses, with a fraction of the code
- Change management: large scale incremental refactoring
- Project specific practices: scaling the tacit knowledge of senior engineers to the whole team
- Infostructure specific guidelines / safeguards: learning from failures
- Packaging the author’s guidance with a library