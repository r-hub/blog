---
slug: win-builder
title: "Everything you should know about WinBuilder"
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
It offers checking on Windows for several R versions.
It is maintained by [Uwe Ligges](https://www.statistik.tu-dortmund.de/ligges.html).

What if you already have a machine with Windows locally, or rely on R-hub package builder's results on Windows?
Well you might still want to use WinBuilder because _"it probably has the most recent CRAN checks activated"_ as [written by Duncan Murdoch on R-package-devel](https://www.mail-archive.com/r-package-devel@r-project.org/msg01653.html).

Checking your package on WinBuilder, though not compulsory, is part of standard advice you'll be given before a CRAN submission, and of [the checklist provided by `usethis::use_release_issue()`](https://usethis.r-lib.org/reference/use_release_issue.html).

## How to use WinBuilder?

Among different ways to submit your package to WinBuilder are

* Building it from the command line, uploading using ftp, with your favourite tools.

* Using the [online upload page](https://win-builder.r-project.org/upload.aspx) after building the package.

* Running one of [`devtools::check_win_release()` and friends](http://devtools.r-lib.org/reference/check_win.html) depending on the R version you're after.

## How to know when WinBuilder is down?

What if you got no result email after more than half an hour?
Maybe WinBuilder is down? 
What to do?

* You can check the queue for each of WinBuilder's R version, [as explained by Henrik Bengtsson on R-package-devel](https://www.mail-archive.com/r-package-devel@r-project.org/msg05040.html). E.g. say you submitted your package to the R-release queue: you can simply visit ftp://win-builder.r-project.org/R-release/ in your browser, or use some ftp code, to see if many other packages are stuck in the queue too.

* If you don't already read R-package-devel, have a look at its [archive](https://www.mail-archive.com/r-package-devel@r-project.org/) to find recent announcements about WinBuilder. E.g. earlier this year Uwe Ligges [posted about upcoming planned downtime](https://www.mail-archive.com/r-package-devel@r-project.org/msg04995.html).

* Maybe [post on R-package-devel](https://www.mail-archive.com/r-package-devel@r-project.org/msg05024.html)?

## What about dependencies on WinBuilder?

[WinBuilder's docs](https://win-builder.r-project.org/) state what system dependencies are available.
_"The tools and software provided by Professor Ripley (https://www.stats.ox.ac.uk/pub/Rtools/R215x.html) as well as third party software products mentioned at https://cran.r-project.org/bin/windows/contrib/ThirdPartySoftware.html are available."_

For _packages_, packages from CRAN, Bioconductor and some packages from OmegaHat are installed by default.

Now, say a package has just been updated on CRAN.
You might have to [wait up to two days for its being updated on WinBuilder](https://www.mail-archive.com/r-package-devel@r-project.org/msg03934.html).
You might [ask Uwe Ligges to update it](https://www.mail-archive.com/r-package-devel@r-project.org/msg01999.html).
You might [install it yourself by using serial uploads](https://win-builder.r-project.org/) _"Additionally it is possible to install packages serially yourself by uploading them serially: The first package to be uploaded should be the one that is needed by any other packages you upload. Packages you installed yourself are deleted on a regular basis."_

## How to deal with WinBuilder's results

If you got an error/warning/note on WinBuilder that you don't get locally, you might need to tweak your package and try again.
You could also use `rhub::check_on_windows()` if the same error/warning/note appears there too, for a quicker turnaround.

Then you might have to [ask for help](/2019/04/11/r-package-devel/).

Regarding spell checks, note that there [might be false positives](https://www.mail-archive.com/r-package-devel@r-project.org/msg01061.html).

## How to run WinBuilder checks continuously?

WinBuilder is meant to be used as part of your CRAN submission preparation, not as a continuous integration system.

[AppVeyor](https://github.com/krlmlr/r-appveyor#r--appveyor--) and [GitHub Actions](https://github.com/r-lib/actions/) have support for Windows.
You could run [R-hub checks regularly](https://jozef.io/r107-multiplatform-gitlabci-rhub/) too.
These different services won't exactly mimick what WinBuilder does, but will give you useful insight into your package's behaviour on Windows.

## Conclusion

In this post we offered a round-up of information around WinBuilder.
Once you're happy with the results you got from WinBuilder, and [R-hub](/2019/03/26/why-care/) pre-checks, you'll submit your package to CRAN and receive incoming checks results.
Once your package gets accepted on CRAN, you'll deal with other CRAN machines via [CRAN checks](/2019/04/25/r-devel-linux-x86-64-debian-clang/). :wink: