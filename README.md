CodeLingo Docs

This repo generates a static HTML site from markdown. Docs for the different versions are organised by branch. The master branch is for changes that should apply to all versions. All other branches should keep up-to-date with the master branch. The lex-sdk and bot-sdk branches are merged with the onprem branch at the point of deploying the platform for a client who has those licences.

See here to run the site: http://www.mkdocs.org

To build the site: `mkdocs build`

This will create the html site under ./site

To publish the docs: `mkdocs gh-deploy`

Documentation on the individual repositories should be kept in sync with this repo. We should look to automate this in the future.


SCRATCH

[CLAIR](/concepts/bots.md) (CodeLingo AI Reviewer). Any fact  If a match statement has no "<", then even if true, no issue will be raised.