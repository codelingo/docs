# Bots
#### Agents Guiding Code Quaity at Scale

<br/>

### Overview

Bots watch resources and look for patterns in them based on the [Tenets](/concepts/tenets.md) associated with the resource. For example, CodeLingo AI Reviewer (CLAIR) is a Bot that preforms a review on a pull request:

<img src="/docs/img/clair_review_simple.png" alt="CLAIR (CodeLingo AI Reviewer) commenting on a pull-request" style="width: 80%;"/>

CLAIR reads the Tenets written in .lingo files in the repository and queries the platform with them. She can be called directly via the commandline:

```bash
$ lingo bot clair review --github-pull-request "https://github.com/example/prog/pull/272"
```


This will print out any patterns in the pull request that match those in the Tenets. In addition to being run directly, Bots can be added to a [Flow](concepts/flows.md). When part of a [Flow](/concepts/flows.md), Bots process the results and pass them onto an external service or other bots in the Flow.

Other possible Bots include:
 
- A forensic Bot that analyses logs and finds event B happened before A, which violates a Tenet
- A project overview Bot that graphs Tech Debt burndown chart and delegates based on ownership
- A Copilot Bot that gives real time feedback to a developer in their IDE as they’re coding
- A profiling Bot that detects high memory usage correlated to similar code
- A crash report Bot that monitors a running system and reports on unexpected runtime information