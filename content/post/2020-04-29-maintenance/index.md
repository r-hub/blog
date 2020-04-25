---
slug: maintenance
title: "Workflow automation tools for package developers"
authors:
  - Maëlle Salmon
date: "2020-04-29"
tags:
- package development
output: 
  html_document:
    keep_md: true
---

As a package developer, there are quite a few things you need to stay on top on.
Following bug reports and feature requests of course, but also regularly testing your package, ensuring the docs are up-to-date and typo-free...
Some of these things you might do without even pausing to think, whereas for others you might need more reminders.
In this blog post, we shall explore a few tools making your workflow smoother.

## What automatic tools?

I've actually covered this topic [a while back on my personal blog](https://masalmon.eu/2017/06/17/automatictools/) but here is an updated list.

### Tools for assessing

* [R CMD check, or `devtools::check()`](http://r-pkgs.had.co.nz/check.html) will check your package for adhesion to some standards (e.g. what folders can there be) and run the tests and [examples](/2020/01/27/examples/).
It's an useful command to run even if your package isn't intended to go on CRAN.

* For Bioconductor developers, there is [`BiocCheck`](https://bioconductor.org/packages/release/bioc/html/BiocCheck.html) that _"encapsulates Bioconductor package guidelines and best practices, analyzing packages "_.

* [`goodpractice`](http://mangothecat.github.io/goodpractice/), and [`lintr`](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/) both provides you with useful static analyses of your package.

* [`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.html) calculates test coverage for your package. Having a good coverage also means `R CMD check` is more informative, since it means it's testing your code. :wink: `covr::package_coverage()` can also provide you with the code coverage of the vignettes and examples!

* [`devtools::spell_check()`](http://devtools.r-lib.org/reference/spell_check.html)

styler

roxygen2 use (otherwise man less in sync)

pkgdown, although best with minimal config (reference grouping!)

### Tools for improving

## Where to use the tools

Locally vs. on the cloud?
Example of GitHub Actions workflows for PRs.

## When to use the tools?

Remember?
R CMD check, coverage: CI! Link to Julia's post. https://juliasilge.com/blog/beginners-guide-to-travis/

> "The idea behind continuous integration is that CI will automatically run R CMD check (along with your tests, etc.) every time you push a commit to GitHub. You don't have to remember to do this; CI automatically checks the code after every commit."
Julia Silge

Link to other CI references (latest usethis release post, Jim's slide comparing CI, tic's docs)

{{< tweet 1205183124868681728 >}}

The life-hack above by Julia Silge, "LIFE HACK: My go-to strategy for getting Travis builds to work is snooping on *other* people's .travis.yml files.", applies to other CI providers too!

precommit, usethis pre-commit hook for the README (skipped by GitHub when edited from the interface)
Regularly scheduled jobs, e.g. URL checking in R-hub docs.
usethis' release issue template.

## Less automatic aspects of package maintenance

Following your own bug tracker (for bug reports but also feature requests). 
Notification settings?
React or work by period?

Following development upstream (R, packages). 
What channels? 

Following developer convos to update and improve your practices.
Nice people refactoring your code? https://github.com/ropensci/codemetar/pulls?q=is%3Apr+author%3Ahsonne https://github.com/ropensci/codemetar/issues/222#issuecomment-448672148 https://www.goodreads.com/book/show/3735293-clean-code
R-pkg-devel &friends, other news channel https://masalmon.eu/2019/01/25/uptodate/, this blog. :wink:

## Conclusion

In this blog post we went over tooling making your package maintainer life easier.
Do _you_ have any special trick?
Please share in the comments below!