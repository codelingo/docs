# Getting Started
<br/>
## Introduction
This guide provides instructions and documentation for:
- installing the CodeLingo command line interface (CLI)
- configuring CodeLingo for your repositories
- integrating CodeLingo into your workflow

For information about writing and discovering Tenets, please see the [Tenet guide](concepts/tenets.md)

### Installation

The lingo client is a command line interface (CLI) tool used to manage the [Lexicons](concepts/tenets.md#lexicons), [Tenets](concepts/tenets.md) and [Bots](concepts/flows.md). The lingo client will help you find, create and run these resources.

[Download](https://github.com/codelingo/lingo/releases) a pre-built binary or, if you have [Golang setup](https://golang.org/doc/install), install from source:

```bash
$ git clone https://github.com/codelingo/lingo $GOPATH/src/github.com/codelingo/lingo
$ cd $GOPATH/src/github.com/codelingo/lingo
$ make install
```

This will download, build and place the `lingo` binary on your $PATH

<br/>

#### Windows

Put the binary in a folder listed in your %PATH%. If you don't have an appropriate folder set up, create a new one (ie C:\Lingo) and append it to PATH with a ; in between by going to Control Panel\System and Security\System -> Advanced system settings -> Environment Variables

<br/>

#### Linux / Unix

Place the lingo binary on your $PATH.

<br/>

### Authentication

1. Create a CodeLingo account: [https://codelingo.io/join](https://codelingo.io/join)

2. Generate the token at codelingo.io/lingo-token and copy it to your clipboard

3. Run `lingo setup` and follow the steps prompted there

```bash
$ lingo setup
```

4. Enter your username (you can see it in the top right corner of codelingo.io)

5. Enter your token, pasting from your clipboard

You should see a success message. The client is now authenticated to talk to the CodeLingo platform.

---

*Under The Hood*: The setup command creates a ~/.codelingo folder in which it stores credentials and configuration details to push code up and get issues back from the CodeLingo platform. You'll note it also adds a ~/.codelingo/config/git-credentials file. This is used by the lingo tool, via git, to sync code to the CodeLingo git server.

<br/>

## Configuration

All configuration for your project is driven by `.lingo` files. Each project requires at least one `.lingo` file, however multiple files can be used.

TODO:

- what is default
- what can be modified
- how to import / add

## CLI Tool

```bash
$ lingo --help
```

```
COMMANDS:
     bots      List Bots
     config    Show summary of config
     flows     List Flows
     lexicons  List Lexicons
     init      Create a .lingo file in the current directory.
     tenets    List Tenets
     update    Update the lingo client to the latest release.
     help, h   Shows a list of commands or help for one command

```

### `lingo init`
TODO: To be completed

```bash
$ lingo init
```

### `lingo review`

<!-- TODO: add commands to discover and install CLAIR -->

To run the project Tenets against your repository locally, run `review` command:

```bash
$ lingo review
```

By default, this will step through each occurence of each Tenet. For example,

```bash
$ lingo review -i
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


NB: The first time `lingo review` is run on a repository, `lingo` will automatically add the Codelingo git server as a remote, so that changes can be synced and analysed on the Codelingo platform.

### `lingo search`
The lingo client can be used to search any public repository on Github, printing any results back out to your command line in JSON format. Searching is a good way to experiment and play with CLQL (CodeLingo Query Language).

```bash
$ lingo search
```

You should see a list of results found by Tenets written in the .lingo file.

### `lingo <resource> list`

The CodeLingo Platform supports an ecosystem of Lexicons, Tenets and Bots. The lingo client is used to discover them. For example, to list available lexicons run the following:

```bash
$ lingo lexicon list

ast/codelingo/cs
ast/codelingo/php
ast/codelingo/golang
vcs/codelingo/git
vcs/codelingo/perforce
...
```

To see a description of a lexicon run  `$ lingo lexicon describe`. For example:

```bash
$ lingo lexicon describe ast/codelingo/cs

C Sharp AST Lexicon

This lexicon is a list of facts about the C Sharp AST.
```

To list all facts the lexicon provides, run `$ lingo lexicon list-facts ast/codelingo/cs`. To see the full list of commands available, please run `$ lingo --help`. The lingo CLI tool also powers IDE plugins, such as the [CLQL generation](/clql).
<br/>
<br/>

## Setting up Flows
### Pull requests (CLAIR)

- TODO: explain exactly what it is
- TODO: update payload URL

Setting up CLAIR on your repos is as easy as adding a new webhook on Github.

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

### Configuring a custom flow

Flows can be used to build any custom workflows. Whether that's dashboarding through panel Bots, or intergations with your existing tools and services through Bots. 

If you are interested in building custom flows and integrations, please contact us directly at: 
 [hello@codelingo.io](hello@codelingo.io).

## Next Steps

**[Explore existing Tenets to add to your project](https://codelingo.io/hub/tenets)**

**[View guide to importing and writing Tenets](/concepts/tenets.md)**



