# CodeLingo Docs

This repo generates a static HTML site from markdown. Docs for the different versions are organised by branch. The master branch is for changes that should apply to all versions. All other branches should keep up-to-date with the master branch. The lex-sdk and flow-sdk branches are merged with the onprem branch at the point of deploying the platform for a client who has those licences.

See here to run the site: http://www.mkdocs.org

### Localhost

```bash

$ mkdocs serve
```

visit http://localhost:8000/

### Build Instructions

1. Build the static site:

```bash

$ mkdocs build
```

This will create the html site under ./site

2. Build a Docker image. Note the push will error due to permissions, but the image will still be built.

```bash

$ ./push.sh
```
