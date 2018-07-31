# Overview

Codelingo is a Platform as a Service (PaaS) for software development teams to solve software development problems. It treats your software as data and automates your workflows, called Flows, with the rules and patterns you define, called Tenets.

Our flagship Flow is the Review Flow, which checks a repository's pull requests conform to its project specific patterns.

# Quick Starts

## Playground

Test out writing a Tenet and running a Flow online with zero installs: [playground](https://codelingo.io/playground) - it's easier than you think!

<!-- TODO image of the playground UI -->

<!-- TODO CLQL tutorial -->

## GitHub Review Flow

After [installing Codelingo on GitHub](https://github.com/apps/codelingo), write the following .lingo.yaml to the root of your repository:

```yaml
# .lingo.yaml file

tenets:
  - import: codelingo/go
```

You're done! Every pull request to your repository will now be checked against the go Tenet bundle we imported above. 

<!-- TODO add screenshot of review comment -->

Other Tenet bundles (including for other languages) from the community can be found at [https://github.com/codelingo/codelingo/tree/master/tenets](https://github.com/codelingo/codelingo/tree/master/tenets).

<!-- TODO add instructions on how to interact with Review Flow with GitHub comments -->

## Local Review Flow

To run the Review Flow against repositories on your local machine, install the [lingo CLI](https://github.com/codelingo/lingo/releases/latest) and set it up with the following commands:

```bash
# Run this command from anywhere. Follow the prompts to set up Codelingo on your machine.
$ lingo config setup

# Run this command inside a git repository to add a default .lingo.yaml file in the current directory.
$ lingo init
```

Replace the content of the .lingo.yaml file we wrote above with:

```yaml
  tenets:
    - import: codelingo/go
```

You can now run the Review Flow to check your source code against the go Tenet bundle we imported above.

```bash
# Run this command from the same directory as the .lingo.yaml file or any of its sub directories.
$ lingo run review
```

# Slow Start

A step by step guide to getting started with Tenets and Flows: 
**[View the getting started guide](getting-started.md)**

# Concepts

The CodeLingo platform has two key concepts: Tenets and Flows.

## Tenets

A Tenet is an encoded project specific best practice used to guide development. A Tenet can be used for: coding styles, performance tuning, security audits, debugging, avoiding gotchas, reducing complexity and churn, and more.

**[View the guide and docs for working with Tenets](concepts/tenets.md)**

**[Explore published Tenets](https://dev.codelingo.io/codelingo/tenets)**

## Flows

A Flow is an automated development workflow that leverages Tenets to do some task, for example automating code reviews. While a Tenet lives next to your code in a .lingo.yaml file, it is inert until a Flow uses it.

**[View the guide and docs for working with Flows](concepts/flows.md)**

# User Guides

See the links under the User Guide drop-down for further resources.
