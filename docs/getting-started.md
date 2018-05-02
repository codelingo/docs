# Getting Started
<br/>
## Introduction
This guide provides instructions and documentation for:

- Installation and usage of the CodeLingo command line interface (CLI)
- Basic configuration of CodeLingo for your repositories via .lingo files
- Instructions for integrating CodeLingo into your workflow via code reviews

## Installation

The lingo CLI tool can be used to manage the [Lexicons](concepts/tenets.md#lexicons), [Tenets](concepts/tenets.md) and [Bots](concepts/flows.md) for your repositories. The lingo client will help you manage these resources.

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

In order to run Tenets against your repository, your lingo client will need to authenticate with the CodeLingo servers. To do so, you are required to have an account. Please follow this steps to set up your client:

1. Create a CodeLingo account <a href="https://codelingo.io/join" target="_blank">here</a>
2. Generate the token from the  <a href="https://codelingo.io/lingo-token" target="_blank">web app here</a>, and copy it to your clipboard
3. Run `$ lingo config setup` and follow the prompts.

```bash
$ lingo config setup
```

4. Enter your username (you can see it in the top right corner of codelingo.io, this should be the same as your github username if this is how you registered)

5. Enter your token, pasting from your clipboard

You should see a success message. The client is now authenticated to talk to the CodeLingo platform.

---

*Under The Hood*: The setup command creates a ~/.codelingo folder in which it stores credentials and configuration details to push code up and get issues back from the CodeLingo platform. You'll note it also adds a ~/.codelingo/config/git-credentials file. This is used by the lingo tool, via git, to sync code to the CodeLingo git server.

## Configuration

Now that you have the Lingo client installed and authenticated, you can create and run Tenets against your repository. All configuration for CodeLingo is driven by `.lingo` files. 

Each lingo file consists of the following components:

- Lexicon import statments that provide the facts to be used to build queries (Tenets)
-  a set of Tenets to be applied to the repositories. These Tenets are either imported, or written directly in the .lingo file.
- Flow specific decorators that integrate the Tenets into your workflow

Each project requires at least one `.lingo` file at root, however multiple files can be used. All `.lingo` files in a repository will be run with the client, with configuration in children directories only being scoped to that directory's files.

To initialize a default lingo file, run `$ lingo init`. The default file contains an example Tenet as follows:

``` yaml
  tenets:
  - name: find-funcs
    doc: Example tenet that finds all functions.
    bots:
      codelingo/review:
        comments: This is a function, but you probably already knew that.
    query: |
      import codelingo/ast/common

      @ review.comment
      common.func({depth: any})
```

This default lingo file has a single Tenet which find functions across any language. In this case, the Lexicon import has been inlined into the Tenet definition (`import codelingo/ast/common`)

As can be seen here, the key parts of each Tenet are:

- **`name`** meta data for the identification of the Tenet
- **`doc`** meta data for the usage of the Tent
- **`bots`** The metadata for bots the Tenet integrates with. In this case, for the review bot, we provide a comment for the review.
- **`query`** - this is the pattern the Tenet is looking for and core to all Tenets.
- **`@ review.comment`** - this decorator integrates the review Flow into the Tenet (more on this later)

## Running a review

Integrating Tenets into your existing developer workflow is done through Flows. The review flow can be used. All flows are run via `$lingo run <flow_name>`.

```bash
  $ lingo run review
```

Note, the first run of any Flow can take a little longer as your repository is ingested for the first time.


## Adding Tenets

Tenets can be added to your project .lingo file via two methods:

- Importing existing Tenets
- Writing custom Tenets

.lingo file can have a combination of both custom Tenets and imported Tenets.

To import Tenets, simply add an import statement to the `tenets:` key:

```
tenets:
  - import: codelingo/go/bool-param
```

For more information about importing Tenets please see the [Tenet guide](concepts/tenets.md#importing). Existing Tenets to import (driven by best practices and the community) can be found [on the Hub](https://codelingo.io/hub/tenets)

To write custom Tenets requires use of CodeLingo Query Language (CLQL). CLQL relies on importing Lexicons, which provide a set of domain specific facts to work with. All Tenets require at minimum a `name` and `query`.

More information on writing custom Tenets can be found in the [Tenet guide](concepts/tenets.md#writing-custom-tenets)

### Integrating reviews

To integrate CodeLingo into your workflow, Flows are used. The CLAIR Flow works to leave comments on Pull Requests to ensure that best practices are followed by all developers on your team..

Setting up the CLAIR flow on your repos is as easy as adding a new webhook on Github.

1. Set the Payload URL to https://clair.codelingo.io.
2. Ensure the content type is set to "application/json".
3. Select the "Let me select individual events" option.
4. Tick the "Pull request" box, leaving all others unchecked.
5. Ensure the "Active" box is ticked.
6. Click "Add webhook".

**For private repos:**
YOu will need to add the clairscent user as a collaborator to your repository. It may take a couple of minutes for CLAIR to accept the collaboration request.

More details instructions can be found [here](https://codelingo.io/flow/github-pull-request-review)

Once configured, CLAIR will comment on pull requests when the Tenets for this project occur.

CLAIR will only review pull requests and will never make changes to your codebase.

Flows can be used to build any custom workflows. Whether that's dashboarding through panel Bots, or integrations with your existing tools and services through Bots.

If you are interested in building custom flows and integrations, please contact us directly at: 
 [hello@codelingo.io](hello@codelingo.io).

## Next Steps

Now that you have basic integration with CodeLingo into your project, you can start to add additional Tenets and build custom workflow augmentation.

**[Explore existing Tenets to add to your project](https://codelingo.io/hub/tenets)**

**[View guide to importing and writing Tenets](/concepts/tenets.md)**

<br/>
<br/>
<br/>
<br/>
## CLI Reference

Below is reference documentation for the CLI.

### `lingo help`

```bash
$ lingo --help
```

This will provide all help commands for the lingo 

```
NAME:
   lingo - Code Quality That Scales.

USAGE:
   lingo [global options] command [command options] [arguments...]

VERSION:
   0.3.14

COMMANDS:
     init        Create a .lingo file in the current directory.
     config      Show summary of config
     run <flow>. Runs a particular flow
     update      Update the lingo client to the latest release.
     help, h     Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --help, -h     show help
   --version, -v  print the version
```

### `lingo init`
```bash
$ lingo init
```
Initialize a new .lingo file inside the current directory. If there is already an existing .lingo file this command will fail. The. default lingo file comes with a single go tenet matches any functions.


### `lingo run review`

<!-- TODO: add commands to discover and install CLAIR -->

To run the project Tenets against your repository locally, run `review` command:

```bash
$ lingo run review
```

By default, this will step through each occurence of each Tenet. For example,

```bash
$ lingo run review -i
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


NB: The first time `lingo run review` is run on a repository, `lingo` will automatically add the Codelingo git server as a remote, so that changes can be synced and analysed on the Codelingo platform.

