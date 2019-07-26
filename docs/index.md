# Overview

Codelingo is a Platform as a Service (PaaS) for software development teams to solve software development problems. It treats your software as data and automates your workflows, called Actions, with the rules and patterns you define, called Tenets.

Our flagship Action is the [Review Action](https://www.codelingo.io/actions/codelingo/review), which checks a repository's pull requests conform to its project specific patterns. We have also built the [Rewrite Action](https://www.codelingo.io/actions/codelingo/rewrite) and the [Docs Action](https://www.codelingo.io/actions/codelingo/docs). 

# Quick Starts

## Playground

Test out writing a Tenet and running a Action online with zero installs using the CodeLingo [playground](https://codelingo.io/playground) - it's easier than you think!

<!-- TODO image of the playground UI -->

<!-- TODO CLQL tutorial -->

## GitHub Review Action

After [installing CodeLingo on GitHub](https://github.com/apps/codelingo), write the following codelingo.yaml to the root of your repository:

```yaml
# codelingo.yaml file

tenets:
  - import: codelingo/go
```

You're done! Every pull request to your repository will now be checked against the Go Tenet Bundle we imported above [like so](https://github.com/codelingo/ReviewDemonstration/pull/1).

<!-- TODO add screenshot of review comment -->

Other Tenet Bundles (including for other languages) from the community can be found at [codelingo.io/tenets](https://www.codelingo.io/tenets).

<!-- TODO add instructions on how to interact with Review Action with GitHub comments -->

## Local Review Action

To run the Review Action against repositories on your local machine, install the [lingo CLI](https://github.com/codelingo/lingo/releases/latest) and set it up with the following commands:

```bash
# Run this command from anywhere. Follow the prompts to set up Codelingo on your machine.
$ lingo config setup

# Run this command inside a git repository to add a default codelingo.yaml file in the current directory.
$ lingo init
```

Replace the content of the codelingo.yaml file we wrote above with:

```yaml
  tenets:
    - import: codelingo/go
```

You can now run the Review Action to check your source code against the Go Tenet Bundle we imported above.

```bash
# Run this command from the same directory as the codelingo.yaml file or any of its sub directories.
$ lingo run review
```

# Getting Started Guide

A step by step guide to getting started with Tenets and Actions: 

**[View the getting started guide](getting-started.md)**

# Concepts

The CodeLingo platform has two key concepts: Tenets and Actions.

## Tenets

A Tenet is an encoded project specific best practice used to guide development. A Tenet can be used for: coding styles, performance tuning, security audits, debugging, avoiding gotchas, reducing complexity and churn, and more.

**[View the guide and docs for working with Tenets](concepts/tenets.md)**

**[Explore published Tenets](https://www.codelingo.io/tenets)**

## Actions

A Action is an automated development workflow that leverages Tenets to do some task, for example automating code reviews. While a Tenet lives next to your code in a codelingo.yaml file, it is inert until a Action uses it.

#### Note:

We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly.

**[View the guide and docs for working with Actions](concepts/actions.md)**