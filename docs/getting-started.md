# Getting Started with the lingo Client

The lingo client is a command line interface (CLI) tool used to manage the Lexicons, Tenets and Bots. The lingo client will help you find, create and run these resources.

<br/>

## Install


[Download] the client binary from your on premise bundle.

<br/>

### Windows

Put the binary in a folder listed in your %PATH%. If you don't have an appropriate folder set up, create a new one (ie C:\Lingo) and append it to PATH with a ";" in between by going to Control Panel\System and Security\System -> Advanced system settings -> Environment Variables.

You must run lingo from Git Bash or similar environment (if not git bash, then at least with git and msys installed). Running in Cmd will not work.


### Linux / Unix  

<br/>

Place the lingo binary on your $PATH.

<br/>

## Setup

1. Create a CodeLingo account: `http://< on-prem-ip >/join`

2. Setup lingo with your user account:

```bash
$ lingo setup
```

You will be prompted to enter a username and token. You can generate the token at `< on-prem-ip >/lingo-token`. 

3. Tell the client to talk to the on premise CodeLingo platform:

```bash
$ lingo use-env onprem
```

Replace the "addr" and "host" with the platform IP in the "onprem" section of `$HOME/.codelingo/configs/platform.yaml`. That's it. The lingo client is now setup on your computer.

---

*Under The Hood*: The setup command creates a ~/.codelingo folder in which it stores credentials and configuration details to push code up and get issues back from the CodeLingo platform. You'll note it also adds a ~/.codelingo/config/git-credentials file. This is used by the lingo tool, via git, to sync code to the CodeLingo git server.

<br/>

## Run a Review

<!-- TODO: add commands to discover and install CLAIR -->

CodeLingo's flagship Bot is CLAIR, CodeLingo AI Reviewer. CLAIR uses Tenets to automatically review pull requests. With the `lingo` tool CLAIR can be run on a local repository from the command line. <!-- add image of CLI review --> CLAIR reads Tenets from .lingo files that live alongside the source code files. The `lingo new` command writes a .lingo file and adds a simple Tenet (which simply finds all functions).

---
*Under The Hood*: The first time `lingo review` is run on a repository, `lingo` will automatically add the Codelingo git server as a remote, so that changes can be synced and analysed on the Codelingo platform.

<br/>

### First Run

Setup a test repository:

```bash
mkdir myawesomepkg
cd myawesomepkg
git init
```

Add a file, named “test.php”, with the following source code:

```PHP
<?php
function writeMsg() {
    echo "Hello world!";
}

writeMsg(); // call the function
?>
```

Add your first Tenet and save it, unchanged:

```bash
lingo new
```

Commit:

```bash
git add -A .
git commit -m"initial commit"
```

Then run `lingo review`. You should see the following output:

```bash
test.php:2

    This is a function, but you probably already knew that.


    ...

  > function writeMsg() {
        echo "Hello world!";
    }

    ...

[o]pen [d]iscard [K]eep:
```

As the Tenet is using the inbuilt common fact "func", it will match functions in both PHP and Golang (the two currently supported languages). Add a go file called "main.go" with the following source code:

```go
package main

import (
  "fmt"
)

func main() {
  fmt.Println("Hello world")
}
```

Run `$ lingo review` and you should now see two comments - one on the PHP function and the other on the Go function.

Note: you don't have to commit this second file. From here on, lingo will be able to see all changes in your repository, whether they are committed or not.

To open a file at the line of the issue, type `o` and hit return. It will give you an option (which it will remember) to set your editor, defaulting to vi.

<br/>

## Write a Tenet

Continuing on from the first run above, open the .lingo file in your editor of choice and change it to the following:

```yaml
tenets:
- name: first-tenet
  comment: This is a function, name 'writeMsg', but you probably knew that.
  match:
    <func:
      name: "writeMsg"
```

This will find funcs named "writeMsg". Save and close the file, then run `lingo review`. Try adding another func called "readMsg" and run a review. Only the "writeMsg" func should be highlighted. Now, update the Tenet to find all funcs that end in "Msg":

```yaml
  match:
    <func:
      name: /.*Msg$/
```

The "<" symbol returns the node that you're interested in. The review comment is attached to the returned node. There can only be one returned node per match statement. If a match statement has no "<", then even if true, no issue will be raised.

Vim has full support for the Lingo syntax, including CLQL. To set it up, [see here](scripts/lingo.vim.readme). Other than the match statement, written in CLQL, the rest of a .lingo file is written in YAML. As such, you can set .lingo files to YAML syntax in your IDE to get partial highlighting.

<!-- 
## CLQL

CLQL is the query language under the `match:` section of a Tenet. It stands for CodeLingo Query Language. The full spec can be found [here](https://docs.google.com/document/d/1NIw1J9u2hiez9ZYZ0S1sV8lJamdE9eyqWa8R9uho0MU/edit), but a practical to get acquainted with the language is to review the [examples](_examples).

## Running Examples

All examples under [examples/php](_examples/php) are working. The other examples have varying levels of completeness and serve as an implementation roadmap. To run the examples, copy the directory out of the repository and follow the same steps as in the tutorial above.

-->

## Discovering Lexicons, Tenets and Bots

The CodeLingo Platform supports an eco-system of Lexicons, Tenets and Bots. The lingo client is used to discover them. For example, to list available lexicons run the following:
 
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
 
To list all facts the lexicon provides, run `$ lingo lexicon list-facts ast/codelingo/cs`. To see the full list of commands available, please run `$ lingo --help`. The lingo CLI tool also powers IDE plugins, such as the [CLQL generation](/clql/index.html).