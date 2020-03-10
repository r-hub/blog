---
slug: win-builder
title: "Everything you should know about Win-builder"
authors:
  - Maëlle Salmon
date: "2020-03-20"
tags:
- package development
---

If you've tried submitting a package on CRAN, you might have heard of WinBuilder, as it is mentioned in [CRAN submission checklist](https://cran.r-project.org/web/packages/submission_checklist.html).
In this post inspired by reading [R-package-devel archive](/2019/04/11/r-package-devel/), we shall go through important questions around WinBuilder.

## What is WinBuilder and why use it?

As mentioned in its [public-facing web page](https://win-builder.r-project.org/), WinBuilder _" provides services for building and checking R source packages for Windows."_.

What if you already have a machine with Windows locally, or rely on R-hub package builder's results on Windows?
Well you might still want to use WinBuilder because _"it probably has the most recent CRAN checks activated"_ as [written by Duncan Murdoch on R-package-devel](https://www.mail-archive.com/r-package-devel@r-project.org/msg01653.html).

Checking your package on WinBuilder, though not compulsory, is part of standard advice you'll be given before a CRAN submission, and of [the checklist provided by `usethis::use_release_issue()`](https://usethis.r-lib.org/reference/use_release_issue.html).

## How to use WinBuilder?

Win-builder

## Conclusion

In this post we offered a round-up of information around Win-builder.
Once you're happy with the results you got from Win-builder, and [R-hub](/2019/03/26/why-care/) pre-checks, you'll submit your package to CRAN and receive incoming checks results.
Once your package gets accepted on CRAN, you'll deal with other CRAN machines via [CRAN checks](/2019/04/25/r-devel-linux-x86-64-debian-clang/). :wink: