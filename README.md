---
title: Pandit
subtitle: Pandoc-based static site generator.
---

# Introduction

Pandit uses [Pandoc](https://pandoc.org)
to generate HTML files from Markdown, Org-mode, reStructuredText, and AsciiDoc files.

To start using Pandit, include the following files in your repository:

`Makefile`
: Build instructions

`css.mk`
: Stylesheets to include in the HTML

`css-x.mk`
: Stylesheets to copy to the output directory

`defaults.yaml`
: Default options for Pandoc

For each source file, the default options are read from all of these files, if they exist:

- `defaults.yaml` in the repository root
- `defaults.yaml` in the current directory
- `<basename>.yaml` (e.g. `example.yaml` for `example.md`)

# Usage

This example sets up a site with the [tufte-pandoc-css](https://github.com/p2pcollab/tufte-pandoc-css) template
and [tufte-css](https://github.com/p2pcollab/tufte-css) stylesheets.

```
mkdir pub
git submodule add https://github.com/p2pcollab/pandit pub/pandit
git submodule add https://github.com/p2pcollab/tufte-pandoc-css pub/tufte-pandoc-css
git submodule add https://github.com/p2pcollab/tufte-css pub/tufte-css
ln -s pub/pandit/Makefile
cp pub/pandit/config/tufte/* .
```

Finally, generate the site:

```
make
```

# License

Licensed under either of Apache License, Version 2.0 or MIT license at your option.
