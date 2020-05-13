# Overview

Codelingo is a Platform as a Service (PaaS) for software development teams to solve software development problems. It treats your software as data and automates your workflows, called Actions, with the rules and patterns you define, called Rules.

Our flagship Action is the [Review Action](https://www.codelingo.io/actions/codelingo/review), which checks a repository's pull requests conform to its project specific patterns. We have also built the [Rewrite Action](https://www.codelingo.io/actions/codelingo/rewrite) and the [Docs Action](https://www.codelingo.io/actions/codelingo/docs). 

# Quick Starts

## Playground

Test out writing a Rule and running a Action online with zero installs using the CodeLingo [playground](https://codelingo.io/playground) - it's easier than you think!

<!-- TODO image of the playground UI -->

<!-- TODO CLQL tutorial -->

## Dashboard

The CodeLingo [Dashboard](https://www.codelingo.io/dashboard) lets you manage you automated workflows for each of your repositories. It is your hub for adding and removing Rules from your repositories and running Actions. Sign in with GitHub and follow the tutorial to run your first Action.

## GitHub Review Action

After [installing CodeLingo on GitHub](https://github.com/apps/codelingo), write the following codelingo.yaml to the root of your repository:

```yaml
# codelingo.yaml file

rules:
  - import: codelingo/go
```

You're done! Every pull request to your repository will now be checked against the Go Rule Bundle we imported above [like so](https://github.com/codelingo/ReviewDemonstration/pull/1).

<!-- TODO add screenshot of review comment -->

Other Rule Bundles (including for other languages) from the community can be found at [codelingo.io/rules](https://www.codelingo.io/rules).

<!-- TODO add instructions on how to interact with Review Action with GitHub comments -->

# Getting Started Guide

A step by step guide to getting started with Rules and Actions: 

**[View the getting started guide](getting-started.md)**

# Concepts

The CodeLingo platform has two key concepts: Rules and Actions.

## Rules

A Rule is an encoded project specific best practice used to guide development. A Rule can be used for: coding styles, performance tuning, security audits, debugging, avoiding gotchas, reducing complexity and churn, and more.

**[View the guide and docs for working with Rules](concepts/rules.md)**

**[Explore published Rules](https://www.codelingo.io/rules)**

## Actions

An Action is an automated development workflow that leverages Rules to do some task, for example automating code reviews. While a Rule lives next to your code in a codelingo.yaml file, it is inert until an Action uses it.

#### Note:

We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly.

**[View the guide and docs for working with Actions](concepts/actions.md)**
