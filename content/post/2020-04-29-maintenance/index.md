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
Some of these things you might be ok doing locally, whereas for others you might want to use some cloud services.
In this blog post, we shall explore a few tools making your workflow smoother.

## What automatic tools?

I've actually covered this topic [a while back on my personal blog](https://masalmon.eu/2017/06/17/automatictools/) but here is an updated list.

### Tools for assessing

* [R CMD check, or `devtools::check()`](http://r-pkgs.org/check.html) will check your package for adhesion to some standards (e.g. what folders can there be) and run the tests and [examples](/2020/01/27/examples/).
It's an useful command to run even if your package isn't intended to go on CRAN.

* For Bioconductor developers, there is [`BiocCheck`](https://bioconductor.org/packages/release/bioc/html/BiocCheck.html) that _"encapsulates Bioconductor package guidelines and best practices, analyzing packages "_.

* [`goodpractice`](http://mangothecat.github.io/goodpractice/), and [`lintr`](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/) both provide you with useful static analyses of your package.

* [`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.html) calculates test coverage for your package. Having a good coverage also means `R CMD check` is more informative, since it means it's testing your code. :wink: `covr::package_coverage()` can also provide you with the code coverage of the vignettes and examples!

* [`devtools::spell_check()`](http://devtools.r-lib.org/reference/spell_check.html), wrapping [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling/reference/spell_check_package.html), runs a spell check on your package and lets you store white-listed words.

### Tools for improving

That's all good, but now, do we really have to improve the package by hand based on all these metrics and flags?
Partly yes, partly no.

* [`styler`](https://styler.r-lib.org/) can help you re-style your code. Of course, you should check the changes before putting them in your production codebase. It's better paired with [version control](https://happygitwithr.com/).

* Using [`roxygen2`](https://roxygen2.r-lib.org/articles/rd.html) is generally handy, starting with your no longer needing to edit the [NAMESPACE](https://r-pkgs.org/namespace.html) by hand. If your package doesn't use `roxygen2` yet, you could use [`Rd2roxygen`](https://yihui.org/rd2roxygen/) to convert the documentation.

* One could argue that using [`pkgdown`](https://pkgdown.r-lib.org/) is a way to improve your R package documentation for very little effort. If you only tweak one thing, please [introduce grouping in the reference page](https://pkgdown.r-lib.org/articles/pkgdown.html#reference-1).

* Even when having to write some things by hand like inventing new tests, `usethis` provides useful functions to help e.g. create test files ([`usethis::use_test()`](https://usethis.r-lib.org/reference/index.html#section-package-development)).

## When and where to use the tools?

Now, knowing about useful tools for assessing and improving your package is good, but _when_ and _where_ do you use them?

### Continuous integration

How about learning to tame some online services to run commands on your R package at your own will and without too much effort?

#### Run something every time you make a change

Knowing your package still pass R CMD check, and what the latest value of test coverage is, is important enough for running commands _after every change you commit to your codebase_.
That is the idea behind continuous integration (CI), that [has been very well explained by Julia Silge with the particular example of Travis CI](https://juliasilge.com/blog/beginners-guide-to-travis/).

> "The idea behind continuous integration is that CI will automatically run R CMD check (along with your tests, etc.) every time you push a commit to GitHub. You don't have to remember to do this; CI automatically checks the code after every commit."
Julia Silge

Travis CI used to be very popular for the R crowd but this might be changing, as [exemplified by usethis latest release](https://www.tidyverse.org/blog/2020/04/usethis-1-6-0/#github-actions).
There are different CI providers with different strengths and weaknesses, and different levels of lock-in to GitHub. :wink:

Not only does CI allow to run `R CMD check` without remembering, it can also help you run `R CMD check` on operating systems that you don't have locally!

You might also find [the `tic` package](https://docs.ropensci.org/tic/) interesting: it defines "CI agnostic workflows".

{{< tweet 1205183124868681728 >}}

The life-hack above by Julia Silge, "LIFE HACK: My go-to strategy for getting Travis builds to work is snooping on *other* people's .travis.yml files.", applies to other CI providers too!

What you can run on continuous integration, beside `R CMD check` and `covr`, includes deploying your `pkgdown` website.

#### Run R CMD check regularly

Even in the absence of your changing anything to your codebase, things might break due to changes upstream (in the packages your package depends on, in the online services it wraps...).
Therefore it might make sense to _schedule_ a regular run of your CI checking workflow.
Many CI services provide that option, see e.g. the docs of [Travis CI](https://docs.travis-ci.com/user/cron-jobs/) and [GitHub Actions](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule).

As a side note, remember than [CRAN packages are checked regularly on several platforms](/2019/04/25/r-devel-linux-x86-64-debian-clang/).

#### Be lazy with continuous integration: PR commands

You can also make the most of services "on the cloud" for not having to run small things locally.
An interesting trick is e.g. the definition of "PR commands" via GitHub Action.
Say someone sends a PR to your repo fixing a typo in the roxygen2 part of an R script, but doesn't run `devtools::document()`, or someone quickly edits `README.Rmd` without knitting it.
You could fetch the PR locally and run respectively `devtools::document()` and `rmarkdown::render()` yourself, or you could make GitHub Action bot do that for you! :dancer:

Refer to the workflows in e.g. [ggplot2 repo](https://github.com/tidyverse/ggplot2/blob/master/.github/workflows/pr-commands.yaml), triggered by writing a comment such as "/document", and their [variant in pksearch repo](https://github.com/r-hub/pkgsearch/blob/master/.github/workflows/pr-label-commands.yml), where _labeling_ the PR.
Both approaches have their pros and cons.
I like labeling because you can't really make a typo, and it doesn't clutter the PR conversation, but you can hide comments later on whereas you cannot hide the labeling event from the PR history so really, to each their own.

{{< figure src="prcommanddocument.png" alt="Screenshot of a GitHub Action workflow" link="https://github.com/r-hub/pkgsearch/issues/98" >}}

This example is specific to GitHub and GitHub Action but you could think of similar ideas for other services.

### Run something _before_ you make a change

Let's build on [a meme](https://knowyourmeme.com/memes/tired-wired) to explain the idea in this subsection:

*  :zzz: Tired: Always remember to do things well
*  :electric_plug: Wired: Use continuous integration to notice wrong stuff
*  :sparkles: Inspired: Use precommit to not even commit wrong stuff

The git version control system allows you to define "pre-commit hooks" for not letting you e.g. commit `README.Rmd` without knitting it.
You might know this if you use `usethis::use_readme_rmd()` that adds such a hook to your project.

To take things further, the [`precommit` R package](https://lorenzwalthert.github.io/precommit/) provides two sets of utilities around the [precommit framework](https://pre-commit.com/): hooks that are useful for R packages or projects, and usethis-like functionalities to set them up.

Examples of [available hooks](https://lorenzwalthert.github.io/precommit/articles/available-hooks.html), some of them possibly editing files, others only assessing them: [checking your R code is still parsable](https://lorenzwalthert.github.io/precommit/articles/available-hooks.html#parsable-r), [spell check](https://lorenzwalthert.github.io/precommit/articles/available-hooks.html#spell-check-1), [checking dependencies are listed in `DESCRIPTION`](https://lorenzwalthert.github.io/precommit/articles/available-hooks.html#deps-in-desc)...
Quite useful, if you're up for adding such checks!

### Check things before show time

Remembering to run automatic assessment tools is key, and both continuous integration and pre-commit hooks can help with that.
Now a less regular but very important occurrence is the perfect occasion to run tons of checks: preparing a CRAN release!
You know, the very nice moment when you use [`rhub::check_for_cran()`](https://r-hub.github.io/rhub/reference/check_for_cran.html) among other things...
What other things by the way?

CRAN has a [submission checklist](https://cran.r-project.org/web/packages/submission_checklist.html), and you could either roll your own or rely on [`usethis::use_release_issue()`](https://usethis.r-lib.org/reference/use_release_issue.html) creating a GitHub issue with important items.
If you don't develop your package on GitHub you could still have a look at the [items](https://github.com/r-lib/usethis/blob/master/R/release.R#L56) for inspiration.
The [`devtools::release()` function](https://github.com/r-lib/devtools/blob/b166195be72927a003e6937de5c3239881095a9f/R/release.R#L39) will ask you whether you ran a spell check.

## Conclusion

In this blog post we went over tooling making your package maintainer life easier: `R CMD check`, `lintr`, `goodpractice`, `covr`, `spelling`, `styler`, `roxygen2`, `usethis`, `pkgdown`... and ways to integrate them into your workflow without having to remembering about them: continuous integration services, pre-commit hooks, using a checklist before a release.  
Tools for improving your R package will often be quite specific to R, whereas tools for integrating them into your practice are more general: continuous integration services are used for all sorts of software projects, pre-commit is initially a Python project.
Therefore, there will be tons of resources about that out there, some of them under the umbrella of [DevOps](https://en.wikipedia.org/wiki/DevOps).
While introducing some automagic into your workflow might save you time and energy, there is some balance to be found in order not to spend to much time on ["meta work"](https://youtu.be/dIjKJjzRX_E?t=633). :clock:

Furthermore, there are other aspects of package development we have not mentioned for which there might be interesting technical hacks: e.g. how do you follow the bug tracker of your package? How do you subscribe to the changelog of its upstream dependencies?

Do _you_ have any special trick?
Please share in the comments below!
