# Getting Started
<br/>
## Introduction
This guide provides instructions and documentation for:

- Installation and usage of the CodeLingo command line interface (CLI)
- Configuration of CodeLingo for your repositories via codelingo.yaml files
- Importing and writing of Tenets
- Instructions for integrating CodeLingo into your workflow for automated code reviews

## Installation

The lingo CLI tool can be used to generate [Tenets](concepts/tenets.md) and run [Flows](concepts/flows.md) for your repositories.

<a href="https://github.com/codelingo/lingo/releases" target="_blank">Download</a> a pre-built binary or, if you have <a href="https://golang.org/doc/install" target="_blank">Golang setup</a>, install from source:
```bash
$ git clone https://github.com/codelingo/lingo $GOPATH/src/github.com/codelingo/lingo
$ cd $GOPATH/src/github.com/codelingo/lingo
$ make install
```

This will download, build and place the `lingo` binary on your $PATH

#### Windows

Put the binary in a folder listed in your %PATH%. If you don't have an appropriate folder set up, create a new one (ie C:\Lingo) and append it to PATH with a ; in between by going to Control Panel\System and Security\System -> Advanced system settings -> Environment Variables

#### Linux / Unix

Place the lingo binary on your $PATH.

## Authentication

In order to run Tenets against your repository, your lingo client will need to authenticate with the CodeLingo servers. To do so, you are required to have an account. Please follow these steps to set up your client:

1. Create a CodeLingo account: navigate to codelingo.io and click on the "Sign in with GitHub" button.
2. Generate the token from the  <a href="https://www.codelingo.io/settings/profile" target="_blank">web app here</a>, and copy it to your clipboard
3. Run `$ lingo config setup` and follow the prompts.
4. Enter your username (you can see it in the top right corner of codelingo.io, this should be the CodeLingo account username you created in step 1)
5. Enter your token, pasting from your clipboard

You should see a success message. The client is now authenticated to talk to the CodeLingo platform.

---

*Under The Hood*: The setup command creates a ~/.codelingo folder in which it stores credentials and configuration details to push code up and get issues back from the CodeLingo platform. Note: It also adds a ~/.codelingo/config/git-credentials file. This is used by the lingo tool, via git, to sync code to the CodeLingo git server.

## Adding Tenets

Writing and running Tenets is driven via configuration stored in your repository's `codelingo.yaml` files. Each `codelingo.yaml` file specifies a collection of Tenets to apply to all code under the directory it's written in. A project requires at least one `codelingo.yaml` file, however multiple files can be used. All `codelingo.yaml` files in a repository will be run by the client, with configuration in children directories only being scoped to that directory's files. `codelingo.yaml` files are based on the YAML format.

To initialize a default `codelingo.yaml` file, run `$ lingo init`. The default file contains an example Tenet as follows:

``` yaml
  tenets:
  - name: find-funcs
    doc: Example tenet that finds all functions.
    flows:
      codelingo/review:
        comment: This is a function, but you probably already knew that.
    query: |
      import codelingo/ast/common

      @review.comment
      common.func(depth = any)
```

This single Tenet will find functions across any language.

Tenets can be added to a project's `codelingo.yaml` file via two methods:

- Importing published Tenets
- Writing custom Tenets

Note: a `codelingo.yaml` file can contain a combination of both custom Tenets and imported Tenets.

### Importing Tenets

To import a published Tenet, add the url to your `codelingo.yaml` file:

```
# example of importing an individual Tenet from the CodeLingo's Go Bundle
tenets:
  - import: codelingo/go/marshelling
```

Tenets can be imported individually (as above), or as a Bundle:

```
#  example of importing the whole Go Bundle
tenets:
  - import: codelingo/go
```

Published Tenets to import (driven by best practices and the community) can be found [on CodeLingo](https://www.codelingo.io/tenets).

**[View more information on importing published Tenets](concepts/tenets.md#importing).**

### Writing Custom Tenets


Custom Tenets can be written from scratch directly in `codelingo.yaml` files using CodeLingo Query Language (CLQL). CLQL relies on importing Lexicons, which provide a set of domain specific facts to work with. Here is an example of a custom Tenet that find all functions in a repository:

```
# example of a Tenet written directly in a codelingo.yaml file
tenets:
  - name: find-funcs
    flows:
       codelingo/review
          comment: "this is a func"
    query: |
       import codelingo/go

       @review comment
       go.func_decl(depth = any)

```

The key parts of each Tenet are:

- **`name`** Meta data for the identification of the Tenet
- **`flows`** The metadata for flows the Tenet integrates with. In this case, for the review flow, we provide a comment for the review.
- **`query`** - this is the pattern the Tenet is looking for and core to all Tenets.
- **`@review comment`** - is a query decorator which extracts the information needed from the query result for the Review Flow. In this case, it'll return the filename and line number for every function declaration found in the repository.


**[View more information on writing custom Tenets](concepts/tenets.md#writing-custom-tenets)**


## Running the Review Flow

Integrating Tenets into your existing developer workflow is done through Flows. The simplest Flow to get started with is the Review Flow. To install, run:

```bash
  $ lingo install review
```

To learn how can use the Review Flow, run:

```bash
  $ lingo run review --help
```

All flows are run via `$ lingo run <flow_name>`.

```bash
  $ lingo run review
```

By default, this will step through each occurrence of each Tenet. For example,

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

In this example, the Tenet is using the inbuilt php fact "stmt_function" which matches functions in PHP. See [Tenet](concepts/tenets.md) for more details.

To open a file at the line of the issue, type `o` and hit return. It will give you an option (which it will remember) to set your editor, defaulting to vi.

Note: The first time `lingo run review` is run on a repository, `lingo` will automatically add the CodeLingo git server as a remote, so that changes can be synced and analysed on the CodeLingo platform.

## Integrating the Review Flow

Flows are used to integrate CodeLingo into your workflow. The Review Flow uses the comment from the Tenets to comment on Pull Requests. This ensures a teams best practices are followed by all developers on a team.

Setting up the Review Flow on a repository is as easy as adding a new webhook on Github.

1. Set the Payload URL to https://flow.codelingo.io/codelingo/review/github
2. Ensure the content type is set to "application/json".
3. Select the "Let me select individual events" option.
4. Tick the "Pull request" box, leaving all others unchecked.
5. Ensure the "Active" box is ticked.
6. Click "Add webhook".

Note: The Review Flow only supports public repos at this time.

Once configured, the Review Flow will comment on pull requests that violate a Tenet.

The Review Flow will only review Pull Requests and will never make changes to your codebase.

Flows can be used to build any custom workflow. Whether that's generating custom reports on your project dashboard, or integrations with your existing tools and services through Functions.

If you are interested in building custom Flows and integrations, please contact us directly at:
 [hello@codelingo.io](hello@codelingo.io).

## Next Steps

Now that you have basic integration with CodeLingo into your project, you can start to add additional Tenets and build custom workflow augmentation.
<br/><br/>
**[Explore published Tenets to add to your project](https://www.codelingo.io/tenets)**
<br/><br/>
**[View guide to importing and writing Tenets](https://www.codelingo.io/docs/concepts/tenets/)**
