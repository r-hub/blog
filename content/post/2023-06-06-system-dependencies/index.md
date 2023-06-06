---
slug: system-dependency
title: "System Dependencies in R Packages & Automatic Testing" 
authors: 
- Hugo Gruson
date: "2023-06-06" 
tags: 
- package development 
- r-package
output: hugodown::hugo_document
rmd_hash: 25709f6b3e97a991

---

In a previous post, we discussed about a package dependency that goes slightly beyond the normal R package ecosystem dependency: R itself. Today, we step even further and discuss about dependencies that have nothing to do with R: system dependencies. In particular, we are going to talk about system dependencies in the context of automated testing: is there anything extra to do when setting continuous integration for your package with system dependencies? How does it work behind the scenes? And how to work with edge cases?

## Introduction: specifying system dependencies in R packages

Before jumping right into the topic of continuous integration, let's take a moment to introduce, or remind you, how system dependencies are specified in R packages. You can directly jump to the next session if this concept is fresh in your memory.

Let's imagine we have a package depending on The official 'Writing R Extensions' guide states:

> Dependencies external to the R system should be listed in the 'SystemRequirements' field, possibly amplified in a separate README file.

One important thing to note is that this field contains free text. As such, to refer to the same piece of software, you could write either one of the following in the package `DESCRIPTION`:

``` yaml
SystemRequirements: ExternalSoftware
```

``` yaml
SystemRequirements: ExternalSoftware 0.1
```

``` yaml
SystemRequirements: lib-externalsoftware
```

## The general case: everything works automagically

If while reading the previous section, you could already sense the problems linked to the fact `SystemRequirements` is a free-text field, fret not! In the very large majority of cases, setting up continuous integration in an R package with system dependencies is exactly the same as with any other R package.

Using, as often, the supercharged usethis package, you can automatically create the relevant GitHub Actions workflow file in your project [^1]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>usethis</span><span class='nf'>::</span><span class='nf'><a href='https://usethis.r-lib.org/reference/use_github_action.html'>use_github_action</a></span><span class='o'>(</span><span class='s'>"check-standard"</span><span class='o'>)</span></span></code></pre>

</div>

The result is:

``` yaml
# Workflow derived from https://github.com/r-lib/actions/tree/v2/examples
# Need help debugging build failures? Start at https://github.com/r-lib/actions#where-to-find-help
on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

name: R-CMD-check

jobs:
  R-CMD-check:
    runs-on: ${{ matrix.config.os }}

    name: ${{ matrix.config.os }} (${{ matrix.config.r }})

    strategy:
      fail-fast: false
      matrix:
        config:
          - {os: macos-latest,   r: 'release'}
          - {os: windows-latest, r: 'release'}
          - {os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'}
          - {os: ubuntu-latest,   r: 'release'}
          - {os: ubuntu-latest,   r: 'oldrel-1'}

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      R_KEEP_PKG_SOURCE: yes

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-pandoc@v2

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.config.r }}
          http-user-agent: ${{ matrix.config.http-user-agent }}
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::rcmdcheck
          needs: check

      - uses: r-lib/actions/check-r-package@v2
        with:
          upload-snapshots: true
```

You may notice there is no explicit mention of system dependencies in this file. Yet, if we use this workflow in an R package with system dependencies, everything will work out-of-the-box in most cases. So, when are system dependencies installed? And how the workflow does even know which dependencies to install since the `SystemRequirements` is free text that may not correspond to the exact name of a library?

## When it's not working out-of-the-box

### Fix it for everybody by submitting a pull request

### Install system dependencies manually in GitHub Actions

### Using a Docker image in GitHub Actions

[^1]: Alternatively, if you're not using usethis, you can manually copy-paste the relevant GitHub Actions workflow file from the `examples` of the `r-lib/actions` project.

