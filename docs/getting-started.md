# Getting Started

_Note: We have deprecated flows in favor of actions. Please modify your codelingo.yaml files accordingly._

## Introduction
This guide provides instructions and documentation for:

- Installation and usage of the CodeLingo command line interface (CLI)
- Configuration of CodeLingo for your repositories via codelingo.yaml files
- Importing and writing of Specs
- Instructions for integrating CodeLingo into your workflow for automated code reviews

## Installation

_Note: lingo and all Actions no longer supports 32-bit operating systems_

The lingo CLI tool can be used to generate [Specs](concepts/specs.md) and run [Actions](concepts/actions.md) for your repositories.

<a href="https://github.com/codelingo/lingo/releases" target="_blank">Download</a> a pre-built binary or, if you have <a href="https://golang.org/doc/install" target="_blank">Golang setup</a>, install from source:
```bash
$ git clone https://github.com/codelingo/lingo $GOPATH/src/github.com/codelingo/lingo
$ cd $GOPATH/src/github.com/codelingo/lingo
$ make install
```

This will download, build and place the `lingo` binary on your $PATH

#### Windows

**NOTE: The `lingo update` command and the auto-update feature does not support Windows. To update lingo, follow these instructions again with the newer binary.**

Put the binary in a folder listed in your `%PATH%`. If you don't have an appropriate folder set up, create a new one (ie `C:\Lingo`) and append it to PATH with a `;` in between by going to Control Panel\System and Security\System -> Advanced system settings -> Environment Variables

#### Linux / Unix

Place the lingo binary on your `$PATH`, either:

Open `~/.bashrc` and add the line `export PATH=$PATH:/path/to/folder/containing/lingo-binary` for wherever you would like the binary to be.
Or put the binary on your current `$PATH`. Note: You can find your current `$PATH` by running:

```bash
$ echo $PATH
```

## Authentication

In order to run Specs against your repository, your lingo client will need to authenticate with the CodeLingo servers. To do so, you are required to have an account. Please follow these steps to set up your client:

1. Create a CodeLingo account: navigate to codelingo.io and click on the "Sign in with GitHub" button.
2. Generate the token from the  <a href="https://www.codelingo.io/settings/profile" target="_blank">web app here</a>, and copy it to your clipboard
3. Run `$ lingo config setup` and follow the prompts.
4. Enter your username (you can see it in the top right corner of codelingo.io, this should be the CodeLingo account username you created in step 1)
5. Enter your token, pasting from your clipboard

You should see a success message. The client is now authenticated to talk to the CodeLingo platform.

---

*Under The Hood*: The setup command creates a `~/.codelingo` folder in which it stores credentials and configuration details to push code up and get issues back from the CodeLingo platform. Note: It also adds a `~/.codelingo/config/git-credentials` file. This is used by the lingo tool, via git, to sync code to the CodeLingo git server.

## Adding Specs

Writing and running Specs is driven via configuration stored in your repository's `codelingo.yaml` files. Each `codelingo.yaml` file specifies a collection of Specs to apply to all code under the directory it's written in. A project requires at least one `codelingo.yaml` file, however multiple files can be used. All `codelingo.yaml` files in a repository will be run by the client, with configuration in children directories only being scoped to that directory's files. `codelingo.yaml` files are based on the YAML format.

To initialize a default `codelingo.yaml` file, run `$ lingo init`. The default file contains an example Spec as follows:

``` yaml
  specs:
  - name: find-funcs
    doc: Example spec that finds all functions.
    actions:
      codelingo/review:
        comment: This is a function, but you probably already knew that.
    query: |
      import codelingo/ast/common

      @review.comment
      common.func(depth = any)
```

This single Spec will find functions across any language.

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

### Writing Custom Specs


Custom Specs can be written from scratch directly in `codelingo.yaml` files using CodeLingo Query Language (CLQL). CLQL relies on importing Lexicons, which provide a set of domain specific facts to work with. Here is an example of a custom Spec that find all functions in a repository:

```
# example of a Spec written directly in a codelingo.yaml file
specs:
  - name: find-funcs
    actions:
       codelingo/review
          comment: "this is a func"
    query: |
       import codelingo/go

       @review comment
       go.func_decl(depth = any)

```

The key parts of each Spec are:

- **`name`** Meta data for the identification of the Spec
- **`actions`** The metadata for actions the Spec integrates with. In this case, for the review action, we provide a comment for the review.
- **`query`** - this is the pattern the Spec is looking for and core to all Specs.
- **`@review comment`** - is a query decorator which extracts the information needed from the query result for the Review Action. In this case, it'll return the filename and line number for every function declaration found in the repository.


**[View more information on writing custom Specs](concepts/specs.md#writing-custom-specs)**


## Running the Review Action

Integrating Specs into your existing developer workflow is done through Actions. The simplest Action to get started with is the Review Action. To install, run:

```bash
  $ lingo install review
```

To learn how can use the Review Action, run:

```bash
  $ lingo run review --help
```

All actions are run via `$ lingo run <flow_name>`.

```bash
  $ lingo run review
```

By default, this will step through each occurrence of each Spec. For example,

```bash
$ lingo run review
test.php:2

    This is a function, but you probably already knew that.


    ...

  > function writeMsg() {
        echo "Hello world!";
    }

    ...

[o]pen [d]iscard [K]eep:
```

In this example, the Spec is using the inbuilt php fact "stmt_function" which matches functions in PHP. See [Spec](concepts/specs.md) for more details.

To open a file at the line of the issue, type `o` and hit return. It will give you an option (which it will remember) to set your editor, defaulting to vi.

Note: The first time `lingo run review` is run on a repository, `lingo` will automatically add the CodeLingo git server as a remote, so that changes can be synced and analysed on the CodeLingo platform.

## Integrating the Review Action

Actions are used to integrate CodeLingo into your workflow. The Review Action uses the comment from the Specs to comment on Pull Requests. This ensures a teams best practices are followed by all developers on a team.

Setting up the Review Action on a repository is as easy as adding a new webhook on Github. Simply navigate to the settings menu of the reposiory you wish to add the review action to and click on Webhooks.

1. Set the Payload URL to https://flow.codelingo.io/codelingo/review/github
2. Ensure the content type is set to "application/json".
3. Select the "Let me select individual events" option.
4. Tick the "Pull request" box, leaving all others unchecked.
5. Ensure the "Active" box is ticked.
6. Click "Add webhook".

For more infomation on creating webhooks, see https://developer.github.com/webhooks/creating/

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
