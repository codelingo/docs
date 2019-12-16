# Getting Started

## Introduction

There are two ways to leverage CodeLingo Actions to automate your workflows, the [CodeLingo Dashboard](https://www.codelingo.io/dashboard) and the [CodeLingo GitHub App](https://github.com/apps/codelingo). Below is an example demonstrating how to use the CodeLingo Dashboard to run an automated code-review and employ the CodeLingo GitHub App to protect against future issues being introduced in Pull Requests.

## Automated Code-Review Example

This example will be a simple demonstration of using the CodeLingo Review Action to automatically find issues in a codebase and prevent them from returning by reviewing each new Pull Request made to the repository. A quicker tutorial can be found on the [CodeLingo Dashboard](https://www.codelingo.io/dashboard). To use CodeLingo for free you must have your code in public repositories on GitHub (GitLab and BitBucket support coming soon).

To begin go the [CodeLingo Dashboard](https://www.codelingo.io/dashboard) and click on `sign in with github` in the top right of the screen. CodeLingo uses [Auth0](https://auth0.com/) to authenticate users so you will be asked to authorize Auth0 to access your email address before being redirected to the CodeLingo Dashboard. The Dashboard acts as a hub for importing Specs and Spec Bundles into your GitHub repository and running Actions such as the CodeLingo Review Action. To do this, click on `install on github` to install the [CodeLingo GitHub App](https://github.com/apps/codelingo) and follow the prompts. You may choose to authorize the CodeLingo GitHub App on all of your public repositories or just the ones you select but keep in mind CodeLingo will never alter your code without your permission. After the CodeLingo GutHub App is successfully installed return to the Dashboard.

CodeLingo works by using what we call Specs, which can be thought of as specifications of anti-patterns or best practice and are expressed using CLQL (Code Lingo Query Language). You can read more about CodeLingo Specs [here](concepts/specs.md), but to demonstrate we just need to know that Specs are defined in codelingo.yaml files at the root of a repository. The dashboard makes it simple to add and remove Specs and Spec Bundles from a GitHub repository.

For this example we will add the [defer-close-file](https://www.codelingo.io/specs/codelingo/effective-go/defer-close-file) Spec from the Effective Go Bundle to a small example repository. This Spec identifies any case of a file that has been opened using the Golang [OS](https://golang.org/pkg/os/) package and recommends adding `defer <file>.Close()`. 

We do this by selecting the repository and clicking on `Add Spec`, then searching for `defer-close-file`. After adding the Spec you should see it listed as shown below:
![Add Spec](img/add-defer.png)
Notice that `defer-close-file` is now listed under Specs, we can use the Review Action to create GitHub Issues for the repository as well as commenting on any instance of an unclosed file in Pull Requests made to the repository. Clicking on `Commit` creates a Pull Request made by the CodeLingoBot adding the Spec to the repository. After merging the Pull Request, return to the CodeLingo Dashboard and refresh the page.
![Done Adding Spec](img/done-adding-defer.png)
You will notice the Spec is now listed in blue in this repository signifying that it can now be used by CodeLingo Actions.

We can now run an automated code review by pressing `REVIEW ALL`. CodeLingo will run the Review Action and use `defer-close-file` Spec to identify unclosed files. After the Action has completed, the following Issue is created on the GitHub Repository:
![GH Issue](img/gh-issue.png)
From now on the CodeLingoBot will automatically review subsequent Pull Requests made to the repository. If the same issue is then introduced in subsequent Pull Request, the CodeLingoBot will comment as such:
![Comment On PR](img/pr-comment.png)


Note: Actions can be used to build any custom workflow. Whether that's generating custom reports on your project dashboard, or integrations with your existing tools and services through Functions.

If you are interested in building custom Actions and integrations, please contact us directly at:
 [hello@codelingo.io](hello@codelingo.io).

## Next Steps

Now that you have basic integration with CodeLingo into your project, you can start to add additional Specs and build custom workflow augmentation.
<br/><br/>
**[Explore published Specs to add to your project](https://www.codelingo.io/specs)**
<br/><br/>
**[View guide to importing and writing Specs](https://www.codelingo.io/docs/concepts/specs/)**
