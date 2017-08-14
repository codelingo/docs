# C# and Perforce Tutorial

This tutorial walks through the setup

<br/>

## Install

#### Perforce
1. Download Perforce client (p4) and server (p4d) [binaries](https://www.perforce.com/downloads).
2. Make both Perforce binaries executable with `$ chmod +x <path to the binary>` and add them to your `$PATH` in Linux and Mac or `%PATH%` in Windows. 

#### C# lexicon 
Install the C# lexicon if it is not available after platform installation.

CSharp(C#) should be listed in namespace `fission-function` if the lexicon has been installed: 

```bash
$ platctl util get-pods
```

e.g.`fission-function   codelingo-ast-csharp-0-0-0-7ef4ebb9-e58a-4e91-8cfe-f7c910e0mbhq   2/2       Running   0          4d`

<br/>

## Setup

[Setup](tutorials/getting-started.md) Lingo client. 

Note: The username of the newly created CodeLingo account must be the same as the local Perforce username.

<br/>

### Test Run

Setup a test repository:

```bash
mkdir myawesomepkg
cd myawesomepkg
p4 -u <p4 username> init -C0 -n
```

Add a file, named “test.cs”, with the following source code:

```CS
public class Hello
{
   public static void Main()
   {
      System.Console.WriteLine("Hello, World!");
   }
}
```

Create a new .lingo file:

```bash
lingo new
```

Edit the .lingo file as follows:

```bash
lexicons:
- codelingo/common
- codelingo/p4
- codelingo/csharp
tenets:
- name: find-funcs
  doc: Example tenet that finds all functions.
  comment: This is a function, but you probably already knew that.
  match: |
    <csharp.MethodDeclaration
```

Commit:

```bash
p4 reconcile
p4 submit -d "initial submit"
```

Then run `lingo review -i`. You should see the following output:

```bash
test.cs:2

    This is a function, but you probably already knew that.


    ...

  > public static void Main()
   {
      System.Console.WriteLine("Hello, World!");
   }

    ...

[o]pen [d]iscard [K]eep:
```

<br/>


