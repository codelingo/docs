# Overview

Codelingo is a Platform as a Service (PaaS) for software development teams to solve software development problems. It treats your software as data and automates your workflows, called Actions, with the rules and patterns you define, called Specs.

Our flagship Action is the [Review Action](https://www.codelingo.io/actions/codelingo/review), which checks a repository's pull requests conform to its project specific patterns. We have also built the [Rewrite Action](https://www.codelingo.io/actions/codelingo/rewrite) and the [Docs Action](https://www.codelingo.io/actions/codelingo/docs). 

# Quick Starts

## Playground

Test out writing a Spec and running a Action online with zero installs using the CodeLingo [playground](https://codelingo.io/playground) - it's easier than you think!

<!-- TODO image of the playground UI -->

<!-- TODO CLQL tutorial -->

## Dashboard

The CodeLingo [Dashboard](https://www.codelingo.io/dashboard) lets you manage you automated workflows for each of your repositories. It is your hub for adding and removing Specs from your repositories and running Actions. Sign in with GitHub and follow the tutorial to run your first Action.

## GitHub Review Action

After [installing CodeLingo on GitHub](https://github.com/apps/codelingo), write the following codelingo.yaml to the root of your repository:

```yaml
# codelingo.yaml file

specs:
  - import: codelingo/go
```

You're done! Every pull request to your repository will now be checked against the Go Spec Bundle we imported above [like so](https://github.com/codelingo/ReviewDemonstration/pull/1).

<!-- TODO add screenshot of review comment -->

Other Spec Bundles (including for other languages) from the community can be found at [codelingo.io/specs](https://www.codelingo.io/specs).

<!-- TODO add instructions on how to interact with Review Action with GitHub comments -->

# Getting Started Guide

A step by step guide to getting started with Specs and Actions: 

**[View the getting started guide](getting-started.md)**

# Concepts

The CodeLingo platform has two key concepts: Specs and Actions.

## Specs

A Spec is an encoded project specific best practice used to guide development. A Spec can be used for: coding styles, performance tuning, security audits, debugging, avoiding gotchas, reducing complexity and churn, and more.

**[View the guide and docs for working with Specs](concepts/specs.md)**

**[Explore published Specs](https://www.codelingo.io/specs)**

## Actions

An Action is an automated development workflow that leverages Specs to do some task, for example automating code reviews. While a Spec lives next to your code in a codelingo.yaml file, it is inert until an Action uses it.

#### Note:

We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly.

**[View the guide and docs for working with Actions](concepts/actions.md)**
