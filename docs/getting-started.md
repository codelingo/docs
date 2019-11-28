# Getting Started

_Note: We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly._

## Introduction
This guide provides instructions and documentation for:

- Configuration of CodeLingo for your repositories via codelingo.yaml files
- Importing and writing of Specs
- Instructions for integrating CodeLingo into your workflow for automated code reviews

## Adding Specs

Writing and running Specs is driven via configuration stored in your repository's `codelingo.yaml` files. Each `codelingo.yaml` file specifies a collection of Specs to apply to all code under the directory it's written in. A project requires at least one `codelingo.yaml` file, however multiple files can be used. All `codelingo.yaml` files in a repository will be run by the client, with configuration in children directories only being scoped to that directory's files. `codelingo.yaml` files are based on the YAML format.

Specs can be added to a project's `codelingo.yaml` file via two methods:

- Importing published Specs
- Writing custom Specs

Note: a `codelingo.yaml` file can contain a combination of both custom Specs and imported Specs.

### Importing Specs

To import a published Spec, add the url to your `codelingo.yaml` file:

```
# example of importing an individual Spec from the CodeLingo's Go Bundle
specs:
  - import: codelingo/go/marshelling
```

Specs can be imported individually (as above), or as a Bundle:

```
#  example of importing the whole Go Bundle
specs:
  - import: codelingo/go
```

When importing a bundle, if there are particular specs you wish to exclude, you can do so using skip:

```
# example of skipping specs from a bundle import
specs:
  - import: codelingo/go
  skip:
    - global-var
    - empty-slice
```

Published Specs to import (driven by best practices and the community) can be found [on CodeLingo](https://www.codelingo.io/specs).

**[View more information on importing published Specs](concepts/specs.md#importing).**

## Running the Review Action

Integrating Specs into your existing developer workflow is done through Actions. The simplest Action to get started with is the Review Action. To install, run:

Here we will probably want to point to the dashboard!

Note: The Review Action only supports public repos at this time.

Once configured, the Review Action will comment on pull requests that violate a Spec.

The Review Action will only review Pull Requests and will never make changes to your codebase.

Actions can be used to build any custom workflow. Whether that's generating custom reports on your project dashboard, or integrations with your existing tools and services through Functions.

If you are interested in building custom Actions and integrations, please contact us directly at:
 [hello@codelingo.io](hello@codelingo.io).

## Next Steps

Now that you have basic integration with CodeLingo into your project, you can start to add additional Specs and build custom workflow augmentation.
<br/><br/>
**[Explore published Specs to add to your project](https://www.codelingo.io/specs)**
<br/><br/>
**[View guide to importing and writing Specs](https://www.codelingo.io/docs/concepts/specs/)**
