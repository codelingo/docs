# C# and Perforce

<br/>

## Install

#### Perforce
1. Download the Perforce client (p4) and server (p4d) [binaries](https://www.perforce.com/downloads).
2. Make both Perforce binaries executable with `$ chmod +x <path to the binary>` and add them to your `$PATH` in Linux and Mac or `%PATH%` in Windows. 

#### C# lexicon 
The CodeLingo Platform comes with the C# lexicon pre-installed.

<br/>

## Setup

If the lingo client has not already been setup, please follow [these setup steps](getting-started.md). 

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

Create a new codelingo.yaml file:

```bash
lingo new
```

Edit the codelingo.yaml file as follows:

```bash
lexicons:
- codelingo/common
- codelingo/csharp
rules:
- name: find-funcs
  doc: Example rule that finds all functions.
  comment: This is a function, but you probably already knew that.
  match: |
    @ clair.comment
    csharp.method_declaration(depth = any)
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


