---
slug: rbuildignore
title: "Non-standard files/directories and Rbuildignore"
authors:
  - Maëlle Salmon
date: "2020-05-25"
tags:
- package development
- standards
output: 
  html_document:
    keep_md: true
---




Paragraphasing [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Creating-R-packages), an R package is _"directory of files which extend R"_.
These files have to follow [a standard structure](https://r-pkgs.org/package-structure-state.html): you can't store everything that suits your fancy in a tarball you submit to CRAN.
In this post we shall go through what can go on CRAN, what else you might want to keep, and how not to let the latter upset R CMD check.

## Standard, known directory and files

At the moment of writing, what a built package can contain is [this list called `known`](https://github.com/wch/r-source/blob/512f39773b05a85ae53103c799bb9ca20ac2dced/src/library/tools/R/check.R#L1365)[^rabbit] defined in the R source, in `tools/R/check.R`.

```r
known <- c("DESCRIPTION", "INDEX", "LICENCE", "LICENSE",
           "LICENCE.note", "LICENSE.note",
           "MD5", "NAMESPACE", "NEWS", "PORTING",
           "COPYING", "COPYING.LIB", "GPL-2", "GPL-3",
           "BUGS", "Bugs",
           "ChangeLog", "Changelog", "CHANGELOG", "CHANGES", "Changes",
           "INSTALL", "README", "THANKS", "TODO", "ToDo",
           "INSTALL.windows",
           "README.md", "NEWS.md",
           "configure", "configure.win", "cleanup", "cleanup.win",
           "configure.ac", "configure.in",
           "datafiles",
           "R", "data", "demo", "exec", "inst", "man",
           "po", "src", "tests", "vignettes",
           "build",       # used by R CMD build
           ".aspell",     # used for spell checking packages
           "java", "tools", "noweb") # common dirs in packages.
```

In this post, we won't go into what these directories and files can contain and how they should be formatted, which is another standard.
We'll focus on their mere existence.

To take a step back, how do such files and directories end up, or not, in the tarball/bundled package?
That's one job of [R CMD build](https://cran.r-project.org/doc/manuals/R-exts.html#Building-package-tarballs) possibly via a wrapper like `devtools::build()`.

[^rabbit]: I might have entered a rabbit hole looking through [THANKS files](https://github.com/search?l=&q=user%3Acran+filename%3ATHANKS&type=Code) on [R-hub mirror of CRAN source code](https://docs.r-hub.io/#cran-source-code-mirror).
I do like reading acknowledgements. :grin:
