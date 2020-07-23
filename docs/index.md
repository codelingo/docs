# Overview

Codelingo is a platform for software development teams to store, discuss and
code their tacit knowledge into project specific rules.

Our platform allows development teams to capture a discussion in a Pull Request,
create a Rule around that discussion then use our DSL, CLQL to generate a
project specific rule that is used to automatically review incoming code to your codebase.

# Quick Starts

## Playground

Test out writing a Rule and running a Action online with zero installs using the CodeLingo [playground](https://codelingo.io/playground) - it's easier than you think!

<!-- TODO image of the playground UI -->

<!-- TODO CLQL tutorial -->

## Dashboard

The CodeLingo Dashboard
[(codelingo.io/dashboard)](https://www.codelingo.io/dashboard) lets you manage
your rules for each of your repositories. It is your teams hub for discussion and creating project specific rules.

# Concepts

The CodeLingo platform has two key concepts: Rules and Actions.

## Rules

A Rule is an encoded project specific best practice used to guide development. A Rule can be used for: coding styles, performance tuning, security audits, debugging, avoiding gotchas, reducing complexity and churn, and more.
Rules can be created from the dashboard, you can either create a blank Rule or
one from a Rule Template.

**[View the guide and docs for working with Rules](concepts/rules.md)**

**[Explore published Rules](https://www.codelingo.io/rules)**

## Actions

An Action is an automated development workflow that leverages Rules to do some task, for example automating code reviews.

**[View the guide and docs for working with Actions](concepts/actions.md)**
